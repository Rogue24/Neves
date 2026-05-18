//
//  JPSwiftMacroOCCompareViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit

class JPSwiftMacroOCCompareViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "OC 宏对比"

        addHero(
            title: "05 Swift 宏 vs OC 宏",
            subtitle: "OC 的 #define 宏和 Swift 宏都能“少写重复代码”，但它们工作的层级完全不同。一个像文本替换，一个像编译器认可的代码生成。"
        )

        addAnalogy("OC 宏像复印机：把纸上的字原样替换进去，快，但不理解意思。Swift 宏像懂语法的助教：它看的是语法树，知道这是表达式、属性、枚举 case，能生成更规矩的代码。")

        addCode(
            """
            // JPMacro.h 里的 OC 宏示例：
            #define JPScreenWidth [UIScreen mainScreen].bounds.size.width
            #define JPKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))
            """
        )

        addCode(
            """
            // Swift 宏更像这样：
            let result = #jpStringify(view.bounds.width)

            // 展开后仍是 Swift 代码：
            let result = (
                value: view.bounds.width,
                source: "view.bounds.width"
            )
            """,
            title: "Swift 宏思路"
        )

        addRuleCard(
            title: "Swift 宏的优势",
            rules: [
                "基于语法树，不是粗暴文本替换。",
                "生成代码还会继续类型检查，更适合大型工程。",
                "可以给出更准确的编译错误，IDE 也更容易理解。",
                "能按 freestanding、attached 等形式限制能力边界。",
            ],
            tint: .systemGreen
        )

        addRuleCard(
            title: "OC 宏常见风险",
            rules: [
                "不理解类型，替换后才暴露问题。",
                "表达式副作用和优先级容易踩坑。",
                "大段宏会让调试和阅读变困难。",
            ],
            tint: .systemOrange
        )

        addPlainText(
            "苹果这样设计 Swift 宏，本质是想保留“自动生成代码”的效率，同时不牺牲 Swift 重视的类型安全、可诊断性和工具链体验。",
            title: "为什么 Swift 要这样设计"
        )
    }
}
