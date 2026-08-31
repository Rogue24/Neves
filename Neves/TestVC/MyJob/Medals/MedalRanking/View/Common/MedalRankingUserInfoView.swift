//
//  MedalRankingUserInfoView.swift
//  Falla
//
//  Created by aa on 2023/6/30.
//

import UIKit

class MedalRankingUserInfoView: UIView {
    static let size: CGSize = [Env.screenWidth, 50.px]
    
    static var nameOrigin: CGPoint { [102.px, 3.5.px] }
    static var nameMaxSize: CGSize { [190.px, 18.5.px] }
    static var nameFont: UIFont { .systemFont(ofSize: 15.px, weight: .medium) }
    
    static var iconMaxCount: Int { 14 }
    static var iconListSize: CGSize { [MedalRankingUserInfoView.size.width - 102.px - 20.px, 20.px] }
    static var iconListAlignment: MedalRankingIconListAlignment { .leading }
    
    private let numLabel: UILabel = {
        let nl = UILabel()
        nl.rtl_refWidth = MedalRankingUserInfoView.size.width
        nl.rtl_frame = [0, 0, 40.px, MedalRankingUserInfoView.size.height]
        nl.textAlignment = .center
        nl.font = .boldSystemFont(ofSize: 19.px)
        nl.textColor = .rgb(191, 191, 191)
        return nl
    }()
    
    private let avatarView: YYAnimatedImageView = {
        let av = YYAnimatedImageView()
        av.rtl_refWidth = MedalRankingUserInfoView.size.width
        av.rtl_frame = [40.px, 0, MedalRankingUserInfoView.size.height, MedalRankingUserInfoView.size.height]
        av.contentMode = .scaleAspectFill
        av.layer.cornerRadius = MedalRankingUserInfoView.size.height * 0.5
        av.layer.masksToBounds = true
        av.runloopMode = RunLoop.Mode.default.rawValue
        av.backgroundColor = .black
        av.image = UIImage(named: "header_no")
        return av
    }()
    
    private let nameLabel: JKRShimmeringLabel = {
        let nl = JKRShimmeringLabel()
        nl.rtl_refWidth = MedalRankingUserInfoView.size.width
        nl.rtl_frame = CGRect(origin: MedalRankingUserInfoView.nameOrigin, size: MedalRankingUserInfoView.nameMaxSize)
        nl.font = MedalRankingUserInfoView.nameFont
        return nl
    }()
    
    private let iconListView: MedalRankingIconListView = {
        let ilView = MedalRankingIconListView()
        ilView.rtl_refWidth = MedalRankingUserInfoView.size.width
        ilView.rtl_frame = [102.px, MedalRankingUserInfoView.size.height - 20.px - 3.5.px, MedalRankingUserInfoView.size.width - 102.px, 20.px]
        ilView.alignment = .leading
        ilView.iconMaxCount = 16
        return ilView
    }()
    
    private let scoreLabel: UILabel = {
        let sl = UILabel()
        sl.rtl_refWidth = MedalRankingUserInfoView.size.width
        sl.rtl_frame = [MedalRankingUserInfoView.size.width - 20.px - 18.px - 100.px - 5.px, 3.5.px, 100.px, 18.5.px]
        sl.font = .systemFont(ofSize: 14.px, weight: .bold)
        sl.textAlignment = Env.isRTL ? .left : .right
        return sl
    }()
    
    private let scoreIcon: UIImageView = {
        let si = UIImageView()
        si.rtl_refWidth = MedalRankingUserInfoView.size.width
        si.rtl_frame = [MedalRankingUserInfoView.size.width - 20.px - 18.px, 3.75.px, 18.px, 18.px]
        si.contentMode = .scaleAspectFit
        si.alpha = 0
        return si
    }()
    
    private(set) var player: SVGAPlayer?
    private(set) var nameImgView: UIImageView?
    
    private var gid: Int?
    private var uid: Int?
    private var tapNameImgAction: (() -> Void)?
    
