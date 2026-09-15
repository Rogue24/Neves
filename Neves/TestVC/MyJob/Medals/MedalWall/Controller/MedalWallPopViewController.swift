//
//  MedalWallViewController.swift
//  Neves
//
//  Created by aa on 2023/7/6.
//

import UIKit
import SnapKit

@objcMembers
class MedalWallPopViewController: UIViewController {
    static let contentSize: CGSize = [Env.screenWidth, Env.screenHeight - Env.safeAreaInsets.top - 117.px]
    
    private let contentView = UIView()
    private let navBar = MedalWallNavigationBar()
    private let collectionView = MedalWallCollectionView()
    
    private var mwVM: MedalWallViewModel?
//    private weak var request: URLSessionTask?
    private var request: DispatchWorkItem?
    
    private weak var fromVC: MedalRouterCompatible?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(0, 0, 0, a: 0)
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(Self.contentSize.height)
            make.bottom.equalTo(view.snp.bottom).offset(Self.contentSize.height)
        }
        
        navBar.closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        contentView.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52.px)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        }
    }
    
    // fd_prefersNavigationBarHidden = true 👇🏻
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.delegate = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MedalRouter.currentVC = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MedalRouter.currentVC = nil
    }
    
//    deinit {
//        print("jpjpjp MedalWallPopViewController 死")
//    }
    
    @objc func closeAction() {
        close()
    }
    
    func fetchData(_ model: JKRCurrentUser) {
        let uid = model.uid
        let nobility = model.nobility
        let svip = model.svip
        let nickname = model.nickname ?? ""
        let avatarurl = model.avatarurl ?? ""
        
//        let url = "/api/user/medals/wall"
//        let params = ["uid": uid]
//        
//        request = JKRNetWorkManager.share().jkr_sendApi(withUrl: url, params: params) { [weak self] returnValue in
//            guard let self = self else { return }
//
//            guard let returnValue else {
//                JKRHUDManager.toast(withMessage: String.fa.networkError)
//                return
//            }
//            
//            var mwVM: MedalWallViewModel?
//            Asyncs.async {
//                guard let dict = returnValue as? [String: Any] else { return }
//                mwVM = MedalWallViewModel(uid, nobility, svip, nickname ?? "", avatarurl ?? "", dict)
//            } mainTask: { [weak self] in
//                guard let self = self, let mwVM else { return }
//                self.mwVM = mwVM
//                self.navBar.updateData(mwVM)
//                self.collectionView.updateData(mwVM)
//            }
//
//        } failure: { [weak self] error in
//            guard self != nil else { return }
//            JKRHUDManager.toast(withMessage: error.localizedDescription)
//        } cancel: {}
        
        let delay = TimeInterval(Int.random(in: 5...10)) / 10.0
        request = Asyncs.asyncDelay(delay) { [weak self] in
            guard let url = Bundle.main.url(forResource: "medals_wall_data", withExtension: "txt"),
                  let data = try? Data(contentsOf: url),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                Asyncs.main { [weak self] in
                    guard let self else { return }
                    self.request = nil
                    JPHUD.showError(withStatus: "网络连接异常，请检查您的网络")
                }
                return
            }
            
            let mwVM = MedalWallViewModel(uid, nobility, svip, nickname, avatarurl, dict)
            Asyncs.main { [weak self] in
                guard let self else { return }
                self.request = nil
                self.mwVM = mwVM
                self.navBar.updateData(mwVM)
                self.collectionView.updateData(mwVM)
            }
        }
        
        // test
//        request = JKRNetWorkManager.share().jkr_sendApi(withUrl: "/api/user/medals", params: ["uid": uid]) { [weak self] returnValue in
//            guard let self = self else { return }
//
//            guard let returnValue else {
//                JKRHUDManager.toast(withMessage: "请求失败")
//                return
//            }
//
//            var mwVM: MedalWallViewModel?
//            Asyncs.async {
//                guard let vvv = returnValue as? [String: Any], let list = vvv["list"] as? [[String: Any]] else { return }
//
//                var list1: [String: Any] = [:]
//                list1["lv"] = "A"
//                list1["list"] = list.shuffled()
//
//                var list2: [String: Any] = [:]
//                list2["lv"] = "B"
//                list2["list"] = list.shuffled()
//
//                var list3: [String: Any] = [:]
//                list3["lv"] = "S"
//                list3["list"] = list.shuffled()
//
//                var list4: [String: Any] = [:]
//                list4["lv"] = "SS"
//                list4["list"] = list.shuffled()
//
//                var list5: [String: Any] = [:]
//                list5["lv"] = "SSS"
//                list5["list"] = list.shuffled()
//
//                var dict: [String: Any] = [:]
//                dict["nickname"] = "捡了个票"
//                dict["avatarurl"] = JKRUserManager.shared().user?.avatarurl ?? ""
//                dict["quarter"] = "1234566"
//                dict["medalPoint"] = "55566"
//                dict["medalPointRank"] = "85"
//                dict["medalList"] = [list1, list2, list3, list4, list5]
//
//                mwVM = MedalWallViewModel(uid, dict)
//                sleep(1)
//
//            } mainTask: { [weak self] in
//                guard let self = self, let mwVM else { return }
//                self.mwVM = mwVM
//                self.navBar.updateData(mwVM)
//                self.collectionView.updateData(mwVM)
//            }
//
//        } failure: { [weak self] error in
//            guard self != nil else { return }
//            JKRHUDManager.toast(withMessage: error.localizedDescription)
//        } cancel: {}
    }
}

extension MedalWallPopViewController: MedalRouterCompatible {
    // MARK: - 创建+弹出
    @objc static func show(from superVC: UIViewController?, model: JKRCurrentUser) {
        guard let superVC else { return }
        
        let popVC = MedalWallPopViewController()
        popVC.fromVC = superVC as? MedalRouterCompatible ?? nil
        
        let navCtr = BaseNavigationController(rootViewController: popVC)
        navCtr.modalPresentationStyle = .overFullScreen
        
        superVC.present(navCtr, animated: false) {
            popVC.show()
            popVC.fetchData(model)
        }
    }
    
    func show() {
        contentView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            if (self.fromVC?.isPop ?? false) == false {
                self.view.layer.backgroundColor = .rgb(0, 0, 0, a: 0.5)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    var isPop: Bool { true }
    
    func close() {
        let fromVC = self.fromVC
        request?.cancel()
        request = nil
        contentView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(Self.contentSize.height)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layer.backgroundColor = .rgb(0, 0, 0, a: 0)
            self.view.layoutIfNeeded()
        } completion: { [weak fromVC] _ in
            self.dismiss(animated: false) { [weak fromVC] in
                MedalRouter.currentVC = fromVC
            }
        }
    }
}
