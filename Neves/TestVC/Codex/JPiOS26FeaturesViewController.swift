//
//  JPiOS26FeaturesViewController.swift
//  Neves
//
//  Created by Codex on 2026/5/10.
//
//  参考：https://juejin.cn/post/7560958498676588590

import UIKit
import FunnyButton
import SnapKit

#if canImport(Observation)
import Observation
#endif

#if canImport(FoundationModels)
import FoundationModels
#endif

#if canImport(Symbols)
import Symbols
#endif

class JPiOS26FeaturesViewController: TestBaseViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private weak var controllerPropertiesLabel: UILabel?
    private weak var textViewStatusLabel: UILabel?

    private var foundationModelsTask: Task<Void, Never>?
    private var controllerPropertiesValue = 0 {
        didSet {
            if #available(iOS 26.0, *) {
                setNeedsUpdateProperties()
            }
        }
    }
    private var controllerPropertiesUpdateCount = 0

    private var navBadgeCount = 1
    private var navBadgeItem: UIBarButtonItem?
    
    private weak var heightConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyActions([
            FunnyAction(name: "1.Properties更新") { [weak self] in
                self?.demoPropertiesUpdatePass()
            },
            FunnyAction(name: "2.@Observable自动更新") { [weak self] in
                self?.demoObservableUIKitProperties()
            },
            FunnyAction(name: "3.Flush动画更新") { [weak self] in
                self?.demoFlushUpdatesAnimation()
            },
            FunnyAction(name: "4.Liquid Glass") { [weak self] in
                self?.demoLiquidGlassEffect()
            },
            FunnyAction(name: "5.Glass Button") { [weak self] in
                self?.demoGlassButtonConfiguration()
            },
            FunnyAction(name: "6.圆角配置") { [weak self] in
                self?.demoCornerConfiguration()
            },
            FunnyAction(name: "7.Scroll Edge") { [weak self] in
                self?.demoScrollEdgeEffects()
            },
            FunnyAction(name: "8.Slider配置") { [weak self] in
                self?.demoSliderTrackConfiguration()
            },
            FunnyAction(name: "9.导航栏徽章") { [weak self] in
                self?.demoNavigationSubtitleAndBadge()
            },
            FunnyAction(name: "10.Symbol渲染") { [weak self] in
                self?.demoSymbolRenderingAndTransition()
            },
            FunnyAction(name: "11.TextView多选区") { [weak self] in
                self?.demoTextViewMultiRangeEditing()
            },
            FunnyAction(name: "12.Foundation Models") { [weak self] in
                self?.demoFoundationModels()
            },
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        foundationModelsTask?.cancel()
        resetNavigationDemo()
    }
    
    // 打断点用的
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    @available(iOS 26.0, *)
    override func updateProperties() {
        super.updateProperties()

        guard let controllerPropertiesLabel else { return }
        controllerPropertiesUpdateCount += 1
        controllerPropertiesLabel.text = """
        VC updateProperties 第 \(controllerPropertiesUpdateCount) 次
        当前状态值：\(controllerPropertiesValue)
        这里适合刷新标题、颜色、显隐、配置对象等“非几何属性”。
        """
        controllerPropertiesLabel.textColor = controllerPropertiesValue.isMultiple(of: 2) ? .systemTeal : .systemIndigo
    }

    @objc private func handleBadgeTap() {
        guard #available(iOS 26.0, *) else { return }
        navBadgeCount += 1
        navBadgeItem?.badge = navBadgeCount.isMultiple(of: 5) ? .indicator() : .count(navBadgeCount)
    }
}

// MARK: - Base UI

private extension JPiOS26FeaturesViewController {

    func setupBaseUI() {
        title = "iOS 26 新特性"
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

        showWelcome()
    }

    func showWelcome() {
        let stack = prepareDemo(
            title: "iOS 26 新特性调试台",
            description: "点击悬浮 FunnyButton 里的动作，逐个查看 iOS 26 UIKit 与 Foundation Models 的新增能力。每个入口都用独立方法和 extension 组织，便于继续追加 demo。"
        )
        addInfo("当前页面只做演示和调试，不依赖 storyboard；低于 iOS 26 的系统会显示兼容提示。", to: stack)
    }

    @discardableResult
    func prepareDemo(title: String, description: String) -> UIStackView {
        foundationModelsTask?.cancel()
        foundationModelsTask = nil
        resetNavigationDemo()
        textViewStatusLabel = nil
        controllerPropertiesLabel = nil

        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let titleLabel = makeLabel(title, font: .systemFont(ofSize: 24, weight: .bold), color: .label)
        let descriptionLabel = makeLabel(description, font: .systemFont(ofSize: 15, weight: .regular), color: .secondaryLabel)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(descriptionLabel)

        let stack = makeVerticalStack(spacing: 12)
        let card = makeCardView()
        card.addSubview(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        contentStack.addArrangedSubview(card)
        return stack
    }

    func showUnavailable(_ featureName: String, link: String) {
        let stack = prepareDemo(
            title: featureName,
            description: "这个 demo 使用 iOS 26 新 API。当前系统低于 iOS 26 时不会执行，只保留说明。"
        )
        addInfo("参考链接：\(link)", to: stack)
    }

    func resetNavigationDemo() {
        title = "iOS 26 新特性"
        navigationItem.rightBarButtonItems = nil
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false

        if #available(iOS 26.0, *) {
            navigationItem.subtitle = nil
            navigationItem.largeTitle = nil
            navigationItem.largeSubtitle = nil
            navBadgeItem = nil
        }
    }

