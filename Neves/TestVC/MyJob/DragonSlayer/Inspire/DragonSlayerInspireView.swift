//
//  DragonSlayerInspireView.swift
//  Neves
//
//  Created by aa on 2021/11/3.
//

import UIKit

class DragonSlayerInspireView: UIView {
    
    // MARK: UI变量
    private var viewMaxY: CGFloat = 0
    private let viewMinH: CGFloat = 111 // 129 - 18
    private let viewMaxH: CGFloat = 201
    
    private let contentFont = UIFont.systemFont(ofSize: 10)
    private let contentColor = UIColor(white: 1, alpha: 0.8)
    private let contentLineSpace: CGFloat = 8
    private let contentVerMargin: CGFloat = 4
    private let contentW: CGFloat = 198
    private let minContentH: CGFloat = 10 // 18 - 4 - 4
    private let maxContentH: CGFloat = 92
    
    // MARK: UI控件
    private let infoView = UIView()
    private let userIcon = UIImageView()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    private let zanIcon = UIImageView(image: UIImage(named: "dragon_icon_guwu2"))
    private let contentLabel = UILabel()
    
    private let inspireBtn = UIView()
    private let inspireLabel = UILabel()
    
    private var bubbleName: String? = nil
    private lazy var bubbles: [Bubble] = []
    
    // MARK: 存储属性
    private(set) var names: [String]
    private(set) var isContainsMe = false
    private(set) var isInspired = false {
        didSet {
            guard isInspired != oldValue else { return }
            updateInspireText()
        }
    }
    var inspireDone: (() -> ())?
    
    // MARK: 定时器
    private var timer: DispatchSourceTimer?
    private(set) var inspireSecond = 50 {
        didSet {
            updateInspireText()
            if inspireSecond <= 0 { hide() }
        }
    }
    
    // MARK: - 生命周期
    init(names: [String]) {
        self.names = names
        super.init(frame: [0, 0, 210, 129])
        setupBg()
        setupInfo()
        setupContent()
        setupInspireBtn()
        updateContent()
        updateInspireText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("鼓舞鼓死了")
    }
    
}

// MARK: - UI初始化
private extension DragonSlayerInspireView {
    
    func setupBg() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let gLayer = CAGradientLayer()
        gLayer.frame = [0, 0, frame.width, viewMinH]
        gLayer.startPoint = [0.5, 0]
        gLayer.endPoint = [0.5, 1]
        gLayer.colors = [UIColor.rgb(77, 22, 52, a: 0.95).cgColor, UIColor.rgb(71, 23, 75, a: 0.95).cgColor]
        layer.addSublayer(gLayer)
        
        let bgLayer = CALayer()
        bgLayer.frame = [0, gLayer.frame.maxY, gLayer.frame.width, 150]
        bgLayer.backgroundColor = UIColor.rgb(71, 23, 75, a: 0.95).cgColor
        layer.addSublayer(bgLayer)
    }
    
    func setupInfo() {
        infoView.frame = [0, 0, frame.width, 59]
        addSubview(infoView)
        
        let topImgView = UIImageView(frame: infoView.bounds)
        topImgView.image = UIImage(named: "dragon_guwu_banner")
        infoView.addSubview(topImgView)
        
        userIcon.frame = [6, 10, 35, 35]
        userIcon.contentMode = .scaleAspectFill
        userIcon.layer.cornerRadius = 17.5
        userIcon.layer.masksToBounds = true
        userIcon.layer.borderWidth = 1
        userIcon.layer.borderColor = UIColor.rgb(255, 204, 164).cgColor
        userIcon.image = UIImage(named: "jp_icon")
        infoView.addSubview(userIcon)
        
        let x = userIcon.frame.maxX + 8
        nameLabel.frame = [x, 7.5, frame.width - x - 8, 20]
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .rgb(255, 205, 171)
        nameLabel.text = "帅哥美男平"
        infoView.addSubview(nameLabel)
        
        let dragonIcon = UIImageView(frame: [x, nameLabel.frame.maxY + 4.5, 14, 14])
        dragonIcon.image = UIImage(named: "dragon_weideng")
        infoView.addSubview(dragonIcon)
        
        let dragonLabel = UILabel()
        dragonLabel.font = .systemFont(ofSize: 11)
        dragonLabel.textColor = .white
        dragonLabel.text = "龙之召唤师"
        dragonLabel.sizeToFit()
        dragonLabel.frame = [dragonIcon.frame.maxX + 3, nameLabel.frame.maxY + 4, dragonLabel.frame.width, 15]
        infoView.addSubview(dragonLabel)
        
        countLabel.frame = [dragonLabel.frame.maxX, dragonLabel.frame.origin.y, 100, 15]
        countLabel.font = .systemFont(ofSize: 11)
        countLabel.textColor = .white
        countLabel.text = "（1龙）"
        infoView.addSubview(countLabel)
    }
    
    func setupContent() {
        zanIcon.alpha = 0
        zanIcon.frame = [12, infoView.frame.maxY + 5, 12, 12]
        addSubview(zanIcon)
        
        contentLabel.frame = [6, infoView.frame.maxY + contentVerMargin + 2, contentW, minContentH]
        contentLabel.numberOfLines = 5
        addSubview(contentLabel)
    }
    
    func setupInspireBtn() {
        inspireBtn.frame = [20, frame.height - 30 - 10, 170, 30]
        inspireBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(inspireAction)))
        addSubview(inspireBtn)
        
        let bgImgView = UIImageView(frame: inspireBtn.bounds)
        bgImgView.image = UIImage(named: "dragon_guwu_btn")
        inspireBtn.addSubview(bgImgView)
        
        let inspireIcon = UIImageView(frame: [39.5, HalfDiffValue(inspireBtn.frame.height, 14), 14, 14])
        inspireIcon.image = UIImage(named: "dragon_icon_guwu1")
        inspireBtn.addSubview(inspireIcon)
        
        inspireLabel.frame = [inspireIcon.frame.maxX + 4, 0, inspireBtn.frame.width, inspireBtn.frame.height]
        inspireLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        inspireLabel.textColor = .rgb(86, 58, 47)
        inspireBtn.addSubview(inspireLabel)
    }
    
    @objc func inspireAction() {
        isInspired = true
    }
    
}

