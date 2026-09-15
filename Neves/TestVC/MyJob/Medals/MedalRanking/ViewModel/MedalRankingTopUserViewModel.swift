//
//  MedalRankingTopUserViewModel.swift
//  Falla
//
//  Created by aa on 2023/7/4.
//

import UIKit
import SVGAPlayer_Optimized

class MedalRankingTopUserViewModel {
    let ranking: MedalRanking.Ranking
    let user: EMLRankingUserModel
    
    var avatarUrl: URL? { rq_avatarurl.map { URL(string: $0) } ?? nil }
    var nobilityUrl: URL? { rq_nobilityIcon.map { URL(string: $0) } ?? nil }
    
    lazy var rq_avatarurl = user.avatarurl?.rq_100x100
    lazy var rq_nobilityIcon = user.nobilityIcon?.rq_40x40
    
    var isOnLine: Bool { user.inGid > 0 && !user.anonymous }
//    var isOnLine: Bool = Bool.random()
    
    var name: String { user.nickname ?? "" }
    var nameMask: UIImage? { JKRShimmeringMask.nickNameMask(withVip: user.nobility, svip: user.svip) }
    var nameFrame: CGRect = .zero
    
    var nameIconModel: MedalRankingIconModel? = nil
    
    var iconVMs: [MedalRankingIconViewModel] = []
    
    var score: String?
    var scoreImage: UIImage?
    var scoreColors: [UIColor] = []
    
    var getOnLineEntity: (() -> SVGAVideoEntity?)?
        
    init(user: EMLRankingUserModel, rank: Int) {
        self.ranking = MedalRanking.Ranking(rank)
        self.user = user
        
        let nameViewSize = MedalRankingTopUserView.nameViewSize(ranking)
        let nameSize = (name as NSString).boundingRect(with: nameViewSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: MedalRankingTopUserView.nameFont], context: nil).size
        nameFrame = [HalfDiffValue(nameViewSize.width, nameSize.width),
                     HalfDiffValue(nameViewSize.height, nameSize.height),
                     nameSize.width, nameSize.height]
        
        let svip = user.svip
        let svipImgName = svip > 0 ? (svip < 11 ? "icon_svip_\(svip)" : "icon_svip_11") : nil
        if let svipImgName, let image = UIImage(named: svipImgName) {
            let imgH: CGFloat = 14.px
            let imgW: CGFloat = imgH * (image.size.width / image.size.height)
            let nameIconModel = MedalRankingIconModel(
                iconSource: .asset(svipImgName),
                iconFrame: [HalfDiffValue(nameViewSize.width, imgW),
                            HalfDiffValue(nameViewSize.height, imgH),
                            imgW, imgH],
                tapAction: { MedalRouter.svip(svip).jump() }
            )
            self.nameIconModel = nameIconModel
        }
        
        if let nameIconModel = self.nameIconModel, nameIconModel.iconFrame.width > 0, nameFrame.width > 0 {
            var iconFrame = nameIconModel.iconFrame
            let space: CGFloat = 3.px
            
            var totalW = nameFrame.width + space + iconFrame.width
            if totalW > nameViewSize.width {
                totalW = nameViewSize.width
            }
            
            let x = HalfDiffValue(nameViewSize.width, totalW)
            let iconX = x + totalW - iconFrame.width
            let nameW = totalW - iconFrame.width - space
            
            iconFrame.origin.x = iconX
            nameIconModel.iconFrame = iconFrame
            
            nameFrame.origin.x = x
            nameFrame.size.width = nameW
        }
        
        if let medalsIcons = user.medalsIcon, medalsIcons.count > 0 {
            let count = min(MedalRankingTopUserView.iconMaxCount, medalsIcons.count)
            var iconModels: [MedalRankingIconModel] = []
            for i in 0 ..< count {
                iconModels.append(
                    MedalRankingIconModel(
                        iconSource: .remote(medalsIcons[i].rq_20x20),
                        iconFrame: [0, 0, 18.px, 18.px],
                        nextSpace: 2.px
                    )
                )
            }
            
            iconVMs = MedalRankingIconViewModel.build(
                with: iconModels,
                iconMaxCount: MedalRankingTopUserView.iconMaxCount,
                iconListSize: MedalRankingTopUserView.iconListSize(ranking),
                iconListAlignment: MedalRankingTopUserView.iconListAlignment(ranking)
            )
        }
        
        score = user.val.friendlyString()
        scoreImage = UIImage(named: "medal_integral_logo_small")
        scoreColors = [.rgb(240, 142, 255), .rgb(71, 57, 255)]
    }
}
