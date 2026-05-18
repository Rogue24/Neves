//
//  JPSwiftMacroDiagnosticsViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import Foundation
import UIKit

class JPSwiftMacroDiagnosticsViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "宏诊断"

        let url = URL(string: "https://developer.apple.com/swift/")!

        addHero(
            title: "03 诊断与校验",
            subtitle: "宏不只是“少写代码”。更重要的是，它能在编译期检查某些规则，把低级错误挡在 App 运行前。"
        )

        addAnalogy("像进站安检：普通字符串可能一路混进运行时，点到某个功能才发现 URL 写坏了；宏可以在编译时就拦住不合格的票。")

        addCode(
            """
            let url = #jpURL("https://developer.apple.com/swift/")
            print(url.absoluteString)
            """
        )

        addCode(
            """
            // 如果写成这样，宏会在编译时报错：
            let badURL = #jpURL("developer.apple.com")

            // 错误原因：
            // 缺少 http/https scheme，不是完整 URL。
            """,
            title: "错误示例"
        )

        addOutput("当前有效 URL：\(url.absoluteString)")

        addRuleCard(
            title: "适合场景",
            rules: [
                "路由名、资源名、URL、配置 key 等本来就是静态字符串。",
                "错误越早发现越好，而且规则稳定清楚。",
            ],
            tint: .systemGreen
        )

        addRuleCard(
            title: "不适合场景",
            rules: [
                "用户输入、接口返回、服务端下发这类运行时数据。",
                "校验规则经常变，改宏比改普通代码更麻烦。",
            ],
            tint: .systemRed
        )
    }
}
