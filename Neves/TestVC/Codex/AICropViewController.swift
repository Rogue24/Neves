//
//  AICropViewController.swift
//  Neves
//
//  Created by aa on 2026/2/20.
//

import UIKit
import FunnyButton

class AICropViewController: TestBaseViewController {

    // MARK: - Public

    var inputImage: UIImage? {
        didSet {
            if isViewLoaded, let inputImage {
                setImage(inputImage)
            }
        }
    }

    func updateImageForCrop(_ image: UIImage) {
        inputImage = image
        if isViewLoaded {
            setImage(image)
        }
    }

    // MARK: - UI

    private let canvasView = UIView()
    private let imageView = UIImageView()
    private let overlayView = CropOverlayInteractiveView()

    private let bottomPanel = UIView()
    private let angleBadge = UILabel()
    private let rulerView = RotationRulerView()
    private let resetButton = UIButton(type: .system)
    private let cropButton = UIButton(type: .system)

    // MARK: - State
    // 当前裁剪框（在 VC 视图坐标系）

    private var cropRect: CGRect = .zero {
        didSet {
            overlayView.cropRect = cropRect
        }
    }
    // 顶部可编辑画布区域（图片与裁剪框活动区）
    private var canvasRect: CGRect = .zero

    // 图片初始适配到画布后的“基准尺寸”（不含用户手势）
    private var baseImageDisplaySize: CGSize = .zero
    // 用户缩放量（在基准尺寸基础上再缩放）
    private var userScale: CGFloat = 1
    // 用户平移量
    private var userTranslation: CGPoint = .zero
    // 当前旋转角（弧度）
    private var rotationAngle: CGFloat = 0

    // 裁剪框最小边长，防止拖拽过小
    private let minCropSide: CGFloat = 100
    // 最大放大倍数，防止无限放大
    private let maxUserScale: CGFloat = 12

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture()
        
//        let defaultImage = inputImage ?? makeDemoImage()
//        self.setImage(defaultImage)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCanvasAndCropIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction { [weak self] in
            guard let self else { return }
            
            if self.imageView.image == nil {
                let image = UIImage.jp.fromBundle("girl", type: "jpg")!
                self.setImage(image)
                return
            }
            
            self.resetAll()
        }
    }
}

private extension AICropViewController {
    // [阅读导航-1] 先看 setupUI / layoutCanvasAndCropIfNeeded：理解页面结构和坐标空间
    // [阅读导航-2] 再看 applyImageTransform：所有图像变换的唯一出口
    // [阅读导航-3] 再看 currentStateValid + stateValid：合法性判定和试探机制
    // [阅读导航-4] 接着看 handleImagePan / handlePinch / applyRotation：三种核心交互
    // [阅读导航-5] 最后看 CropOverlayInteractiveViewDelegate：裁剪框拖拽如何接入主约束

