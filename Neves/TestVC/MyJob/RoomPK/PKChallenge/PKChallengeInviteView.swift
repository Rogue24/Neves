//
//  PKChallengeInviteView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

import UIKit

class PKChallengeInviteView: UIView {
    @IBOutlet weak var pkAnimContainer: UIView!
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLabelContainer: UIView!
    @IBOutlet weak var sociatyLabel: UILabel!
    
    @IBOutlet weak var acceptBgView: GradientView!
    @IBOutlet weak var acceptBtn: NoHighlightButton!
    @IBOutlet weak var refuseBtn: NoHighlightButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userIcon.layer.cornerRadius = 27.5
        userIcon.layer.masksToBounds = true
        
        acceptBgView.layer.cornerRadius = 12
        acceptBgView.layer.masksToBounds = true
        acceptBgView
            .startPoint(0, 0.5)
            .endPoint(1, 0.5)
            .colors(.rgb(14, 178, 241), .rgb(110, 227, 255))
        
        refuseBtn.layer.cornerRadius = 12
        refuseBtn.layer.masksToBounds = true
    }
    
    @discardableResult
    static func show(on superview: UIView) -> PKChallengeInviteView {
        let inviteView = PKChallengeInviteView.loadFromNib()
        
        superview.addSubview(inviteView)
        inviteView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 230, height: 135))
            make.left.equalToSuperview().offset(-230)
            make.centerY.equalToSuperview()
        }
        superview.layoutIfNeeded()
        
        inviteView.show()
        return inviteView
    }
    
    func show() {
        snp.updateConstraints { make in
            make.left.equalToSuperview()
        }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: []) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in }
    }
    
    func hide() {
        snp.updateConstraints { make in
            make.left.equalToSuperview().offset(-230)
        }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
