//
//  JPSwiftMacroFreestandingViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit

class JPSwiftMacroFreestandingViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "Freestanding 宏"

        let resultValue = (3 + 4) * 2
        let resultSource = "(3 + 4) * 2"

        addHero(
            title: "02 Freestanding 宏",
            subtitle: "Freestanding 可以理解为“独立站着的宏”。它不用贴在类型、属性、方法上，而是像函数一样出现在表达式位置，常见形式是 #xxx。"
        )

        addAnalogy("像拍照留底：你把一道算式交给宏，它一边保留算式本身用于计算，一边把算式的原始写法也拍下来。")

        addCode(
            """
            let result = #jpStringify((3 + 4) * 2)
            result.value   // \(resultValue)
            result.source  // "\(resultSource)"
            """
        )

        addCode(
            """
            // 宏展开后大概是这样：
            let result = (
                value: (3 + 4) * 2,
                source: "(3 + 4) * 2"
            )
            """,
            title: "展开后"
        )

        addOutput(
            """
            value = \(resultValue)
            source = \(resultSource)
            """
        )

        addRuleCard(
            title: "适合场景",
            rules: [
                "调试、日志、断言里既要值，也要源码表达式。",
                "需要在编译期读取一段源码结构，然后生成一个普通表达式。",
            ],
            tint: .systemGreen
        )

        addRuleCard(
            title: "不适合场景",
            rules: [
                "普通函数已经能表达清楚的计算，不需要硬改成宏。",
                "运行时才知道的数据，宏拿不到，因为宏发生在编译期。",
            ],
            tint: .systemRed
        )
    }
}