    func makeVerticalStack(spacing: CGFloat = 10) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        return stack
    }

    func makeHorizontalStack(spacing: CGFloat = 10) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }

    func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }

    func makeDemoCanvas(height: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = .tertiarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return view
    }

    func makeLabel(_ text: String, font: UIFont, color: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    @discardableResult
    func addInfo(_ text: String, to stack: UIStackView) -> UILabel {
        let label = makeLabel(text, font: .systemFont(ofSize: 14), color: .secondaryLabel)
        stack.addArrangedSubview(label)
        return label
    }

    func makeDemoButton(_ title: String, action: @escaping (UIAction) -> Void) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.titleLineBreakMode = .byWordWrapping
        config.baseForegroundColor = .systemBlue
        config.background.backgroundColor = .systemBlue.withAlphaComponent(0.12)
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)

        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.titleLabel?.numberOfLines = 2
        button.addAction(UIAction(handler: action), for: .touchUpInside)
        return button
    }
}

// MARK: - 1. Properties Update Pass
// 参考：https://juejin.cn/post/7520093724988145715
/**
 * `UIViewController`与`UIView`均增加了一个名为`updateProperties()`的新方法，可以通过修改属性值达到更新 UI 的效果。
 * 它是一种轻量级的 UI 更新方式，不会触发完整的布局过程（不会触发`layoutSubviews()`或者`viewWillLayoutSubviews()`方法）。
 * 常见使用场景如下：
 *  - 更改 UI 的内容。
 *  - 显示/隐藏 UI。
 *  - 无需移动或者调整 UI 的大小。
 * 可以自动追踪`@Observable Object`。
 * 可以通过调用`setNeedsUpdateProperties()`方法手动触发更新。
 */

private final class PropertiesUpdateDemoView: UIView {

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    var value = 0 {
        didSet {
            if #available(iOS 26.0, *) {
                setNeedsUpdateProperties()
            }
        }
    }
    private var updateCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)

        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        stack.addArrangedSubview(detailLabel)
    }

    @available(iOS 26.0, *)
    override func updateProperties() {
        super.updateProperties()
        updateCount += 1
        titleLabel.text = "UIView updateProperties 第 \(updateCount) 次"
        detailLabel.text = "value = \(value)，颜色和文案都在 updateProperties 里统一刷新。"
        backgroundColor = value.isMultiple(of: 2) ? .systemMint.withAlphaComponent(0.22) : .systemOrange.withAlphaComponent(0.22)
    }
    
    // 打断点用的
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

private extension JPiOS26FeaturesViewController {

    func demoPropertiesUpdatePass() {
        // [iOS 26] setNeedsUpdateProperties 用来请求“属性更新”：
        // UIKit 会在 layoutSubviews 之前合并多次请求，适合刷新文案、颜色、显隐、configuration 等非几何属性。
        // 参考链接：https://developer.apple.com/documentation/uikit/uiview/setneedsupdateproperties()
        // 参考链接：https://developer.apple.com/documentation/uikit/updating-views-automatically-with-observation-tracking
        guard #available(iOS 26.0, *) else {
            showUnavailable("Properties 更新周期", link: "https://developer.apple.com/documentation/uikit/uiview/setneedsupdateproperties()")
            return
        }

        controllerPropertiesValue = 0
        controllerPropertiesUpdateCount = 0

        let stack = prepareDemo(
            title: "setNeedsUpdateProperties / updateProperties",
            description: "这个 demo 同时演示 UIViewController 和 UIView 的 updateProperties。连续改状态时，UIKit 会把多次 setNeedsUpdateProperties 合并到下一轮更新；点立即刷新会调用 updatePropertiesIfNeeded。"
        )

        let controllerLabel = makeLabel("", font: .systemFont(ofSize: 15, weight: .medium), color: .label)
        controllerLabel.backgroundColor = .systemBackground
        controllerLabel.layer.cornerRadius = 10
        controllerLabel.layer.masksToBounds = true
        controllerLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(92)
        }
        controllerPropertiesLabel = controllerLabel
        stack.addArrangedSubview(controllerLabel)

        let demoView = PropertiesUpdateDemoView()
        demoView.snp.makeConstraints { make in
            make.height.equalTo(112)
        }
        stack.addArrangedSubview(demoView)

        let buttons = makeHorizontalStack()
        buttons.addArrangedSubview(makeDemoButton("连续改 3 次") { [weak self, weak demoView] _ in
            guard let self, let demoView else { return }
            for _ in 0..<3 {
                self.controllerPropertiesValue += 1
                demoView.value += 1
            }
        })
        buttons.addArrangedSubview(makeDemoButton("立即刷新") { [weak self, weak demoView] _ in
            guard let self, let demoView else { return }
            self.controllerPropertiesValue += 1
            demoView.value += 1
            self.updatePropertiesIfNeeded()
            demoView.updatePropertiesIfNeeded()
        })
        stack.addArrangedSubview(buttons)

        addInfo("要点：不要手动调用 updateProperties()；状态变更后调用 setNeedsUpdateProperties()，让 UIKit 在正确的更新阶段统一刷新。", to: stack)
        setNeedsUpdateProperties()
        demoView.setNeedsUpdateProperties()
    }
}

