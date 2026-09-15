//
//  MedalRankingTopUserView.swift
//  Falla
//
//  Created by aa on 2023/6/30.
//

import UIKit
import Kingfisher
import SVGAPlayer_Optimized

class MedalRankingTopUserView: UIView {
    static var top1Size: CGSize { size(.top1) }
    static var top2Size: CGSize { size(.top2) }
    static var top3Size: CGSize { size(.top3) }
    
    static func size(_ ranking: MedalRanking.Ranking) -> CGSize {
        switch ranking {
        case .top1: return [122.px, MedalRankingTopView.size.height]
        case .top2: return [HalfDiffValue(Env.screenWidth, 122.px) - 8.px, MedalRankingTopView.size.height]
        case .top3: return [HalfDiffValue(Env.screenWidth, 122.px) - 8.px, MedalRankingTopView.size.height]
        default: return .zero
        }
    }
    
    static var nameFont: UIFont { .systemFont(ofSize: 14.px, weight: .semibold) }
    static func nameViewSize(_ ranking: MedalRanking.Ranking) -> CGSize {
        switch ranking {
        case .top1: return [122.px, 24.px]
        case .top2: return [HalfDiffValue(Env.screenWidth, 122.px) - 8.px, 24.px]
        case .top3: return [HalfDiffValue(Env.screenWidth, 122.px) - 8.px, 24.px]
        default: return .zero
        }
    }
    
    static var iconMaxCount: Int { 6 }
    
    static func iconListSize(_ ranking: MedalRanking.Ranking) -> CGSize {
        switch ranking {
        case .top1: return [122.px, 18.px]
        case .top2: return [HalfDiffValue(Env.screenWidth, 122.px) - 8.px, 18.px]
        case .top3: return [HalfDiffValue(Env.screenWidth, 122.px) - 8.px, 18.px]
        default: return .zero
        }
    }
    
    static func iconListAlignment(_ ranking: MedalRanking.Ranking) -> MedalRankingIconListAlignment {
//        switch ranking {
//        case .top1: return .center
//        case .top2: return .trailing
//        case .top3: return .leading
//        default: return .leading
//        }
        return .center
    }
    
    private let ranking: MedalRanking.Ranking
    private var userVM: MedalRankingUserViewModel? = nil
    
    private var mySubviews: [MedalRankingTopUserSubviewCompatible] = []
    
    init(_ showType: MedalRanking.ShowType, ranking: MedalRanking.Ranking) {
        self.ranking = ranking
        super.init(frame: .zero)
        setupUI()
        setupSubviews(showType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        rtl_refWidth = Env.screenWidth
        switch ranking {
        case .top1:
            let size = Self.top1Size
            rtl_frame = CGRect(origin: [HalfDiffValue(Env.screenWidth, size.width), 0], size: size)
        case .top2:
            let size = Self.top2Size
            rtl_frame = CGRect(origin: [8.px, 0], size: size)
        case .top3:
            let size = Self.top3Size
            rtl_frame = CGRect(origin: [(Env.screenWidth - size.width) - 8.px, 0], size: size)
        default:
            rtl_frame = .zero
        }
    }
    
    private func setupSubviews(_ showType: MedalRanking.ShowType) {
        let crownView = UserCrownView(ranking: ranking, refWidth: bounds.width)
        var nextY = crownView.frame.maxY
        
        let nameView = NameView(refWidth: bounds.width, y: nextY, showType: showType)
        nameView.alpha = 0
        nextY = nameView.frame.maxY + 3.5.px
        
        let ilView = MedalRankingIconListView()
        ilView.iconMaxCount = MedalRankingTopUserView.iconMaxCount
        ilView.alignment = MedalRankingTopUserView.iconListAlignment(ranking)
        ilView.rtl_refWidth = bounds.width
        ilView.rtl_frame = CGRect(origin: [ranking == .top2 ? 8.px : 0, nextY], size: MedalRankingTopUserView.iconListSize(ranking))
        ilView.alpha = 0
        nextY = ilView.frame.maxY + 5.5.px
        
        let scoreView = ScoreView(refWidth: bounds.width, y: nextY)
        scoreView.alpha = 0
        
        mySubviews = [crownView, nameView, ilView, scoreView]
        mySubviews.forEach { addSubview($0) }
    }
}

extension MedalRankingTopUserView {
    func willUpdateData(_ topUserVM: MedalRankingTopUserViewModel?) {
        mySubviews.forEach { $0.willUpdateData(topUserVM) }
    }
    
