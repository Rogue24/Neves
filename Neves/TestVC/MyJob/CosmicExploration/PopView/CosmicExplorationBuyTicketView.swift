//
//  CosmicExplorationBuyTicketView.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

class CosmicExplorationBuyTicketView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeBtn: NoHighlightButton!
    
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var rechargeLabel: UILabel!
    @IBOutlet weak var rechargeBtn: UIButton!
    
    @IBOutlet weak var leftGiftIcon: UIImageView!
    @IBOutlet weak var leftGiftLabel: UILabel!
    @IBOutlet weak var rightGiftIcon: UIImageView!
    @IBOutlet weak var rightGiftLabel: UILabel!
    
    @IBOutlet weak var explainLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var count1View: UIView!
    @IBOutlet weak var count1SelImgView: UIImageView!
    @IBOutlet weak var count1Label: UILabel!
    
    @IBOutlet weak var count2View: UIView!
    @IBOutlet weak var count2SelImgView: UIImageView!
    @IBOutlet weak var count2Label: UILabel!
    
    @IBOutlet weak var count3View: UIView!
    @IBOutlet weak var count3SelImgView: UIImageView!
    @IBOutlet weak var count3Label: UILabel!
    
    @IBOutlet weak var count4View: UIView!
    @IBOutlet weak var count4TextField: UITextField!
    
    @IBOutlet weak var confirmBtn: NoHighlightButton!
    @IBOutlet weak var bottomLabel: UILabel!
    
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleImgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rechargeViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rechargeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rechargeViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var coinIconLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var coinIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coinIconRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rechargeLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rechargeLabelRightConstraint: NSLayoutConstraint!
    
    @IBOutlet var giftBgIconWidthConstraints: [NSLayoutConstraint]!
    @IBOutlet var giftIconWidthConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var giftLabelTopConstraints: [NSLayoutConstraint]!
    @IBOutlet var giftLabelHeightConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var zengIconLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var zengIconTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var midIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var midIconLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var midIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var midIconRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var explainLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var explainLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var count1ViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var confirmBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmBtnWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFont()
        setupConstraints()
        setupLayouts()
        setupEvents()
        selectedIndex = 1
        chooseCount = 1
    }
    
    // MARK: - 点击空白关闭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 停止响应事件的回传
//        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        if contentView.frame.contains(point) {
            endEditing(true)
        } else {
            close()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var keyboardFrame: CGRect = .zero
    
    var selectedIndex = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            updateCountViews()
        }
    }
    
    var chooseCount = 0 {
        didSet {
            guard chooseCount != oldValue else { return }
            updateChooseCount()
        }
    }
}

extension CosmicExplorationBuyTicketView {
    func setupFont() {
        coinLabel.font = .systemFont(ofSize: 13.px)
        rechargeLabel.font = .systemFont(ofSize: 11.px)
        leftGiftLabel.font = .systemFont(ofSize: 11.px)
        rightGiftLabel.font = .systemFont(ofSize: 11.px)
        explainLabel.font = .systemFont(ofSize: 11.px)
        count1Label.font = .systemFont(ofSize: 15.px)
        count2Label.font = .systemFont(ofSize: 15.px)
        count3Label.font = .systemFont(ofSize: 15.px)
        count4TextField.font = .systemFont(ofSize: 15.px)
        confirmBtn.titleLabel?.font = .boldSystemFont(ofSize: 15.px)
        bottomLabel.font = .systemFont(ofSize: 10.px)
    }
    
    func setupConstraints() {
        contentViewBottomConstraint.constant = -PortraitScreenWidth.px
        
        titleImgViewTopConstraint.constant = 5.px
        titleImgViewWidthConstraint.constant = 154.px
        closeBtnWidthConstraint.constant = 30.px
        
        rechargeViewTopConstraint.constant = 8.px
        rechargeViewHeightConstraint.constant = 29.px
        rechargeViewBottomConstraint.constant = 10.px
        
        coinIconLeftConstraint.constant = 24.5.px
        coinIconWidthConstraint.constant = 15.px
        coinIconRightConstraint.constant = 3.px
        
        rechargeLabelLeftConstraint.constant = 5.px
        rechargeLabelRightConstraint.constant = 2.px
        
        giftBgIconWidthConstraints.forEach { $0.constant = 85.px }
        giftIconWidthConstraints.forEach { $0.constant = 60.px }
        giftLabelTopConstraints.forEach { $0.constant = 10.px }
        giftLabelHeightConstraints.forEach { $0.constant = 14.px }
        
        zengIconLeftConstraint.constant = 6.px
        zengIconTopConstraint.constant = 6.px
        
        midIconTopConstraint.constant = 36.5.px
        midIconLeftConstraint.constant = 7.5.px
        midIconWidthConstraint.constant = 30.px
        midIconRightConstraint.constant = 7.5.px
        
        explainLabelTopConstraint.constant = 13.px
        explainLabelBottomConstraint.constant = 10.px
        
        count1ViewWidthConstraint.constant = 60.px
        
        confirmBtnTopConstraint.constant = 10.px
        confirmBtnWidthConstraint.constant = 295.px
    }
    
