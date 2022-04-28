//
//  PKChallengeFoldView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

import UIKit

class PKChallengeFoldView: UIView {
    @IBOutlet weak var leftUserIcon: UIImageView!
    @IBOutlet weak var rightUserIcon: UIImageView!
    @IBOutlet weak var pkAnimContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftUserIcon.layer.cornerRadius = 14
        leftUserIcon.layer.masksToBounds = true
        
        rightUserIcon.layer.cornerRadius = 14
        rightUserIcon.layer.masksToBounds = true
    }
    
    @discardableResult
    static func show(on superview: UIView) -> PKChallengeFoldView {
        let foldView = PKChallengeFoldView.loadFromNib()
        foldView.alpha = 0
        
        superview.addSubview(foldView)
        foldView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 105, height: 45))
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-(DiffTabBarH + 50))
        }
        superview.layoutIfNeeded()
        
        foldView.show()
        return foldView
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