// MARK: - 2. UIKit Observation Tracking
// 参考1：https://juejin.cn/post/7518758885274517541
// 参考2：https://chatgpt.com/share/6a2672db-d858-83ec-b6d5-91bc20b7876d
/**
 * UIKit 支持`@Observable类型`。
 * 修饰的类型必须是类而不能是结构体。
 * 当其中的数据（属性值）发生更改时，相应的 UI 能够自动更新，而无需手动调用`setNeedsLayout()`、`setNeedsDisplay()`、`layoutIfNeeded()`等方法。
 * 需要将 UI 更新的代码放在`UIView`的`layoutSubviews()`或者`UIViewController` 的`viewWillLayoutSubviews()`方法中。当`@Observable`中的数据发生变化时，`layoutSubviews()`与`viewWillLayoutSubviews()`方法会【自动调用】。
 * 该功能可以支持到 iOS 18，但需要在 Info.plist 文件中增加字段`UIObservationTrackingEnabled`，并且将其值设置为YES。
 *
 * 例如`model`是`@Observable类型`，在控制器的`viewWillLayoutSubviews`方法中有这么一句`nameLabel.text = model.name`，
 * 那么 UIKit 会自动记录：`model.name`，也就是：这个控制器的 UI 依赖了这个值。以后其他地方改：`model.name = "Swift"`，UIKit 会自动重新触发相关更新流程，不需要你手动调用`setNeedsLayout()`。
 *
 * iOS 26 推荐用`updateProperties()`（兼容 iOS 18 才会用`layoutSubviews()`与`viewWillLayoutSubviews()`方法 ）。
 * - 苹果说`updateProperties`会在`layoutSubviews`【前】运行，并且它也会自动追踪`Observable`，可以手动用`setNeedsUpdateProperties()`触发。
 * - 这个方法更适合更新内容、样式、配置，而不是布局，这比把所有东西都塞进`layoutSubviews()`更干净。因为`layoutSubviews`本质是【布局】方法，不应该在里面塞一堆文本、颜色、图片更新等这些跟布局无关的操作。
 *
 * `@Observable`不是【监听整个对象】，而是【监听你读到的属性】。
 * - 例如我在`updateProperties`里面读的是`model.count`，不是`model.count2`，那么我在其他处修改了`model.count2`，是不会触发`updateProperties`的 ---【谁被读，谁被追踪】。
 */

#if canImport(Observation)
@available(iOS 26.0, *)
@Observable
private final class ObservableUIKitDemoModel {
    var count = 0
    var count2 = 0
    var colorIndex = 0
    var isHighlighted = false
    var accentColor: UIColor = .systemBlue
}

@available(iOS 26.0, *)
private final class ObservableUIKitDemoView: UIView {

    private let model: ObservableUIKitDemoModel
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private var updateCount = 0

    init(model: ObservableUIKitDemoModel) {
        self.model = model
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layer.borderWidth = 1

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        titleLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        titleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)

        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        stack.addArrangedSubview(detailLabel)
    }

    @available(iOS 26.0, *)
    override func updateProperties() {
        super.updateProperties()

        updateCount += 1

        // 这里读取 @Observable model 的属性，UIKit 会记录依赖关系；
        // 后续这些属性变化时，会自动让本 view 再次进入 updateProperties。
        let accentColor = model.accentColor
        let highlighted = model.isHighlighted
        titleLabel.text = "@Observable count = \(model.count)"
        detailLabel.text = """
        updateProperties 第 \(updateCount) 次
        highlighted = \(highlighted)
        这次刷新不是按钮里手动 setNeedsUpdateProperties 触发的。
        """
        titleLabel.textColor = accentColor
        layer.borderColor = accentColor.cgColor
        backgroundColor = highlighted ? accentColor.withAlphaComponent(0.16) : .systemBackground
    }
    
    // 打断点用的
    override func layoutSubviews() {
        super.layoutSubviews()
        // 这里啥事没干，没有记录`@Observable类型`模型，UIKit不会触发这里。
    }
}
#endif

private extension JPiOS26FeaturesViewController {

    func demoObservableUIKitProperties() {
        // [iOS 26] UIKit 的 updateProperties() 支持 Swift Observation 追踪。
        // 在 updateProperties() 中读取 @Observable 对象的属性后，后续属性变化会自动让 UIKit 重新调度 properties update。
        // 参考链接：https://developer.apple.com/documentation/uikit/updating-views-automatically-with-observation-tracking
        // 参考链接：https://developer.apple.com/documentation/observation/observable()
        guard #available(iOS 26.0, *) else {
            showUnavailable("@Observable 自动刷新 UIKit", link: "https://developer.apple.com/documentation/uikit/updating-views-automatically-with-observation-tracking")
            return
        }

        let stack = prepareDemo(
            title: "@Observable + updateProperties",
            description: "这个 demo 只修改 @Observable model，不在按钮回调里手动调用 setNeedsUpdateProperties。UIKit 会根据 updateProperties 内读取过的属性自动重新刷新。"
        )

        #if canImport(Observation)
        let model = ObservableUIKitDemoModel()
        let colors: [UIColor] = [.systemBlue, .systemPink, .systemGreen, .systemOrange, .systemPurple]
        let demoView = ObservableUIKitDemoView(model: model)
        demoView.heightAnchor.constraint(equalToConstant: 142).isActive = true
        stack.addArrangedSubview(demoView)

        let statusLabel = addInfo("已建立初始 observation tracking。点击按钮后只改 model，观察卡片自动更新。", to: stack)
        let buttons = makeHorizontalStack()
        buttons.addArrangedSubview(makeDemoButton("count + 1") { [weak statusLabel] _ in
            model.count += 1
            statusLabel?.text = "刚刚执行：model.count += 1，没有手动 setNeedsUpdateProperties。"
//            model.count2 += 1
//            statusLabel?.text = "刚刚执行：model.count2 += 1，count2 = \(model.count2)，但没有触发 updateProperties。"
        })
        buttons.addArrangedSubview(makeDemoButton("切换状态/颜色") { [weak statusLabel] _ in
            model.isHighlighted.toggle()
            model.colorIndex += 1
            model.accentColor = colors[model.colorIndex % colors.count]
            statusLabel?.text = "刚刚执行：toggle + accentColor 更新，UIKit 自动调度 updateProperties。"
        })
        stack.addArrangedSubview(buttons)

