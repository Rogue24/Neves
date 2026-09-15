//
//  MedalRankingListBgView.swift
//  Neves
//
//  Created by aa on 2023/7/4.
//

import UIKit

class MedalRankingListBgView: UIView {
    private let baseY: CGFloat
    
    init(_ showType: MedalRanking.ShowType) {
        let headerH = MedalRankingHeaderView.size(showType).height
        self.baseY = showType == .fullScreen ? (headerH - 16.px) : headerH
        
        super.init(frame: CGRect(origin: [0, self.baseY], size: Env.screenSize))
        isUserInteractionEnabled = false
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16.px
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateOffsetY(_ offsetY: CGFloat) {
        frame.origin.y = offsetY > baseY ? offsetY : baseY
    }
}
