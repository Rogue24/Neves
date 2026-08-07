# CALayer 渲染为 UIImage 技术讨论

> 主题:把任意 `CALayer` 绘制成 `UIImage`——支持自定义区域绘制、内容模式(AspectFit / AspectFill / Fill)自适应,以及高频复用渲染器的设计与取舍。
> 日期:2026-08-07

## 目录

1. [需求演进:从"自由区域"到"内容模式自适应"](#需求演进从自由区域到内容模式自适应)
2. [自定义区域绘制:拉伸铺满 + 超出裁剪](#自定义区域绘制拉伸铺满--超出裁剪)
3. [内容模式自适应:AspectFit / AspectFill / Fill](#内容模式自适应aspectfit--aspectfill--fill)
4. [核心绘制的 DRY 架构:fitRegion + draw](#核心绘制的-dry-架构fitregion--draw)
5. [高频场景:是否该共用一个 context](#高频场景是否该共用一个-context)
6. [每帧画完要不要 clear](#每帧画完要不要-clear)
7. [既然每次都是干净画布,还需要 saveGState / restoreGState 吗](#既然每次都是干净画布还需要-savegstate--restoregstate-吗)
8. [自定义 CGBitmapContext 是否比 UIGraphicsImageRenderer 更好](#自定义-cgbitmapcontext-是否比-uigraphicsimagerenderer-更好)
9. [内存安全:autoreleasepool 与 renderer 复用位置](#内存安全autoreleasepool-与-renderer-复用位置)
10. [最终文件组织](#最终文件组织)

---

## 需求演进:从"自由区域"到"内容模式自适应"

**结论:** 最终沉淀出两套入口——一套"给定任意矩形区域,把 layer 拉伸铺进去"(自由区域),一套"给定内容模式,自动算出区域"(自适应),二者共享同一套底层绘制逻辑。

需求是逐步澄清的,关键的一次更正值得记录:

- 最初把"自定义区域"实现成了"在区域内 AspectFit"。
- **更正:** 自定义区域方法**不保持比例**——就是完全按给定区域拉伸铺满,超出画布的部分裁剪掉。AspectFit 那套逻辑属于另一个"内容模式"入口,不要混在一起。

还有一个容易忽略的点确认下来了:自定义区域是**相对于画布坐标系**的(不是绝对像素),因此同样受 `scale`(像素倍率)影响。例如画布 300×300、区域 `[50, 50, 100, 200]`,layer 会被完整绘制进这个矩形内。

---

## 自定义区域绘制:拉伸铺满 + 超出裁剪

**结论:** 用 CTM 变换(平移到区域原点 + 按宽高分别缩放)把 layer 铺满任意 `region`,不保持比例;超出画布的部分由上下文自动裁剪,无需手动 `clip`。

```swift
/// 将`layer`拉伸铺满画布中的指定区域(不保持比例),超出画布的部分自动裁剪,生成`image`
func image(size: CGSize,
           region: CGRect,
           scale: CGFloat? = nil,
           background: UIColor? = nil) -> UIImage {
    let format = UIGraphicsImageRendererFormat()
    if let scale { format.scale = scale }
    format.opaque = (background != nil && background != .clear)

    return UIGraphicsImageRenderer(size: size, format: format).image { context in
        draw(in: context.cgContext, size: size, region: region, background: background)
    }
}
```

要点:

- `region` 的宽高分别参与 X/Y 缩放(`region.width / layerSize.width`、`region.height / layerSize.height`),因此**允许变形**,这正是"完全按区域绘制"的语义。
- 超出画布 `size` 的部分,`UIGraphicsImageRenderer` 的上下文会**自动裁剪**,不用自己写 `clip`。
- `opaque` 只在有非透明背景时才为 `true`,否则保持透明输出。

---

## 内容模式自适应:AspectFit / AspectFill / Fill

**结论:** 用一个 `FitMode` 枚举描述三种适配方式,把"算区域"的活交给 `fitRegion`,最终仍复用上面的区域绘制。三种模式的数学本质就是缩放比例取 `min` / `max` / 各自独立。

枚举名从最初的 `ContentMode` 改成了 `FitMode`——**更正原因:** `ContentMode` 太通用,且与 `UIView.ContentMode` 撞名,`FitMode` 更贴合"缩放适配"这个语义。

```swift
extension CALayer {
    /// `layer`缩放适配画布的模式
    enum FitMode {
        case aspectFit   // 等比缩放,完整显示,可能留白
        case aspectFill  // 等比缩放,填满画布,超出裁剪
        case fill        // 拉伸填满,不保持比例(可能变形)
    }
}
```

三种模式的比例算法对比:

| 模式 | 缩放比例 | 效果 | 是否变形 |
| --- | --- | --- | --- |
| `aspectFit` | `min(sx, sy)` | 完整显示,可能留白 | 否 |
| `aspectFill` | `max(sx, sy)` | 填满画布,超出裁剪 | 否 |
| `fill` | X/Y 各自独立 | 拉伸铺满整个画布 | 可能 |

其中 `sx = size.width / layerSize.width`、`sy = size.height / layerSize.height`;等比模式下用统一 `ratio` 算出 `fitted` 尺寸,再通过 `(size - fitted) / 2` 居中。`fill` 直接返回整个画布区域(等价于把整个画布当 region)。

---

## 核心绘制的 DRY 架构:fitRegion + draw

**结论:** 把"算目标区域"和"实际绘制"拆成两个纯函数——`fitRegion` 只负责根据模式算出 `CGRect`,`draw` 只负责把 layer 铺进给定 `CGRect`。两个入口(自定义区域 / 内容模式)与高频渲染器都复用它们,零重复。

```text
image(size:mode:)  ──► fitRegion(in:mode:) ──┐
                                             ├──► draw(in:size:region:background:) ──► render(in:)
image(size:region:) ─────────────────────────┘
```

`fitRegion`(纯计算,无副作用):

```swift
func fitRegion(in size: CGSize, mode: FitMode) -> CGRect {
    let layerSize = bounds.size
    switch mode {
    case .fill:
        return CGRect(origin: .zero, size: size)
    case .aspectFit, .aspectFill:
        guard layerSize.width > 0, layerSize.height > 0 else {
            return CGRect(origin: .zero, size: size)
        }
        let sx = size.width / layerSize.width
        let sy = size.height / layerSize.height
        let ratio = mode == .aspectFit ? min(sx, sy) : max(sx, sy)
        let fitted = CGSize(width: layerSize.width * ratio, height: layerSize.height * ratio)
        return CGRect(
            x: (size.width - fitted.width) / 2,
            y: (size.height - fitted.height) / 2,
            width: fitted.width,
            height: fitted.height
        )
    }
}
```

`draw`(核心绘制,自包含):

```swift
func draw(in ctx: CGContext, size: CGSize, region: CGRect, background: UIColor? = nil) {
    // 背景铺满整个画布,不受`region`变换影响,故放在`save/restore`之外
    if let background {
        background.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
    }

    let layerSize = bounds.size
    guard layerSize.width > 0, layerSize.height > 0,
          region.width > 0, region.height > 0
    else { return }

    ctx.saveGState()
    defer { ctx.restoreGState() }

    // 平移到区域原点,再按宽高分别拉伸铺满整个`region`(不保持比例)
    ctx.translateBy(x: region.minX, y: region.minY)
    ctx.scaleBy(x: region.width  / layerSize.width,
                y: region.height / layerSize.height)

    // ⚠️`region`超出画布(size)的部分会被上下文自动裁剪掉,无需手动`clip`
    render(in: ctx)
}
```

设计要点:

1. **背景填充放在 `save/restore` 之外**——它要铺满整个画布,不能被 region 的 CTM 变换影响。
2. **`draw` 自包含、不污染传入的 context**——内部用 `saveGState` / `defer restoreGState` 严格配对,因此可以安全地把同一个 context 连续喂给多个 layer(为高频复用铺路)。
3. **两处 guard**——layer 尺寸和 region 尺寸都必须为正,否则 `scaleBy` 会得到 0 或 NaN。

---

## 高频场景:是否该共用一个 context

**结论:** 是,值得。对【固定画布尺寸 + 同线程 + 高频】的场景(如逐帧视频),复用同一个 `UIGraphicsImageRenderer` 实例能省下每帧重建上下文配置(色彩空间、bitmapInfo、内存池)的开销。为此单独封装一个 `LayerImageRenderer`。

```swift
final class LayerImageRenderer {
    let size: CGSize
    private let background: UIColor?
    private let renderer: UIGraphicsImageRenderer

    init(size: CGSize, scale: CGFloat? = nil, background: UIColor? = nil) {
        let format = UIGraphicsImageRendererFormat()
        if let scale { format.scale = scale }
        format.opaque = (background != nil && background != .clear)
        self.size = size
        self.background = background
        self.renderer = UIGraphicsImageRenderer(size: size, format: format)
    }

    /// 按指定模式渲染一个`layer`为`image`(复用同一`renderer`)
    func image(of layer: CALayer, mode: CALayer.FitMode = .aspectFit) -> UIImage {
        image(of: layer, region: layer.fitRegion(in: size, mode: mode))
    }

    /// 按自定义区域渲染一个`layer`为`image`(复用同一`renderer`)
    func image(of layer: CALayer, region: CGRect) -> UIImage {
        renderer.image { context in
            layer.draw(in: context.cgContext, size: size, region: region, background: background)
        }
    }
}
```

三个关键约束:

1. **复用的是 context 配置,不是像素内存**——每次 `image(of:)` 仍返回各自独立的 `UIImage`,像素不共享(这是必须的,否则多帧会互相覆盖)。
2. **非线程安全**——创建后必须始终在同一线程调用。
3. **复用 `CALayer.draw`**——渲染器不重复造轮子,直接调扩展里的 `draw` / `fitRegion`。

---

## 每帧画完要不要 clear

**结论:** 不用。`UIGraphicsImageRenderer` 每次 `.image { }` 调用都会给一块**全新的干净画布**,不是在旧画布上叠加。手动 `clear` 是多余的。

这和旧式 `UIGraphicsBeginImageContext` + `UIGraphicsGetImageFromCurrentImageContext` 的手动管理模型不同——旧模型里同一个 context 反复画确实需要 `ctx.clear(...)`;而 `UIGraphicsImageRenderer` 复用的只是**配置**,画布本身每次都是新的。

---

## 既然每次都是干净画布,还需要 saveGState / restoreGState 吗

**结论:** 从"画布干净"这个角度看,单次绘制确实不需要;但 `draw` 里仍然保留 `save/restore`,原因是**让 `draw` 成为一个自包含、不污染外部 context 的通用函数**——代价可忽略,收益是安全。

两层理由:

1. **对当前 `UIGraphicsImageRenderer` 路径**:每次闭包是干净上下文,单纯就这一次绘制而言,`save/restore` 可省。
2. **对通用性**:`draw` 接收的是外部传入的 `CGContext`。一旦将来有人把一个**已带变换或需要连续复用**的 context 传进来,`save/restore` 就能保证 `draw` 不留下 CTM 残留、不影响后续绘制。`saveGState/restoreGState` 成本极低,用它换"函数自包含"这个属性很划算。

所以这是一个**有意保留**的设计,不是冗余。

---

## 自定义 CGBitmapContext 是否比 UIGraphicsImageRenderer 更好

**结论:** 单就 `layer → UIImage` 而言,`UIGraphicsImageRenderer` 更好——性能相近,但更安全、更简洁。手搓 `CGBitmapContext` 换来的那点微小性能差距不划算。(真正的大头优化是彻底跳过中间那张 UIImage,但那是另一条管线级别的改造,不属于本次范围。)

两者对比:

| 维度 | `UIGraphicsImageRenderer` | 自定义 `CGContext(data:...)` |
| --- | --- | --- |
| 易用性 | 高,闭包封装、自动管理 | 低,要手动管 bitmap 内存、bytesPerRow、色彩空间、字节序 |
| 复用性 | 实例可复用,但每次 `.image{}` 返回新 UIImage | 完全自己掌控,可反复画进同一块 buffer |
| 输出 | 直接给 UIImage | 给 CGImage / 裸像素,要 UIImage 还得自己包 |
| 坐标系 | 已自动翻转成 UIKit 习惯(左上原点) | 默认 Core Graphics 原点在左下,要自己翻转 |
| 正确性风险 | 低,系统保证 | 高,参数配错就是花屏 / 崩溃 |
| 纯性能 | 已经很好(底层也是 IOSurface / 位图) | 理论略优,但日常差距可忽略 |

**延伸判断:** 若某天真要压榨性能,方向不是"换 context 类型",而是"绕开 UIImage"——比如直接把内容渲染进 `CVPixelBuffer`,省掉 `layer → UIImage → CVPixelBuffer` 的中间拷贝。那才是量级上的优化,当前实现不涉及。

---

## 内存安全:autoreleasepool 与 renderer 复用位置

**结论:** 高频循环里,`renderer` 必须建在循环外(否则复用失效),每帧生成的 `image` 及像素处理必须包在 `autoreleasepool` 内(否则内存峰值堆积)。这两点在 `VideoMaker+Layer.swift` 的逐帧管线里都已到位。

- **`renderer` 建在循环外**(`VideoMaker+Layer.swift:84`):`let renderer = LayerImageRenderer(size: size, scale: 1)` 位于 `for` 之外——若写进循环内,每帧重建实例,复用配置的意义就没了。
- **每帧 `image` 生成包在 `autoreleasepool` 内**(`VideoMaker+Layer.swift:131` 起):逐帧产生的 `UIImage` / `CVPixelBuffer` 是 autorelease 对象,不主动排空的话会在整个循环结束前一直累积,拉高内存峰值;放进 `autoreleasepool { }` 后每帧及时释放。

```swift
let renderer = LayerImageRenderer(size: size, scale: 1)   // 循环外,复用
for i in 0 ... frameCount {
    // ...
    autoreleasepool {                                     // 每帧及时排空
        var image: UIImage?
        if let layer = layers.first, let layer = layer {
            image = renderer.image(of: layer, mode: .aspectFit)
        }
        // ... 生成 pixelBuffer 并 append ...
    }
}
```

---

## 最终文件组织

**结论:** 按职责拆成三个文件,单向依赖、无循环引用,同 target 内 `internal` 可见性即可。

| 文件 | 职责 | 依赖 |
| --- | --- | --- |
| `Neves/Neves/Extension/CALayer+.swift` | `FitMode` 枚举 + `image` / `fitRegion` / `draw` 扩展方法(最底层) | 无 |
| `Neves/Neves/Tool/LayerImageRenderer.swift` | 高频复用渲染器 | 依赖 `CALayer.FitMode` / `draw` / `fitRegion` |
| `Neves/Neves/Tool/VideoMaker/VideoMaker+Layer.swift` | 逐帧视频合成 `makeVideo`(调用方) | 依赖 `LayerImageRenderer` |

依赖方向:`CALayer+.swift` ← `LayerImageRenderer.swift` ← `VideoMaker+Layer.swift`,单向、清晰。

---

## 总体结论

1. **两套入口 + 一套底层**:自定义区域(`image(size:region:)`,拉伸铺满 + 超出裁剪)与内容模式自适应(`image(size:mode:)`,AspectFit / AspectFill / Fill)共享 `fitRegion` + `draw`,DRY 到位。
2. **自定义区域不保持比例**,内容模式才保持——两者语义严格区分;区域是画布坐标系内的相对值,受 `scale` 影响。
3. **枚举名用 `FitMode`** 而非 `ContentMode`,避免与 `UIView.ContentMode` 撞名且语义更准。
4. **高频场景复用 `UIGraphicsImageRenderer` 实例**(封装为 `LayerImageRenderer`):复用配置、输出独立 UIImage、非线程安全、同线程使用。
5. **不需要手动 clear**——每次 `.image{}` 都是干净画布;**保留 `save/restore`** 是为让 `draw` 自包含、可安全复用于外部 context,而非冗余。
6. **`layer → UIImage` 首选 `UIGraphicsImageRenderer`**,不值得手搓 `CGBitmapContext`;真要极致优化应绕开 UIImage 直出 `CVPixelBuffer`。
7. **内存两要点**:`renderer` 建在循环外(保住复用),每帧绘制包 `autoreleasepool`(压住峰值)——逐帧视频管线已落实。
