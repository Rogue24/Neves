//
//  EMLPopCard.swift
//  Falla
//
//  Created by aa on 2024/9/4.
//

import UIKit

class EMLPopCard: UIView {
    enum ShowStyle {
        case scaleXY(_ xy: CGFloat = 0.75)
        case translationY(_ ty: CGFloat = 50.px)
        case sheet(_ showInset: CGFloat = 0, _ closeInset: CGFloat = 10)
    }
    var showStyle: ShowStyle = .scaleXY()
    
    enum BgCloseType {
        case unable
        case normal
        case spring
        case custom(_ action: () -> ())
    }
    var bgCloseType: BgCloseType = .normal
    
    var closeHandler: ((_ isSpring: Bool) -> Void)?
    var switchCardHandler: ((_ oldCard: EMLPopCard, _ newCard: EMLPopCard, _ delay: TimeInterval) -> Void)?
    
    func putOn(_ container: UIView) {
        container.addSubview(self)
    }
    
    func preShow() {
        switch showStyle {
        case let .scaleXY(xy):
            transform = CGAffineTransformMakeScale(xy, xy)
            alpha = 0
            
        case let .translationY(ty):
            transform = CGAffineTransform(translationX: 0, y: ty)
            alpha = 0
            
        case let .sheet(_, inset):
            frame.origin.y = (superview?.bounds.height ?? Env.screenHeight) + inset
        }
    }
    
    func show(completion: (() -> Void)? = nil) {
        isUserInteractionEnabled = true
        
        switch showStyle {
        case .scaleXY:
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.69, initialSpringVelocity: 1) {
                self.transform = CGAffineTransformIdentity
                self.alpha = 1
            } completion: { _ in
                guard self.isUserInteractionEnabled else { return }
                completion?()
            }
            
        case .translationY:
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: []) {
                self.transform = CGAffineTransformIdentity
                self.alpha = 1
            } completion: { _ in
                guard self.isUserInteractionEnabled else { return }
                completion?()
            }
            
        case let .sheet(inset, _):
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
                self.frame.origin.y = (self.superview?.bounds.height ?? Env.screenHeight) - self.frame.height - inset
            } completion: { _ in
                guard self.isUserInteractionEnabled else { return }
                completion?()
            }
        }
    }
    
    func close(completion: (() -> Void)? = nil) -> TimeInterval {
        isUserInteractionEnabled = false
        
        let duration: TimeInterval
        switch showStyle {
        case let .scaleXY(xy):
            duration = 0.25
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransformMakeScale(xy, xy)
                self.alpha = 0
            } completion: { _ in
                guard !self.isUserInteractionEnabled else { return }
                completion?()
            }
            
        case let .translationY(ty):
            duration = 0.38
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransform(translationX: 0, y: ty)
                self.alpha = 0
            } completion: { _ in
                guard !self.isUserInteractionEnabled else { return }
                completion?()
            }
            
        case let .sheet(_, inset):
            duration = 0.4
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
                self.frame.origin.y = (self.superview?.bounds.height ?? Env.screenHeight) + inset
            } completion: { _ in
                guard !self.isUserInteractionEnabled else { return }
                completion?()
            }
        }
        
        return duration
    }
    
    func springClose(completion: (() -> Void)? = nil) -> TimeInterval {
        switch showStyle {
        case .sheet:
            EML_DebugLog("showStyle为sheet，不支持springClose！！！")
            return close(completion: completion)
        default:
            break
        }
        
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.11) {
            self.transform = CGAffineTransformMakeScale(1.03, 1.03)
        } completion: { _ in
            guard !self.isUserInteractionEnabled else { return }
            UIView.animate(withDuration: 0.24) {
                self.transform = CGAffineTransformMakeScale(0.75, 0.75)
                self.alpha = 0
            } completion: { _ in
                guard !self.isUserInteractionEnabled else { return }
                completion?()
            }
        }
        
        return 0.35
    }
}
