# 03 Diagnostics：把错误提前到编译期

## 一句话先讲明白

宏可以在编译期间检查输入，如果发现不符合规则，就直接让编译器报错。

这比 App 跑起来以后才崩，体验好得多。

## 生活类比

`#jpURL` 像“进站安检”：

- 有效车票：放行。
- 票面格式明显不对：进站前就拦住。
- 不等你坐上车才发现上错站。

## 最小代码

```swift
let url = #jpURL("https://developer.apple.com/swift/")
```

## 展开后大概长这样

```swift
let url = Foundation.URL(string: "https://developer.apple.com/swift/")!
```

## 错误示例

```swift
let badURL = #jpURL("developer.apple.com")
```

这会在编译期报错，因为它不是完整的 `http` 或 `https` URL。

## 为什么这有价值

字符串最容易出错：

- 路由名打错。
- 资源名打错。
- URL 少了 scheme。
- 配置 key 少了一个字符。

如果这些字符串本来就是写死在源码里的，让宏提前检查，比运行到某个页面才发现要可靠。

## 适合用

- 静态 URL。
- 静态路由。
- 静态资源名。
- 静态配置 key。

## 不适合用

- 用户输入。
- 接口返回。
- 服务端下发配置。
- 运行时拼出来的字符串。

宏看的是源码，不是运行时世界。