    // [入口 A] 搭建 UI：上方画布、裁剪遮罩、底部角度标尺与按钮
    func setupUI() {
        title = "裁剪"
        view.backgroundColor = .black

        canvasView.backgroundColor = .black
        canvasView.frame = view.bounds
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(canvasView)

        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        canvasView.addSubview(imageView)

        overlayView.frame = view.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.backgroundColor = .clear
        overlayView.delegate = self
        view.addSubview(overlayView)

        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.backgroundColor = .black
        view.addSubview(bottomPanel)

        angleBadge.translatesAutoresizingMaskIntoConstraints = false
        angleBadge.textAlignment = .center
        angleBadge.font = .systemFont(ofSize: 14, weight: .medium)
        angleBadge.textColor = UIColor(red: 1, green: 0.86, blue: 0.2, alpha: 1)
        angleBadge.layer.borderWidth = 1.5
        angleBadge.layer.borderColor = UIColor(red: 1, green: 0.86, blue: 0.2, alpha: 1).cgColor
        angleBadge.layer.cornerRadius = 26
        angleBadge.clipsToBounds = true
        angleBadge.text = "0°"
        bottomPanel.addSubview(angleBadge)

        rulerView.translatesAutoresizingMaskIntoConstraints = false
        // 底部标尺输出角度（度），统一从这里驱动旋转
        rulerView.onAngleChange = { [weak self] degree in
            self?.applyRotation(degree: degree)
        }
        bottomPanel.addSubview(rulerView)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("重置", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        resetButton.tintColor = .white
        resetButton.addTarget(self, action: #selector(handleResetTap), for: .touchUpInside)
        bottomPanel.addSubview(resetButton)

        cropButton.translatesAutoresizingMaskIntoConstraints = false
        cropButton.setTitle("裁剪", for: .normal)
        cropButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cropButton.tintColor = .white
        cropButton.addTarget(self, action: #selector(handleCropTap), for: .touchUpInside)
        bottomPanel.addSubview(cropButton)

        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: 200),

            angleBadge.centerXAnchor.constraint(equalTo: bottomPanel.centerXAnchor),
            angleBadge.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 8),
            angleBadge.widthAnchor.constraint(equalToConstant: 52),
            angleBadge.heightAnchor.constraint(equalToConstant: 52),

            rulerView.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 24),
            rulerView.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -24),
            rulerView.topAnchor.constraint(equalTo: angleBadge.bottomAnchor, constant: 12),
            rulerView.heightAnchor.constraint(equalToConstant: 58),