        addInfo("要点：把 UI 派生逻辑放进 updateProperties()；当里面读取到的 @Observable 属性变化时，UIKit 会自动失效并合并更新。", to: stack)
        demoView.setNeedsUpdateProperties()
        demoView.updatePropertiesIfNeeded()
        #else
        addInfo("当前 SDK 无法 import Observation，已跳过 @Observable 演示。", to: stack)
        #endif
    }
}

// MARK: - 3. Flush Updates Animation
// 参考1：https://juejin.cn/post/7528721862462291978
// 参考2：https://chatgpt.com/share/6a2672f9-a468-83ec-a65c-46ad96582bd4

private final class FlushUpdatesDemoView: UIView {

    private let label = UILabel()

    var step = 0 {
        didSet {
            if #available(iOS 26.0, *) {
                setNeedsUpdateProperties()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 14
        layer.masksToBounds = true

        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
        label.pinEdges(to: self, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
    }

    @available(iOS 26.0, *)
    override func updateProperties() {
        super.updateProperties()
        label.text = "pending property step = \(step)\n动画开始前会 flush 更新"
        backgroundColor = step.isMultiple(of: 2) ? .systemBlue.withAlphaComponent(0.16) : .systemPink.withAlphaComponent(0.16)
    }
    
    // 打断点用的
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

private extension JPiOS26FeaturesViewController {

    func demoFlushUpdatesAnimation() {
        // [iOS 26] flushUpdates 用于动画上下文切换时先冲刷 pending traits / properties / layout，
        // 避免动画启动时还拿着旧属性或旧布局。
        // 参考链接：https://developer.apple.com/documentation/uikit/uiview/animationoptions
        guard #available(iOS 26.0, *) else {
            showUnavailable("Flush Updates 动画", link: "https://developer.apple.com/documentation/uikit/uiview/animationoptions")
            return
        }
        
        let testView = UIView()
        let subView = UIView()

        let stack = prepareDemo(
            title: "UIView.AnimationOptions.flushUpdates",
            description: "先修改 demo view 的属性，再进入动画。使用 flushUpdates 时，UIKit 会在动画上下文变化前同步处理 pending properties/layout。"
        )

        let box = FlushUpdatesDemoView()
        box.snp.makeConstraints { make in
            make.height.equalTo(128)
        }
        stack.addArrangedSubview(box)
        
        let buttons = makeHorizontalStack()
        buttons.addArrangedSubview(makeDemoButton("UIView.animate") { [weak box] _ in
            guard let box else { return }
            box.step += 1
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .flushUpdates]) {
                box.transform = box.transform == .identity ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
            }
            
            /**
             * 在约束动画里，可以把`flushUpdates`理解成 UIKit 帮我们完成了以前手动`layoutIfNeeded()`用来确定起点和终点的工作；
             * 但它不是机械调用两次`layoutIfNeeded()`，而是在动画上下文变化时统一刷新`pending updates`。
             * - `pending updates`：“欠着没算的布局”，也就是约束改了但UI布局还没更新的时候（系统通常会等到下一轮RunLoop再统一布局）
             */
//            self.heightConstraint?.update(offset: 100)
//            testView.layoutIfNeeded() // 1.先把当前布局刷到最新，确定动画起点
//            self.heightConstraint?.update(offset: 150) // 2.修改约束，制造目标状态
//            UIView.animate(withDuration: 3, delay: 0) {
//                testView.layoutIfNeeded()
//            } // 3.在动画block里刷新布局，系统会把frame变化做成动画
            // 👆🏻等同于👇🏻
            self.heightConstraint?.update(offset: 100)
            UIView.animate(withDuration: 3, delay: 0, options: .flushUpdates) {
                self.heightConstraint?.update(offset: 150)
            } // `flushUpdates`通常可以替代「动画前确定起点+动画中刷新终点」的那套手动`layoutIfNeeded()`流程。
        })
        buttons.addArrangedSubview(makeDemoButton("PropertyAnimator") { [weak box] _ in
            guard let box else { return }
            box.step += 1
            let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut) {
                box.alpha = box.alpha == 1 ? 0.62 : 1
                box.transform = box.transform.rotated(by: .pi / 32)
            }
            animator.flushUpdates = true
            animator.startAnimation()
        })
        stack.addArrangedSubview(buttons)
        addInfo("要点：flushUpdates 不是替代 layoutIfNeeded，而是告诉 UIKit 在动画边界处理 pending 更新，减少旧状态参与动画。", to: stack)
        box.setNeedsUpdateProperties()
        
        testView.backgroundColor = .randomColor
        stack.addArrangedSubview(testView)
        testView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
        
        subView.backgroundColor = .randomColor
        testView.addSubview(subView)
        subView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            heightConstraint = make.height.equalTo(10).constraint
        }
    }
}

// MARK: - 4. Liquid Glass

private extension JPiOS26FeaturesViewController {

    func demoLiquidGlassEffect() {
        // [iOS 26] UIGlassEffect / UIGlassContainerEffect 是 UIKit 的 Liquid Glass 材料入口。
        // 多个玻璃元素放进同一个 container 时，系统可以把它们合成为更自然的玻璃效果。
        // 参考链接：https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
        guard #available(iOS 26.0, *) else {
            showUnavailable("Liquid Glass Effect", link: "https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass")
            return
        }

        let stack = prepareDemo(
            title: "UIGlassEffect / UIGlassContainerEffect",
            description: "下面的彩色背景上叠加了一个 UIGlassContainerEffect，里面再放多个 UIGlassEffect 子元素。"
        )

        let canvas = makeDemoCanvas(height: 260)
        stack.addArrangedSubview(canvas)

