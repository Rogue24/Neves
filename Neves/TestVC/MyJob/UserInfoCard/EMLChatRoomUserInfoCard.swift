//
//  EMLChatRoomUserInfoCard.swift
//  Falla
//
//  Created by aa on 2025/6/6.
//

import UIKit
import SnapKit
import SVGAPlayer_Optimized

class EMLChatRoomUserInfoCard: EMLPopCard {
    let uid: Int
    let isMe: Bool
    private(set) var userInfo: UserInfo?
    
    private static let avatarWH: CGFloat = 64.px
    private static let topViewH: CGFloat = 40.px
    private static let operationH: CGFloat = 60.px
    private static let manageBottomInset: CGFloat = (10 + 8 + 35 + 8).px
    private static let contentW: CGFloat = 315.px
    
    private let contentView = GradientView()
    
    // ====================================================
    private var totemIconView: UIImageView?
    
    // ====================================================
    private var topView: UIView?
    
    // ====================================================
    private let baseInfoView = UIStackView()
    
    // ------------------------------------------
    private let identityView = UIStackView()
    private let nicknameLabel = JKRShimmeringLabel()
    
    // ------------------------------------------
    private let profileView = UIStackView()
    
    private let uidView = FancyIDView(defaultColor: .rgb(119, 119, 119), iconWH: 20.px)
    
    private let countryLabel = UILabel()
    
    // ------------------------------------------
    private let levelsView = UIStackView()
    
    // ------------------------------------------
    private let medalsView = UIStackView()
    
    // ====================================================
    private let signatureLabel = UILabel()
    
    // ====================================================
    private var titlesView: EMLUserTitleFlowView?
    
    // ====================================================
    private var badgeCollectionView: EMLCountryRegionBadgeCollectionView?
    
    // ====================================================
    private var operationView: UIView?
    
    // ====================================================
    private var manageView: UIStackView?
    
    // ====================================================
    private var visualView: SVGAExImageView?
    
    // ====================================================
    private let avatarView = YYAnimatedImageView()
    private let headwearView = HeadwearView()
    private var nobilityIconView: UIImageView?
    private var cpAvatarView: YYAnimatedImageView?
    private var ringSvgaPlayer: RingerFXPlayer?
    
    // ====================================================
    private(set) var isMystery = false
    private var mysteryView: UIView?
    
    init(uid: Int, isMystery: Bool) {
        self.uid = uid
        self.isMe = uid == (JKRUserManager.shared().user?.uid ?? 0)
        self.isMystery = isMystery
        super.init(frame: .zero)
        clipsToBounds = false
        
        showStyle = .scaleXY(0.95)
        bgCloseType = .normal
        
        // 内容视图
        setupContentView()
        // 用户头像+头饰
        setupAvatarViews()
        
//        topView?.backgroundColor = .randomColor
//        baseInfoView.backgroundColor = .randomColor
//        identityView.backgroundColor = .randomColor
//        profileView.backgroundColor = .randomColor
//        levelsView.backgroundColor = .randomColor
//        medalsView.backgroundColor = .randomColor
//        signatureLabel.backgroundColor = .randomColor
//        operationView?.backgroundColor = .randomColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        EML_DebugLog("EMLChatRoomUserInfoCard 死！", String(format: "%p", self))
    }
    
    override func putOn(_ container: UIView) {
        super.putOn(container)
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func show(completion: (() -> Void)? = nil) {
        super.show(completion: completion)
        fetchUserInfo()
    }
}

// MARK: - 初始化UI
private extension EMLChatRoomUserInfoCard {
    /// 内容视图
    func setupContentView() {
        contentView.colors = [.white]
        contentView.startPoint = [0.5, 0]
        contentView.endPoint = [0.5, 1]
        contentView.layer.cornerRadius = 8.px
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(Self.avatarWH * 0.5)
            make.width.equalTo(Self.contentW)
            make.height.equalTo(200.px)
        }
    }
    
    /// 用户头像+头饰
    func setupAvatarViews() {
        avatarView.image = "header_no".jp.image
        avatarView.layer.cornerRadius = Self.avatarWH * 0.5
        avatarView.layer.borderColor = .rgb(255, 255, 255)
        avatarView.layer.borderWidth = 2.px
        avatarView.layer.masksToBounds = true
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatarView)))
        addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView.snp.top)
            make.width.height.equalTo(Self.avatarWH)
        }
        
        headwearView.isUserInteractionEnabled = false
        addSubview(headwearView)
        headwearView.snp.makeConstraints { make in
            make.center.equalTo(avatarView)
            make.width.height.equalTo(108.px)
        }
    }
}

