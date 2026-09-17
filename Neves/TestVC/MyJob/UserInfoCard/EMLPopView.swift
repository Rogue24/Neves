//
//  EMLPopView.swift
//  Falla
//
//  Created by aa on 2024/9/4.
//

import UIKit
import SnapKit

@objcMembers
class EMLPopView: UIView {
    enum BgEffect {
        case color(_ c: UIColor)
        case blur(_ e: UIVisualEffect)
    }
    
    private let bgEffect: BgEffect
    
    private var blurView: UIVisualEffectView?
    
    private let closeBtn = NoHighlightButton(type: .custom)
    
    private(set) var card: EMLPopCard
    
    var didClose: (() -> Void)? = nil
    
    required init(card: EMLPopCard, bgEffect: BgEffect) {
        self.card = card
        self.bgEffect = bgEffect
        super.init(frame: Env.screenBounds)
        layer.backgroundColor = .rgb(0, 0, 0, a: 0)
        
        switch bgEffect {
        case .color: break
        case .blur:
            let blurView = UIVisualEffectView(effect: nil)
            blurView.frame = bounds
            blurView.isUserInteractionEnabled = false
            addSubview(blurView)
            self.blurView = blurView
        }
        
        closeBtn.frame = bounds
        closeBtn.addTarget(self, action: #selector(bgCloseAction), for: .touchUpInside)
        addSubview(closeBtn)
        
        card.putOn(self)
        
        card.closeHandler = { [weak self] isSpring in
            self?.close(isSpring: isSpring)
        }
        
        card.switchCardHandler = { [weak self] _, newCard, delay in
            guard let self else { return }
            self.switchCard(newCard, delay: delay)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        EML_DebugLog("EMLPopView 死！", String(format: "%p", self))
    }
    
    @discardableResult
    static func show(card: EMLPopCard, bgColor: UIColor, on view: UIView, completion: (() -> Void)? = nil) -> Self {
        show(card: card, bgEffect: .color(bgColor), on: view, completion: completion)
    }
    
    @discardableResult
    static func show(card: EMLPopCard, bgBlur: UIVisualEffect, on view: UIView, completion: (() -> Void)? = nil) -> Self {
        show(card: card, bgEffect: .blur(bgBlur), on: view, completion: completion)
    }
    
    @discardableResult
    static func show(card: EMLPopCard, bgEffect: BgEffect = .color(.rgb(0, 0, 0, a: 0.5)), on view: UIView, completion: (() -> Void)? = nil) -> Self {
        let popView = Self.init(card: card, bgEffect: bgEffect)
        popView.show(on: view, completion: completion)
        return popView
    }
    
    func show(on view: UIView, completion: (() -> Void)? = nil) {
        view.endEditing(true) // 关闭键盘
        view.addSubview(self)
        layoutIfNeeded()
        
        card.preShow()
        
        Asyncs.main {
            self.show(completion: completion)
        }
    }
    
    private func show(completion: (() -> Void)?) {
        isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            switch self.bgEffect {
            case let .color(c):
                self.layer.backgroundColor = c.cgColor
            case let .blur(e):
                self.blurView?.effect = e
            }
        }
        
        card.show(completion: completion)
    }
    
    func switchCard(_ newCard: EMLPopCard, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        let oldCard = self.card
        
        newCard.closeHandler = oldCard.closeHandler
        newCard.switchCardHandler = oldCard.switchCardHandler
        
        oldCard.closeHandler = nil
        oldCard.switchCardHandler = nil
        
        newCard.putOn(self)
        self.card = newCard
        
        superview?.endEditing(true) // 关闭键盘
        superview?.addSubview(self)
        layoutIfNeeded()
        
        newCard.preShow()
        Asyncs.main {
            _ = oldCard.close { [weak oldCard] in
                oldCard?.removeFromSuperview()
            }
            
            if delay > 0 {
                Asyncs.mainDelay(delay) {
                    newCard.show(completion: completion)
                }
            } else {
                newCard.show(completion: completion)
            }
        }
    }
    
    func close(isSpring: Bool) {
        isUserInteractionEnabled = false
        
        var cardDone = false
        var mineDone = false
        
        let duration: TimeInterval
        if isSpring {
            duration = card.springClose {
                cardDone = true
                self.closeDone(cardDone, mineDone)
            }
        } else {
            duration = card.close {
                cardDone = true
                self.closeDone(cardDone, mineDone)
            }
        }
        
        UIView.animate(withDuration: duration) {
            switch self.bgEffect {
            case .color:
                self.layer.backgroundColor = .rgb(0, 0, 0, a: 0)
            case .blur:
                self.blurView?.effect = nil
            }
        } completion: { _ in
            guard !self.isUserInteractionEnabled else { return }
            mineDone = true
            self.closeDone(cardDone, mineDone)
        }
    }
    
    private func closeDone(_ cardDone: Bool, _ mineDone: Bool) {
        guard cardDone, mineDone else { return }
        removeFromSuperview()
        didClose?()
    }
    
    @objc private func bgCloseAction() {
        switch card.bgCloseType {
        case .unable:
            return
        case .normal:
            close(isSpring: false)
        case .spring:
            close(isSpring: true)
        case let .custom(action):
            action()
        }
    }
}

// MARK: - For OC
extension EMLPopView {
    @objc static func showHofIdentityCard(models: [EMLHofIdentityModel]) {
        guard models.count > 0, let window = UIApplication.fa_window else { return }
        guard let idCard = EMLHofIdentityCard(models: models) else { return }
        show(card: idCard, on: window)
    }
    