            resetButton.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 28),
            resetButton.bottomAnchor.constraint(equalTo: bottomPanel.bottomAnchor, constant: -10),

            cropButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -28),
            cropButton.bottomAnchor.constraint(equalTo: bottomPanel.bottomAnchor, constant: -10)
        ])
    }

    func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        imageView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        imageView.addGestureRecognizer(pinch)
    }

    // [入口 B] 每次布局时计算画布与裁剪框，确保它们处于正确几何关系
    func layoutCanvasAndCropIfNeeded() {
        let topInset = view.safeAreaInsets.top + 16
        let bottomInset = view.safeAreaInsets.bottom + 200 + 16

        canvasRect = CGRect(
            x: 16,
            y: topInset,
            width: view.bounds.width - 32,
            height: max(120, view.bounds.height - topInset - bottomInset)
        )

        // 首次进入：给一个默认居中的正方形裁剪框
        if cropRect == .zero {
            let side = min(canvasRect.width, canvasRect.height) * 0.82
            cropRect = CGRect(
                x: canvasRect.midX - side / 2,
                y: canvasRect.midY - side / 2,
                width: side,
                height: side
            ).integral
        } else {
            // 尺寸变化后，至少保证裁剪框留在画布范围
            cropRect = cropRect.intersection(canvasRect)
        }

        overlayView.canvasRect = canvasRect

        if imageView.image != nil {
            layoutImageAtCurrentState(resetIfNeeded: baseImageDisplaySize == .zero)
            // 布局后做一次合法性兜底，避免出现裁剪框越界
            ensureValidStateOrClamp(animated: false)
        }
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
        baseImageDisplaySize = .zero
        userScale = 1
        userTranslation = .zero
        rotationAngle = 0
        rulerView.setAngle(0, notify: false)
        updateAngleText(0)

        if view.bounds.width > 0 {
            layoutImageAtCurrentState(resetIfNeeded: true)
            ensureValidStateOrClamp(animated: false)
        }
    }

    func layoutImageAtCurrentState(resetIfNeeded: Bool) {
        guard let image = imageView.image else { return }
        guard canvasRect.width > 0, canvasRect.height > 0 else { return }

        if resetIfNeeded {
            // 以“完整显示在画布内”为初始态（接近系统相册初始效果）
            let fitScale = min(canvasRect.width / image.size.width, canvasRect.height / image.size.height)
            baseImageDisplaySize = CGSize(width: image.size.width * fitScale, height: image.size.height * fitScale)
            imageView.bounds = CGRect(origin: .zero, size: baseImageDisplaySize)
            imageView.center = CGPoint(x: canvasRect.midX, y: canvasRect.midY)
            userScale = 1
            userTranslation = .zero
            rotationAngle = 0
        } else {
            // 非首次：仅重建基准几何，用户状态保留
            imageView.bounds = CGRect(origin: .zero, size: baseImageDisplaySize)
            imageView.center = CGPoint(x: canvasRect.midX, y: canvasRect.midY)
        }

        applyImageTransform()
    }

    // [核心 C] 图片状态 -> 真实 transform（所有手势最终都走这）
    func applyImageTransform() {
        // 所有图片变换统一走这里：平移 -> 旋转 -> 缩放
        // 好处：交互逻辑只改状态变量，渲染路径单一，排查问题更容易
        let t = CGAffineTransform(translationX: userTranslation.x, y: userTranslation.y)
            .rotated(by: rotationAngle)
            .scaledBy(x: userScale, y: userScale)
        imageView.transform = t
    }

    // [核心 D] 约束判定：当前（或指定）裁剪框是否被图片完整覆盖
    func currentStateValid(for rect: CGRect? = nil) -> Bool {
        // 核心约束：裁剪框四个角必须都落在图片内
        // 满足这个条件即可认为“不会裁到黑边”
        let targetRect = rect ?? cropRect
        guard targetRect.width > 0, targetRect.height > 0 else { return false }

        let points = [
            CGPoint(x: targetRect.minX, y: targetRect.minY),
            CGPoint(x: targetRect.maxX, y: targetRect.minY),
            CGPoint(x: targetRect.maxX, y: targetRect.maxY),
            CGPoint(x: targetRect.minX, y: targetRect.maxY)
        ]

        for p in points {
            // 把 VC 坐标转换到 imageView 本地坐标进行 contains 判断
            let local = imageView.convert(p, from: view)
            if !imageView.bounds.contains(local) {
                return false
            }
        }
        return true
    }

    // [核心 E] 一键兜底：若越界则自动修复（补缩放 / 回退）
    func ensureValidStateOrClamp(animated: Bool) {
        guard !currentStateValid() else { return }

        // 优先放大，保持旋转和位移不变，直到裁剪框完整落入图片
        // 目标是找“刚好合法”的最小 scale，减少画面跳变
        var low = userScale
        var high = max(userScale, 1)
        while high < maxUserScale {
            if stateValid(scale: high, translation: userTranslation, rotation: rotationAngle) {
                break
            }
            high *= 1.35
        }

        if high <= maxUserScale, stateValid(scale: high, translation: userTranslation, rotation: rotationAngle) {
            // 二分逼近最小合法缩放
            for _ in 0..<20 {
                let mid = (low + high) * 0.5
                if stateValid(scale: mid, translation: userTranslation, rotation: rotationAngle) {
                    high = mid
                } else {
                    low = mid
                }
            }
            userScale = min(high, maxUserScale)
            applyImageTransform()
            return
        }

        // 放大到上限仍无解（极端情况）就回到初始状态兜底
        resetAll(animated: animated)
    }

    // [工具 F] 试探某个候选状态是否合法（供二分算法使用）
    func stateValid(scale: CGFloat, translation: CGPoint, rotation: CGFloat) -> Bool {
        // 试探函数：
        // 临时应用候选状态 -> 校验 -> 还原现场
        // 外层二分/插值都依赖它
        let backupScale = userScale
        let backupTranslation = userTranslation
        let backupRotation = rotationAngle

        userScale = scale
        userTranslation = translation
        rotationAngle = rotation
        applyImageTransform()
        let valid = currentStateValid()

        userScale = backupScale
        userTranslation = backupTranslation
        rotationAngle = backupRotation
        applyImageTransform()
        return valid
    }

    // [交互 G1] 图片平移：越界时沿路径二分回退
    @objc func handleImagePan(_ gesture: UIPanGestureRecognizer) {
        let delta = gesture.translation(in: view)
        gesture.setTranslation(.zero, in: view)

        let from = userTranslation
        let target = CGPoint(x: from.x + delta.x, y: from.y + delta.y)

        // 目标位置合法就直接应用
        if stateValid(scale: userScale, translation: target, rotation: rotationAngle) {
            userTranslation = target
            applyImageTransform()
            return
        }

        // 目标不合法：在 from -> target 路径上二分，找最远合法点
        var low: CGFloat = 0
        var high: CGFloat = 1
        for _ in 0..<18 {
            let mid = (low + high) * 0.5
            let candidate = from.lerp(to: target, t: mid)
            if stateValid(scale: userScale, translation: candidate, rotation: rotationAngle) {
                low = mid
            } else {
                high = mid
            }
        }
        userTranslation = from.lerp(to: target, t: low)
        applyImageTransform()
    }

    // [交互 G2] 图片缩放：越界时二分求最接近目标的合法值
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let from = userScale
        let raw = from * gesture.scale
        let target = min(max(raw, 1), maxUserScale)
        gesture.scale = 1

        // 目标缩放合法就直接应用
        if stateValid(scale: target, translation: userTranslation, rotation: rotationAngle) {
            userScale = target
            applyImageTransform()
            return
        }

        var low = from
        var high = target
        if high < low {
            swap(&low, &high)
        }

        // 不合法时，同样通过二分逼近最接近目标的合法 scale
        for _ in 0..<20 {
            let mid = (low + high) * 0.5
            if stateValid(scale: mid, translation: userTranslation, rotation: rotationAngle) {
                if target > from {
                    high = mid
                } else {
                    low = mid
                }
            } else {
                if target > from {
                    low = mid
                } else {
                    high = mid
                }
            }
        }

        userScale = target > from ? high : low
        applyImageTransform()
    }

    // [交互 G3] 角度旋转：来自底部标尺，范围 [-45, 45]
    func applyRotation(degree: CGFloat) {
        // UI 层用角度，计算层用弧度
        let rad = degree * .pi / 180
        let oldRotation = rotationAngle
        let oldScale = userScale

        // 当前缩放下能旋转成功就直接应用
        if stateValid(scale: userScale, translation: userTranslation, rotation: rad) {
            rotationAngle = rad
            applyImageTransform()
            updateAngleText(degree)
            return
        }

        // 旋转后越界：自动补缩放，尽量保留用户当前视角/位置
        var low = userScale
        var high = max(userScale, 1)
        while high < maxUserScale {
            if stateValid(scale: high, translation: userTranslation, rotation: rad) {
                break
            }
            high *= 1.3
        }

        if high <= maxUserScale, stateValid(scale: high, translation: userTranslation, rotation: rad) {
            // 二分找该旋转角下的最小合法缩放
            for _ in 0..<18 {
                let mid = (low + high) * 0.5
                if stateValid(scale: mid, translation: userTranslation, rotation: rad) {
                    high = mid
                } else {
                    low = mid
                }
            }
            rotationAngle = rad
            userScale = min(high, maxUserScale)
            applyImageTransform()
            updateAngleText(degree)
            return
        }

        // 仍无解就回退，避免 UI 抖动和跳变
        rotationAngle = oldRotation
        userScale = oldScale
        applyImageTransform()
        let oldDegree = oldRotation * 180 / .pi
        rulerView.setAngle(oldDegree, notify: false)
        updateAngleText(oldDegree)
    }

    func updateAngleText(_ degree: CGFloat) {
        let rounded = Int(degree.rounded())
        angleBadge.text = "\(rounded)°"
    }

    @objc func handleResetTap() {
        resetAll()
    }

    func resetAll(animated: Bool = false) {
        // 一键回到初始编辑态：框居中、角度 0、缩放 1、平移 0
        let work = {
            self.cropRect = CGRect(
                x: self.canvasRect.midX - min(self.canvasRect.width, self.canvasRect.height) * 0.41,
                y: self.canvasRect.midY - min(self.canvasRect.width, self.canvasRect.height) * 0.41,
                width: min(self.canvasRect.width, self.canvasRect.height) * 0.82,
                height: min(self.canvasRect.width, self.canvasRect.height) * 0.82
            ).integral

            self.userScale = 1
            self.userTranslation = .zero
            self.rotationAngle = 0
            self.applyImageTransform()
            self.rulerView.setAngle(0, notify: false)
            self.updateAngleText(0)
            self.ensureValidStateOrClamp(animated: false)
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: work)
        } else {
            work()
        }
    }

    @objc func handleCropTap() {
        guard let output = cropCurrentImage() else { return }
        showCropResult(output)
    }

    // [结果 H] 生成裁剪结果图
    func cropCurrentImage() -> UIImage? {
        // 把画布按 cropRect 截取成新图：
        // 通过平移上下文，让 cropRect 对齐到渲染原点
        guard cropRect.width > 0, cropRect.height > 0 else { return nil }
        let renderer = UIGraphicsImageRenderer(size: cropRect.size)
        return renderer.image { context in
            context.cgContext.translateBy(x: -cropRect.minX, y: -cropRect.minY)
            canvasView.layer.render(in: context.cgContext)
        }
    }

    func showCropResult(_ image: UIImage) {
        let vc = UIViewController()
        vc.title = "裁剪结果"
        vc.view.backgroundColor = .black

        let resultView = UIImageView(image: image)
        resultView.contentMode = .scaleAspectFit
        resultView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(resultView)

        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            resultView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            resultView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigationController?.pushViewController(vc, animated: true)
    }

    func makeDemoImage(size: CGSize = CGSize(width: 1500, height: 1100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let colors = [
                UIColor(red: 0.55, green: 0.1, blue: 0.1, alpha: 1).cgColor,
                UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1).cgColor,
                UIColor(red: 0.75, green: 0.6, blue: 0.2, alpha: 1).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0, 0.55, 1]
            let space = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locations) else { return }
            ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 110),
                .foregroundColor: UIColor.white.withAlphaComponent(0.88),
                .paragraphStyle: paragraph
            ]
            "Crop Demo".draw(in: CGRect(x: 0, y: size.height / 2 - 70, width: size.width, height: 140), withAttributes: attrs)
        }
    }
}