    func updateData(_ topUserVM: MedalRankingTopUserViewModel?) {
        _ = mySubviews.reduce(mySubviews.first?.origin.y ?? 0) { $1.updateData(topUserVM, $0) }
    }
}

protocol MedalRankingTopUserSubviewCompatible: UIView {
    func willUpdateData(_ topUserVM: MedalRankingTopUserViewModel?)
    func updateData(_ topUserVM: MedalRankingTopUserViewModel?, _ y: CGFloat) -> CGFloat
}
extension MedalRankingTopUserSubviewCompatible {
    func willUpdateData(_ topUserVM: MedalRankingTopUserViewModel?) {}
}

// MARK: - 头像+皇冠+贵族
private extension MedalRankingTopUserView {
    class UserCrownView: UIView, MedalRankingTopUserSubviewCompatible {
        let ranking: MedalRanking.Ranking
        
        let avatarView: AnimatedImageView = {
            let av = AnimatedImageView()
            av.contentMode = .scaleAspectFill
            av.layer.masksToBounds = true
            av.runLoopMode = RunLoop.Mode.default
            av.backgroundColor = .black
            av.image = UIImage(named: "header_no")
            av.isUserInteractionEnabled = false
            return av
        }()
        let crownView = UIImageView()
        let nobilityView = UIImageView()
        var player: SVGARePlayer?
        
        private var gid: Int?
        private var uid: Int?
        
        init(ranking: MedalRanking.Ranking, refWidth: CGFloat) {
            self.ranking = ranking
            super.init(frame: .zero)
            clipsToBounds = false
            setupUI(refWidth)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupUI(_ refWidth: CGFloat) {
            rtl_refWidth = refWidth
            
            switch ranking {
            case .top1:
                rtl_frame = [0, 0, refWidth, 86.5.px]
                
                avatarView.rtl_refWidth = bounds.width
                avatarView.rtl_frame = CGRect(origin: [32.px, 16.px], size: [(58.5).px, 58.5.px])
                avatarView.layer.cornerRadius = 29.25.px
                
                crownView.frame = bounds
                crownView.image = UIImage(named: "medal_ranking_top1")
                
                nobilityView.rtl_refWidth = bounds.width
                nobilityView.rtl_frame = CGRect(origin: [bounds.width - 30.px - 15.px, bounds.height - 30.px], size: [30.px, 30.px])
                
            case .top2:
                let size: CGSize = [(87.5).px, 71.px]
                rtl_frame = [refWidth - size.width - 10.5.px, 47.px, size.width, size.height]
                
                avatarView.rtl_refWidth = bounds.width
                avatarView.rtl_frame = CGRect(origin: [19.px, 10.5.px], size: [50.px, 50.px])
                avatarView.layer.cornerRadius = 25.px
                
                crownView.frame = bounds
                crownView.image = UIImage(named: "medal_ranking_top2")
                
                nobilityView.rtl_refWidth = bounds.width
                nobilityView.rtl_frame = CGRect(origin: [bounds.width - 30.px, bounds.height - 30.px], size: [30.px, 30.px])
                
            case .top3:
                let size: CGSize = [(87.5).px, 71.px]
                rtl_frame = [8.px, 57.px, size.width, size.height]
                
                avatarView.rtl_refWidth = bounds.width
                avatarView.rtl_frame = CGRect(origin: [19.px, 10.5.px], size: [50.px, 50.px])
                avatarView.layer.cornerRadius = 25.px
                
                crownView.frame = bounds
                crownView.image = UIImage(named: "medal_ranking_top3")
                
                nobilityView.rtl_refWidth = bounds.width
                nobilityView.rtl_frame = CGRect(origin: [bounds.width - 30.px, bounds.height - 30.px], size: [30.px, 30.px])
                
            default:
                rtl_frame = .zero
            }
            
            addSubview(avatarView)
            addSubview(crownView)
            addSubview(nobilityView)
            
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatarView)))
        }
        
