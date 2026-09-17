//
//  EMLChatRoomUserInfoCard+Action.swift
//  Falla
//
//  Created by aa on 2025/6/23.
//

import UIKit

// MARK: - 用户头像+CP头像+CP戒指
extension EMLChatRoomUserInfoCard {
    @objc func tapAvatarView() {
        guard let userInfo else { return }
        jumpToUserHomePage(userInfo.uid)
    }
    
    @objc func tapCpAvatarView() {
        guard let userInfo else { return }
        jumpToUserHomePage(userInfo.cpUid)
    }
    
    @objc func tapRingSvgaPlayer() {
        guard let userInfo, let navCtr = viewController?.navigationController else { return }
        guard let urlCpSpace = JKRSystemConfigManager.shared().jkr_getSystemConfigModel()?.urlCpSpace else { return }
        
        let urlStr = "\(urlCpSpace)?uid=\(userInfo.cpUid)"
        let webVC = JKRWebViewController(urlString: urlStr)
        navCtr.pushViewController(webVC, animated: true)
        
        closeHandler?(false)
    }
}

// MARK: - 顶部栏：更多+静音+@用户
extension EMLChatRoomUserInfoCard {
    @objc func moreAction() {
        guard let userInfo, let viewController else { return }
        let uid = userInfo.uid
        JKRSheetController()
            .addAction("report_user".fa.localized) {
                guard let urlReport = JKRSystemConfigManager.shared().jkr_getSystemConfigModel()?.urlReport else { return }
                let urlStr = urlReport + "?targetUid=\(uid)&targetGid=0"
                FallaRouter.jump(url: urlStr)
            }
            .presentFrom(viewController)
    }
    
    @objc func voiceAction(_ sender: UIButton) {
        guard let userInfo else { return }
        
        if sender.isSelected {
            if JKRAgoraManager.shared().jkr_unBanUserVoice(userInfo.uid) {
                sender.isSelected = false
                return
            }
        } else {
            if JKRAgoraManager.shared().jkr_banUserVoice(userInfo.uid) {
                sender.isSelected = true
                EML_EventLog("click_soundoff")
                JKRHUDManager.toast(withMessage: "str_room_user_block_user_voice".fa.localized)
                return
            }
        }
        
        JKRHUDManager.toast(withMessage: "network_status_room".fa.localized)
    }
    
    @objc func atAction() {
        guard let userInfo, let viewController else { return }
        JKRChatRoomInputController.show(
            from: viewController,
            atUserName: "@" + (userInfo.nickname ?? ""),
            atUserUid: userInfo.uid
        )
        closeHandler?(false)
    }
}

// MARK: - 基本信息：勋章墙+家族+SVIP
extension EMLChatRoomUserInfoCard {
//    @objc func tapMedalsView() {
//        guard let userInfo, let viewController else { return }
//        MedalWallPopViewController.show(from: viewController, model: userInfo)
//    }
    
    @objc func tapFamilyNameplate() {
        guard let userInfo, let navCtr = viewController?.navigationController else { return }
        let familyVC = JKRFamilyDetailController()
        familyVC.familyId = userInfo.familyId
        navCtr.pushViewController(familyVC, animated: true)
    }
    
    @objc func tapSvipIconView() {
        guard let userInfo, let navCtr = viewController?.navigationController else { return }
        let svipVC = YYJSVIPViewController(svipLevel: userInfo.svip)
        navCtr.pushViewController(svipVC, animated: true)
    }
}

// MARK: - <EMLUserTitleFlowViewDelegate> 用户称号
extension EMLChatRoomUserInfoCard: EMLUserTitleFlowViewDelegate {
    func userTitleFlowView(_ titleFlowView: EMLUserTitleFlowView, didSelectCellFor jumpUrl: String) {
        // JP_Test
//        jumpUrl = @"vochat://hallOfFame/identityCard/popUp?season=1&val=123&enterTimestamp=1725422097&seasonBeginTimestamp=1725422099&topN=1";
//        jumpUrl = @"vochat://highlightCard?card=https%3A%2F%2Fres-g.resygg.com%2Fawss3_4268622_1726716164082761938_1460321395.png&senderAvatar=https%3A%2F%2Ffalla-ures1.resygg.com%2F12925000-1641976321.180380-22c83f7da87e101efeee8b23296fc94d.jpg&senderName=aaa&receiverAvatar=https%3A%2F%2Ffalla-res1.resygg.com%2Fawss3_10000_1678863002644383283_1414387739.jpg&reveiverName=bbb&sendTime=1728702216";
        guard !jumpUrl.isEmpty, let userInfo else { return }
        
        guard jumpUrl.hasPrefix(JUMP_HOF_IDENTITYCARD_KEY) else {
            FallaRouter.jump(url: jumpUrl)
            return
        }
        
        let avatarurl = userInfo.avatarurl ?? ""
        let nickname = userInfo.nickname ?? ""
        var suid = userInfo.suid ?? ""
        if suid.isEmpty { suid = "\(userInfo.uid)" }
        let region = userInfo.region
        
        FallaRouter.hofIdentityCard_handling(jumpUrl) {
            var params = $0
            params["avatarurl"] = avatarurl
            params["nickname"] = nickname
            params["suid"] = suid
            params["region"] = region
            return params
        }
    }
}

