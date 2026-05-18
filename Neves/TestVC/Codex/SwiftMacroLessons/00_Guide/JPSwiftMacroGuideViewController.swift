//
//  JPSwiftMacroGuideViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit

class JPSwiftMacroGuideViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "Swift 宏入门"

        addHero(
            title: "Swift 宏：从零开始",
            subtitle: "这套 demo 按“先会用，再懂原理，最后懂取舍”的顺序走。每一章都有控制器和同目录 README.md，页面负责演示，文档负责慢慢讲透。"
        )

        addAnalogy("可以先把 Swift 宏想成“编译期自动填表员”：你交给它一张规范表格，它在 App 真正运行前，帮你把重复、机械、容易写错的 Swift 代码填好。")

        addPlainText(
            """
            学习顺序建议：
            1. 先知道宏不是运行时魔法。
            2. 再看 #xxx 这种独立表达式宏。
            3. 然后看宏如何把错误提前到编译期。
            4. 最后看 @xxx 如何给类型自动补代码。
            5. 收尾必须学取舍：不是所有重复都值得用宏。
            """,
            title: "路线图"
        )

        addChapterButton(title: "01 宏是什么", detail: "先把“编译期展开”讲成人话") {
            JPSwiftMacroIntroViewController()
        }
        addChapterButton(title: "02 Freestanding 宏", detail: "从 #jpStringify 看 #xxx 怎么工作") {
            JPSwiftMacroFreestandingViewController()
        }
        addChapterButton(title: "03 诊断与校验", detail: "用 #jpURL 把字符串错误提前发现") {
            JPSwiftMacroDiagnosticsViewController()
        }
        addChapterButton(title: "04 Attached 宏", detail: "用 @JPDebugSummary 自动生成样板代码") {
            JPSwiftMacroAttachedViewController()
        }
        addChapterButton(title: "05 对比 OC 宏", detail: "文本替换 vs 语法树生成") {
            JPSwiftMacroOCCompareViewController()
        }
        addChapterButton(title: "06 什么时候该用", detail: "别为了用宏而用宏") {
            JPSwiftMacroWhenToUseViewController()
        }
    }
}