        @objc func tapAvatarView() {
//            switch (gid, uid) {
//            case let (gid?, _):
//                MedalRouter.room(gid).jump()
//            case let (_, uid?):
//                MedalRouter.profile(uid).jump()
//            default:
//                MedalRouter.anonymons.jump()
//            }
            if let uid {
                MedalRouter.profile(uid).jump()
            } else {
//                MedalRouter.anonymons.jump() // 勋章榜单都能跳个人页，不需要这个了
            }
        }
        
        func willUpdateData(_ topUserVM: MedalRankingTopUserViewModel?) {
            guard let topUserVM else { return }
            
            // 直播图标
            if topUserVM.isOnLine, self.player == nil, let videoItem = topUserVM.getOnLineEntity?() {
                let player = SVGARePlayer()
                player.rtl_refWidth = bounds.width
                switch ranking {
                case .top1:
                    player.frame = CGRect(origin: [avatarView.rtl_maxX - 7, avatarView.frame.origin.y - 4], size: [21.px, 21.px])
                case .top2:
                    player.frame = CGRect(origin: [avatarView.rtl_maxX - 9, avatarView.frame.origin.y - 4], size: [21.px, 21.px])
                case .top3:
                    player.frame = CGRect(origin: [avatarView.rtl_maxX - 9, avatarView.frame.origin.y - 4], size: [21.px, 21.px])
                default:
                    return
                }
                player.videoItem = videoItem
                player.alpha = 0
                addSubview(player)
                self.player = player
            }
        }
        
        func updateData(_ topUserVM: MedalRankingTopUserViewModel?, _ y: CGFloat) -> CGFloat {
            frame.origin.y = y
            
            gid = nil
            uid = nil
            
            guard let topUserVM else {
                avatarView.kf.cancelDownloadTask()
                avatarView.image = UIImage(named: "header_no")
                
                nobilityView.kf.cancelDownloadTask()
                nobilityView.image = nil
                
                player?.stopAnimation()
                player?.alpha = 0
                
                avatarView.isUserInteractionEnabled = false
                return frame.maxY
            }
            
            avatarView.kf.setImage(
                with: topUserVM.avatarUrl,
                placeholder: UIImage(named: "header_no"),
                options: [.transition(.fade(0.2)), .keepCurrentImageWhileLoading]
            )
            
            nobilityView.kf.setImage(
                with: topUserVM.nobilityUrl,
                options: [.transition(.fade(0.2)), .keepCurrentImageWhileLoading]
            )
            
            if topUserVM.isOnLine {
                player?.startAnimation()
                player?.alpha = 1
            } else {
                player?.stopAnimation()
                player?.alpha = 0
            }
            
            avatarView.isUserInteractionEnabled = true
//            if !topUserVM.user.anonymous {
//                if topUserVM.user.inGid > 0 {
//                    gid = topUserVM.user.inGid
//                } else {
//                    uid = topUserVM.user.uid
//                }
//            }
            uid = topUserVM.user.uid
            
            return frame.maxY
        }
    }
}

// MARK: - 名字+等级
private extension MedalRankingTopUserView {
    class NameView: UIView, MedalRankingTopUserSubviewCompatible {
        let nameLabel = JKRShimmeringLabel()
        var nameImgView: UIImageView?
        var tapNameImgAction: (() -> Void)?
        