// MARK: - 数据处理
private extension EMLChatRoomUserInfoCard {
    func fetchUserInfo() {
        let params: [AnyHashable : Any] = [
            "gid": CrShared.gid,
            "uid": uid,
            "isMystery": isMystery,
        ]
        JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/group/user/info", params: params) { [weak self] returnValue in
            guard let self, let dict = returnValue as? [String: Any],
                  let userInfo = UserInfo.mj_object(withKeyValues: dict) else { return }
            
            if self.isMystery, (JKRUserManager.shared().user?.hasMysteryInfoPower ?? false) == false {
                // JP_Test：神秘人调试ing
//                if self.uid == 101610 {
//                    let dataCardSkin = userInfo.dataCardSkin ?? CardSkin()
//                    dataCardSkin.svga = "https://falla-res1.resygg.com/mystery/mystery_data_card.svga"
//                    dataCardSkin.borderColor = "#CC3AFF"
//                    dataCardSkin.gradientColor = ["#FFFFFF", "#F5D4FE"]
//                    dataCardSkin.bgImage = "https://res-g.resygg.com/awss3_3169122_1725950235659808984_601631323.png"
//                    userInfo.dataCardSkin = dataCardSkin
//                    self.updateUserInfo(userInfo)
//                    return
//                }
                
                if let mysteryInfo = dict["mysteryInfo"] as? [String: Any], let mysteryDataCardSkin = mysteryInfo["mysteryDataCardSkin"] as? [String: Any] {
                    let dataCardSkin = userInfo.dataCardSkin ?? CardSkin()
                    dataCardSkin.svga = mysteryDataCardSkin["svga"] as? String ?? ""
                    dataCardSkin.topImage = mysteryDataCardSkin["topImage"] as? String ?? ""
                    dataCardSkin.borderColor = mysteryDataCardSkin["borderColor"] as? String ?? ""
                    dataCardSkin.gradientColor = mysteryDataCardSkin["gradientColor"] as? [String] ?? []
                    dataCardSkin.bgImage = mysteryDataCardSkin["bgImage"] as? String ?? ""
                    userInfo.dataCardSkin = dataCardSkin
                }
            } else {
                self.isMystery = false
            }
            
            self.updateUserInfo(userInfo)
        } failure: { _ in } cancel: {}
    }
    
    func updateUserInfo(_ userInfo: UserInfo) {
        self.userInfo = userInfo
        
        // 皮肤头冠+贵族图腾
        setupCardSkinViews(userInfo)
        
        if isMystery {
            setupMysteryView(userInfo) // 神秘人
        } else {
            setupAvatarOtherViews(userInfo) // 贵族图标+CP头像+CP戒指
            setupTopView(userInfo) // 顶部栏
            setupBaseInfoView() // 用户基本信息
            setupSignatureLabel(userInfo) // 个性签名
            setupManageView(userInfo) // 管理栏
            setupOperationView(userInfo) // 操作栏
        }
        
        updateAvatar(userInfo)
        updateBaseInfo(userInfo)
        
        contentView.layoutIfNeeded()
        
        var contentH: CGFloat
        if isMystery {
            contentH = (54 + 21 + 134).px // 名字底部间距 + 名字高度 + 神秘人文本高度
            if isMe {
                if userInfo.isInSeat {
                    contentH += 52.px // 下麦按钮+闭麦按钮的空间
                } else {
                    contentH += 32.px
                }
            } else {
                contentH += 44.px // 详情按钮高度
                if userInfo.isInRoom {
                    contentH += 52.px // 送礼按钮的空间
                } else {
                    contentH += 18.px
                }
            }
        } else {
            var y = signatureLabel.frame.maxY
            y = setupTitlesView(userInfo, y: y) // 用户称号列表
            y = setupBadgeCollectionView(userInfo, y: y) // 国家区域徽章列表
            
            contentH = y
            if operationView != nil {
                contentH += Self.operationH
            }
            if manageView != nil {
                contentH += Self.manageBottomInset
            } else {
                contentH += 8.px
            }
        }
        
        // 防止同时过多刷新，延迟一点点再刷新高度和其他动效，减轻负担
        Asyncs.mainDelay(0.01) { [weak self] in
            guard let self else { return }
            self.updateCardLayout(userInfo, contentH)
            self.updateCardSkin(userInfo)
            self.updateAvatarOtherUI(userInfo)
        }
    }
}

// MARK: - 动态构建UI
private extension EMLChatRoomUserInfoCard {
    /// 皮肤头冠+贵族图腾
    func setupCardSkinViews(_ userInfo: UserInfo) {
        guard let skin = userInfo.dataCardSkin else { return }
        
        if !skin.svga.isEmpty || !skin.topImage.isEmpty {
            let visualView = SVGAExImageView()
            visualView.imageContentMode = .scaleToFill
            visualView.playerContentMode = .scaleToFill
            insertSubview(visualView, belowSubview: avatarView)
            visualView.snp.makeConstraints { make in
                make.width.equalTo(330.px)
                make.height.equalTo(98.px)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(avatarView)
            }
            self.visualView = visualView
        }
        
        if !skin.bgImage.isEmpty {
            let totemIconView = UIImageView()
            totemIconView.contentMode = .scaleAspectFit
            contentView.insertSubview(totemIconView, at: 0)
            totemIconView.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(316.5.px)
            }
            self.totemIconView = totemIconView
        }
    }
    
    /// 贵族图标+CP头像+CP戒指
    func setupAvatarOtherViews(_ userInfo: UserInfo) {
        if let nobilityIcon = userInfo.nobilityIcon, !nobilityIcon.isEmpty {
            let nobilityIconView = UIImageView()
            nobilityIconView.alpha = 0
            addSubview(nobilityIconView)
            nobilityIconView.snp.makeConstraints { make in
                make.width.height.equalTo(27.5.px)
                make.centerX.equalTo(avatarView).offset(-32.px) // 贵族图标无需RTL适配
                make.bottom.equalTo(avatarView).offset(5.5.px)
            }
            self.nobilityIconView = nobilityIconView
        }
        
        if userInfo.cpUid > 0, let cpRingInfo = userInfo.cpRingInfo, cpRingInfo.ringId > 0 {
            let cpAvatarView = YYAnimatedImageView()
            cpAvatarView.image = "header_no".jp.image
            cpAvatarView.layer.cornerRadius = 20.px
            cpAvatarView.layer.borderColor = .rgb(255, 255, 255)
            cpAvatarView.layer.borderWidth = 1.26.px
            cpAvatarView.layer.masksToBounds = true
            cpAvatarView.alpha = 0
            cpAvatarView.isUserInteractionEnabled = true
            cpAvatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCpAvatarView)))
            addSubview(cpAvatarView)
            cpAvatarView.snp.makeConstraints { make in
                make.left.equalTo(avatarView.snp.right).offset(30.px) // cp头像无需RTL适配
                make.bottom.equalTo(avatarView)
                make.width.height.equalTo(40.px)
            }
            self.cpAvatarView = cpAvatarView
            
            let ringSvgaPlayer = RingerFXPlayer(frame: [0, 0, 59.px, 59.px])
            ringSvgaPlayer.setNeedJvhua(style: .medium)
            ringSvgaPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRingSvgaPlayer)))
            addSubview(ringSvgaPlayer)
            ringSvgaPlayer.snp.makeConstraints { make in
                make.right.equalTo(cpAvatarView.snp.left).offset(17.px) // cp戒指无需RTL适配
                make.bottom.equalTo(cpAvatarView).offset(22.px)
                make.width.height.equalTo(59.px)
            }
            self.ringSvgaPlayer = ringSvgaPlayer
        }
    }
    
    /// 顶部栏
    func setupTopView(_ userInfo: UserInfo) {
        guard !isMe else { return }
        
        let topInset = visualView != nil ? 20.px : 8.px
        
        let topView = UIView()
        topView.alpha = 0
        contentView.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Self.topViewH)
            make.top.equalTo(topInset)
        }
        self.topView = topView
        
        let moreBtn = UIButton(type: .system)
        moreBtn.setImage("user_info_card_report_icon".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        moreBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        topView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30.px)
            make.left.equalTo(12.px) // topView无需RTL适配
        }
        
        let atBtn = UIButton(type: .system)
        atBtn.setImage("chatroom_userinfo_card_at".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        atBtn.addTarget(self, action: #selector(atAction), for: .touchUpInside)
        topView.addSubview(atBtn)
        atBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30.px)
            make.right.equalTo(-8.px) // topView无需RTL适配
        }
        
        if userInfo.isInSeat {
            let voiceBtn = HighlightUnchangedButton(type: .custom)
            voiceBtn.tintColor = .clear
            voiceBtn.setImage("chatroom_userinfo_card_voice_open".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
            voiceBtn.setImage("chatroom_userinfo_card_voice_close".jp.image?.withRenderingMode(.alwaysOriginal), for: .selected)
            voiceBtn.isSelected = JKRAgoraManager.shared().jkr_userIsBan(userInfo.uid)
            voiceBtn.addTarget(self, action: #selector(voiceAction(_:)), for: .touchUpInside)
            topView.addSubview(voiceBtn)
            voiceBtn.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.height.equalTo(30.px)
                make.left.equalTo(12.px + 30.px + 4.px) // topView无需RTL适配
            }
        }
    }
    
    /// 用户基本信息
    func setupBaseInfoView() {
        baseInfoView.axis = .vertical
        baseInfoView.alignment = .center
        baseInfoView.distribution = .fill
        baseInfoView.spacing = 4.px
        baseInfoView.alpha = 0
        contentView.addSubview(baseInfoView)
        baseInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(52.px)
        }
        
        // ------------------------------------------
        identityView.axis = .horizontal
        identityView.alignment = .center
        identityView.distribution = .fill
        identityView.spacing = 4.px
        baseInfoView.addArrangedSubview(identityView)
        identityView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(16.px)
            make.trailing.lessThanOrEqualTo(-16.px)
        }
        
        nicknameLabel.font = UIFont.systemFont(ofSize: 18.px, weight: .medium)
        nicknameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // 可以被压缩
        identityView.addArrangedSubview(nicknameLabel)
        
        // ------------------------------------------
        profileView.axis = .horizontal
        profileView.alignment = .center
        profileView.distribution = .fill
        profileView.spacing = 6.px
        baseInfoView.addArrangedSubview(profileView)
        
        profileView.addArrangedSubview(uidView)
        
        let line = UIView()
        line.backgroundColor = .rgb(232, 232, 232)
        profileView.addArrangedSubview(line)
        line.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(10.px)
        }
        
        countryLabel.font = .systemFont(ofSize: 12.px)
        countryLabel.textColor = .rgb(119, 119, 119)
        profileView.addArrangedSubview(countryLabel)
        
        // ------------------------------------------
        levelsView.axis = .horizontal
        levelsView.alignment = .center
        levelsView.distribution = .fill
        levelsView.spacing = 4.px
        baseInfoView.addArrangedSubview(levelsView)
        
        // ------------------------------------------
        medalsView.axis = .horizontal
        // V2 勋章双尺寸混排：钻章(大)/勋章(小)底边对齐（§4c）。medalsView 独立成行，改 .bottom 只影响勋章群。
        medalsView.alignment = .bottom
        medalsView.distribution = .fill
        medalsView.spacing = 4.px
