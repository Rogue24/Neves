//
//  PKProgressPlayhouseInfoView.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

import UIKit

class PKProgressPlayhouseInfoView: UIView {
    
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var rightTitleLabel: UILabel!
    
    @IBOutlet weak var bottomTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        
        leftIcon.layer.borderWidth = 1
        leftIcon.layer.borderColor = UIColor.white.cgColor
        leftIcon.layer.cornerRadius = 3.6
        leftIcon.layer.masksToBounds = true
        
        rightIcon.layer.borderWidth = 1
        rightIcon.layer.borderColor = UIColor.white.cgColor
        rightIcon.layer.cornerRadius = 3.6
        rightIcon.layer.masksToBounds = true
        
        bottomTitleLabel.isHidden = true
    }
}