extension AICropViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension AICropViewController: CropOverlayInteractiveViewDelegate {
    // [阅读导航-I] 主控制器 <-> 裁剪框视图的桥接层
    // 先看 adjust(proposedRect)，再看 didChange(end)

    func cropOverlay(_ overlay: CropOverlayInteractiveView, adjust proposedRect: CGRect, from currentRect: CGRect) -> CGRect {
        // 先做几何约束：最小尺寸 + 不出画布
        guard canvasRect.width > 0 else { return currentRect }

        var target = proposedRect

        if target.width < minCropSide { target.size.width = minCropSide }
        if target.height < minCropSide { target.size.height = minCropSide }
        if target.width > canvasRect.width { target.size.width = canvasRect.width }
        if target.height > canvasRect.height { target.size.height = canvasRect.height }

        if target.minX < canvasRect.minX { target.origin.x = canvasRect.minX }
        if target.maxX > canvasRect.maxX { target.origin.x = canvasRect.maxX - target.width }
        if target.minY < canvasRect.minY { target.origin.y = canvasRect.minY }
        if target.maxY > canvasRect.maxY { target.origin.y = canvasRect.maxY - target.height }

        // 目标框若仍被图片完整覆盖，直接通过
        if currentStateValid(for: target) {
            return target.integral
        }

        // 否则在 current -> target 之间二分，取最远合法位置
        var low: CGFloat = 0
        var high: CGFloat = 1
        for _ in 0..<20 {
            let mid = (low + high) * 0.5
            let candidate = currentRect.lerp(to: target, t: mid)
            if currentStateValid(for: candidate) {
                low = mid
            } else {
                high = mid
            }
        }

        return currentRect.lerp(to: target, t: low).integral
    }