// MARK: - 操作栏：发送礼物+用户主页+发消息/好友申请
extension EMLChatRoomUserInfoCard {
    @objc func sendGiftAction() {
        guard let userInfo else { return }
        EML_EventLog("room_usercard_gift")
        let suid: String?
        let avatarurl: String?
        let nickname: String?
        if isMystery {
            suid = "*****"
            avatarurl = userInfo.mysteryInfo?.mysteryAvatar
            nickname = userInfo.mysteryInfo?.mysteryName
        } else {
            suid = userInfo.suid
            avatarurl = userInfo.avatarurl
            nickname = userInfo.nickname
        }
        ChatRoomViewController.sendGift(toUser: userInfo.uid,
                                        suid: suid,
                                        avatarurl: avatarurl,
                                        nickname: nickname,
                                        isMystery: isMystery)
        closeHandler?(false)
    }

    @objc func homePageAction() {
        guard let userInfo else { return }
        EML_EventLog("room_usercard_homepage")
        jumpToUserHomePage(userInfo.uid)
    }

    @objc func sendMsgAction() {
        guard let userInfo, let navCtr = viewController?.navigationController else { return }
        EML_EventLog("room_usercard_friend")
        
        let uid = userInfo.uid
        
        if userInfo.isFriend {
            let conversationVC = NewConversationViewController()
            conversationVC.targetId = "\(uid)"
            conversationVC.conversationType = .ConversationType_PRIVATE
            conversationVC.source = "语聊房"
            navCtr.pushViewController(conversationVC, animated: true)
            return
        }
        
        // 好友申请
        let alertCtr = JKRAlertViewController.alert(withAlertTitle: "str_friend_dialog_friend_apply_title".fa.localized, alertMessage: nil)
        alertCtr.addTextField {
            $0.text = "str_dialog_room_add_friend_hint".fa.localized
            $0.isUserInteractionEnabled = false
        }
        alertCtr
            .addCommonCancel(nil)
            .addCommonConfirm {
                JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/friend/invite", params: ["uid": uid, "content": ""]) { _ in
                    JKRHUDManager.toast(withMessage: "str_dialog_room_add_friend_toast".fa.localized)
                } failure: { error in
                    JKRHUDManager.toast(withMessage: error.localizedDescription)
                } cancel: {}
            }
            .presentFrom(navCtr)
    }
}

