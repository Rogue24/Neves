//
//  PKChallengePopView.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

import UIKit

class PKChallengePopView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var leftUserIcon: UIImageView!
    @IBOutlet weak var leftUserNameLabel: UILabel!
    @IBOutlet weak var leftUserLabelContainer: UIView!
    @IBOutlet weak var leftSociatyLabel: UILabel!
    
    @IBOutlet weak var rightUserIcon: UIImageView!
    @IBOutlet weak var rightUserNameLabel: UILabel!
    @IBOutlet weak var rightUserLabelContainer: UIView!
    @IBOutlet weak var rightSociatyLabel: UILabel!
    
    @IBOutlet weak var pkAnimContainer: UIView!
    @IBOutlet weak var cancelBtn: NoHighlightButton!
    @IBOutlet weak var closeBtn: NoHighlightButton!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftUserIcon.layer.cornerRadius = 32.5
        leftUserIcon.layer.masksToBounds = true
        
        rightUserIcon.layer.cornerRadius = 32.5
        rightUserIcon.layer.masksToBounds = true
        
        cancelBtn.layer.borderColor = UIColor.white.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.cornerRadius = 14
        cancelBtn.layer.masksToBounds = true
        
        closeBtn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        closeBtn.layer.cornerRadius = 8
        closeBtn.layer.masksToBounds = true
        closeBtn.layoutSubviewsHandler = { btn in
            guard let imageView = btn.imageView,
                  let titleLabel = btn.titleLabel else { return }
            var imageFrame = imageView.frame
            var titleFrame = titleLabel.frame
            let space: CGFloat = 0
            let totalW: CGFloat = imageFrame.width + space + titleFrame.width
            let totalMaxX: CGFloat = HalfDiffValue(btn.frame.width, totalW) + totalW
            imageFrame.origin.x = totalMaxX - imageFrame.width
            titleFrame.origin.x = imageFrame.origin.x - titleFrame.width - space
            imageView.frame = imageFrame
            titleLabel.frame = titleFrame
        }
    }
    
    @discardableResult
    static func show(on superview: UIView) -> PKChallengePopView {
        let popView = PKChallengePopView.loadFromNib()
        popView.contentViewBottomConstraint.constant = -popView.contentViewHeightConstraint.constant
        superview.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        superview.layoutIfNeeded()
        popView.show()
        return popView
    }
    
    func show() {
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    @IBAction func close() {
        contentViewBottomConstraint.constant = -contentViewHeightConstraint.constant
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