    func cropOverlay(_ overlay: CropOverlayInteractiveView, didChange cropRect: CGRect, end: Bool) {
        self.cropRect = cropRect
        if end {
            // 结束拖拽后再做一次兜底
            ensureValidStateOrClamp(animated: false)
        }
    }
}

protocol CropOverlayInteractiveViewDelegate: AnyObject {
    func cropOverlay(_ overlay: CropOverlayInteractiveView, adjust proposedRect: CGRect, from currentRect: CGRect) -> CGRect
    func cropOverlay(_ overlay: CropOverlayInteractiveView, didChange cropRect: CGRect, end: Bool)
}

final class CropOverlayInteractiveView: UIView {
    // [阅读导航-J] 裁剪框组件（只负责：命中、拖拽、绘制）
    // 不负责“是否越界到图片外”，该规则交给 delegate 决定

    enum DragMode {
        case none
        case move
        case left
        case right
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    weak var delegate: CropOverlayInteractiveViewDelegate?
    var canvasRect: CGRect = .zero {
        didSet { setNeedsDisplay() }
    }
    var cropRect: CGRect = .zero {
        didSet { setNeedsDisplay() }
    }

    // 当前拖拽模式：移动整体/改某条边/改某个角
    private var dragMode: DragMode = .none
    private var beginRect: CGRect = .zero

