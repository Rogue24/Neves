//
//  MedalRankingUserCell.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//

import UIKit

class MedalRankingUserCell: UICollectionViewCell {
    static let size: CGSize = [Env.screenWidth, 80.px]
    
    private let userInfoView = MedalRankingUserInfoView(nameColor: .rgb(51, 51, 51), scoreColor: .rgb(255, 180, 0))
    private let line = CALayer()
    
    var isLast: Bool = false {
        didSet {
            guard isLast != oldValue else { return }
            line.isHidden = isLast
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        userInfoView.frame.origin.y = HalfDiffValue(Self.size.height, MedalRankingUserInfoView.size.height)
        contentView.addSubview(userInfoView)
        
        line.rtl_refWidth = Self.size.width
        line.rtl_frame = [16.px, Self.size.height - 0.5, Self.size.width - 16.px, 0.5]
        line.backgroundColor = .rgb(241, 241, 241)
        contentView.layer.addSublayer(line)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(_ userVM: MedalRankingUserViewModel) {
        userInfoView.willUpdateData(userVM)
        userInfoView.updateData(userVM)
    }
}