//        medalsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMedalsView)))
        baseInfoView.addArrangedSubview(medalsView)
    }
    
    /// 个性签名
    func setupSignatureLabel(_ userInfo: UserInfo) {
        signatureLabel.font = .systemFont(ofSize: 12.px)
        signatureLabel.textColor = .rgb(119, 119, 119)
        signatureLabel.textAlignment = .center
        signatureLabel.alpha = 0
        contentView.addSubview(signatureLabel)
        signatureLabel.snp.makeConstraints { make in
            make.leading.equalTo(16.px)
            make.trailing.equalTo(-16.px)
            make.top.equalTo(baseInfoView.snp.bottom).offset(2.px)
            make.height.equalTo(24.px)
        }
        
        if let signature = userInfo.signature, !signature.isEmpty {
            signatureLabel.text = signature
        } else {
            signatureLabel.text = "str_user_center_descr_empty".jp.localized
        }
    }
    
    /// 管理栏
    func setupManageView(_ userInfo: UserInfo) {
        var manageBtns: [UIButton] = []
        
        if isMe, userInfo.isInSeat { // 本人，且在座位上
            // 下麦
            let downMicBtn = UIButton(type: .system)
            downMicBtn.setImage("chatroom_userinfo_card_kick_down".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
            downMicBtn.addTarget(self, action: #selector(upOrDownMicAction), for: .touchUpInside)
            manageBtns.append(downMicBtn)
            
            if !userInfo.isSeatMute { // 麦位是否打开麦克风
                // 开/闭麦
                let toggleMuteBtn = UIButton(type: .system)
                let image: UIImage?
                if userInfo.isMicOpen {
                    if JKRAgoraManager.shared().noPermission {
                        image = "chatroom_userinfo_card_no_sound_banned".jp.image
                    } else {
                        image = "chatroom_userinfo_card_no_sound".jp.image
                    }
                } else {
                    image = "chatroom_userinfo_card_no_sound_banned".jp.image
                }
                toggleMuteBtn.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                toggleMuteBtn.addTarget(self, action: #selector(toggleMuteAction), for: .touchUpInside)
                manageBtns.append(toggleMuteBtn)
            }
        }
        else if !isMe, let roomInfo = CrShared.baseRoomInfo { // 非本人
            let adminPower = ChatRoomGroupPower.admin // 3
            let myPower = roomInfo.groupPower
            let targetPower = userInfo.groupPower
            
            var isManageable = false
            if myPower.rawValue > adminPower.rawValue {
                isManageable = true
            } else if myPower == adminPower { // 管理员
                if myPower.rawValue > targetPower.rawValue {
                    isManageable = true
                } else if myPower == targetPower {
                    isManageable = roomInfo.groupSubPower.rawValue > userInfo.groupSubPower.rawValue
                }
            }
            
            if isManageable {
                // 设置权限
                let manageBtn = UIButton(type: .system)
                manageBtn.setImage("chatroom_userinfo_card_manage".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
                manageBtn.addTarget(self, action: #selector(manageAction), for: .touchUpInside)
                manageBtns.append(manageBtn)
            }
            
            var isNeedOther = isManageable
            // 外管可以对非房主有其他操作（除设置权限）
            if !isNeedOther, targetPower != .owner, userInfo.hasForbidPower {
                isNeedOther = true
            }
            
            if isNeedOther {
                // 上/下麦
                let upOrDownMicBtn = UIButton(type: .system)
                let upOrDownMicImage: UIImage?
                if userInfo.isInSeat {
                    upOrDownMicImage = "chatroom_userinfo_card_kick_down".jp.image
                } else {
                    upOrDownMicImage = "chatroom_userinfo_card_invite_up".jp.image
                }
                upOrDownMicBtn.setImage(upOrDownMicImage?.withRenderingMode(.alwaysOriginal), for: .normal)
                upOrDownMicBtn.addTarget(self, action: #selector(upOrDownMicAction), for: .touchUpInside)
                manageBtns.append(upOrDownMicBtn)
                
                // 闭麦（用户在座位上+座位开麦+用户开麦）
                if userInfo.isInSeat, !userInfo.isSeatMute, userInfo.isMicOpen {
                    let muteBtn = UIButton(type: .system)
                    muteBtn.setImage("chatroom_userinfo_card_no_sound".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
                    muteBtn.addTarget(self, action: #selector(toggleMuteAction), for: .touchUpInside)
                    manageBtns.append(muteBtn)
                }
                
                // 禁言
                let forbidBtn = UIButton(type: .system)
                let forbidImage: UIImage?
                if userInfo.isForbidMsg {
                    forbidImage = "chatroom_userinfo_card_no_messages_banned".jp.image
                } else {
                    forbidImage = "chatroom_userinfo_card_no_messages".jp.image
                }
                forbidBtn.setImage(forbidImage?.withRenderingMode(.alwaysOriginal), for: .normal)
                forbidBtn.addTarget(self, action: #selector(forbidAction), for: .touchUpInside)
                manageBtns.append(forbidBtn)
                
                // 踢出
                let kickoutBtn = UIButton(type: .system)
                kickoutBtn.setImage("chatroom_userinfo_card_kick_out".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
                kickoutBtn.addTarget(self, action: #selector(kickoutAction), for: .touchUpInside)
                manageBtns.append(kickoutBtn)
            }
        }
        
        guard manageBtns.count > 0 else { return }
        
        let manageView = UIStackView()
        manageView.clipsToBounds = false
        manageView.axis = .horizontal
        manageView.alignment = .fill
        manageView.distribution = .fillEqually
        manageView.spacing = 0
        manageView.alpha = 0
        contentView.addSubview(manageView)
        manageView.snp.makeConstraints { make in
            make.bottom.equalTo(-8.px)
            make.leading.equalTo(10.px)
            make.trailing.equalTo(-10.px)
            make.height.equalTo(35.px)
        }
        self.manageView = manageView
        
        for btn in manageBtns {
            manageView.addArrangedSubview(btn)
        }
        
        let line = UIView()
        line.backgroundColor = .rgb(221, 221, 221)
        manageView.addSubview(line)
        line.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(-8.px)
            make.width.equalTo(Self.contentW)
            make.height.equalTo(0.5)
        }
    }
    
    /// 操作栏
    func setupOperationView(_ userInfo: UserInfo) {
        guard !isMe else { return }
        
        let bottomInset = manageView != nil ? Self.manageBottomInset : 8.px
        
        let operationView = UIView()
        operationView.alpha = 0
        contentView.addSubview(operationView)
        operationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Self.operationH)
            make.bottom.equalTo(-bottomInset)
        }
        self.operationView = operationView
        
        let btnW = Self.contentW / 3.0
        let btnH = 50.px
        let btnY = HalfDiffValue(Self.operationH, btnH)
        
        let lineW = 0.5
        let lineH = 23.px
        let lineY = HalfDiffValue(Self.operationH, lineH)
        
        let layoutSubviewsHandler: (_ btn: CustomLayoutButton) -> Void = {
            guard let imageView = $0.imageView,
                  let titleLabel = $0.titleLabel else { return }
            let imgWH = 26.px
            let space = 6.px
            let totalH = imgWH + space + titleLabel.frame.height
            imageView.frame = [HalfDiffValue($0.bounds.width, imgWH), HalfDiffValue($0.bounds.height, totalH), imgWH, imgWH]
            titleLabel.frame.origin = [HalfDiffValue($0.frame.width, titleLabel.frame.width), imageView.frame.maxY + space]
        }
        
        let font = UIFont.systemFont(ofSize: 12.px, weight: .regular)
        let titleColor = UIColor.rgb(51, 51, 51)
        
        let sendGiftBtn = CustomLayoutButton(type: .system)
        sendGiftBtn.titleLabel?.font = font
        sendGiftBtn.setTitleColor(titleColor, for: .normal)
        sendGiftBtn.setTitle("send_gift".jp.localized, for: .normal)
        sendGiftBtn.setImage("chatroom_userinfo_card_gift".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendGiftBtn.rtl_refWidth = Self.contentW
        sendGiftBtn.rtl_frame = [0, btnY, btnW, btnH]
        sendGiftBtn.layoutSubviewsHandler = layoutSubviewsHandler
        sendGiftBtn.addTarget(self, action: #selector(sendGiftAction), for: .touchUpInside)
        operationView.addSubview(sendGiftBtn)
        
        let line1 = UIView(frame: [btnW, lineY, lineW, lineH])
        line1.backgroundColor = .rgb(230, 230, 230)
        operationView.addSubview(line1)
        
        let homePageBtn = CustomLayoutButton(type: .system)
        homePageBtn.titleLabel?.font = font
        homePageBtn.setTitleColor(titleColor, for: .normal)
        homePageBtn.setTitle("user_home".jp.localized, for: .normal)
        homePageBtn.setImage("chatroom_userinfo_card_homepage".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        homePageBtn.rtl_refWidth = Self.contentW
        homePageBtn.rtl_frame = [btnW, btnY, btnW, btnH]
        homePageBtn.layoutSubviewsHandler = layoutSubviewsHandler
        homePageBtn.addTarget(self, action: #selector(homePageAction), for: .touchUpInside)
        operationView.addSubview(homePageBtn)
        
        let line2 = UIView(frame: [btnW * 2, lineY, lineW, lineH])
        line2.backgroundColor = .rgb(230, 230, 230)
        operationView.addSubview(line2)
        
        let sendMsgBtn = CustomLayoutButton(type: .system)
        sendMsgBtn.titleLabel?.font = font
        sendMsgBtn.rtl_refWidth = Self.contentW
        sendMsgBtn.rtl_frame = [btnW * 2, btnY, btnW, btnH]
        sendMsgBtn.layoutSubviewsHandler = layoutSubviewsHandler
        sendMsgBtn.addTarget(self, action: #selector(sendMsgAction), for: .touchUpInside)
        operationView.addSubview(sendMsgBtn)
        
        if userInfo.isFriend {
            sendMsgBtn.titleLabel?.font = .systemFont(ofSize: 12.px, weight: .bold)
            sendMsgBtn.setTitleColor(.rgb(0, 201, 163), for: .normal)
            sendMsgBtn.setTitle("str_main_message_title1".jp.localized, for: .normal)
            sendMsgBtn.setImage("chatroom_userinfo_card_send_message".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            sendMsgBtn.titleLabel?.font = .systemFont(ofSize: 12.px, weight: .regular)
            sendMsgBtn.setTitleColor(.rgb(51, 51, 51), for: .normal)
            sendMsgBtn.setTitle("str_user_center_add_friends".jp.localized, for: .normal)
            sendMsgBtn.setImage("chatroom_userinfo_card_add_friend".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
//        sendGiftBtn.backgroundColor = .randomColor
//        homePageBtn.backgroundColor = .randomColor
//        sendMsgBtn.backgroundColor = .randomColor
    }
    
    /// 用户称号列表
    func setupTitlesView(_ userInfo: UserInfo, y: CGFloat) -> CGFloat {
        let usedTitles = userInfo.getUsedTitles()
        guard usedTitles.count > 0 else { return y }
        
        let titlesLayout = EMLUserTitleFlowView.Layout(
            viewOrigin: [0, y],
            viewWidth: Self.contentW,
            contentInset: UIEdgeInsets(top: 5.px, left: 16.px, bottom: 5.px, right: 16.px),
            contentAlignment: .center,
            interitemSpacing: 8.px,
            lineSpacing: 2.px,
            itemHeight: 25.px
        )
        let titlesView = EMLUserTitleFlowView(titlesLayout)
        contentView.addSubview(titlesView)
        titlesView.delegate = self
        titlesView.cellAnimated = true
        titlesView.reloadData(usedTitles)
        titlesView.alpha = 0
        self.titlesView = titlesView
        
        return y + titlesView.viewFrame.height
    }
    
    /// 国家区域徽章列表
    func setupBadgeCollectionView(_ userInfo: UserInfo, y: CGFloat) -> CGFloat {
        guard let badgelist = userInfo.badgelist, badgelist.count > 0 else { return y }
        
        let badgeCollectionView = EMLCountryRegionBadgeCollectionView(width: Self.contentW)
        badgeCollectionView.frame.origin.y = y
        contentView.addSubview(badgeCollectionView)
        badgeCollectionView.updateUI(badgelist)
        badgeCollectionView.alpha = 0
        self.badgeCollectionView = badgeCollectionView
        
        return y + badgeCollectionView.frame.height
    }
    
    /// 神秘人
    func setupMysteryView(_ userInfo: UserInfo) {
        guard let mysteryInfo = userInfo.mysteryInfo else { return }
        
        let mysteryView = UIView()
        mysteryView.backgroundColor = .clear
        mysteryView.alpha = 0
        contentView.addSubview(mysteryView)
        mysteryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.mysteryView = mysteryView
        
        // ------------------------------------------
        if !isMe, userInfo.isInSeat {
            let voiceBtn = HighlightUnchangedButton(type: .custom)
            voiceBtn.tintColor = .clear
            voiceBtn.setImage("chatroom_userinfo_card_voice_open".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
            voiceBtn.setImage("chatroom_userinfo_card_voice_close".jp.image?.withRenderingMode(.alwaysOriginal), for: .selected)
            voiceBtn.isSelected = JKRAgoraManager.shared().jkr_userIsBan(userInfo.uid)
            voiceBtn.addTarget(self, action: #selector(voiceAction(_:)), for: .touchUpInside)
            mysteryView.addSubview(voiceBtn)
            voiceBtn.snp.makeConstraints { make in
                make.width.height.equalTo(30.px)
                make.left.equalTo(14.px)
                make.top.equalTo(31.px)
            }
        }
        
        // ------------------------------------------
        identityView.axis = .horizontal
        identityView.alignment = .center
        identityView.distribution = .fill
        identityView.spacing = 4.px
        mysteryView.addSubview(identityView)
        identityView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(54.px)
            make.height.equalTo(21.px)
            make.leading.greaterThanOrEqualTo(16.px)
            make.trailing.lessThanOrEqualTo(-16.px)
        }
        
        nicknameLabel.font = UIFont.systemFont(ofSize: 18.px, weight: .semibold)
        nicknameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // 可以被压缩
        identityView.addArrangedSubview(nicknameLabel)
        
        if let medalUrl = mysteryInfo.medals.first {
            let mysteryIconView = UIImageView()
            identityView.addArrangedSubview(mysteryIconView)
            mysteryIconView.snp.makeConstraints { make in
                make.width.height.equalTo(18.px)
            }
            let url = URL(string: medalUrl.rq_20x20)
            mysteryIconView.jkr_setImage(with: url,
                                         placeholder: nil,
                                         loadErrorPlaceholder: nil,
                                         options: .setImageWithFadeAnimation)
        }
        
        // v9.13.0：神秘人不再显示房间贡献排名
//        let contribRanking = CrShared.contrib_ranking(uid)
//        if contribRanking > 0 {
//            let contribLabel = ContributionRankingLabel(height: 14.px)
//            let labelWH = contribLabel.frame.size
//            identityView.addArrangedSubview(contribLabel)
//            contribLabel.snp.makeConstraints { make in
//                make.size.equalTo(labelWH)
//            }
//            contribLabel.ranking = contribRanking
//        }
        
        // ------------------------------------------
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17.px, weight: .medium)
        label.textAlignment = .center
        label.textColor = .rgb(27, 18, 49)
        label.text = FallaLocalized.str_mysterious_using.string
        mysteryView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(identityView.snp.bottom)
            make.leading.equalTo(29.px)
            make.trailing.equalTo(-29.px)
            make.height.equalTo(134.px)
        }
        
        // ------------------------------------------
        if isMe {
            if userInfo.isInSeat {
                let manageView = UIStackView()
                manageView.clipsToBounds = false
                manageView.axis = .horizontal
                manageView.alignment = .fill
                manageView.distribution = .fillEqually
                manageView.spacing = 0
                mysteryView.addSubview(manageView)
                manageView.snp.makeConstraints { make in
                    make.bottom.equalTo(-20.px)
                    make.leading.equalTo(10.px)
                    make.trailing.equalTo(-10.px)
                    make.height.equalTo(35.px)
                }
                
                // 下麦
                let downMicBtn = UIButton(type: .system)
                downMicBtn.setImage("chatroom_userinfo_card_kick_down".jp.image?.withRenderingMode(.alwaysOriginal), for: .normal)
                downMicBtn.addTarget(self, action: #selector(upOrDownMicAction), for: .touchUpInside)
                manageView.addArrangedSubview(downMicBtn)
                
                if !userInfo.isSeatMute { // 麦位是否打开麦克风
                    // 开/闭麦
                    let toggleMuteBtn = UIButton(type: .system)
                    let image: UIImage?
                    if userInfo.isMicOpen {
                        if JKRAgoraManager.shared().noPermission {
                            image = "chatroom_userinfo_card_no_sound_banned".jp.image
                        } else {
                            image = "chatroom_userinfo_card_no_sound".jp.image
                        }
                    } else {
                        image = "chatroom_userinfo_card_no_sound_banned".jp.image
                    }
                    toggleMuteBtn.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                    toggleMuteBtn.addTarget(self, action: #selector(toggleMuteAction), for: .touchUpInside)
                    manageView.addArrangedSubview(toggleMuteBtn)
                }
            }
            return
        }
        
        // ------------------------------------------
        let isNeedSendGift = !isMe && userInfo.isInRoom
        let bottomInset = isNeedSendGift ? 52.px : 18.px
        
        let detailBtn = JPBounceView()
        detailBtn.layer.cornerRadius = 22.px
        detailBtn.layer.masksToBounds = true
        detailBtn.scale = 0.975
        detailBtn.viewTouchUpInside = { [weak self] _ in
            UIViewController.fa_topMostNavCtr?.pushViewController(FLMysteriousController(), animated: true)
            self?.closeHandler?(false)
        }
        mysteryView.addSubview(detailBtn)
        detailBtn.snp.makeConstraints { make in
            make.height.equalTo(44.px)
            make.leading.equalTo(29.px)
            make.trailing.equalTo(-29.px)
            make.bottom.equalTo(-bottomInset)
        }
        
        let gView = GradientView()
        gView.isUserInteractionEnabled = false
        gView.rtl_set(startPoint: [0, 0.5], endPoint: [1, 0.5])
        gView.colors = [.rgb(136, 97, 184), .rgb(26, 9, 75)]
        detailBtn.addSubview(gView)
        gView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let detailLabel = UILabel()
        detailLabel.font = .systemFont(ofSize: 18.px, weight: .bold)
        detailLabel.textColor = .white
        detailLabel.text = "check_detail".jp.localized
        detailBtn.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        if isNeedSendGift {
            let sendGiftBtn = UIButton(type: .system)
            let attTitle = NSAttributedString(string: "send_gift".jp.localized, attributes: [
                .font: UIFont.systemFont(ofSize: 13.px, weight: .medium),
                .foregroundColor: UIColor.rgb(144, 99, 181),
                .underlineStyle: NSUnderlineStyle.single.rawValue, // 改这里：single / thick / double
                .underlineColor: UIColor.rgb(144, 99, 181),
            ])
            sendGiftBtn.setAttributedTitle(attTitle, for: .normal)
            sendGiftBtn.addTarget(self, action: #selector(sendGiftAction), for: .touchUpInside)
            mysteryView.addSubview(sendGiftBtn)
            sendGiftBtn.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(20.px)
                make.bottom.equalTo(-16.px)
            }
        }
    }
}

// MARK: - 更新用户头像+用户基本信息
private extension EMLChatRoomUserInfoCard {
    func updateAvatar(_ userInfo: UserInfo) {
        let avatarurl: String?
        if isMystery {
            avatarurl = userInfo.mysteryInfo?.mysteryAvatar
        } else {
            avatarurl = userInfo.avatarurl
        }
        guard let avatarurl else { return }
        avatarView.jkr_setImage(with: URL(string: avatarurl.rq_100x100),
                                placeholder: avatarView.image,
                                options: .avoidSetImage) { [weak self] image, _, _, kUrl, isCancelled in
            if isCancelled { return }
            guard let self else { return }
            guard let imageURL = self.avatarView.imageURL, imageURL == kUrl else { return }
            self.avatarView.image = image ?? "header_no".jp.image
            self.avatarView.jp.addFade(duration: 0.2)
        }
    }
    
    func updateBaseInfo(_ userInfo: UserInfo) {
        if isMystery {
            let nickname = userInfo.mysteryInfo?.mysteryName ?? ""
            nicknameLabel.jkr_setMysteryNickname(nickname, showMask: true, defaultTextColor: .black)
            return
        }
        
        // ------------------------------------------
        nicknameLabel.jkr_setNickName(withNickName: userInfo.nickname ?? "",
                                      nobility: userInfo.nobility,
                                      svip: userInfo.svip,
                                      showMask: true,
                                      defaultTextColor: .rgb(51, 51, 51))
        
        if userInfo.gender == 1 || userInfo.gender == 2 {
            let genderIconView = UIImageView()
            genderIconView.image = userInfo.gender == 1 ? "icon_gender_male".jp.image : "icon_gender_female".jp.image
            identityView.addArrangedSubview(genderIconView)
            genderIconView.snp.makeConstraints { make in
                make.width.height.equalTo(14.px)
            }
        }
        
        if userInfo.groupPower.rawValue >= ChatRoomGroupPower.member.rawValue {
            let powerIconView = UIImageView()
            powerIconView.image = UIImage.jkr_getGroupPowerImage(with: userInfo.groupPower, groupSubPower: userInfo.groupSubPower)
            identityView.addArrangedSubview(powerIconView)
            powerIconView.snp.makeConstraints { make in
                make.width.height.equalTo(14.px)
            }
        }
        
        /// V9.18.0 外管身份标签
        let identityIconW = userInfo.identityLabelResources?.weight ?? 0
        let identityIconH = userInfo.identityLabelResources?.height ?? 0
        let identityUrl = userInfo.identityLabelResources?.resourceUrl ?? ""
        
        if identityIconW.isNaN == false && identityIconH.isNaN == false && identityIconW > 0 && identityIconH > 0 && identityUrl.count > 0 {
            let identityIconView = UIImageView()
            identityView.addArrangedSubview(identityIconView)
            
            let showWidth = 20 * (identityIconW / identityIconH)
            identityIconView.snp.makeConstraints { make in
                make.height.equalTo(20.px)
                make.width.equalTo(showWidth.px)
            }
            identityIconView.jkr_setImage(with: URL.init(string: identityUrl))
        }
        
        let contribRanking = CrShared.contrib_ranking(uid)
        if contribRanking > 0 {
            let contribLabel = ContributionRankingLabel(height: 14.px)
            let labelWH = contribLabel.frame.size
            identityView.addArrangedSubview(contribLabel)
            contribLabel.snp.makeConstraints { make in
                make.size.equalTo(labelWH)
            }
            contribLabel.ranking = contribRanking
        }
        
        // ------------------------------------------
        var index = 0
        if userInfo.svip > 0 {
            let svip = userInfo.svip > 11 ? 11 : userInfo.svip
            let svipIconView = UIImageView()
            svipIconView.image = "icon_svip_\(svip)".jp.image
            svipIconView.contentMode = .scaleAspectFit
            svipIconView.isUserInteractionEnabled = true
            svipIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSvipIconView)))
            profileView.insertArrangedSubview(svipIconView, at: index)
            svipIconView.snp.makeConstraints { make in
                make.width.equalTo(63.px)
                make.height.equalTo(16.px)
            }
            index += 1
        }
        
        if userInfo.influenceLv > 0 {
            let influenceLvView = JKRInfluenceLvView()
            profileView.insertArrangedSubview(influenceLvView, at: index)
            influenceLvView.snp.makeConstraints { make in
                make.width.equalTo(JKRInfluenceLvView.getWidthWithHeight(16.px))
                make.height.equalTo(16.px)
            }
            influenceLvView.jkr_setIcon(withInfluenceLevel: userInfo.influenceLv)
        }
        
        uidView.updateUI(withId: userInfo.suid ?? "",
                         idLv: userInfo.newSuidLv,
                         nobility: userInfo.nobility,
                         svip: userInfo.svip)
        
        // hidePrivacyInfo 隐藏个人信息 1-隐藏，2-展示（国家、注册天数、关注数、粉丝数和访客数）
        if userInfo.hidePrivacyInfo == 1 {
            countryLabel.text = "***"
        } else {
            countryLabel.text = userInfo.countryname
        }
        
        // ------------------------------------------
        if userInfo.familyId > 0, let title = userInfo.familyNameplate, let conf = userInfo.familyNameplateConf {
            let nameplateView = FamilyNameplateView(viewH: 20.px)
            nameplateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapFamilyNameplate)))
            
            levelsView.addArrangedSubview(nameplateView)
            nameplateView.snp.makeConstraints { make in
                make.height.equalTo(20.px)
            }
            
            nameplateView.updateUI(bgUrl: conf.bgImg,
                                   badgeUrl: conf.medalImg,
                                   titleColor: conf.fontColor,
                                   title: title)
        }
        
        if userInfo.wealthlv > 0 {
            let wealthIconView = SweepImageView()
            wealthIconView.contentMode = .scaleAspectFit
            wealthIconView.sweepWidth = 15
            levelsView.addArrangedSubview(wealthIconView)
            wealthIconView.snp.makeConstraints { make in
                make.width.equalTo(34.px)
                make.height.equalTo(14.px)
            }
            wealthIconView.jkr_setWealthLvImage(withWealthLv: userInfo.wealthlv)
        }
        
        if userInfo.charmlv > 0 {
            let charmIconView = SweepImageView()
            charmIconView.contentMode = .scaleAspectFit
            charmIconView.sweepWidth = 15
            levelsView.addArrangedSubview(charmIconView)
            charmIconView.snp.makeConstraints { make in
                make.width.equalTo(34.px)
                make.height.equalTo(14.px)
            }
            charmIconView.jkr_setCharmLvImage(withCharmLv: userInfo.charmlv)
        }
        
        if userInfo.activelv > 0 {
            let activeIconView = UIImageView()
            activeIconView.contentMode = .scaleAspectFit
            levelsView.addArrangedSubview(activeIconView)
            activeIconView.snp.makeConstraints { make in
                make.width.equalTo(34.px)
                make.height.equalTo(14.px)
            }
            activeIconView.jkr_setActiveLvImage(withActiveLv: userInfo.activelv)
        }
        
        if userInfo.newerStatus == 1 {
            let newUserIconView = UIImageView(image: "new_user_medal_icon".jp.image)
            newUserIconView.contentMode = .scaleAspectFit
            levelsView.addArrangedSubview(newUserIconView)
            newUserIconView.snp.makeConstraints { make in
                make.width.equalTo(34.px)
                make.height.equalTo(14.px)
            }
        }
        
        if userInfo.cpState == 1, userInfo.cpLv > 0 {
            let cpLevelIconView = UIImageView()
            cpLevelIconView.contentMode = .scaleAspectFit
            levelsView.addArrangedSubview(cpLevelIconView)
            cpLevelIconView.snp.makeConstraints { make in
                make.width.equalTo(24.px)
                make.height.equalTo(24.px)
            }
            cpLevelIconView.jkr_setCpLvImage(withCpLv: userInfo.cpLv)
        }
        
        levelsView.isHidden = levelsView.arrangedSubviews.count == 0
        
        // 勋章 V2（钻章+勋章双尺寸混排）：过滤印记(style=1)及非 2/3、按服务端下发序渲染（不重排），
        // 逐项双尺寸（勋章 baseWH=20 / 钻章 round(20×1.2)=24），resize 后缀随 style。复用组件层公共类方法（§3/§4a）。
        let displayableMedalsV2 = JKRMedalIconV2Model.displayableMedalsIconV2(userInfo.medalsIconV2)
        let medalsV2 = Array(displayableMedalsV2.prefix(10)) // 最多显示10个
        for medal in medalsV2 {
            let medalIconView = UIImageView()
            medalIconView.contentMode = .scaleAspectFit
            medalsView.addArrangedSubview(medalIconView)
            // 约束边长走 .px（与卡片其它图标一致的屏幕适配尺寸）：勋章 20.px / 钻章 round(20.px×1.2)。
            let wh = medal.medalWH(20.px)
            medalIconView.snp.makeConstraints { make in
                make.width.height.equalTo(wh)
            }
            // 图源 baseWH 走逻辑 20（组件内部乘 screen scale）：勋章位与旧 rq_20x20 字节级等价，钻章按逻辑 24（§4a）。
            let urlStr = medal.resizedIconURL(20) ?? ""
            medalIconView.jkr_setImage(
                with: URL(string: urlStr),
                placeholder: nil,
                loadErrorPlaceholder: nil,
                options: .setImageWithFadeAnimation
            )
        }
        
        medalsView.isHidden = medalsView.arrangedSubviews.count == 0
    }
}

// MARK: - 更新卡片布局+卡片皮肤+头饰及其他UI
private extension EMLChatRoomUserInfoCard {
    func updateCardLayout(_ userInfo: UserInfo, _ contentH: CGFloat) {
        var borderColor: UIColor?
        var colors: [UIColor]?
        if let skin = userInfo.dataCardSkin {
            if !skin.borderColor.isEmpty {
                borderColor = UIColor(hexString: skin.borderColor)
            }
            if skin.gradientColor.count > 0 {
                colors = skin.gradientColor.map { UIColor(hexString: $0) }
            }
        }
        
        contentView.snp.updateConstraints { make in
            make.height.equalTo(contentH)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1) {
            self.superview?.layoutIfNeeded()
            
            if let borderColor {
                self.contentView.layer.borderColor = borderColor.cgColor
                self.contentView.layer.borderWidth = 2.px
            }
            
            if let colors {
                self.contentView.colors = colors
            }
        }
        
        var showViews: [UIView] = []
        if isMystery {
            if let mysteryView {
                showViews.append(mysteryView)
            }
        } else {
            if let nobilityIconView {
                showViews.append(nobilityIconView)
            }
            if let cpAvatarView {
                showViews.append(cpAvatarView)
            }
            if let topView {
                showViews.append(topView)
            }
            showViews.append(baseInfoView)
            showViews.append(signatureLabel)
            if let titlesView {
                showViews.append(titlesView)
            }
            if let badgeCollectionView {
                showViews.append(badgeCollectionView)
            }
            if let operationView {
                showViews.append(operationView)
            }
            if let manageView {
                showViews.append(manageView)
            }
        }
        UIView.animate(withDuration: 0.2, delay: 0.1) {
            for view in showViews {
                view.alpha = 1
            }
        }
    }
    
    func updateCardSkin(_ userInfo: UserInfo) {
        guard let skin = userInfo.dataCardSkin else { return }
        
        // 皮肤头冠
        if let visualView {
            visualView.updateUI(url: skin.svga.isEmpty ? skin.topImage : skin.svga, animated: true)
        }
        
        // 贵族图腾
        if let totemIconView {
            totemIconView.jkr_setImage(with: URL(string: skin.bgImage),
                                       placeholder: nil,
                                       loadErrorPlaceholder: nil,
                                       options: .setImageWithFadeAnimation)
        }
    }
    
    func updateAvatarOtherUI(_ userInfo: UserInfo) {
        // 头饰
        if isMystery {
            if let mysteryInfo = userInfo.mysteryInfo {
                headwearView.updateUI(source: .svga(mysteryInfo.headSvga), animated: true)
            } else {
                headwearView.clean(animated: true)
            }
        } else {
            if let headSvga = userInfo.headSvga, !headSvga.isEmpty {
                headwearView.updateUI(source: .svga(headSvga), avatarUrl: userInfo.headEffectCfg?.avatarurl2, animated: true)
            } else if let headImage = userInfo.headImage, !headImage.isEmpty {
                headwearView.updateUI(source: .remote(headImage), animated: true)
            } else {
                headwearView.clean(animated: true)
            }
        }
        
        // 贵族图标
        if let nobilityIconView, let nobilityIcon = userInfo.nobilityIcon {
            nobilityIconView.jkr_setImage(with: URL(string: nobilityIcon.rq_40x40),
                                          placeholder: nil,
                                          loadErrorPlaceholder: nil,
                                          options: .setImageWithFadeAnimation)
        }
        
        // CP头像
        if let cpAvatarView, let cpAvatarurl = userInfo.cpAvatarurl {
            cpAvatarView.jkr_setImage(with: URL(string: cpAvatarurl.rq_40x40),
                                      placeholder: cpAvatarView.image,
                                      loadErrorPlaceholder: cpAvatarView.image,
                                      options: .setImageWithFadeAnimation)
        }
        
        // CP戒指
        if let ringSvgaPlayer, let cpRingInfo = userInfo.cpRingInfo {
            let mode: RingerFXPlayer.Mode
            if cpRingInfo.ringLv == "S", !cpRingInfo.beginMp4.isEmpty, !cpRingInfo.loopMp4.isEmpty {
                mode = .mp4_loopMp4(mp4Url: cpRingInfo.beginMp4, loopMp4Url: cpRingInfo.loopMp4)
            } else {
                if !cpRingInfo.effect.isEmpty {
                    mode = .mp4_svga(mp4Url: "", svgaUrl: cpRingInfo.effect, svgaLoopFrame: 40)
                } else {
                    mode = .mp4_svga(mp4Url: "", svgaUrl: cpRingInfo.image)
                }
            }
            ringSvgaPlayer.play(mode: mode)
        }
    }
}
