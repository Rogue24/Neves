//
//  JPSwiftMacroLessonBaseViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/18.
//

import UIKit
import SnapKit

class JPSwiftMacroLessonBaseViewController: TestBaseViewController {

    private let scrollView = UIScrollView()
    let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLessonUI()
        renderLesson()
    }

    func renderLesson() {}
}

// MARK: - UI

extension JPSwiftMacroLessonBaseViewController {

    func setupLessonUI() {
        view.backgroundColor = .systemGroupedBackground

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 14
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }

        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(UIEdgeInsets(top: 16, left: 16, bottom: 28, right: 16))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-32)
        }
    }

    func addHero(title: String, subtitle: String) {
        let titleLabel = makeLabel(title, font: .systemFont(ofSize: 26, weight: .bold), color: .label)
        let subtitleLabel = makeLabel(subtitle, font: .systemFont(ofSize: 15), color: .secondaryLabel)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
    }

    @discardableResult
    func addLessonCard(title: String, body: String? = nil) -> UIStackView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.layer.masksToBounds = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        stack.addArrangedSubview(makeLabel(title, font: .systemFont(ofSize: 18, weight: .bold), color: .label))
        if let body {
            stack.addArrangedSubview(makeLabel(body, font: .systemFont(ofSize: 15), color: .secondaryLabel))
        }

        contentStack.addArrangedSubview(card)
        return stack
    }

    func addAnalogy(_ text: String) {
        let stack = addLessonCard(title: "生活类比")
        stack.addArrangedSubview(makeTintedText(text, color: .systemTeal))
    }

    func addCode(_ code: String, title: String = "最小代码") {
        let stack = addLessonCard(title: title)
        stack.addArrangedSubview(makeCodeLabel(code))
    }

    func addOutput(_ output: String, title: String = "运行结果") {
        let stack = addLessonCard(title: title)
        stack.addArrangedSubview(makeTintedText(output, color: .systemIndigo))
    }

    func addRuleCard(title: String, rules: [String], tint: UIColor) {
        let stack = addLessonCard(title: title)
        rules.forEach { rule in
            stack.addArrangedSubview(makeTintedText("• \(rule)", color: tint))
        }
    }

    func addChapterButton(title: String, detail: String, builder: @escaping () -> UIViewController) {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = title
        config.subtitle = detail
        config.titleAlignment = .leading
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
        button.configuration = config
        button.contentHorizontalAlignment = .fill
        button.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(builder(), animated: true)
        }, for: .touchUpInside)
        contentStack.addArrangedSubview(button)
    }

    func addPlainText(_ text: String, title: String) {
        let stack = addLessonCard(title: title)
        stack.addArrangedSubview(makeLabel(text, font: .systemFont(ofSize: 15), color: .secondaryLabel))
    }

    func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    func makeTintedText(_ text: String, color: UIColor) -> UILabel {
        let label = makeLabel(text, font: .systemFont(ofSize: 15, weight: .medium), color: .label)
        label.backgroundColor = color.withAlphaComponent(0.12)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        label.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        return LessonInsetLabel(wrapping: label)
    }

    func makeCodeLabel(_ code: String) -> UILabel {
        let label = LessonInsetLabel()
        label.text = code
        label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.backgroundColor = .tertiarySystemGroupedBackground
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return label
    }
}

private final class LessonInsetLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    convenience init(wrapping label: UILabel) {
        self.init(frame: .zero)
        text = label.text
        font = label.font
        textColor = label.textColor
        backgroundColor = label.backgroundColor
        numberOfLines = label.numberOfLines
        adjustsFontForContentSizeCategory = label.adjustsFontForContentSizeCategory
        layer.cornerRadius = label.layer.cornerRadius
        layer.masksToBounds = label.layer.masksToBounds
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right, height: size.height + textInsets.top + textInsets.bottom)
    }
}
