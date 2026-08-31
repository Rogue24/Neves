//
//  MedalRouter.swift
//  Falla
//
//  Created by aa on 2023/7/12.
//

import Foundation

protocol MedalRouterCompatible: UIViewController {
    var isPop: Bool { get }
    func close()
}

enum MedalRouter {
    case anonymons(_ nobility: Int)
    case room(_ gid: Int)
    case profile(_ uid: Int)
    case svip(_ level: Int)
    case ranking(_ isPop: Bool)
    case detailList(_ medalList: [JKRUserMedalsList],
                    _ targetIndex: Int,
                    _ indexDidChanged: ((_ currentIndex: Int) -> Void)?)
    case desc
    
    static weak var currentVC: MedalRouterCompatible?
    
    func jump() {
        guard let currentVC = Self.currentVC else { return }
        
        switch self {
        case let .anonymons(nobility):
            EMLNobilityAnonymonsAlertController.show(from: currentVC,
                                                     typeIdx: EMLAnonymonsEnterType_RankingList,
                                                     nobility: nobility)
            
        case let .room(gid):
            Self.push(.room(gid), currentVC)
            
        case let .profile(uid):
            Self.push(.other({
                let vc = EMLPersonalCenterViewController()
                vc.userId = uid
                vc.source = "勋章榜单"
                return vc
            }), currentVC)
            
        case let .svip(level):
            Self.push(.other({ YYJSVIPViewController(svipLevel: level) }), currentVC)
            
        case let .ranking(isPop):
            guard isPop else {
                Self.push(.other({ MedalRankingViewController() }), currentVC)
                return
            }
            MedalRankingPopViewController.show(from: currentVC)
            
        case let .detailList(medalList, targetIndex, indexDidChanged):
            MedalDetailListViewController.show(
                from: currentVC,
                userMedalList: medalList,
                targetIndex: targetIndex,
                indexDidChanged: indexDidChanged
            )
            
        case .desc:
            guard let urlStr = JKRSystemConfigManager.shared().jkr_getSystemConfigModel()?.medalDescUrl else { return }
            Self.push(.other({ JKRWebViewController(urlString: urlStr) }), currentVC)
        }
    }
    
    private enum PushVC {
        case room(_ gid: Int)
        case other(_ builder: () -> UIViewController)
    }
    
    private static func push(_ toVC: PushVC, _ fromVC: MedalRouterCompatible) {
        guard fromVC.navigationController == nil, let presentingVC = fromVC.presentingViewController else {
            switch toVC {
            case let .room(gid):
                ChatRoomViewController.joinChatRoom(groupID: gid)
            case let .other(builder):
                fromVC.fa_topMostNavCtr?.pushViewController(builder(), animated: true)
            }
            return
        }
        
        fromVC.close()
        
        Asyncs.mainDelay(0.05) {
            switch toVC {
            case let .room(gid):
                ChatRoomViewController.joinChatRoom(groupID: gid)
            case let .other(builder):
                presentingVC.fa_topMostNavCtr?.pushViewController(builder(), animated: true)
            }
        }
    }
}

