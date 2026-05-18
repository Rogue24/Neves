import Foundation

/// 把表达式的运行结果和源码文字一起交给你。
///
/// `#jpStringify(1 + 2)` 会展开成类似：
///
///     (value: 1 + 2, source: "1 + 2")
@freestanding(expression)
public macro jpStringify<T>(_ value: T) -> (value: T, source: String) = #externalMacro(
    module: "JPSwiftMacroLessonsMacros",
    type: "JPStringifyMacro"
)

/// 在编译期检查 URL 字符串，再生成一个 `URL`。
///
/// 这个宏故意只接受静态字符串字面量，方便展示“把错误提前到编译期”。
@freestanding(expression)
public macro jpURL(_ stringLiteral: String) -> URL = #externalMacro(
    module: "JPSwiftMacroLessonsMacros",
    type: "JPURLMacro"
)

/// 给结构体生成一个 `debugSummary` 属性。
///
/// 适合展示 attached member macro 如何把机械重复的调试描述交给编译器生成。
@attached(member, names: named(debugSummary))
public macro JPDebugSummary() = #externalMacro(
    module: "JPSwiftMacroLessonsMacros",
    type: "JPDebugSummaryMacro"
)

/// 给无关联值枚举生成 `CustomStringConvertible` 的实现。
///
/// 适合展示 attached extension macro 如何生成协议胶水代码。
@attached(extension, conformances: CustomStringConvertible, names: named(description))
public macro JPEnumDescription() = #externalMacro(
    module: "JPSwiftMacroLessonsMacros",
    type: "JPEnumDescriptionMacro"
)