        let colorStack = makeHorizontalStack(spacing: 0)
        canvas.addSubview(colorStack)
        colorStack.pinEdges(to: canvas)
        [UIColor.systemPink, .systemOrange, .systemTeal, .systemIndigo].forEach {
            let block = UIView()
            block.backgroundColor = $0
            colorStack.addArrangedSubview(block)
        }

        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = 22
        let glassContainer = UIVisualEffectView(effect: containerEffect)
        canvas.addSubview(glassContainer)

        let glassStack = makeHorizontalStack(spacing: 18)
        glassContainer.contentView.addSubview(glassStack)
        glassStack.pinEdges(to: glassContainer.contentView, insets: UIEdgeInsets(top: 34, left: 22, bottom: 34, right: 22))

        glassStack.addArrangedSubview(makeGlassTile(style: .regular, tint: .white.withAlphaComponent(0.18), title: "regular"))
        glassStack.addArrangedSubview(makeGlassTile(style: .clear, tint: .systemYellow.withAlphaComponent(0.16), title: "clear"))
        glassStack.addArrangedSubview(makeGlassTile(style: .regular, tint: .systemBlue.withAlphaComponent(0.20), title: "interactive"))

        glassContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 32, left: 18, bottom: 32, right: 18))
        }

        addInfo("要点：交互元素可设置 effect.interactive = true；多个玻璃元素相邻时用 UIGlassContainerEffect 承载。", to: stack)
    }

    @available(iOS 26.0, *)
    func makeGlassTile(style: UIGlassEffect.Style, tint: UIColor, title: String) -> UIView {
        let effect = UIGlassEffect(style: style)
        effect.tintColor = tint
        effect.isInteractive = title == "interactive"

        let view = UIVisualEffectView(effect: effect)
        view.layer.cornerRadius = 22
        view.clipsToBounds = true

        let label = makeLabel(title, font: .systemFont(ofSize: 16, weight: .bold), color: .white, alignment: .center)
        view.contentView.addSubview(label)
        label.pinEdges(to: view.contentView)
        return view
    }
}

// MARK: - 5. Glass Button Configuration

private extension JPiOS26FeaturesViewController {

    func demoGlassButtonConfiguration() {
        // [iOS 26] UIButton.Configuration 新增 Liquid Glass 系列按钮样式。
        // 参考链接：https://developer.apple.com/documentation/UIKit/UIButton/Configuration-swift.struct
        guard #available(iOS 26.0, *) else {
            showUnavailable("Glass Button Configuration", link: "https://developer.apple.com/documentation/UIKit/UIButton/Configuration-swift.struct")
            return
        }

        let stack = prepareDemo(
            title: "UIButton.Configuration Glass",
            description: "iOS 26 为 UIButton.Configuration 增加 glass / prominentGlass / clearGlass / prominentClearGlass。"
        )

        let buttons = [
            ("glass", UIButton.Configuration.glass()),
            ("prominentGlass", UIButton.Configuration.prominentGlass()),
            ("clearGlass", UIButton.Configuration.clearGlass()),
            ("prominentClearGlass", UIButton.Configuration.prominentClearGlass()),
        ]

        buttons.forEach { name, baseConfig in
            var config = baseConfig
            config.title = name
            config.subtitle = "Liquid Glass Button"
            config.image = UIImage(systemName: "sparkles")
            config.imagePlacement = .leading
            config.imagePadding = 8
            config.cornerStyle = .capsule

            let button = UIButton(configuration: config)
            button.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
            stack.addArrangedSubview(button)
        }

        addInfo("要点：这些样式交给系统适配 Liquid Glass，不需要自己堆 blur / vibrancy / 阴影。", to: stack)
    }
}

// MARK: - 6. Corner Configuration

private extension JPiOS26FeaturesViewController {

    func demoCornerConfiguration() {
        // [iOS 26] UIView.cornerConfiguration 可以表达固定圆角、胶囊圆角、容器同心圆角等语义。
        // effectiveRadius(corner:) 可读取系统按当前几何解析后的真实半径。
        // 参考链接：https://developer.apple.com/documentation/uikit/uicornerconfiguration-swift.struct
        guard #available(iOS 26.0, *) else {
            showUnavailable("Corner Configuration", link: "https://developer.apple.com/documentation/uikit/uicornerconfiguration-swift.struct")
            return
        }

        let stack = prepareDemo(
            title: "UIView.cornerConfiguration",
            description: "新圆角配置把“想要什么圆角”表达成配置对象，系统按视图尺寸和容器关系解析最终半径。"
        )

        let fixed = makeCornerSample(title: "固定 24pt", color: .systemBlue)
        fixed.cornerConfiguration = .uniformCorners(radius: .fixed(24))

        let capsule = makeCornerSample(title: "胶囊", color: .systemGreen)
        capsule.cornerConfiguration = .capsule()

        let concentric = makeCornerSample(title: "容器同心圆角", color: .systemPurple)
        concentric.cornerConfiguration = .uniformCorners(radius: .containerConcentric(minimum: 12))

        [fixed, capsule, concentric].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(64)
            }
            stack.addArrangedSubview($0)
        }

        let resultLabel = addInfo("等待布局后读取 effectiveRadius...", to: stack)
        DispatchQueue.main.async {
            let fixedRadius = fixed.effectiveRadius(corner: .allCorners)
            let capsuleRadius = capsule.effectiveRadius(corner: .allCorners)
            let concentricRadius = concentric.effectiveRadius(corner: .allCorners)
            resultLabel.text = "effectiveRadius：固定 \(Int(fixedRadius)) / 胶囊 \(Int(capsuleRadius)) / 同心 \(Int(concentricRadius))"
        }
    }

    @available(iOS 26.0, *)
    func makeCornerSample(title: String, color: UIColor) -> UILabel {
        let label = makeLabel(title, font: .systemFont(ofSize: 17, weight: .bold), color: .white, alignment: .center)
        label.backgroundColor = color
        label.clipsToBounds = true
        return label
    }
}