    init(nameColor: UIColor, scoreColor: UIColor) {
        super.init(frame: CGRect(origin: .zero, size: MedalRankingUserInfoView.size))
        isUserInteractionEnabled = false
        
        addSubview(numLabel)
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(iconListView)
        addSubview(scoreLabel)
        addSubview(scoreIcon)
        
        nameLabel.textColor = nameColor
        scoreLabel.textColor = scoreColor
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapNameImgView() {
        tapNameImgAction?()
    }
    
    @objc func tapMe() {
//        switch (gid, uid) {
//        case let (gid?, _):
//            MedalRouter.room(gid).jump()
//        case let (_, uid?):
//            MedalRouter.profile(uid).jump()
//        default:
//            MedalRouter.anonymons.jump()
//        }
        if let uid {
            MedalRouter.profile(uid).jump()
        } else {
//            MedalRouter.anonymons.jump() // 勋章榜单都能跳个人页，不需要这个了
        }
    }
}

extension MedalRankingUserInfoView {
    func willUpdateData(_ userVM: MedalRankingUserViewModel?) {
        guard let userVM else { return }
        
        // 直播图标
        if userVM.isOnLine, self.player == nil, let videoItem = userVM.getOnLineEntity?() {
            let player = SVGAPlayer()
            player.frame = CGRect(origin: .zero, size: [85.px, 85.px])
            player.rtl_refWidth = bounds.width
            player.rtl_center = avatarView.rtl_center
            player.videoItem = videoItem
            player.alpha = 0
            addSubview(player)
            self.player = player
        }
        
        if let iconModel = userVM.nameIconModel, nameImgView == nil {
            let niv = UIImageView()
            niv.rtl_refWidth = bounds.width
            niv.rtl_frame = iconModel.iconFrame
            niv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapNameImgView)))
            niv.isUserInteractionEnabled = false
            niv.alpha = 0
            addSubview(niv)
            nameImgView = niv
        }
        
        iconListView.willReloadIcons(userVM.iconVMs)
    }
    
    func updateData(_ userVM: MedalRankingUserViewModel?) {
        gid = nil
        uid = nil
        
        tapNameImgAction = nil
        nameImgView?.isUserInteractionEnabled = false
        
        guard let userVM else {
            numLabel.text = ""
            
            avatarView.cancelCurrentImageRequest()
            avatarView.image = UIImage(named: "header_no")
            
            player?.stopAnimation()
            player?.alpha = 0
            
            nameLabel.text = ""
            nameLabel.shimmerMask = nil
            
            iconListView.reloadIcons([])
            
            nameImgView?.alpha = 0
            
            scoreLabel.text = ""
            scoreIcon.alpha = 0
            
            isUserInteractionEnabled = false
            return
        }
        
        numLabel.text = userVM.numStr
        
        avatarView.jkr_setImage(with: userVM.avatarUrl,
                                placeholder: UIImage(named: "header_no"),
                                loadErrorPlaceholder: UIImage(named: "header_no"),
                                options: .setImageWithFadeAnimation)
        
        if userVM.isOnLine {
            player?.startAnimation()
            player?.alpha = 1
        } else {
            player?.stopAnimation()
            player?.alpha = 0
        }
        
        nameLabel.rtl_frame = userVM.nameFrame
        nameLabel.text = userVM.name
        nameLabel.shimmerMask = userVM.nameMask
        
        if let nameImgView = nameImgView, let iconModel = userVM.nameIconModel {
            MedalRanking.IconSource.setup(iconModel.iconSource, for: nameImgView)
            nameImgView.rtl_frame = iconModel.iconFrame
            nameImgView.alpha = 1
            
            if let tapAction = iconModel.tapAction {
                tapNameImgAction = tapAction
                nameImgView.isUserInteractionEnabled = true
            }
        } else {
            nameImgView?.alpha = 0
        }
        
        iconListView.reloadIcons(userVM.iconVMs)
        
        scoreLabel.text = userVM.score
        scoreIcon.image = userVM.scoreImage
        scoreIcon.alpha = 1
        
        isUserInteractionEnabled = true
//        if !userVM.user.anonymous {
//            if userVM.user.inGid > 0 {
//                gid = userVM.user.inGid
//            } else {
//                uid = userVM.user.uid
//            }
//        }
        uid = userVM.user.uid
    }
}
