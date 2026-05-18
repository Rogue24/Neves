//
//  JPSwiftMacroAttachedViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit

struct MacroAttachedLessonUser {
    let name: String
    let level: Int
    let isLearningMacro: Bool

    var debugSummary: String {
        "\(Self.self)(name: \(name), level: \(level), isLearningMacro: \(isLearningMacro))"
    }
}

enum MacroAttachedLessonState: CustomStringConvertible {
    case beginner
    case practicing
    case reviewing

    var description: String {
        switch self {
        case .beginner: return "beginner"
        case .practicing: return "practicing"
        case .reviewing: return "reviewing"
        }
    }
}

class JPSwiftMacroAttachedViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "Attached 宏"

        let user = MacroAttachedLessonUser(name: "小白同学", level: 1, isLearningMacro: true)
        let state = MacroAttachedLessonState.practicing

        addHero(
            title: "04 Attached 宏",
            subtitle: "Attached 宏是“贴在声明上的宏”，常见形式是 @xxx。它可以贴在 struct、enum、属性、函数上，帮这个声明补代码。"
        )

        addAnalogy("像给表格盖一个“自动补全”章：你写清楚字段，宏就按固定模板补出调试描述、协议实现这类机械内容。")

        addCode(
            """
            @JPDebugSummary
            struct User {
                let name: String
                let level: Int
            }

            let user = User(name: "小白同学", level: 1)
            print(user.debugSummary)
            """
        )

        addCode(
            """
            // 宏展开后大概会补出：
            var debugSummary: String {
                "\\(Self.self)(name: \\(name), level: \\(level))"
            }
            """,
            title: "展开后"
        )

        addOutput(
            """
            \(user.debugSummary)
            enum description = \(state.description)
            """
        )

        addRuleCard(
            title: "适合场景",
            rules: [
                "给很多类型生成相同规则的样板代码。",
                "生成 Codable、日志、路由、依赖注入等协议胶水。",
                "规则稳定，展开结果读起来像普通 Swift。",
            ],
            tint: .systemGreen
        )

        addRuleCard(
            title: "不适合场景",
            rules: [
                "核心业务逻辑不要藏在宏里，否则读代码的人找不到真正发生了什么。",
                "生成规则复杂到团队看不懂时，维护成本会反超收益。",
            ],
            tint: .systemRed
        )
    }
}
