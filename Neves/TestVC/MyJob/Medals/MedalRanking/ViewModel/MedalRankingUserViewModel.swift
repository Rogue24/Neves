//
//  MedalRankingUserViewModel.swift
//  Neves
//
//  Created by aa on 2023/7/3.
//

import UIKit
import SVGAPlayer_Optimized

class MedalRankingUserViewModel {
    let ranking: MedalRanking.Ranking
    let user: EMLRankingUserModel
    
    let numStr: String
    
    var avatarUrl: URL? { rq_avatarurl.map { URL(string: $0) } ?? nil }
    lazy var rq_avatarurl = user.avatarurl?.rq_100x100
    
    var isOnLine: Bool { user.inGid > 0 && !user.anonymous }
//    var isOnLine: Bool = Bool.random()
    
    var name: String { user.nickname ?? "" }
    var nameMask: UIImage? { JKRShimmeringMask.nickNameMask(withVip: user.nobility, svip: user.svip) }
    var nameFrame: CGRect = .zero
    
    var nameIconModel: MedalRankingIconModel? = nil
    
    var iconVMs: [MedalRankingIconViewModel] = []
    
    var score: String?
    var scoreImage: UIImage?
    
    var getOnLineEntity: (() -> SVGAVideoEntity?)?
    
    init(user: EMLRankingUserModel, rank: Int, maxRank: Int) {
        self.ranking = MedalRanking.Ranking(rank)
        self.user = user
        
        if rank > 0 {
            let isOverflow = maxRank > 0 && (rank > maxRank)
            self.numStr = isOverflow ? "\(maxRank)+" : "\(rank)"
        } else {
            self.numStr = "-"
        }
        
        let nameOrigin = MedalRankingUserInfoView.nameOrigin
        let nameMaxSize = MedalRankingUserInfoView.nameMaxSize
        let nameSize = (name as NSString).boundingRect(with: nameMaxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: MedalRankingUserInfoView.nameFont], context: nil).size
        nameFrame = CGRect(origin: nameOrigin, size: nameSize)
        
        let genderIconName = user.gender == 1 ? "icon_gender_male" : (user.gender == 2 ? "icon_gender_female" : nil)
        if let genderIconName, let image = UIImage(named: genderIconName) {
            let imgWH = 14.px
            let imgX = nameFrame.maxX + 4.px
            let imgY = nameFrame.origin.y + HalfDiffValue(nameFrame.height, imgWH)
            let nameIconModel = MedalRankingIconModel(
                iconSource: .image(image),
                iconFrame: [imgX, imgY, imgWH, imgWH]
            )
            self.nameIconModel = nameIconModel
        }
        
        if let nameIconModel = self.nameIconModel, nameIconModel.iconFrame.width > 0, nameFrame.width > 0 {
            var iconFrame = nameIconModel.iconFrame
            let space: CGFloat = 4.px
            
            var totalW = nameFrame.width + space + iconFrame.width
            if totalW > nameMaxSize.width {
                totalW = nameMaxSize.width
            }
            
            iconFrame.origin.x = nameOrigin.x + totalW - iconFrame.width
            nameIconModel.iconFrame = iconFrame
            
            nameFrame.size.width = totalW - iconFrame.width - space
        }
        
        let listWidth = MedalRankingUserInfoView.iconListSize.width
        let iconWH: CGFloat = 20.px
        let space: CGFloat = 4.px
        
        var x: CGFloat = 0
        var iconModels: [MedalRankingIconModel] = []
        
        if let nobilityUrl = user.nobilityIcon, nobilityUrl.count > 0 {
            if (x + iconWH) <= listWidth {
                iconModels.append(
                    MedalRankingIconModel(
                        iconSource: .remote(nobilityUrl.rq_40x40),
                        iconFrame: [0, 0, iconWH, iconWH],
                        nextSpace: space
                    )
                )
                x += (iconWH + space)
            }
        }
        
        let svip = user.svip
        let svipImgName = svip > 0 ? (svip < 11 ? "icon_svip_\(svip)" : "icon_svip_11") : nil
        if let svipImgName, let image = UIImage(named: svipImgName) {
            let imgH: CGFloat = 14.px
            let imgW: CGFloat = imgH * (image.size.width / image.size.height)
            if (x + imgW) <= listWidth {
                iconModels.append(
                    MedalRankingIconModel(
                        iconSource: .asset(svipImgName),
                        iconFrame: [0, 0, imgW, imgH],
                        nextSpace: space,
                        tapAction: { MedalRouter.svip(svip).jump() }
                    )
                )
                x += (imgW + space)
            }
        }
        
        if let medalsIcons = user.medalsIcon, medalsIcons.count > 0 {
            for medalsIcon in medalsIcons {
                guard (x + iconWH) <= listWidth else { break }
                iconModels.append(
                    MedalRankingIconModel(
                        iconSource: .remote(medalsIcon.rq_20x20),
                        iconFrame: [0, 0, iconWH, iconWH],
                        nextSpace: space
                    )
                )
                x += (iconWH + space)
            }
        }
        
        iconVMs = MedalRankingIconViewModel.build(
            with: iconModels,
            iconMaxCount: MedalRankingUserInfoView.iconMaxCount,
            iconListSize: MedalRankingUserInfoView.iconListSize,
            iconListAlignment: MedalRankingUserInfoView.iconListAlignment
        )
        
        score = user.val.friendlyString()
        scoreImage = UIImage(named: "medal_integral_logo_small")
    }
}