// MARK: - 管理栏：上/下麦+开/闭麦+设置权限+禁言+踢出
extension EMLChatRoomUserInfoCard {
    @objc func upOrDownMicAction() {
        // 神秘人不能对他人操作
        if !isMe, JKRUserManager.shared().user?.currentIsMystery() == true {
            JKRHUDManager.toast(withMessage: FallaLocalized.str_mysterious_switch_to_real_identity_tip.string)
            return
        }
        
        guard let userInfo, let viewController else { return }
        
        let uid = userInfo.uid
        closeHandler?(false)
        
        if userInfo.isInSeat {
            HDMGPGameManager.shared().exitGame(withVC: viewController, operation: 1, userId: "\(uid)") {
                CrShared.seatView.exitSeat(userId: uid) {
                    EML_EventLog("room_usercard_disablemic")
                } failure: { _ in }
            }
            return
        }
        
        let params: [AnyHashable: Any] = [
            "uid": uid,
            "gid": CrShared.gid,
            "groupModeId": CrShared.baseRoomInfo?.groupModeId ?? 0,
        ]
        JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/group/seat/invite", params: params) { _ in
            JKRHUDManager.toast(withMessage: "str_cp_apply_sent_tips".fa.localized)
        } failure: { error in
            switch (error as NSError).code {
            case FallaErrorCode.exitRoom.rawValue:
                CrShared.exitRoom()
            default:
                JKRHUDManager.toast(withMessage: error.localizedDescription)
            }
        } cancel: {}
    }
    
    @objc func toggleMuteAction() {
        // 神秘人不能对他人操作
        if !isMe, JKRUserManager.shared().user?.currentIsMystery() == true {
            JKRHUDManager.toast(withMessage: FallaLocalized.str_mysterious_switch_to_real_identity_tip.string)
            return
        }
        
        guard let userInfo else { return }
        
        let isToClose: Bool
        if isMe {
            isToClose = !JKRAgoraManager.shared().noPermission && userInfo.isMicOpen
        } else {
            isToClose = userInfo.isMicOpen
        }
        
        if isToClose {
            CrShared.seatView.closeMic(userID: userInfo.uid, isOnlyMic: false)
        } else {
            CrShared.seatView.openMic(userID: userInfo.uid)
        }
        
        closeHandler?(false)
    }

    @objc func manageAction() {
        // 神秘人不能对他人操作
        if !isMe, JKRUserManager.shared().user?.currentIsMystery() == true {
            JKRHUDManager.toast(withMessage: FallaLocalized.str_mysterious_switch_to_real_identity_tip.string)
            return
        }
        
        InnerRoomSelectionVC.show(from: self.viewController, setUserGroupPower: userInfo) { [weak self] power, adminPower in
            self?.trySetUserPower(power, adminPower)
        }
    }

    @objc func forbidAction() {
        // 神秘人不能对他人操作
        if !isMe, JKRUserManager.shared().user?.currentIsMystery() == true {
            JKRHUDManager.toast(withMessage: FallaLocalized.str_mysterious_switch_to_real_identity_tip.string)
            return
        }
        
        guard let userInfo, let viewController else { return }
        
        let uid = userInfo.uid
        let isToForbidMsg = !userInfo.isForbidMsg
        
        let title = isToForbidMsg ? "forbid_user_send_msg".fa.localized : "unforbid_user_send_msg".fa.localized
        JKRAlertViewController.alert(withAlertTitle: title, alertMessage: nil)
            .addCommonCancel(nil)
            .addCommonConfirm {
                let params: [AnyHashable: Any] = [
                    "uid": uid,
                    "gid": CrShared.gid,
                    "durationSec": isToForbidMsg ? 86400 : -1,
                ]
                JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/group/ban", params: params) { [weak self] _ in
                    JKRHUDManager.toast(withMessage: "setting_success".fa.localized)
                    if isToForbidMsg { EML_EventLog("room_usercard_disablechat") }
                    self?.closeHandler?(false)
                } failure: { error in
                    switch (error as NSError).code {
                    case FallaErrorCode.nobilityCannotForbidden.rawValue:
                        JKRHUDManager.toast(withMessage: "app_nobility_stop_voice_king_fail".fa.localized)
                        
                    case FallaErrorCode.userNotAdmin.rawValue:
                        JKRHUDManager.toast(withMessage: "str_country_admin_power_error".fa.localized)
                        
                    case FallaErrorCode.exitRoom.rawValue:
                        CrShared.exitRoom()
                        
                    default:
                        JKRHUDManager.toast(withMessage: error.localizedDescription)
                    }
                } cancel: {}
            }
            .presentFrom(viewController)
    }

    @objc func kickoutAction() {
        // 神秘人不能对他人操作
        if !isMe, JKRUserManager.shared().user?.currentIsMystery() == true {
            JKRHUDManager.toast(withMessage: FallaLocalized.str_mysterious_switch_to_real_identity_tip.string)
            return
        }
        
        InnerRoomSelectionVC.show(from: self.viewController, kickUserFromRoom: { [weak self] seconds in
            self?.kickOut(seconds)
        })
    }
}

// MARK: - 私有方法
private extension EMLChatRoomUserInfoCard {
    // MARK: 用户主页跳转
    func jumpToUserHomePage(_ uid: Int) {
        guard CrShared.gotoUserHomePage(uid, isMystery: (uid == self.uid ? isMystery : false)) else {
            return
        }
        closeHandler?(false)
    }
    
