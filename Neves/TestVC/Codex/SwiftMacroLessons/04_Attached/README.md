# 04 Attached：贴在声明上的 `@xxx`

## 一句话先讲明白

Attached macro 是“贴在某个声明上”的宏，常见形式是 `@xxx`。

它可以根据这个声明生成成员、扩展、协议实现等代码。

## 生活类比

它像“表格自动补全章”：

- 你写字段。
- 宏看懂字段。
- 它按固定模板补出调试描述或协议胶水。

## 最小代码

```swift
@JPDebugSummary
struct User {
    let name: String
    let level: Int
}

let user = User(name: "小白同学", level: 1)
print(user.debugSummary)
```

## 展开后大概长这样

```swift
struct User {
    let name: String
    let level: Int

    var debugSummary: String {
        "\(Self.self)(name: \(name), level: \(level))"
    }
}
```

## enum 的例子

```swift
@JPEnumDescription
enum State {
    case beginner
    case practicing
}
```

宏会生成类似：

```swift
extension State: CustomStringConvertible {
    var description: String {
        switch self {
        case .beginner: return "beginner"
        case .practicing: return "practicing"
        }
    }
}
```

## 适合用

- 很多类型都有同样的样板代码。
- 协议实现机械重复。
- 生成规则稳定，不需要读者猜。

## 不适合用

- 核心业务逻辑。
- 变化频繁的规则。
- 展开后代码很难读的场景。

宏应该减少复杂度，不应该把复杂度藏起来。