// MARK: - 7. Scroll Edge Effects

private extension JPiOS26FeaturesViewController {

    func demoScrollEdgeEffects() {
        // [iOS 26] UIScrollView 新增边缘效果对象，可分别控制 top / bottom / left / right。
        // UIScrollEdgeElementContainerInteraction 让悬浮在边缘的控件参与边缘效果形状计算。
        // 参考链接：https://developer.apple.com/documentation/UIKit/UIScrollEdgeEffect
        // 参考链接：https://developer.apple.com/documentation/uikit/uiscrolledgeelementcontainerinteraction
        guard #available(iOS 26.0, *) else {
            showUnavailable("Scroll Edge Effects", link: "https://developer.apple.com/documentation/UIKit/UIScrollEdgeEffect")
            return
        }

        let stack = prepareDemo(
            title: "UIScrollEdgeEffect",
            description: "滚动区域顶部使用 hard edge，底部使用 soft edge；底部玻璃按钮容器通过 interaction 告诉 scroll view 自己覆盖在边缘。"
        )

        let canvas = makeDemoCanvas(height: 360)
        stack.addArrangedSubview(canvas)

        let innerScrollView = UIScrollView()
        innerScrollView.topEdgeEffect.style = .hard
        innerScrollView.bottomEdgeEffect.style = .soft
        canvas.addSubview(innerScrollView)
        innerScrollView.pinEdges(to: canvas)

        let content = makeVerticalStack(spacing: 8)
        innerScrollView.addSubview(content)
        content.pinEdges(to: innerScrollView.contentLayoutGuide, insets: UIEdgeInsets(top: 18, left: 18, bottom: 90, right: 18))
        content.snp.makeConstraints { make in
            make.width.equalTo(innerScrollView.frameLayoutGuide).offset(-36)
        }

        for index in 1...18 {
            let row = makeLabel("Scroll Edge Row \(index)", font: .systemFont(ofSize: 16, weight: .medium), color: .label)
            row.backgroundColor = index.isMultiple(of: 2) ? .systemBackground : .secondarySystemBackground
            row.layer.cornerRadius = 10
            row.layer.masksToBounds = true
            row.snp.makeConstraints { make in
                make.height.equalTo(42)
            }
            content.addArrangedSubview(row)
        }

        let bottomBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        bottomBar.layer.cornerRadius = 18
        bottomBar.clipsToBounds = true
        canvas.addSubview(bottomBar)

        let interaction = UIScrollEdgeElementContainerInteraction()
        interaction.scrollView = innerScrollView
        interaction.edge = .bottom
        bottomBar.addInteraction(interaction)

        var isHard = false
        let toggleButton = makeDemoButton("切换底部 edge") { [weak innerScrollView] action in
            guard let innerScrollView, let button = action.sender as? UIButton else { return }
            isHard.toggle()
            innerScrollView.bottomEdgeEffect.style = isHard ? .hard : .soft
            button.setDemoButtonTitle(isHard ? "底部 hard" : "底部 soft")
        }
        bottomBar.contentView.addSubview(toggleButton)
        toggleButton.pinEdges(to: bottomBar.contentView, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))

        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(58)
        }
    }
}

// MARK: - 8. Slider Track Configuration

private extension JPiOS26FeaturesViewController {

    func demoSliderTrackConfiguration() {
        // [iOS 26] UISlider.TrackConfiguration 支持刻度、仅允许刻度值、可用范围、neutralValue；
        // UISlider.Style.thumbless 可以做无拇指滑杆，适合播放进度等场景。
        // 参考链接：https://developer.apple.com/documentation/uikit/uislider
        guard #available(iOS 26.0, *) else {
            showUnavailable("Slider Track Configuration", link: "https://developer.apple.com/documentation/uikit/uislider")
            return
        }

        let stack = prepareDemo(
            title: "UISlider.TrackConfiguration",
            description: "这个 slider 只允许落在 tick 上，并限制可用范围为 0.1...0.9；按钮可切换 default / thumbless。"
        )

        let valueLabel = makeLabel("value = 0.50", font: .monospacedDigitSystemFont(ofSize: 20, weight: .semibold), color: .label, alignment: .center)
        stack.addArrangedSubview(valueLabel)

        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.sliderStyle = .thumbless
        slider.trackConfiguration = UISlider.TrackConfiguration(
            allowsTickValuesOnly: true,
            neutralValue: 0.5,
            enabledRange: 0.1...0.9,
            ticks: [
                .init(position: 0, title: "0"),
                .init(position: 0.25, title: "25"),
                .init(position: 0.5, title: "50"),
                .init(position: 0.75, title: "75"),
                .init(position: 1, title: "100"),
            ]
        )
        slider.addAction(UIAction { [weak slider, weak valueLabel] _ in
            guard let slider else { return }
            valueLabel?.text = String(format: "value = %.2f", slider.value)
        }, for: .valueChanged)
        stack.addArrangedSubview(slider)

        stack.addArrangedSubview(makeDemoButton("切换 thumb 显示") { [weak slider] action in
            guard let slider, let button = action.sender as? UIButton else { return }
            slider.sliderStyle = slider.sliderStyle == .thumbless ? .default : .thumbless
            button.setDemoButtonTitle(slider.sliderStyle == .thumbless ? "当前 thumbless" : "当前 default")
        })
    }
}

// MARK: - 9. Navigation Subtitle And Badge

private extension JPiOS26FeaturesViewController {