    // MARK: 设置用户权限
    func trySetUserPower(_ groupPower: ChatRoomGroupPower, _ groupSubPower: ChatRoomGroupAdminPower) {
        guard let userInfo else { return }

        guard groupSubPower == .`super` else {
            _updateUserPower(groupPower, groupSubPower)
            return
        }

        let uid = userInfo.uid
        let nickname = userInfo.nickname ?? ""

        // 7.8.0 设置超管要先查房间超管人数上限以及超管用户信息
        JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/group/superAdmin", params: ["gid": CrShared.gid]) { [weak self] returnValue in
            guard let self, let dict = returnValue else { return }

            // 先判断当前用户是不是已经是超级管理员
            let superAdminMembers = dict["superAdminMembers"] as? [[AnyHashable: Any]] ?? []

            let isAlreadySuperAdmin = superAdminMembers.contains {
                let kUid = $0["uid"] as? Int ?? 0
                return kUid == uid
            }

            guard !isAlreadySuperAdmin else {
                // 已是超管toast提示就好
                JKRHUDManager.toast(withMessage: "str_already_super_administrator".fa.localized)
                return
            }


            // 如果还不是超管且此房间已有超管的情况下 要判断超管上限人数，没达到上限直接设置，到达上限就替换最旧的超管：就是拿第一个元素
            let superAdminMaxNum = dict["superAdminMaxNum"] as? Int ?? 0
            guard superAdminMembers.count > 0, superAdminMaxNum <= superAdminMembers.count else {
                self._updateUserPower(groupPower, groupSubPower)
                return
            }

            let firstUser = superAdminMembers[0]
            let firstUserNickname = firstUser["nickname"] as? String ?? ""
            let title = "str_super_admin_power_change_new".fa.localized(nickname, firstUserNickname, superAdminMaxNum)
            JKRAlertViewController.alert(withAlertTitle: title, alertMessage: nil)
                .addCommonCancel(nil)
                .addCommonConfirm { self._updateUserPower(groupPower, groupSubPower) }
                .presentFrom(self.viewController)

        } failure: { error in
            JKRHUDManager.toast(withMessage: error.localizedDescription)
        } cancel: {}
    }
    
    // MARK: 权限更新
    func _updateUserPower(_ groupPower: ChatRoomGroupPower, _ groupSubPower: ChatRoomGroupAdminPower) {
        guard let userInfo else { return }
        let oldGroupPower = userInfo.groupPower
        let oldGroupSubPower = userInfo.groupSubPower
        
        let params: [AnyHashable: Any] = [
            "uid": userInfo.uid,
            "gid": CrShared.gid,
            "groupPower": groupPower.rawValue,
            "groupSubPower": groupSubPower.rawValue,
        ]
        JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/group/user/invite", params: params) { [weak self] _ in
            if groupPower.rawValue > oldGroupPower.rawValue {
                JKRHUDManager.toast(withMessage: "str_invite_group_invite_success".fa.localized)
            }
            else if groupPower == oldGroupPower, groupSubPower != oldGroupSubPower, oldGroupSubPower != .`super` {
                JKRHUDManager.toast(withMessage: "str_invite_group_invite_success".fa.localized)
            }
            else {
                JKRHUDManager.toast(withMessage: "setting_success".fa.localized)
            }
            
            CrShared.seatView.getMicListDataFromService()
            EML_EventLog("room_usercard_privilege")
            self?.closeHandler?(false)
            
        } failure: { [weak self] error in
            switch (error as NSError).code {
            case FallaErrorCode.roomAdminLimitReached.rawValue:
                guard let navCtr = self?.viewController?.navigationController else { return }
                JKRAlertViewController.alert(withAlertTitle: "room_set_manager_full_hint".fa.localized, alertMessage: nil)
                    .addDefault("check_room_manager_list".fa.localized) {
                        navCtr.pushViewController(EMLRoomManagerViewController(), animated: true)
                    }
                    .addCommonCancel(nil)
                    .presentFrom(navCtr)
                
            case FallaErrorCode.userNotAdmin.rawValue:
                JKRHUDManager.toast(withMessage: "str_country_admin_power_error".fa.localized)
                
            case FallaErrorCode.exitRoom.rawValue:
                CrShared.exitRoom()
                
            default:
                JKRHUDManager.toast(withMessage: error.localizedDescription)
                self?.closeHandler?(false)
            }
        } cancel: {}
    }
    
    // MARK: 踢出房间
    func kickOut(_ seconds: Int) {
        guard let userInfo, let viewController else { return }
        let uid = userInfo.uid
        HDMGPGameManager.shared().exitGame(withVC: viewController, operation: 2, userId: "\(uid)") {
            let params: [AnyHashable: Any] = [
                "uid": uid,
                "gid": CrShared.gid,
                "durationSec": seconds,
            ]
            JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/group/kick", params: params) { [weak self] _ in
                JKRHUDManager.toast(withMessage: "setting_success".fa.localized)
                EML_EventLog("room_usercard_kickout")
                self?.closeHandler?(false)
            } failure: { error in
                switch (error as NSError).code {
                case FallaErrorCode.nobilityCannotKicked.rawValue:
                    JKRHUDManager.toast(withMessage: "app_nobility_kit_out_room_king_fail".fa.localized)

                case FallaErrorCode.userNotAdmin.rawValue:
                    JKRHUDManager.toast(withMessage: "str_country_admin_power_error".fa.localized)

                case FallaErrorCode.exitRoom.rawValue:
                    CrShared.exitRoom()

                default:
                    JKRHUDManager.toast(withMessage: error.localizedDescription)
                }
            } cancel: {}
        }
    }
}
