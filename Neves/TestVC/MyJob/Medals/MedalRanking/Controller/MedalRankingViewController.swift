//
//  MedalRankingViewController.swift
//  Falla
//
//  Created by aa on 2023/6/30.
//

import UIKit

@objcMembers
class MedalRankingViewController: UIViewController {
    private let dataMgr = MedalRankingDataManager(isNeedShowOnLine: false)
    
    private var _range: MedalRanking.RegionRange = .global
    private var range: MedalRanking.RegionRange {
        get { _range }
        set {
            guard _range != newValue else { return }
            _range = newValue
            if dataMgr.fetchData(for: segmentView.currentType, _range, isReload: false), listView.mj_header?.isRefreshing == false {
                listView.mj_header?.beginRefreshing()
            }
        }
    }
    
    private lazy var navBar = MedalRankingNavigationBar(range: range)
    private let segmentView = MedalRankingSegmentView()
    private let listView = MedalRankingListView(.fullScreen, .quarterly)
    private let myView = MedalRankingMyView(.fullScreen)
    
    private var segmentViewBaseY: CGFloat = 0
    private var refreshInsetTop: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.scrollDelegate = self
        view.addSubview(listView)
        
        navBar.frame.origin.y = Env.safeAreaInsets.top
        navBar.backBtn.addTarget(self, action: #selector(goback), for: .touchUpInside)
        navBar.helpBtn.addTarget(self, action: #selector(goHelp), for: .touchUpInside)
        view.addSubview(navBar)
        
        segmentViewBaseY = navBar.frame.maxY + 8.5.px
        segmentView.frame.origin = [HalfDiffValue(Env.screenWidth, segmentView.frame.width), segmentViewBaseY]
        segmentView.switchListTypeHandler = { [weak self] currentType in
            self?.switchList(currentType)
        }
        view.insertSubview(segmentView, belowSubview: navBar)
        
        myView.frame.origin.y = Env.screenHeight
        view.addSubview(myView)
        
        refreshInsetTop = segmentView.frame.maxY + 5.px
        let refreshHeader = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(reloadCurrentList))
        refreshHeader.ignoredScrollViewContentInsetTop = -refreshInsetTop
        refreshHeader.isAutomaticallyChangeAlpha = true
        listView.mj_header = refreshHeader
        listView.bringSubviewToFront(refreshHeader)
        
        dataMgr.responder = self
        dataMgr.fetchData(for: segmentView.currentType, range, isReload: false)
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
//        print("jpjpjp MedalRankingViewController 死")
//    }
}

// MARK: - Actions
extension MedalRankingViewController {
    @objc func goback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func goHelp() {
        MedalRouter.desc.jump()
    }
    
    @objc func reloadCurrentList() {
        dataMgr.fetchData(for: segmentView.currentType, range, isReload: true)
    }
    
    func switchList(_ type: MedalRanking.ListType) {
        if dataMgr.fetchData(for: type, range, isReload: false), listView.mj_header?.isRefreshing == false {
            listView.mj_header?.beginRefreshing()
        }
    }
}

// MARK: - MedalRankingDataResponder
extension MedalRankingViewController: MedalRankingDataResponder {
    func updateDefaultRange(_ range: MedalRanking.RegionRange, isCanSwitch: Bool, nationalFlag: String) {
        _range = range
        guard isCanSwitch else { return }
        navBar.toggleBtn.setupRegion(range == .country, nationalFlag: nationalFlag) { [weak self] in
            self?.range = $0 ? .country : .global
        }
    }
    
    func updateData(_ result: Result<MedalRankingViewModel, MedalRanking.Error>) {
        let currentType = segmentView.currentType
        
        switch result {
        case let .success(vm):
            guard vm.type == currentType, vm.range == range else { return }
            
            listView.mj_header?.endRefreshing()
            listView.updateData(vm.listVM)
            
            myView.updateData(vm.listVM?.myUserVM)
            guard myView.frame.origin.y >= Env.screenHeight else { return }
            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
                self.myView.frame.origin.y = Env.screenHeight - self.myView.frame.height
            }
            
        case let .failure(er):
            guard !er.isUserCancel, er.listType == currentType, er.range == range else { return }
            listView.mj_header?.endRefreshing()
            JPHUD.showError(withStatus: er.localizedDescription)
        }
    }
}

// MARK: - MedalRankingListViewDelegate
extension MedalRankingViewController: MedalRankingListViewDelegate {
    func didScrollHandle(_ listView: MedalRankingListView) {
        updateOffsetY(listView.contentOffset.y)
    }
    
    func endScrollHandle(_ listView: MedalRankingListView) {
        updateOffsetY(listView.contentOffset.y)
    }
    
    func updateOffsetY(_ offsetY: CGFloat) {
        navBar.updateOffsetY(offsetY)
        segmentView.frame.origin.y = segmentViewBaseY - (offsetY <= 0 ? 0 : offsetY)
        if let mj_header = listView.mj_header {
            let diffH = -mj_header.mj_h
            mj_header.mj_y = refreshInsetTop + (offsetY < diffH ? offsetY : diffH)
        }
    }
}

// MARK: - MedalRouterCompatible
extension MedalRankingViewController: MedalRouterCompatible {
    var isPop: Bool { false }
    
    func close() {
        dismiss(animated: true)
    }
}