    func demoNavigationSubtitleAndBadge() {
        // [iOS 26] UINavigationItem 支持 subtitle / largeSubtitle，
        // UIBarButtonItem 支持 prominent 样式、badge、sharesBackground 等导航栏新表现。
        // 参考链接：https://developer.apple.com/documentation/uikit/uinavigationitem
        // 参考链接：https://developer.apple.com/documentation/UIKit/UIBarButtonItem/badge-4sz3f
        guard #available(iOS 26.0, *) else {
            showUnavailable("Navigation Subtitle And Badge", link: "https://developer.apple.com/documentation/uikit/uinavigationitem")
            return
        }

        let stack = prepareDemo(
            title: "UINavigationItem / UIBarButtonItem",
            description: "看导航栏：这里设置了 subtitle、largeTitle、largeSubtitle，以及一个带 badge 的 prominent bar button。"
        )

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "iOS 26"
        navigationItem.subtitle = "UIKit 新增导航能力"
        navigationItem.largeTitle = "iOS 26 UIKit"
        navigationItem.largeSubtitle = "Subtitle / Badge / Shared Background"

        navBadgeCount = 1
        let badgeItem = UIBarButtonItem(title: "消息", style: .prominent, target: self, action: #selector(handleBadgeTap))
        badgeItem.badge = .count(navBadgeCount)
        badgeItem.sharesBackground = true
        badgeItem.identifier = "jp.ios26.nav.badge"
        navBadgeItem = badgeItem

        let indicatorItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleBadgeTap))
        indicatorItem.badge = .indicator()
        indicatorItem.sharesBackground = true
        navigationItem.rightBarButtonItems = [badgeItem, indicatorItem]

        stack.addArrangedSubview(makeDemoButton("点我增加导航栏 badge") { [weak self] _ in
            self?.handleBadgeTap()
        })
        addInfo("要点：badge 当前只支持导航栏 bar button；sharesBackground 可让相邻 item 共享背景。", to: stack)
    }
}

// MARK: - 10. Symbol Rendering And Transition

private extension JPiOS26FeaturesViewController {

    func demoSymbolRenderingAndTransition() {
        // [iOS 26] UIImage.SymbolVariableValueMode / SymbolColorRenderingMode 控制 SF Symbol 的变量值和颜色渲染。
        // UIButton.Configuration.symbolContentTransition 可为按钮图标替换提供系统转场。
        // 参考链接：https://developer.apple.com/documentation/uikit/uiimage/symbolvariablevaluemode
        // 参考链接：https://developer.apple.com/documentation/UIKit/UIButton/Configuration-swift.struct
        guard #available(iOS 26.0, *) else {
            showUnavailable("Symbol Rendering And Transition", link: "https://developer.apple.com/documentation/uikit/uiimage/symbolvariablevaluemode")
            return
        }

        let stack = prepareDemo(
            title: "SF Symbols 渲染与转场",
            description: "上方三枚图标使用不同 variableValue；下方按钮通过 symbolContentTransition 切换图标。"
        )

        let symbolRow = makeHorizontalStack()
        [0.2, 0.55, 0.9].forEach { value in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemBlue
            let base = UIImage.SymbolConfiguration(pointSize: 54, weight: .semibold)
            let variable = UIImage.SymbolConfiguration(variableValueMode: .draw)
            let gradient = UIImage.SymbolConfiguration(colorRenderingMode: .gradient)
            imageView.image = UIImage(
                systemName: "speaker.wave.3.fill",
                variableValue: value,
                configuration: base.applying(variable).applying(gradient)
            )
            imageView.snp.makeConstraints { make in
                make.height.equalTo(76)
            }
            symbolRow.addArrangedSubview(imageView)
        }
        stack.addArrangedSubview(symbolRow)

        let names = ["bell.fill", "bell.slash.fill", "sparkles", "speaker.wave.3.fill"]
        var index = 0
        var config = UIButton.Configuration.glass()
        config.title = "切换 Symbol"
        config.image = UIImage(systemName: names[index])
        config.imagePlacement = .top
        config.imagePadding = 8

        #if canImport(Symbols)
        config.symbolContentTransition = UISymbolContentTransition(.replace, options: .default)
        #endif

        let button = UIButton(configuration: config)
        button.snp.makeConstraints { make in
            make.height.equalTo(96)
        }
        button.addAction(UIAction { [weak button] _ in
            guard let button else { return }
            index = (index + 1) % names.count
            var next = button.configuration
            next?.image = UIImage(systemName: names[index])
            next?.subtitle = names[index]
            button.configuration = next
        }, for: .touchUpInside)
        stack.addArrangedSubview(button)

        #if canImport(Symbols)
        addInfo("要点：symbolContentTransition 需要 Symbols framework；这里只使用 replace 转场。", to: stack)
        #else
        addInfo("当前 SDK 无法 import Symbols，已跳过 symbolContentTransition，仅展示变量值渲染。", to: stack)
        #endif
    }
}

// MARK: - 11. TextView Multi Range Editing

private extension JPiOS26FeaturesViewController {

    func demoTextViewMultiRangeEditing() {
        // [iOS 26] UITextView.selectedRanges 支持多个选区；
        // delegate 也新增 shouldChangeTextInRanges / editMenuForTextInRanges，替代只处理 union range 的旧接口。
        // 参考链接：https://developer.apple.com/documentation/uikit/uitextview
        guard #available(iOS 26.0, *) else {
            showUnavailable("TextView 多选区", link: "https://developer.apple.com/documentation/uikit/uitextview")
            return
        }

        let stack = prepareDemo(
            title: "UITextView.selectedRanges",
            description: "设置多个 selectedRanges 后，iOS 26 的新 delegate 方法可以拿到完整 ranges，而不是旧 selectedRange 的 union。"
        )