    private let hitPadding: CGFloat = 28
    private let minSide: CGFloat = 80

    override init(frame: CGRect) {
        super.init(frame: frame)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard cropRect.width > 0 else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.setFillColor(UIColor.black.withAlphaComponent(0.62).cgColor)
        ctx.fill(bounds)
        ctx.clear(cropRect)

        let borderPath = UIBezierPath(rect: cropRect)
        UIColor.white.setStroke()
        borderPath.lineWidth = 2
        borderPath.stroke()

        // 系统风格关键元素：九宫格 + 角标 + 边中点短线
        drawGrid(in: ctx)
        drawHandles(in: ctx)
    }

    // [组件核心 J1] 拖拽手势主流程
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let p = gesture.location(in: self)
        let t = gesture.translation(in: self)

        switch gesture.state {
        case .began:
            // 在开始时锁定操作类型，防止拖动过程中模式跳变
            dragMode = detectMode(at: p)
            beginRect = cropRect
        case .changed:
            guard dragMode != .none else { return }
            // 把手势位移换算成目标裁剪框
            var target = rect(byApplying: t, from: beginRect, mode: dragMode)
            // 统一做“最小尺寸/翻转”修正
            target = normalized(rect: target, mode: dragMode)
            let adjusted = delegate?.cropOverlay(self, adjust: target, from: cropRect) ?? target
            cropRect = adjusted
            delegate?.cropOverlay(self, didChange: adjusted, end: false)
        case .ended, .cancelled, .failed:
            delegate?.cropOverlay(self, didChange: cropRect, end: true)
            dragMode = .none
        default:
            break
        }
    }

