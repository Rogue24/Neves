//
//  JPSwiftMacroIntroViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit

class JPSwiftMacroIntroViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "宏是什么"

        addHero(
            title: "01 宏是什么",
            subtitle: "一句话：Swift 宏是在编译期间运行的小工具，它根据你的源码生成新的 Swift 源码，然后再交给编译器继续检查。"
        )

        addAnalogy("做饭前先备菜：运行时像正式开火，宏像开火前把葱姜蒜切好、配料称好。它不负责把菜炒熟，但能把机械准备工作提前做完。")

        addCode(
            """
            let result = #jpStringify(1 + 2)
            print(result.value)
            print(result.source)
            """
        )

        addCode(
            """
            // 宏展开后大概是这样：
            let result = (value: 1 + 2, source: "1 + 2")
            """,
            title: "展开后"
        )

        addRuleCard(
            title: "你先记住这三点",
            rules: [
                "宏运行在编译期，不是 App 跑起来后才临时变代码。",
                "宏生成的仍然是 Swift 代码，所以还会继续接受类型检查。",
                "宏适合处理稳定、机械、重复的代码，不适合藏复杂业务逻辑。",
            ],
            tint: .systemBlue
        )
    }
}
