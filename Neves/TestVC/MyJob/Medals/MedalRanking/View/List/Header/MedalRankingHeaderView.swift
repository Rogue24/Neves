//
//  MedalRankingHeaderView.swift
//  Falla
//
//  Created by aa on 2023/6/30.
//

import UIKit

class MedalRankingHeaderView: UIView {
    static func size(_ showType: MedalRanking.ShowType) -> CGSize {
        switch showType {
        case .fullScreen: return [Env.screenWidth, 365.px + Env.safeAreaInsets.top]
        case .pop: return [Env.screenWidth, 267.px]
        }
    }
     
    static func topViewY(_ showType: MedalRanking.ShowType, _ listType: MedalRanking.ListType) -> CGFloat {
        switch showType {
        case .fullScreen:
            switch listType {
            case .quarterly:
                return Env.safeAreaInsets.top + 44 + 8.5.px + 36.px + 43.px
            case .overall:
                return Env.safeAreaInsets.top + 44 + 8.5.px + 36.px + 35.px
            }
            
        case .pop:
            switch listType {
            case .quarterly:
                return 43.px
            case .overall:
                return 16.px
            }
        }
    }
    
    private let showType: MedalRanking.ShowType
    private var listType: MedalRanking.ListType
    
    private let bgImgView = UIImageView()
    private var bgImgH: CGFloat = 0
    
    private let topView: MedalRankingTopView
    private var topViewBaseY: CGFloat = 0
    
    var helpBtn: NoHighlightButton? = nil
    
    private var offsetY: CGFloat = 0
    
    init(_ showType: MedalRanking.ShowType, _ listType: MedalRanking.ListType) {
        self.showType = showType
        self.listType = listType
        self.topView = MedalRankingTopView(showType)
        
        super.init(frame: CGRect(origin: .zero, size: MedalRankingHeaderView.size(showType)))
        clipsToBounds = false
        
        if showType == .fullScreen {
            bgImgView.image = UIImage(named: "medal_ranking_bg1")
        } else {
            bgImgView.image = UIImage(named: "medal_ranking_bg2")
        }
//        if let image = bgImgView.image {
//            bgImgH = bounds.width * (image.size.height / image.size.width)
//        }
        if bgImgH < bounds.height {
            bgImgH = bounds.height
        }
        bgImgView.frame = [0, 0, bounds.width, bgImgH]
        bgImgView.contentMode = .scaleAspectFill
        addSubview(bgImgView)
        
        topViewBaseY = Self.topViewY(showType, listType)
        topView.frame.origin.y = topViewBaseY
        addSubview(topView)
        
        if showType == .pop {
            let helpBtn = NoHighlightButton(type: .custom)
            helpBtn.setImage(UIImage(named: "medal_ranking_help_gray")?.withRenderingMode(.alwaysOriginal), for: .normal)
            helpBtn.rtl_refWidth = bounds.width
            helpBtn.rtl_frame = [bounds.width - 48.px, 0, 48.px, 48.px]
            addSubview(helpBtn)
            self.helpBtn = helpBtn
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MedalRankingHeaderView {
    func updateOffsetY(_ offsetY: CGFloat) {
        self.offsetY = offsetY
        
        if offsetY < 0 {
            let newH = bounds.height - offsetY
            bgImgView.frame = [0, offsetY, bounds.width, newH > bgImgH ? newH : bgImgH]
        } else {
            bgImgView.frame = [0, 0, bounds.width, bgImgH]
        }
        
        updateTopViewY()
    }
    
    func updateTopViewY() {
        if offsetY < -MJRefreshHeaderHeight {
            let diffY = (offsetY + MJRefreshHeaderHeight) * 0.2
            topView.frame.origin.y = topViewBaseY + diffY
            helpBtn?.frame.origin.y = diffY
        } else {
            topView.frame.origin.y = topViewBaseY
            helpBtn?.frame.origin.y = 0
        }
    }
}

extension MedalRankingHeaderView {
    func updateData(_ listVM: MedalRankingListViewModel?) {
        listType = listVM?.type ?? .quarterly
        topView.updateData(listVM)
        
        Asyncs.mainDelay(0.1) {
            UIView.animate(withDuration: 0.45,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0,
                           options: []) {
                self.topViewBaseY = Self.topViewY(self.showType, self.listType)
                self.updateTopViewY()
            }
        }
    }
}