    // [组件核心 J2] 命中测试：判断是拖角、拖边还是整体移动
    private func detectMode(at p: CGPoint) -> DragMode {
        // 命中优先级：角点 > 边 > 内部移动
        guard cropRect.insetBy(dx: -hitPadding, dy: -hitPadding).contains(p) else { return .none }

        let nearLeft = abs(p.x - cropRect.minX) <= hitPadding
        let nearRight = abs(p.x - cropRect.maxX) <= hitPadding
        let nearTop = abs(p.y - cropRect.minY) <= hitPadding
        let nearBottom = abs(p.y - cropRect.maxY) <= hitPadding

        if nearLeft && nearTop { return .topLeft }
        if nearRight && nearTop { return .topRight }
        if nearLeft && nearBottom { return .bottomLeft }
        if nearRight && nearBottom { return .bottomRight }

        if nearLeft { return .left }
        if nearRight { return .right }
        if nearTop { return .top }
        if nearBottom { return .bottom }

        if cropRect.contains(p) { return .move }
        return .none
    }

    // [组件核心 J3] 根据拖动类型把位移映射到目标 rect
    private func rect(byApplying t: CGPoint, from rect: CGRect, mode: DragMode) -> CGRect {
        // 不同模式只改对应边或角，保持其它边不变
        var r = rect
        switch mode {
        case .move:
            r.origin.x += t.x
            r.origin.y += t.y
        case .left:
            r.origin.x += t.x
            r.size.width -= t.x
        case .right:
            r.size.width += t.x
        case .top:
            r.origin.y += t.y
            r.size.height -= t.y
        case .bottom:
            r.size.height += t.y
        case .topLeft:
            r.origin.x += t.x
            r.size.width -= t.x
            r.origin.y += t.y
            r.size.height -= t.y
        case .topRight:
            r.size.width += t.x
            r.origin.y += t.y
            r.size.height -= t.y
        case .bottomLeft:
            r.origin.x += t.x
            r.size.width -= t.x
            r.size.height += t.y
        case .bottomRight:
            r.size.width += t.x
            r.size.height += t.y
        case .none:
            break
        }
        return r
    }

    // [组件核心 J4] 尺寸归一化：防止宽/高被拖到过小
    private func normalized(rect: CGRect, mode: DragMode) -> CGRect {
        // 如果被拖成过小，则钳到 minSide，并尽量保留“拖动边”的手感
        var r = rect

        if r.width < minSide {
            let delta = minSide - r.width
            switch mode {
            case .left, .topLeft, .bottomLeft:
                r.origin.x -= delta
            default:
                break
            }
            r.size.width = minSide
        }

        if r.height < minSide {
            let delta = minSide - r.height
            switch mode {
            case .top, .topLeft, .topRight:
                r.origin.y -= delta
            default:
                break
            }
            r.size.height = minSide
        }

        return r
    }

    private func drawGrid(in ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        ctx.setLineWidth(1)

        let stepX = cropRect.width / 3
        let stepY = cropRect.height / 3
        for i in 1...2 {
            let x = cropRect.minX + CGFloat(i) * stepX
            ctx.move(to: CGPoint(x: x, y: cropRect.minY))
            ctx.addLine(to: CGPoint(x: x, y: cropRect.maxY))

            let y = cropRect.minY + CGFloat(i) * stepY
            ctx.move(to: CGPoint(x: cropRect.minX, y: y))
            ctx.addLine(to: CGPoint(x: cropRect.maxX, y: y))
        }
        ctx.strokePath()
        ctx.restoreGState()
    }