    @objc static func showHighlightGiftCard(models: [HighlightGiftModel]) {
        guard models.count > 0, let window = UIApplication.fa_window else { return }
        guard let giftCard = HighlightGiftCard(models: models) else { return }
        show(card: giftCard, on: window)
    }
    
    // 告白礼物
    @objc static func showConfessionCard(models: [ConfessionGiftModel]) {
        guard models.count > 0, let window = UIApplication.fa_window else { return }
        guard let giftCard = ConfessionCard(models: models) else { return }
        show(card: giftCard, on: window)
    }
    
    @objc static func showNotifiSettingCardIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (status, err) in
            guard !status else { return }
            
            // 当前时间的时间戳
            let nowTimeInt = Int(Date().timeIntervalSince1970)
            
            guard let saveDict = UserDefaults.standard.fa.dictionary(forKey: .NotifiSettingReminderTime),
                  let saveNumber = saveDict["number"] as? Int,
                  let saveTimeInt = saveDict["timeStamp"] as? Int
            else {
                Asyncs.main {
                    guard let window = UIApplication.fa_window else { return }
                    let nsCard = NotifiSettingCard(reminderDic: ["number": 3, "timeStamp": nowTimeInt])
                    show(card: nsCard, on: window)
                }
                return
            }
            
//            let isTest = JKREnvironmentConfigManager.isTestEnvironment()
            let leastTimeInt: Int
            switch saveNumber {
            case 3:
                leastTimeInt = 259200
//                leastTimeInt = isTest ? 180 : 259200
            case 7:
                leastTimeInt = 604800
//                leastTimeInt = isTest ? 420 : 604800
            default:
                return
            }
            
            let diffTimeInt = nowTimeInt - saveTimeInt
            guard diffTimeInt > leastTimeInt else { return }
            
            Asyncs.main {
                guard let window = UIApplication.fa_window else { return }
                let nsCard = NotifiSettingCard(reminderDic: ["number": 7, "timeStamp": nowTimeInt])
                show(card: nsCard, on: window)
            }
        }
    }
    
    @objc static func showUserHomePageGuideCard() {
        guard let window = UIApplication.fa_window else { return }
        let card = UserHomePageGuideCard()
        show(card: card, bgColor: .clear, on: window)
    }
    
    @objc static func showNobilityOpenedSuccessfullyCard(_ nobilityUserInfo: JKRNobilityUserInfo, on view: UIView?) {
        guard let view = view ?? UIApplication.fa_window else { return }
        let card = NobilityOpenedSuccessfullyCard(nobilityUserInfo)
        show(card: card, bgBlur: UIBlurEffect(style: .dark), on: view)
    }
}
