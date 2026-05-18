# 05 OC Compare：Swift 宏和 OC 宏有什么区别

## 一句话先讲明白

Objective-C 的 `#define` 宏主要是预处理阶段的文本替换；Swift 宏是编译器理解语法后的代码生成。

一个像复印机，一个像懂语法的助教。

## OC 宏示例

项目里的 `JPMacro.h` 有这类写法：

```objc
#define JPScreenWidth [UIScreen mainScreen].bounds.size.width
#define JPKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))
```

它的核心思想是：在编译前，把某段文字替换成另一段文字。

## Swift 宏示例

```swift
let result = #jpStringify(view.bounds.width)
```

展开后大概是：

```swift
let result = (
    value: view.bounds.width,
    source: "view.bounds.width"
)
```

## 关键区别

| 对比点 | OC 宏 | Swift 宏 |
| --- | --- | --- |
| 工作对象 | 文本 | 语法树 |
| 是否理解类型 | 不理解 | 生成后继续类型检查 |
| 错误提示 | 经常绕 | 可以主动诊断 |
| IDE 友好度 | 较弱 | 更容易被工具链理解 |
| 适合大型工程 | 容易失控 | 边界更清楚 |

## 为什么苹果要这样设计

Swift 很重视三件事：

- 类型安全。
- 错误可诊断。
- 工具链可理解。

如果 Swift 直接照搬 C/OC 的文本宏，就会破坏这些目标。所以 Swift 宏选择基于语法树工作：既保留“生成代码”的效率，又尽量不牺牲 Swift 的安全性和可维护性。

## Swift 宏的优势

- 不靠字符串拼接理解代码。
- 能知道自己贴在 struct、enum、函数还是属性上。
- 能生成普通 Swift 代码。
- 能给出更具体的编译错误。

## 仍然要克制

Swift 宏比 OC 宏安全，但不是免死金牌。

如果宏让代码更难读、更难调试、更难定位问题，那就不该用。
