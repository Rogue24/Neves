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
            JPHUD.showInfo(withStatus: "用户已开启VIP\(nobility)特权：榜单上匿名")
            
        case let .room(gid):
            Self.push(.room(gid), currentVC)
            
        case let .profile(uid):
            Self.push(.other({
                let vc = TestBaseViewController()
                vc.title = "个人主页_\(uid)"
                return vc
            }), currentVC)
            
        case let .svip(level):
            Self.push(.other({
                let vc = TestBaseViewController()
                vc.title = "SVIP详情_\(level)"
                return vc
            }), currentVC)
            break
            
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
            Self.push(.other({
                let vc = TestBaseViewController()
                vc.title = "WebView"
                return vc
            }), currentVC)
        }
    }
    
    private enum PushVC {
        case room(_ gid: Int)
        case other(_ builder: () -> UIViewController)
    }
    
    private static func push(_ toVC: PushVC, _ fromVC: some MedalRouterCompatible) {
        guard fromVC.navigationController == nil, let presentingVC = fromVC.presentingViewController else {
            switch toVC {
            case let .room(gid):
                let vc = TestBaseViewController()
                vc.title = "ChatRoom_\(gid)"
                fromVC.jp.topNavCtr?.pushViewController(vc, animated: true)
            case let .other(builder):
                fromVC.jp.topNavCtr?.pushViewController(builder(), animated: true)
            }
            return
        }
        
        fromVC.close()
        
        Asyncs.mainDelay(0.05) {
            switch toVC {
            case let .room(gid):
                let vc = TestBaseViewController()
                vc.title = "ChatRoom_\(gid)"
                presentingVC.jp.topNavCtr?.pushViewController(vc, animated: true)
            case let .other(builder):
                presentingVC.jp.topNavCtr?.pushViewController(builder(), animated: true)
            }
        }
    }
}