        let textView = UITextView()
        textView.text = "第一段文字可以被选中。\n第二段文字也可以被选中。\n第三段用于测试多选区编辑回调。"
        textView.font = .systemFont(ofSize: 17)
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 12
        textView.delegate = self
        textView.isEditable = true
        textView.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        stack.addArrangedSubview(textView)

        let statusLabel = addInfo("尚未设置多选区。", to: stack)
        textViewStatusLabel = statusLabel

        let buttons = makeHorizontalStack()
        buttons.addArrangedSubview(makeDemoButton("设置多选区") { [weak textView, weak statusLabel] _ in
            guard let textView else { return }
            textView.selectedRanges = [
                NSRange(location: 0, length: 4),
                NSRange(location: 12, length: 4),
            ]
            statusLabel?.text = "当前 selectedRanges：\(textView.selectedRanges.map { NSStringFromRange($0) }.joined(separator: ", "))"
        })
        buttons.addArrangedSubview(makeDemoButton("清空选择") { [weak textView, weak statusLabel] _ in
            guard let textView else { return }
            textView.selectedRanges = [NSRange(location: (textView.text as NSString).length, length: 0)]
            statusLabel?.text = "已清空选择：\(textView.selectedRanges.map { NSStringFromRange($0) }.joined(separator: ", "))"
        })
        stack.addArrangedSubview(buttons)
    }
}

// MARK: - 12. Foundation Models

private extension JPiOS26FeaturesViewController {

    func demoFoundationModels() {
        // [iOS 26] Foundation Models 提供本地系统语言模型入口。
        // 先检查 SystemLanguageModel.default.availability；可用时再创建 LanguageModelSession 并 respond。
        // 参考链接：https://developer.apple.com/documentation/foundationmodels
        guard #available(iOS 26.0, *) else {
            showUnavailable("Foundation Models", link: "https://developer.apple.com/documentation/foundationmodels")
            return
        }

        let stack = prepareDemo(
            title: "Foundation Models",
            description: "这个 demo 会先显示 SystemLanguageModel.default.availability。模型可用时，发送一个轻量中文 prompt；不可用时显示具体原因。"
        )

        let outputLabel = makeLabel("准备检查模型可用性...", font: .systemFont(ofSize: 15, weight: .medium), color: .label)
        outputLabel.backgroundColor = .systemBackground
        outputLabel.layer.cornerRadius = 12
        outputLabel.layer.masksToBounds = true
        outputLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(140)
        }
        stack.addArrangedSubview(outputLabel)

        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            outputLabel.text = "availability: available\n正在请求模型..."
            addInfo("要点：真实设备或模拟器可能因为 Apple Intelligence 未开启、设备不支持或模型未就绪而不可用。", to: stack)
            foundationModelsTask = Task { @MainActor [weak outputLabel] in
                do {
                    let session = LanguageModelSession(
                        model: model,
                        instructions: "你是一个 iOS 26 Foundation Models 调试助手。回答必须简短、中文、偏工程解释。"
                    )
                    let response = try await session.respond(to: "用一句话说明 Foundation Models 适合在 App 里做什么。")
                    guard !Task.isCancelled else { return }
                    outputLabel?.text = """
                    availability: available
                    response:
                    \(response.content)
                    """
                } catch {
                    guard !Task.isCancelled else { return }
                    outputLabel?.text = "availability: available\nrespond error:\n\(error.localizedDescription)"
                }
            }

        case .unavailable(let reason):
            outputLabel.text = """
            availability: unavailable
            reason: \(foundationModelsReasonText(reason))
            """
            addInfo("不可用也属于正常验收结果：只要能展示 availability 和 reason，即说明 API 链路可工作。", to: stack)
        }
        #else
        outputLabel.text = "当前 SDK 无法 import FoundationModels，已跳过模型调用。"
        #endif

        addInfo("参考链接：https://developer.apple.com/documentation/foundationmodels", to: stack)
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    func foundationModelsReasonText(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "deviceNotEligible（设备不符合 Apple Intelligence / Foundation Models 条件）"
        case .appleIntelligenceNotEnabled:
            return "appleIntelligenceNotEnabled（Apple Intelligence 未开启）"
        case .modelNotReady:
            return "modelNotReady（模型尚未下载或尚未准备好）"
        @unknown default:
            return "\(reason)"
        }
    }
    #endif
}

// MARK: - UITextViewDelegate

extension JPiOS26FeaturesViewController: UITextViewDelegate {

    @available(iOS 26.0, *)
    func textView(_ textView: UITextView, shouldChangeTextInRanges ranges: [NSValue], replacementText text: String) -> Bool {
        let rangeText = ranges.map { NSStringFromRange($0.rangeValue) }.joined(separator: ", ")
        textViewStatusLabel?.text = "shouldChangeTextInRanges：\(rangeText)，replacementText：\(text)"
        return true
    }

    @available(iOS 26.0, *)
    func textView(_ textView: UITextView, editMenuForTextInRanges ranges: [NSValue], suggestedActions: [UIMenuElement]) -> UIMenu? {
        let rangeText = ranges.map { NSStringFromRange($0.rangeValue) }.joined(separator: ", ")
        textViewStatusLabel?.text = "editMenuForTextInRanges：\(rangeText)"
        return nil
    }
}

// MARK: - 扩展方法

private extension UIButton {

    func setDemoButtonTitle(_ title: String) {
        if var configuration {
            configuration.title = title
            self.configuration = configuration
        } else {
            setTitle(title, for: .normal)
        }
    }
}

private extension UIView {

    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        snp.makeConstraints { make in
            make.edges.equalTo(view).inset(insets)
        }
    }

    func pinEdges(to guide: UILayoutGuide, insets: UIEdgeInsets = .zero) {
        snp.makeConstraints { make in
            make.edges.equalTo(guide).inset(insets)
        }
    }
}
