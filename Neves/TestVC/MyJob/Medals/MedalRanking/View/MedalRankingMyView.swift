//
//  MedalRankingMyView.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//

import UIKit

class MedalRankingMyView: GradientView {
    static let size: CGSize = [Env.screenWidth, 70.px + Env.safeAreaInsets.bottom]
    
    private let userInfoView: MedalRankingUserInfoView
    
    init(_ showType: MedalRanking.ShowType) {
        let bgColors: [UIColor]
        switch showType {
        case .fullScreen:
            userInfoView = MedalRankingUserInfoView(nameColor: .white, scoreColor: .white)
            bgColors = [.rgb(66, 60, 107), .rgb(110, 96, 157)]
        case .pop:
            userInfoView = MedalRankingUserInfoView(nameColor: .rgb(51, 51, 51), scoreColor: .rgb(255, 180, 0))
            bgColors = [.rgb(244, 241, 255), .rgb(219, 226, 255)]
        }
        
        super.init(frame: CGRect(origin: .zero, size: MedalRankingMyView.size))
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 12.px
        
        if Env.isRTL {
            startPoint = [1, 0.5]
            endPoint = [0, 0.5]
        } else {
            startPoint = [0, 0.5]
            endPoint = [1, 0.5]
        }
        colors = bgColors
        
        userInfoView.frame.origin.y = HalfDiffValue(70.px, userInfoView.frame.height)
        addSubview(userInfoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(_ userVM: MedalRankingUserViewModel?) {
        userInfoView.willUpdateData(userVM)
//        Asyncs.mainDelay(0.1) {
//            UIView.animate(withDuration: 0.45,
//                           delay: 0,
//                           usingSpringWithDamping: 0.9,
//                           initialSpringVelocity: 0,
//                           options: []) {
//                self.userInfoView.updateData(userVM)
//            }
//        }
        userInfoView.updateData(userVM)
    }
}