    private func drawHandles(in ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineWidth(4)

        let l = cropRect.minX
        let r = cropRect.maxX
        let t = cropRect.minY
        let b = cropRect.maxY
        let d: CGFloat = 16

        // 四角 L 形
        ctx.move(to: CGPoint(x: l, y: t + d)); ctx.addLine(to: CGPoint(x: l, y: t)); ctx.addLine(to: CGPoint(x: l + d, y: t))
        ctx.move(to: CGPoint(x: r - d, y: t)); ctx.addLine(to: CGPoint(x: r, y: t)); ctx.addLine(to: CGPoint(x: r, y: t + d))
        ctx.move(to: CGPoint(x: l, y: b - d)); ctx.addLine(to: CGPoint(x: l, y: b)); ctx.addLine(to: CGPoint(x: l + d, y: b))
        ctx.move(to: CGPoint(x: r - d, y: b)); ctx.addLine(to: CGPoint(x: r, y: b)); ctx.addLine(to: CGPoint(x: r, y: b - d))

        // 中点短线
        let mx = (l + r) * 0.5
        let my = (t + b) * 0.5
        ctx.move(to: CGPoint(x: mx - 10, y: t)); ctx.addLine(to: CGPoint(x: mx + 10, y: t))
        ctx.move(to: CGPoint(x: mx - 10, y: b)); ctx.addLine(to: CGPoint(x: mx + 10, y: b))
        ctx.move(to: CGPoint(x: l, y: my - 10)); ctx.addLine(to: CGPoint(x: l, y: my + 10))
        ctx.move(to: CGPoint(x: r, y: my - 10)); ctx.addLine(to: CGPoint(x: r, y: my + 10))

        ctx.strokePath()
        ctx.restoreGState()
    }
}

private final class RotationRulerView: UIView {
    // [阅读导航-K] 旋转标尺组件（只负责角度输入与刻度绘制）

    var onAngleChange: ((CGFloat) -> Void)?

    private(set) var currAngle: CGFloat = 0
    private let minAngle: CGFloat = -45
    private let maxAngle: CGFloat = 45
    // 拖动灵敏度：每移动 1pt 对应多少角度
    private let degreePerPoint: CGFloat = 0.22

    private var beginAngle: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // [组件核心 K1] 设置并钳制角度，可选是否通知上层
    func setAngle(_ newValue: CGFloat, notify: Bool) {
        // 旋转范围固定为 [-45, 45]
        currAngle = min(max(newValue, minAngle), maxAngle)
        setNeedsDisplay()
        if notify {
            onAngleChange?(currAngle)
        }
    }

    // [组件核心 K2] 绘制刻度尺与中央指示线
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let centerX = rect.midX
        let baseY = rect.maxY - 8

        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.65).cgColor)
        ctx.setLineWidth(2)

        // 刻度整体“反向平移”，营造滑尺效果；中央黄线保持不动
        for degree in stride(from: Int(minAngle) - 30, through: Int(maxAngle) + 30, by: 1) {
            let x = centerX + (CGFloat(degree) - currAngle) / degreePerPoint
            if x < rect.minX - 4 || x > rect.maxX + 4 { continue }

            let isMajor = degree % 5 == 0
            let h: CGFloat = isMajor ? 24 : 14
            ctx.move(to: CGPoint(x: x, y: baseY - h))
            ctx.addLine(to: CGPoint(x: x, y: baseY))
        }
        ctx.strokePath()

        ctx.setStrokeColor(UIColor(red: 1, green: 0.86, blue: 0.2, alpha: 1).cgColor)
        ctx.setLineWidth(3)
        ctx.move(to: CGPoint(x: centerX, y: baseY - 34))
        ctx.addLine(to: CGPoint(x: centerX, y: baseY + 2))
        ctx.strokePath()
        ctx.restoreGState()
    }

    // [组件核心 K3] 手势位移 -> 角度变化
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginAngle = currAngle
        case .changed:
            // 使用累计 translation，让角度变化连续稳定
            let tx = gesture.translation(in: self).x
            let next = beginAngle - tx * degreePerPoint
            setAngle(next, notify: true)
        default:
            break
        }
    }
}

private extension CGPoint {
    func lerp(to: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(x: x + (to.x - x) * t, y: y + (to.y - y) * t)
    }
}

private extension CGRect {
    func lerp(to: CGRect, t: CGFloat) -> CGRect {
        CGRect(
            x: origin.x + (to.origin.x - origin.x) * t,
            y: origin.y + (to.origin.y - origin.y) * t,
            width: size.width + (to.size.width - size.width) * t,
            height: size.height + (to.size.height - size.height) * t
        )
    }
}
