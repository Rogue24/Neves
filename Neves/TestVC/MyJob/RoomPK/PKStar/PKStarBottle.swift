//
//  PKStarBottle.swift
//  Neves
//
//  Created by aa on 2022/4/29.
//

import UIKit

//pk_flyingstar    pk_fm_star  pk_star_active1~6  pk_star_grey1~6

class PKStarBottle: UIView {
    
    let bottleImgView = UIImageView(image: UIImage(named: "pk_fullbottle"))
    let starImgViews: [UIImageView] = Array(1...6).reversed().map {
        UIImageView(image: UIImage(named: "pk_star_active\($0)"))
    }
    
    init() {
        super.init(frame: [0, 0, 50, 50])
        
        bottleImgView.size = size
        addSubview(bottleImgView)
        
        starImgViews.forEach {
            $0.size = size
            addSubview($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareLaunch() {
        starImgViews.forEach { $0.alpha = 1 }
    }
    
}
