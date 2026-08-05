# LottieShowViewController 抓帧问题技术讨论

> 主题:`makeAnimationImage2` 抓取 Lottie 当前帧画面不完整的原因与优化
> 日期:2026-08-04

---

## 目录

1. [makeAnimationImage2 抓不到完整画面的原因](#1-makeanimationimage2-抓不到完整画面的原因)
2. [display() 与 forceDisplayUpdate() 的区别](#2-display-与-forcedisplayupdate-的区别)
3. [主线程 renderInContext: 会不会卡顿](#3-主线程-renderincontext-会不会卡顿)
4. [主线程定帧 + 子线程绘制能否分担消耗](#4-主线程定帧--子线程绘制能否分担消耗)
5. [定帧放子线程会崩溃](#5-定帧放子线程会崩溃)
6. [不上屏的专属 layer 能否降低主线程负担](#6-不上屏的专属-layer-能否降低主线程负担)
7. [jp_convertToImage 的优化](#7-jp_converttoimage-的优化)
8. [警告一:uncommitted CATransaction](#8-警告一uncommitted-catransaction)
9. [警告二:layout off the main thread](#9-警告二layout-off-the-main-thread)

---

## 1. makeAnimationImage2 抓不到完整画面的原因

**结论:能实现,但现在的写法抓不到,根因是渲染引擎选错了。**

对比两个方法的差别:

- `makeAnimationImage`(能正常工作)抓的是 **`MainThreadAnimationLayer`**(在 `makeAnimationLayer` 里手动 new 的)。
- `makeAnimationImage2`(抓不全)抓的是 `lottieLayer.animationLayer`,而 `lottieLayer` 是用 `LottieAnimationLayer(animation:)` 创建的。

问题在于:`LottieAnimationLayer(animation:)` 用的是默认配置 `LottieConfiguration.shared`,其 `renderingEngine = .automatic`(见 `LottieAnimationLayer.swift:39` 和 `LottieConfiguration.swift:13`)。`.automatic` 在绝大多数动画上会选用 **Core Animation 引擎**,也就是 `lottieLayer.animationLayer` 实际是一个 **`CoreAnimationLayer`**,而不是 `MainThreadAnimationLayer`。

两种引擎的渲染机制完全不同:

- **主线程引擎(`MainThreadAnimationLayer`)**:每一帧都把形状/内容真实地绘制进 CALayer 树。所以 `renderInContext:` 能沿图层树抓到当前帧的完整内容。
- **Core Animation 引擎(`CoreAnimationLayer`)**:它的 `display()` 里明确注释了 "doesn't directly render any content"(`CoreAnimationLayer.swift:165-171`)。它给每个子图层挂 `CAAnimation`,交给系统的渲染进程(render server)在 GPU 侧按时间线插值出当前帧。当前帧画面只存在于 **presentation layer + 系统渲染进程**里,**model layer(`renderInContext:` 抓的那个)上并没有当前帧的画面**。所以抓出来是残缺/错位/空白的。

第二层加重问题的因素(时序):`LottieAnimationLayer.currentFrame` 的 setter 是**异步**更新的——它在 `CATransaction` 的 completion block 里才调 `forceDisplayUpdate()`(`LottieAnimationLayer.swift:1093-1099`)。而在后台队列 `imageMakerQueue` 上做 `renderInContext:`,很可能内容还没更新到目标帧。

### 解决方案

**方案一(最推荐,改动最小):强制用主线程渲染引擎创建 `lottieLayer`。**

```swift
LottieAnimationLayer(animation: animation,
                     configuration: LottieConfiguration(renderingEngine: .mainThread))
```

这样 `lottieLayer.animationLayer` 就是 `MainThreadAnimationLayer`,`jp_convertToImage`(即 `renderInContext:`)就能抓到完整当前帧,和现在能用的 `makeAnimationImage` 完全同一套机制。

配套注意时序:设置帧后要**同步**刷新再抓图。当前 `sliderDidChanged` 里对 lottieLayer 调的是 `lottieLayer.display()`,对包装类不保证刷新内容,建议改用 `lottieLayer.forceDisplayUpdate()`。

**方案二(想保留 Core Animation 引擎时):不要抓 model layer,要抓 presentation。** 需渲染 `lottieLayer.animationLayer?.presentation()`,且必须在主线程、动画提交给 render server 之后执行。不稳定(presentation 可能为 nil),不推荐。

**方案三(绕开图层渲染):** 用 `LottieAnimationView` 设置 `currentFrame` 后对 view 做 `drawViewHierarchyInRect:afterScreenUpdates:`(`makeAnimationImage3` 的思路),要求 `afterScreenUpdates:true`、主线程、view 已上屏。

---

## 2. display() 与 forceDisplayUpdate() 的区别

**一句话区别:**

- `display()` 是 **CALayer 系统机制的入口**,会先看 presentation layer 决定用哪一帧,再做**增量渲染**(只更新"有变化"的节点)。
- `forceDisplayUpdate()` 是 **强制全量重绘**,直接用当前 `currentFrame`,并把 `forceUpdates=true` 灌到整棵节点树,**无视增量判断,所有节点都重算**。

两个方法最终都调到 `animationLayer.displayWithFrame(frame:forceUpdates:)`,差别在**传的帧**和**`forceUpdates` 标志**(`MainThreadAnimationLayer.swift:183` vs `212`):

**`display()`**(第 183-201 行):

```swift
open override func display() {
    guard Thread.isMainThread else { return }   // ① 非主线程直接 return
    var newFrame =
      if 有正在跑的 animationKeys {
        presentation()?.currentFrame ?? currentFrame   // ② 取 presentation 的帧
      } else {
        currentFrame
      }
    for layer in animationLayers {
        layer.displayWithFrame(frame: newFrame, forceUpdates: forceDisplayUpdateOnEachFrame) // ③ 默认 false
    }
}
```

**`forceDisplayUpdate()`**(第 212-216 行):

```swift
func forceDisplayUpdate() {
    for layer in animationLayers {
        layer.displayWithFrame(frame: currentFrame, forceUpdates: true)  // 恒为 true,恒用 currentFrame
    }
}
```

三个关键差异:

| | `display()` | `forceDisplayUpdate()` |
|---|---|---|
| **线程限制** | 非主线程直接 `return`(什么都不干) | 无限制,任意线程都会执行 |
| **用哪一帧** | 有动画时用 `presentation()` 的插值帧;否则用 `currentFrame` | 恒定用 model 的 `currentFrame` |
| **是否强制** | `forceUpdates` = `forceDisplayUpdateOnEachFrame`(默认 `false`) | `forceUpdates` = `true` |

`forceUpdates` 标志的作用,顺着 `displayWithFrame → updateTree → updateContents`(`AnimatorNode.swift:152`)看:

```swift
hasLocalUpdates = forceLocalUpdate ? forceLocalUpdate : propertyMap.needsLocalUpdate(frame: frame)
```

- `false` 时:靠 `needsLocalUpdate(frame:)` 判断有没有变化,**没变就跳过重建**(增量优化)。
- `true` 时:直接把 `hasLocalUpdates` 置真,**强制重算整棵树的输出**。

### 对抓帧场景的意义

1. **`display()` 会被 `guard Thread.isMainThread else { return }` 挡掉。** 在后台队列上调 `display()` 会**直接什么都不做**;而 `forceDisplayUpdate()` 在后台线程仍会执行。
2. **`display()` 依赖 presentation。** 若 layer 上挂着 `CAAnimation`,`display()` 取的是中间插值帧,不一定等于目标帧;`forceDisplayUpdate()` 恒定用设的 `currentFrame`。
3. **`display()` 有增量跳过。** 极端情况可能该更新却被判成"无变化"跳过;`forceDisplayUpdate()` 保证这一帧被完整重建。

对"设完某帧后立刻精确抓图"这种需求,`forceDisplayUpdate()` 比 `display()` 更可靠。

---

## 3. 主线程 renderInContext: 会不会卡顿

**会卡。** `renderInContext:` 是 **CPU 同步栅格化**——遍历整棵图层树,把每个 shape/mask/image 用 CoreGraphics 画进 CGContext。对复杂 Lottie 单帧可能是几毫秒到几十毫秒,放主线程会卡在主线程上,slider 拖动会掉帧。所以"子线程绘制"的方向本身是对的。

### 隐藏的致命问题

**关键点:`renderInContext:` 抓的是图层的"当前内容",而 Lottie 主线程引擎的"当前内容"是由 `currentFrame` + `display()`/`forceDisplayUpdate()` 在内存里算出来的,这个过程必须和抓图保持一致的时序。**

现在的流程:

```
主线程:  lottieLayer.currentFrame = X   // 异步,CATransaction completion 里才真正刷新
主线程:  lottieLayer.display()
子线程:  renderInContext:               // 读图层树内容
```

两个坑叠加:

1. **设帧是异步的。** `currentFrame` 的 setter 把 `forceDisplayUpdate()` 塞进 `CATransaction` 的 completion block(`LottieAnimationLayer.swift:1093-1099`),下一个 runloop 才刷新。子线程可能在内容还没更新到 X 帧时就抓了。
2. **跨线程读同一棵图层树。** 主线程可能正在重算这棵树,子线程同时在 `renderInContext:` 遍历它——**数据竞争**,可能崩,也可能抓到半新半旧的画面。

**Lottie 主线程引擎的图层内容,天然是"主线程持有"的,不能一边让主线程算、一边让子线程抓同一个对象。**

---

## 4. 主线程定帧 + 子线程绘制能否分担消耗

**可以分担一部分,但分担的量比想象的少,而且有前提坑。**

Lottie 主线程引擎渲染一帧,分两个阶段:

**阶段 1:定帧(`currentFrame = X` + `forceDisplayUpdate()`)——纯 CPU,发生在主线程**
- 遍历整棵动画节点树,按 X 帧插值出所有 shape 的贝塞尔路径、transform、opacity、mask、渐变。
- 这是**最重的 CPU 计算**。源码 `rebuildContents` 里大多数 shape 走 `shapeLayer.path = renderer.outputPath`(`ShapeRenderLayer.swift:80`)——把算好的 path 塞给 CAShapeLayer,栅格化交给系统合成期(GPU)。

**阶段 2:`renderInContext:` 抓图——CPU 栅格化**
- 对绝大多数 shape(走 CAShapeLayer 那条路),path 已在阶段 1 算好,这里只是把现成 path 光栅化;
- 只有少数 `shouldRenderInContext == true` 的特殊节点(某些渐变/特殊 fill,`ShapeRenderLayer.swift:71`、`85`)才在 `draw(in:)` 里真正现算。

**所以把阶段 2 挪到子线程,分担的是"栅格化",而最重的插值计算(阶段 1)仍在主线程。**

### 两个必须正视的风险

**风险 1:数据竞争(躲不掉,不是时序问题)**

回调里判断结果对不对,防不住读写并发:

```
主线程:  正在为下一次 slider 变化跑 forceDisplayUpdate()   // 写 shapeLayer.path
子线程:  正在 renderInContext: 遍历同一批 CAShapeLayer     // 读 path / bounds
```

CoreAnimation 的 layer **不是线程安全的**。轻则抓到半新半旧的画面,重则 EXC_BAD_ACCESS。回调里的 `currentFrame == currentFrame` 判断只能丢弃错帧结果,**拦不住崩溃,也拦不住读到撕裂的中间态**。

**风险 2:分担收益可能不划算**

主线程仍承担阶段 1(重计算),省下的只是栅格化,而 CAShapeLayer 路径下的栅格化本就不在 `renderInContext:` 的 CPU 里发生太多。只有在**大量 `shouldRenderInContext` 节点 / 复杂位图 / 大尺寸**的动画上,阶段 2 才够重,子线程分担才明显。

---

## 5. 定帧放子线程会崩溃

**确认:定帧放子线程会偶发崩溃,不能这么做。**

定帧的本质是**改 CALayer 树**:算出 path 后写进 `CAShapeLayer.path`、改 bounds/position、调 `setNeedsDisplay`,`LottieAnimationLayer` 那层还会包一层 `CATransaction`(`LottieAnimationLayer.swift:1093`)。

CoreAnimation 对"改图层"是**主线程亲和 + 进程级全局状态**:

- CALayer 属性写入、`CATransaction` 提交,都依赖主线程 runloop 的 commit 周期和进程内共享的事务/渲染状态。
- 就算 layer 是"专属离屏、只归一个串行队列",它**改的仍是那份全局 CoreAnimation 状态**,而主线程此刻正在跑自己的 commit 循环。两边同时动全局状态 → 偶发崩溃。

**关键更正:`forceDisplayUpdate()` 没有 `guard Thread.isMainThread` 只是"不会被 return 掉",不等于线程安全。**

关键区分:
- **改图层(定帧)= 写操作 = 必须主线程。** 躲不掉。
- **`renderInContext:`(抓图)= 读+栅格化 = 子线程可容忍。**

### 正确架构:最初的思路本来就是对的

能正常工作的 `makeAnimationImage` 的分工恰恰是:

```
主线程:  animationLayer.currentFrame = X; animationLayer.display()   // 定帧(写)
子线程:  animationLayer.jp_convertToImage()                          // renderInContext(读)
```

**这就是"主线程定帧 + 子线程绘制",而且它 work。** 之前抓不全的唯一病因是 `makeAnimationImage2` 用了默认 Core Animation 引擎,和线程无关。

正确做法:让 `lottieLayer` 也用 `MainThreadAnimationLayer`(或 `.mainThread` 配置),沿用 `makeAnimationImage` 那套分工。

### 降主线程负担的现实手段

主线程省不掉的是定帧里的 **path 插值计算**。想进一步降负担,只能从**定帧的频次和规模**下手:

- **节流 slider**:合并连续变化,只在停下时定帧。
- **缓存帧**:用 `[frame: UIImage]` 缓存,来回拖动命中缓存直接出图。
- **降规模**:抓图尺寸/scale 按需调小。

### 残留的数据竞争

"主线程定帧 + 子线程读同一 layer"仍有窗口:子线程还在读时用户又拖 slider,主线程再次改同一棵树 → 撕裂甚至崩。`makerItem?.cancel()` + 串行队列能缩小窗口,但挡不住已经在跑的那次。彻底干净可用**双缓冲**:两个 `MainThreadAnimationLayer` 交替。不追求极致时靠回调 `currentFrame` 校验丢弃错帧通常够用。

---

## 6. 不上屏的专属 layer 能否降低主线程负担

**会,但省下的不是主动做的那部分工作,而是"本来会白白发生的附带工作"。**

一个 layer 加进屏幕层级后,CoreAnimation 会在每一帧刷新里对它做一堆事,落在主线程的有:

1. **摆脱 commit 循环里的编码传输。** 上屏 layer 在 commit 时要把内容编码打包发给 render server,这段在主线程。离屏且不被 window 持有的 layer,commit 阶段跳过这步。
2. **摆脱屏幕刷新驱动的 `display()`(更值钱)。** 上屏且在播放的 Lottie,`currentFrame` 上挂 `CAAnimation`,系统随屏幕刷新(60/120Hz)不断触发 `display()` → 每次在主线程重算整棵 path 树。离屏 layer 不参与屏幕刷新,只有主动定帧时才 `display()` 一次。等于把"每秒 60 次重算"降成"拖一下算一次"。
3. **不触发离屏渲染/合成相关的隐式处理**(主要 GPU,对主线程影响小)。

### 不会帮你省的部分

- **定帧本身的 path 插值计算**——主动调时该算的照算,离屏不离屏一样。
- **`renderInContext:` 的栅格化**——主动抓图的开销,离屏也省不掉。

**离屏省的是"系统按刷新率自动替你做、而你不需要的那些次运算";主动发起的每次定帧+抓图,成本不变。**

真正的大头收益来自整体模式:**屏幕上只放静态 `UIImageView` + 按需出帧**,而不是实时 Lottie 每帧主线程 `display()`。离屏 layer 只是让这个模式成立的一块拼图。

---

## 7. jp_convertToImage 的优化

当前实现(`CALayer` 分类版,`UIView+JPExtension.m:341`):

```objc
- (UIImage *)jp_convertToImage {
    UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
//    format.opaque = NO;
//    format.scale = self.contentsScale;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [self renderInContext:context.CGContext];
    }];
    return image;
}
```

### 可优化点

**1. `format.scale` 没设,可能白白多画 9 倍像素(收益最大)**

默认 `scale = [UIScreen mainScreen].scale`(3x),300×300 的 layer 实际栅格化成 900×900。若只是 slider 预览缩略图 → 设 `format.scale = 1`,像素量降到 1/9;若要清晰 → 至少对齐 layer 的 `renderScale`(`contentsScale`),不必再叠一层屏幕 scale。

**2. `format.opaque` 应显式设置**

Lottie layer 有 `backgroundColor`,画面不透明 → 设 `format.opaque = YES`,位图不带 alpha 通道,栅格化和合成更快,内存更小。需要透明背景则设 `NO`。

**3. `bounds.size` 为空时的防御**

`initWithSize:` 传 `CGSizeZero` 会得到无效 renderer / 空图。加 `if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) return nil;`。

**4. `renderInContext:` 的语义(不是 bug,要知道)**

- 渲染 model layer 当前内容,不含 presentation(动画中间态)——正是要的"定格帧"。
- 不渲染 `CAMetalLayer`/`CAEAGLLayer` 等。Lottie 主线程引擎是纯 CAShapeLayer,不受影响。

**5. 不必回退到旧 API。** `UIGraphicsImageRenderer` 比老的 `UIGraphicsBeginImageContextWithOptions` 更优,保持现状。

### 优化后形态(参考)

```objc
- (UIImage *)jp_convertToImage {
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) return nil;   // 防御
    UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
    format.opaque = YES;                 // 不透明画面 → 去掉 alpha 通道
    format.scale  = self.contentsScale;  // 跟 layer 渲染 scale 对齐,别无脑用屏幕 3x
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [self renderInContext:context.CGContext];
    }];
}
```

**提醒:这是通用分类方法,别处可能也在调(需要透明/3x)。把 `opaque/scale` 写死会影响其他调用方。更稳妥是加带参重载:**

```objc
- (UIImage *)jp_convertToImageWithScale:(CGFloat)scale opaque:(BOOL)opaque;
```

### 优先级

1. `format.scale`(按需降到 1x 或对齐 `contentsScale`)—— 收益最大,像素量可降 1/9。
2. `format.opaque = YES`(画面不透明时)—— 去 alpha。
3. 空 size 防御 —— 健壮性。
4. 用重载而非改动通用方法 —— 避免影响其他调用方。

---

## 8. 警告一:uncommitted CATransaction

```
warning, deleted thread with uncommitted CATransaction; set CA_DEBUG_TRANSACTIONS=1 ...
```

**是子线程抓图引起的,主线程定帧没责任。**

含义:某线程创建了隐式 CATransaction,线程销毁时事务还没提交。

机制:

- 任何对 CALayer 的改动都会隐式开启一个 CATransaction。
- 在**主线程**,runloop 里的 CA observer 会在每次迭代末尾**自动 commit**——所以主线程改 layer 不用手动提交。
- 但 **GCD 工作线程没有跑"会提交 CA 事务"的 runloop**。在 `imageMakerQueue` 上碰了 layer → 隐式事务开启 → 没人 commit → 线程销毁时报 warning。

为什么是抓图而非定帧:`jp_convertToImage` 里的 `renderInContext:` 会触发标了 `setNeedsDisplay` 的图层走 `display()` → `rebuildContents` 里写 `shapeLayer.path`、`bounds`、`position`(`ShapeRenderLayer.swift:70-82`)——这些写操作在子线程发生,就开了没人提交的隐式事务。

### 解决

子线程做 CA 工作时,自己用显式 `CATransaction` 包起来并手动 commit:

```swift
let workItem = DispatchWorkItem {
    CATransaction.begin()
    CATransaction.setDisableActions(true)   // 顺带禁掉隐式动画
    let image = lottieLayer.animationLayer?.jp_convertToImage()
    CATransaction.commit()                   // 关键:在本线程内提交
    Asyncs.main { ... }
}
```

或把 begin/commit 包进 `jp_convertToImage` 内部,任何线程调用都自带提交。`setDisableActions:YES` 附带好处:抓图时禁掉隐式动画。

**提醒:warning 消掉 ≠ 真正安全。** 显式 `CATransaction` 只修好"事务没提交"这个表面问题,不保证跨线程访问同一批 layer 的线程安全。彻底干净还是要隔离抓图用的 layer(专属离屏 / 双缓冲)。

---

## 9. 警告二:layout off the main thread

```
Unsupported layout off the main thread for <UIView: 0x...> with nearest ancestor
view controller <Neves.LottieShowViewController: 0x...>
```

**和警告一是同一类问题的另一种表现——本该主线程做的工作跑到了子线程。**

字面意思:某个 `UIView` 的**布局过程**(`layoutSubviews` / `layoutSublayers` / `layoutIfNeeded`)在**非主线程**被触发了。UIKit 布局不是线程安全的。

### 为什么出现

根因还是子线程抓图。`renderInContext:` / `drawViewHierarchyInRect:` 在渲染前会确保图层/视图树是最新布局状态——如果树里有 `setNeedsLayout` 待处理,渲染就触发一次 layout pass。这次渲染在子线程,layout 就落在了子线程。

两条可能路径:

1. **`makeAnimationImage3`(第 409 行)**:`lottieView.jp_convertToImage(...)` 走 `drawViewHierarchyInRect:`,直接对 UIView 做层级绘制。这个 API 本就要求主线程 + 会触发 view 布局——子线程调它几乎必然报错。**最可疑的直接来源。**
2. **`makeAnimationImage2` / `makeAnimationImage`**:若 layer 或祖先(`lottieView`)带着未处理的 `setNeedsLayout`,子线程 render 触发 flush 时也可能连带 view layout 在子线程跑。

### 解决

核心原则:**布局必须主线程完成;子线程只做纯栅格化,不能再触发 layout。**

1. **抓图前,主线程先把布局做干净:**

```swift
// 主线程
lottieLayer.layoutIfNeeded()
lottieLayer.animationLayer?.layoutIfNeeded()
// 然后再派发到子线程抓图
imageMakerQueue.async { ... renderInContext ... }
```

2. **别在子线程用 `drawViewHierarchyInRect:`(即 `makeAnimationImage3` 那条)。** 它强制要求主线程,`afterScreenUpdates:true` 还会触发一次提交。抓 Lottie 应走 CALayer 的 `renderInContext:`。

3. **抓图用的 layer 尽量离屏、无 UIView 宿主。** 独立的、不挂在任何 UIView 上的 `MainThreadAnimationLayer` 没有 view delegate,不存在"触发某个 UIView 的 layoutSubviews",这条 warning 从根上消失。

### 两条 warning 的关系

一套的,都指向:**在子线程直接碰了"属于主线程的" UIKit/CA 对象树。**

- `uncommitted CATransaction` → 子线程改了 layer,事务没人提交。
- `layout off the main thread` → 子线程 render 触发了 view/layer 布局。

**加 `CATransaction begin/commit` 能压第一条,但压不掉第二条**——布局这条得靠"主线程先布局好 + 子线程只栅格化 + 抓图 layer 与 view 解耦"。

真正干净的架构是**抓图 layer 与主线程实时操作的 view/layer 隔离**,而不是让子线程去读主线程正在用的那棵树。

---

## 总体结论

1. `makeAnimationImage2` 抓不全的根因:`LottieAnimationLayer(animation:)` 默认走 Core Animation 引擎,当前帧不在 model layer 上。改用 `.mainThread` 引擎即可。
2. "主线程定帧 + 子线程抓图"方向正确(`makeAnimationImage` 已验证),别把定帧搬去子线程(会崩)。
3. `forceDisplayUpdate()` 比 `display()` 更适合"定帧后精确抓图"(强制全量、认准 currentFrame、不挑线程 return)。
4. 降主线程负担:静态图展示 + 按需出帧 + 节流 + 缓存 + 离屏 layer,而不是搬线程。
5. `jp_convertToImage` 优化:设 `scale`(收益最大)、`opaque`、空 size 防御,用带参重载避免影响其他调用方。
6. 两条 warning 都源于子线程操作 CA/UIKit 对象:显式 `CATransaction` + 主线程预布局 + 抓图 layer 隔离。
