//
//  FireworkRulePopView.swift
//  Neves_Example
//
//  Created by aa on 2020/10/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class FireworkRulePopView: UIView {

    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    var closeHandle: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgImgView.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
        bgImgView.alpha = 0
        
        ruleLabel.transform = bgImgView.transform
        ruleLabel.alpha = 0
        
        closeBtn.transform = CGAffineTransform.init(translationX: 0, y: 40)
        closeBtn.alpha = 0
        
        layoutIfNeeded()
    }
    
    deinit {
        JPrint("老子死了吗")
    }
    
    class func show(onView view: UIView? = nil, _ showHandle: (() -> Void)?, closeHandle: (() -> Void)?) {
        guard let superview = view ?? UIApplication.shared.keyWindow else { return }
        
        let popView = Self.loadFromNib()
        superview.addSubview(popView)
        popView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        superview.layoutIfNeeded()
        
        popView.closeHandle = closeHandle
        popView.show(showHandle)
    }
    
    func show(_ animHandle: (() -> Void)?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
            self.bgImgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.bgImgView.alpha = 1
            
            self.ruleLabel.transform = self.bgImgView.transform
            self.ruleLabel.alpha = 1
            
            self.closeBtn.transform = CGAffineTransform.init(translationX: 0, y: 0)
            self.closeBtn.alpha = 1
            
            self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.5).cgColor
            
            animHandle?()
        }, completion: nil)
    }
    
    @IBAction func close() {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.bgImgView.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
            self.bgImgView.alpha = 0
            
            self.ruleLabel.transform = self.bgImgView.transform
            self.ruleLabel.alpha = 0
            
            self.closeBtn.transform = CGAffineTransform.init(translationX: 0, y: 40)
            self.closeBtn.alpha = 0
            
            self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
            
            self.closeHandle?()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
