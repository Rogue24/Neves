//
//  JPSwiftMacroWhenToUseViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit

class JPSwiftMacroWhenToUseViewController: JPSwiftMacroLessonBaseViewController {

    override func renderLesson() {
        title = "宏的取舍"

        addHero(
            title: "06 什么时候该用宏",
            subtitle: "宏不是高级玩具。它的目标不是“看起来很酷”，而是用编译期生成代码，减少真实复杂度。"
        )

        addAnalogy("像买洗碗机：每天一堆盘子、流程固定、人工容易烦，值得买。只有一个杯子，非要搬台洗碗机，就是把简单事情复杂化。")

        addRuleCard(
            title: "该用宏",
            rules: [
                "重复样板代码稳定、机械、容易写错。",
                "能把字符串、配置、路由、资源名等错误提前到编译期。",
                "生成的代码有清晰规则，调用者不用猜。",
                "比 property wrapper、protocol extension、泛型、函数更能减少真实复杂度。",
            ],
            tint: .systemGreen
        )

        addRuleCard(
            title: "不该用宏",
            rules: [
                "只是为了少写几行普通代码。",
                "业务规则频繁变化，宏生成逻辑会变成隐藏复杂度。",
                "团队大多数人读不懂展开结果。",
                "错误信息难懂，调试成本高于收益。",
                "普通函数、泛型、协议扩展、property wrapper 已经能清楚表达。",
            ],
            tint: .systemRed
        )

        addCode(
            """
            // 决策口诀：
            重复到烦、规则稳定、错误能提前，才考虑宏。
            看不见的复杂度，不要用宏藏起来。
            """,
            title: "口诀"
        )

        addPlainText(
            """
            一个实用判断：
            如果你删除宏以后，只是多写了两三行清楚的普通代码，那先别用宏。
            如果不用宏会复制几十处模板，而且每处都可能写错，那宏才开始值得认真考虑。
            """,
            title: "落地判断"
        )
    }
}