        init(refWidth: CGFloat, y: CGFloat, showType: MedalRanking.ShowType) {
            super.init(frame: .zero)
            clipsToBounds = false
            
            rtl_refWidth = refWidth
            rtl_frame = [0, y, refWidth, 24.px]
            
            nameLabel.rtl_refWidth = bounds.width
            nameLabel.rtl_frame = bounds
            nameLabel.font = MedalRankingTopUserView.nameFont
            nameLabel.lineBreakMode = .byTruncatingTail
            switch showType {
            case .fullScreen:
                nameLabel.textColor = .white
            case .pop:
                nameLabel.textColor = .rgb(51, 51, 51)
            }
            addSubview(nameLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func tapNameImgView() {
            tapNameImgAction?()
        }
        
        func willUpdateData(_ topUserVM: MedalRankingTopUserViewModel?) {
            guard let topUserVM else { return }
            
            if let iconModel = topUserVM.nameIconModel, nameImgView == nil {
                let niv = UIImageView()
                niv.rtl_refWidth = bounds.width
                niv.rtl_frame = iconModel.iconFrame
                niv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapNameImgView)))
                niv.isUserInteractionEnabled = false
                niv.alpha = 0
                addSubview(niv)
                nameImgView = niv
            }
        }
        
        func updateData(_ topUserVM: MedalRankingTopUserViewModel?, _ y: CGFloat) -> CGFloat {
            frame.origin.y = y
            
            tapNameImgAction = nil
            nameImgView?.isUserInteractionEnabled = false
            
            guard let topUserVM else {
                nameLabel.alpha = 0
                nameLabel.shimmerMask = nil
                
                nameImgView?.alpha = 0
                
                alpha = 0
                return y + 5.5.px
            }
            
            nameLabel.alpha = 1
            nameLabel.rtl_frame = topUserVM.nameFrame
            nameLabel.text = topUserVM.name
            nameLabel.shimmerMask = topUserVM.nameMask
            
            if let nameImgView = nameImgView, let iconModel = topUserVM.nameIconModel {
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
            
            alpha = 1
            return frame.maxY + 3.5.px
        }
    }
}

// MARK: - 勋章列表
extension MedalRankingIconListView: MedalRankingTopUserSubviewCompatible {
    func willUpdateData(_ topUserVM: MedalRankingTopUserViewModel?) {
        willReloadIcons(topUserVM?.iconVMs ?? [])
    }
    
    func updateData(_ topUserVM: MedalRankingTopUserViewModel?, _ y: CGFloat) -> CGFloat {
        frame.origin.y = y
        
        let iconVMs = topUserVM?.iconVMs ?? []
        reloadIcons(iconVMs)
        
        guard iconVMs.count > 0 else {
            alpha = 0
            return y
        }
        
        alpha = 1
        return frame.maxY + 5.5.px
    }
}

// MARK: - 积分
private extension MedalRankingTopUserView {
    class ScoreView: GradientView, MedalRankingTopUserSubviewCompatible {
        let scoreLabel = UILabel()
        let iconView = UIImageView()
        
        init(refWidth: CGFloat, y: CGFloat) {
            super.init(frame: .zero)
            
            let w = 77.px
            let h = 22.5.px
            rtl_refWidth = refWidth
            rtl_frame = [HalfDiffValue(refWidth, w), y, w, h]
            
            layer.cornerRadius = bounds.height * 0.5
            layer.masksToBounds = true
            
            if Env.isRTL {
                startPoint = [1, 0.5]
                endPoint = [0, 0.5]
            } else {
                startPoint = [0, 0.5]
                endPoint = [1, 0.5]
            }
            
            scoreLabel.rtl_refWidth = bounds.width
            scoreLabel.rtl_frame = [5.px, 0, 50.px, bounds.height]
            scoreLabel.textColor = .white
            scoreLabel.textAlignment = .center
            scoreLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
            addSubview(scoreLabel)
            
            iconView.rtl_refWidth = bounds.width
            iconView.rtl_frame = [bounds.width - 8.px - 16.px, HalfDiffValue(bounds.height, 16.px), 16.px, 16.px]
            iconView.contentMode = .scaleAspectFit
            addSubview(iconView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateData(_ topUserVM: MedalRankingTopUserViewModel?, _ y: CGFloat) -> CGFloat {
            frame.origin.y = y
            
            guard let topUserVM else {
                alpha = 0
                return y
            }
            
            scoreLabel.text = topUserVM.score
            iconView.image = topUserVM.scoreImage
            colors = topUserVM.scoreColors
            
            alpha = 1
            return frame.maxY
        }
    }
}