    func setupLayouts() {
        stackView.spacing = 15.px
        count1View.layer.borderColor = UIColor.rgb(54, 58, 97).cgColor
        count1View.layer.borderWidth = 1
        count2View.layer.borderColor = UIColor.rgb(54, 58, 97).cgColor
        count2View.layer.borderWidth = 1
        count3View.layer.borderColor = UIColor.rgb(54, 58, 97).cgColor
        count3View.layer.borderWidth = 1
        count4View.layer.borderColor = UIColor.rgb(54, 58, 97).cgColor
        count4View.layer.borderWidth = 1
        confirmBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4.px, right: 0)
    }
    
    func setupEvents() {
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        rechargeBtn.addTarget(self, action: #selector(goRechargeAction), for: .touchUpInside)
        count1View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countViewDidClick(_:))))
        count2View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countViewDidClick(_:))))
        count3View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countViewDidClick(_:))))
        confirmBtn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        count4TextField.delegate = self
        count4TextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension CosmicExplorationBuyTicketView {
    
    @objc func closeAction() {
        close()
    }
    
    @objc func goRechargeAction() {
        JPrint("去充值")
        endEditing(true)
    }
    
    @objc func countViewDidClick(_ tapGR: UITapGestureRecognizer) {
        JPrint("?")
        guard let tapView = tapGR.view else { return }
        
        switch tapView {
        case count1View:
            selectedIndex = 1
            
        case count2View:
            selectedIndex = 2
            
        case count3View:
            selectedIndex = 3
            
        default:
            break
        }
    }
    
    @objc func confirmAction() {
        JPrint("确定")
    }
    
}


extension CosmicExplorationBuyTicketView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Asyncs.mainDelay(0.2) {
            guard self.count4TextField.isFirstResponder else { return }
            self.selectedIndex = 4
        }
        
        guard let text = textField.text, let count = Int(text), count > 0 else {
            textField.text = ""
            return
        }
        
        // 光标挪到最后（不能在同一runloop下修改光标位置）
        Asyncs.main {
            guard let start = textField.position(from: textField.beginningOfDocument, offset: text.count),
                  let end = textField.position(from: textField.beginningOfDocument, offset: text.count)
            else { return }
            textField.selectedTextRange = textField.textRange(from: start, to: end)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        Asyncs.mainDelay(0.2) {
            guard !self.count4TextField.isFirstResponder, self.selectedIndex == 4 else { return }
            self.selectedIndex = 0
        }
        
        if let text = textField.text, let count = Int(text), count > 0 {
            return
        }
        
        textField.text = "其他"
    }
        
    @objc func textFieldEditingChanged() {
        JPrint(count4TextField.text ?? "")
        
        if let text = count4TextField.text, let count = Int(text), count > 0 {
            chooseCount = count
            return
        }
        
        count4TextField.text = ""
        chooseCount = 0
    }
}

extension CosmicExplorationBuyTicketView {
    @objc func keyboardWillChangeFrame(_ noti: Notification) {
        guard count4TextField.isFirstResponder else { return }

        guard let userInfo = noti.userInfo else { return }
//        JPrint("keyboardWillChangeFrame ---", userInfo)

        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        guard keyboardFrame != self.keyboardFrame else { return }
        self.keyboardFrame = keyboardFrame
        
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        contentViewBottomConstraint.constant = PortraitScreenHeight - keyboardFrame.origin.y
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
}

extension CosmicExplorationBuyTicketView {
    func updateCountViews() {
        let norTextColor = UIColor.rgb(182, 216, 249)
        let selTextColor = UIColor.white
        
        var count1SelImgViewIsHidden = true
        var count1LabelColor = norTextColor
        
        var count2SelImgViewIsHidden = true
        var count2LabelColor = norTextColor
        
        var count3SelImgViewIsHidden = true
        var count3LabelColor = norTextColor
        
        var count4BorderColor = UIColor.rgb(54, 58, 97)
        var count4TextColor = norTextColor
        
        switch selectedIndex {
        case 1:
            count1SelImgViewIsHidden = false
            count1LabelColor = selTextColor
            chooseCount = 1
            
        case 2:
            count2SelImgViewIsHidden = false
            count2LabelColor = selTextColor
            chooseCount = 10
            
        case 3:
            count3SelImgViewIsHidden = false
            count3LabelColor = selTextColor
            chooseCount = 100
            
        case 4:
            count4BorderColor = UIColor.rgb(245, 104, 91)
            count4TextColor = selTextColor
            chooseCount = Int(count4TextField.text ?? "") ?? 0
            
        default:
            chooseCount = 0
        }
        
        count1SelImgView.isHidden = count1SelImgViewIsHidden
        count1Label.textColor = count1LabelColor
        
        count2SelImgView.isHidden = count2SelImgViewIsHidden
        count2Label.textColor = count2LabelColor
        
        count3SelImgView.isHidden = count3SelImgViewIsHidden
        count3Label.textColor = count3LabelColor
        
        count4View.layer.borderColor = count4BorderColor.cgColor
        count4TextField.textColor = count4TextColor
    }
    
    func updateChooseCount() {
        let ticketCount = chooseCount * 100
        
        let confirmText = "确定购买" + (ticketCount > 0 ? "（\(ticketCount)金币）" : "")
        confirmBtn.setTitle(confirmText, for: .normal)
        
        bottomLabel.text = ticketCount > 0 ? "预计获赠\(ticketCount)星际船票" : ""
    }
}

extension CosmicExplorationBuyTicketView {
    @discardableResult
    static func show(on view: UIView) -> CosmicExplorationBuyTicketView {
        let buyTicketView = CosmicExplorationBuyTicketView.loadFromNib()
        buyTicketView.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        buyTicketView.frame = PortraitScreenBounds
        buyTicketView.layoutIfNeeded()
        view.addSubview(buyTicketView)
        
        // TODO: 临时做法
        Asyncs.main {
            buyTicketView.show()
        }
        
        return buyTicketView
    }
    
    func show() {
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.4).cgColor
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    @objc func close() {
        NotificationCenter.default.removeObserver(self)
        endEditing(true)
        
        contentViewBottomConstraint.constant = -PortraitScreenWidth.px
        UIView.animate(withDuration: 0.3) {
            self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