// MARK: - 刷新内容
private extension DragonSlayerInspireView {
    
    func updateContent(animated: Bool = false) {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = contentFont
        attributes[.foregroundColor] = contentColor
        
        let parag = NSMutableParagraphStyle()
        parag.lineSpacing = contentLineSpace
        parag.firstLineHeadIndent = 22
        attributes[.paragraphStyle] = parag
        
        var text = ""
        var startLocation = 0
        var zanAlpha: CGFloat = 0
        var contentH: CGFloat = 0
        var isFull = false
        
        if names.count > 0 {
            text = "\(names.count)人已鼓舞 | "
            startLocation = text.count
            zanAlpha = 1
            
            for (i, name) in names.enumerated() {
                if i != 0 { text += "、" }
                text += name
            }
            
            contentH = (text as NSString).boundingRect(with: [contentW, 999], options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
            
            // 文本的高度 - 字体高度 > 行间距 -----> 判断为当前超过1行
            let isMoreThanOneLine = (contentH - contentFont.lineHeight) > contentLineSpace
            if !isMoreThanOneLine || contentH < minContentH {
                contentH = minContentH
                parag.lineSpacing = 0
            }
            
            if contentH > maxContentH {
                contentH = maxContentH
                isFull = true
            }
        } else {
            parag.lineSpacing = 0
        }
        
        let attStr = NSMutableAttributedString(string: text, attributes: attributes)
        if isContainsMe, let myName = names.first {
            attStr.addAttributes([.foregroundColor: UIColor.rgb(255, 205, 171)],
                                 range: NSRange(location: startLocation, length: myName.count))
        }
        
        contentLabel.attributedText = attStr
        contentLabel.lineBreakMode = .byTruncatingTail // 得重新设置才能显示省略号
        
        defer {
            if isFull, let bubbleName = self.bubbleName {
                showBubble(bubbleName)
            }
            self.bubbleName = nil
        }
        
        guard contentLabel.frame.size.height != contentH else { return }
        contentLabel.frame.size.height = contentH
        
        let inspireBtnY = contentH == 0 ? (infoView.frame.maxY + 12) : (contentLabel.frame.origin.y + contentH + contentVerMargin + 10)
        let viewH = inspireBtnY + inspireBtn.frame.height + 10
        let update: () -> () = {
            self.zanIcon.alpha = zanAlpha
            self.inspireBtn.frame.origin.y = inspireBtnY
            self.frame = [self.frame.origin.x, self.viewMaxY - viewH, self.frame.width, viewH]
        }
        
        guard animated else {
            update()
            return
        }
        
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: update,
                       completion: nil)
    }
    
    func showBubble(_ name: String) {
        let bubbles = self.bubbles
        
        let bubble = Bubble(name: name)
        bubble.frame.origin = [frame.width - bubble.frame.width, inspireBtn.frame.origin.y - 10 - bubble.frame.height]
        bubble.alpha = 0
        addSubview(bubble)
        self.bubbles.append(bubble)
        
        UIView.animate(withDuration: 0.5) {
            bubble.frame.origin.x = self.frame.width - bubble.frame.width - 7
            bubble.alpha = 1
            bubbles.forEach {
                $0.frame.origin.y -= $0.frame.height + 3
            }
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: []) {
                bubble.alpha = 0
            } completion: { _ in
                self.bubbles.removeAll { $0 == bubble }
                bubble.removeFromSuperview()
            }
        }
    }
    
}

// MARK: - 刷新鼓舞状态+秒数
extension DragonSlayerInspireView {
    
    private func updateInspireText() {
        var text = isInspired ? "已鼓舞" : "鼓舞TA"
        if inspireSecond > 0 {
            text += "（\(inspireSecond)s）"
        }
        inspireLabel.text = text
    }
    
}

// MARK: - 倒计时+隐藏
private extension DragonSlayerInspireView {
    
    func countingDown() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.inspireSecond -= 1
        }
        timer.resume()
        self.timer = timer
    }
    
    func hide() {
        timer?.cancel()
        timer = nil
        
        isUserInteractionEnabled = false
        inspireDone?()
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
}

// MARK: - API

extension DragonSlayerInspireView {
    
    // MARK: 展示
    static func show(withNames names: [String], on view: UIView, inspireDone: (() -> ())?) -> DragonSlayerInspireView {
        let popView = DragonSlayerInspireView(names: names)
        popView.frame.origin = [-popView.frame.width - 10, view.frame.height - popView.frame.height - DiffTabBarH - 57]
        popView.viewMaxY = popView.frame.maxY
        popView.inspireDone = inspireDone
        view.addSubview(popView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: []) {
            popView.frame.origin.x = 10
        } completion: { _ in
            popView.countingDown()
        }
        
        return popView
    }
    
    // MARK: 鼓舞
    func inspireFor(_ name: String) {
        let isMe = name == "你平爷我"
        
        if isContainsMe, isMe {
            return
        }
        
        if isMe {
            names.insert(name, at: 0)
            isContainsMe = true
        } else {
            names.append(name)
            bubbleName = name
        }
        
        updateContent(animated: true)
    }
    
}
