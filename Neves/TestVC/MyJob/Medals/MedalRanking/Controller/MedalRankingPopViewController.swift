//
//  MedalRankingPopViewController.swift
//  Falla
//
//  Created by aa on 2023/7/5.
//

import UIKit
import SnapKit

@objcMembers
class MedalRankingPopViewController: UIViewController {
    static let contentSize: CGSize = [Env.screenWidth, Env.screenHeight - Env.safeAreaInsets.top - 117.px]
    
    private let dataMgr = MedalRankingDataManager(isNeedShowOnLine: false)
    
    private var _range: MedalRanking.RegionRange = .global
    private var range: MedalRanking.RegionRange {
        get { _range }
        set {
            guard _range != newValue else { return }
            _range = newValue
            let currentType = self.currentType
            MedalRanking.ListType.allCases.forEach { type in
                if type == currentType { // 当前列表，去请求数据
                    let listView = getListView(for: type)
                    if dataMgr.fetchData(for: type, newValue, isReload: false), listView.0.mj_header?.isRefreshing == false {
                        listView.0.mj_header?.beginRefreshing()
                    }
                } else { // 其他列表，如果还没请求成功的，就取消请求并清空列表（滑过去再请求）
                    let vm = dataMgr.getViewModel(for: type, newValue)
                    vm.request?.cancel()
                    updateData(.success(vm))
                }
            }
        }
    }
    
    private let contentView = UIView()
    private lazy var segmentBar = MedalRankingNavSegmentBar(range: range)
    
    private let pageView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .clear
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.isPagingEnabled = true
        sv.bounces = false
        return sv
    }()
    
    private var listViews: [(MedalRankingListView, MedalRankingMyView)] = []
    
    private var _maxOffsetX: CGFloat = 0
    private var _startHorOffsetX: CGFloat = 0
    
    private var _isMainScrolling = false
    private var _isDidClickAnimating = false
    
    private var _isFirstDecelerate = true
    private var _isDecelerate = false
    
    private(set) var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            guard !_isDidClickAnimating else { return }
            
            let vm = dataMgr.getViewModel(for: currentType, range)
            guard !vm.isRequested else { return }
            
            dataMgr.fetchData(for: vm.type, range, isReload: false)
        }
    }
    
    var currentType: MedalRanking.ListType {
        MedalRanking.ListType(rawValue: selectedIndex) ?? .quarterly
    }
    
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

        contentView.frame = CGRect(origin: [0, Env.screenHeight], size: Self.contentSize)
        view.addSubview(contentView)
        
        segmentBar.rtl_refWidth = contentView.bounds.width
        segmentBar.delegate = self
        contentView.addSubview(segmentBar)
        
        pageView.backgroundColor = .white
        pageView.rtl_refWidth = contentView.bounds.width
        pageView.rtl_frame = [0, segmentBar.frame.maxY, contentView.bounds.width, contentView.bounds.height - segmentBar.frame.maxY]
        contentView.addSubview(pageView)
        
        let contentWidth = pageView.bounds.width * CGFloat(MedalRanking.ListType.allCases.count)
        _maxOffsetX = contentWidth - pageView.bounds.width
        
        var x: CGFloat = 0
        for type in MedalRanking.ListType.allCases {
            let listView = MedalRankingListView(.pop, type)
            listView.tag = type.rawValue
            listView.rtl_refWidth = contentWidth
            listView.rtl_frame = CGRect(origin: [x, 0], size: pageView.bounds.size)
            listView.scrollDelegate = self
            pageView.addSubview(listView)
            
            listView.headerView.helpBtn?.tag = type.rawValue
            listView.headerView.helpBtn?.addTarget(self, action: #selector(goHelp(_:)), for: .touchUpInside)
            
            let refreshHeader = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(reloadListData(_:)))
            refreshHeader.tag = type.rawValue
            refreshHeader.isAutomaticallyChangeAlpha = true
            listView.mj_header = refreshHeader
            listView.bringSubviewToFront(refreshHeader)
            
            let myView = MedalRankingMyView(.pop)
            myView.tag = type.rawValue
            myView.rtl_refWidth = contentWidth
            myView.rtl_frame.origin = [x, pageView.bounds.height]
            pageView.addSubview(myView)
            
            listViews.append((listView, myView))
            x += listView.bounds.width
        }
        pageView.contentSize = [contentWidth, 0]
        pageView.setContentOffset(pageView.contentOffset, animated: true)
        pageView.rtl_contentRefWidth = contentWidth
        pageView.rtl_contentOffset = .zero
        pageView.delegate = self
        
        dataMgr.responder = self
        dataMgr.fetchData(for: currentType, range, isReload: false)
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
//        print("jpjpjp MedalRankingPopViewController 死")
//    }
}

// MARK: - Actions
private extension MedalRankingPopViewController {
    @objc func closeAction() {
        close()
    }
    
    @objc func goHelp(_ sender: UIButton) {
        MedalRouter.desc.jump()
    }
    
    @objc func reloadListData(_ sender: MJRefreshStateHeader) {
        let type = MedalRanking.ListType(rawValue: sender.tag) ?? .quarterly
        dataMgr.fetchData(for: type, range, isReload: true)
    }
}

// MARK: - Private Func
private extension MedalRankingPopViewController {
    /// 根据类型获取目标`listView`
    func getListView(for type: MedalRanking.ListType) -> (MedalRankingListView, MedalRankingMyView) {
        for listView in listViews where listView.0.tag == type.rawValue {
            return listView
        }
        return listViews[0]
    }
    
    /// 刷新下标
    func updateSelectedIndex(_ offsetX: CGFloat) {
        let viewWidth = pageView.bounds.width
        selectedIndex = Int((offsetX + viewWidth * 0.5) / viewWidth)
        _startHorOffsetX = viewWidth * CGFloat(selectedIndex)
    }
}

// MARK: - MedalRankingDataResponder
extension MedalRankingPopViewController: MedalRankingDataResponder {
    func updateDefaultRange(_ range: MedalRanking.RegionRange, isCanSwitch: Bool, nationalFlag: String) {
        _range = range
        guard isCanSwitch else { return }
        segmentBar.toggleBtn.setupRegion(range == .country, nationalFlag: nationalFlag) { [weak self] in
            self?.range = $0 ? .country : .global
        }
    }
    
    func updateData(_ result: Result<MedalRankingViewModel, MedalRanking.Error>) {
        switch result {
        case let .success(vm):
            guard vm.range == range else { return }
            let listView = getListView(for: vm.type)
            
            listView.0.mj_header?.endRefreshing()
            listView.0.updateData(vm.listVM)
            
            listView.1.updateData(vm.listVM?.myUserVM)
            guard listView.1.frame.origin.y >= pageView.bounds.height else { return }
            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
                listView.1.frame.origin.y = self.pageView.bounds.height - listView.1.frame.height
            }
            
        case let .failure(er):
            guard !er.isUserCancel, er.range == range else { return }
            let listView = getListView(for: er.listType)
            listView.0.mj_header?.endRefreshing()
            JPHUD.showError(withStatus: er.localizedDescription)
        }
    }
}

// MARK: - MedalRankingListViewDelegate
extension MedalRankingPopViewController: MedalRankingListViewDelegate {
    func didScrollHandle(_ listView: MedalRankingListView) {
        updateOffsetY(listView)
    }
    
    func endScrollHandle(_ listView: MedalRankingListView) {
        updateOffsetY(listView)
    }
    
    func updateOffsetY(_ listView: MedalRankingListView) {
        guard let mj_header = listView.mj_header else { return }
        let offsetY = listView.contentOffset.y
        let diffH = -mj_header.mj_h
        mj_header.mj_y = offsetY < diffH ? offsetY : diffH
    }
}

// MARK: - MedalRankingNavSegmentBarDelegate
extension MedalRankingPopViewController: MedalRankingNavSegmentBarDelegate {
    func segementBar(_ segementBar: MedalRankingNavSegmentBar, titleDidClickAnimation animateDuration: TimeInterval, selectedIndex: Int) {
        _isDidClickAnimating = true
        
        let offset: CGPoint = [CGFloat(selectedIndex) * pageView.bounds.width, 0]
        
        if animateDuration <= 0.0 {
            pageView.rtl_contentOffset = offset
            scrollViewDidEndDecelerating(pageView)
            return
        }
        
        pageView.isUserInteractionEnabled = false
        UIView.animate(withDuration: animateDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.pageView.rtl_contentOffset = offset
        } completion: { _ in
            self.pageView.isUserInteractionEnabled = true
            self.scrollViewDidEndDecelerating(self.pageView)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MedalRankingPopViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _isMainScrolling = true
        // 确定当期下标
        let offsetX = scrollView.rtl_contentOffset.x
        updateSelectedIndex(offsetX)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _isMainScrolling = true
        if _isDidClickAnimating { return }
        
        let offsetX = scrollView.rtl_contentOffset.x
        
        var currentPage: Int = 0
        var sourceIndex: Int = 0
        var targetIndex: Int = 0
        var progress: CGFloat = 0
        if PageScrollProgress(WithPageSizeValue: scrollView.bounds.width,
                              pageCount: listViews.count,
                              offsetValue: offsetX,
                              maxOffsetValue: _maxOffsetX,
                              startOffsetValue: &_startHorOffsetX,
                              currentPage: &currentPage,
                              sourcePage: &sourceIndex,
                              targetPage: &targetIndex,
                              progress: &progress) {
            segmentBar.updateLayout(sourceIndex: sourceIndex,
                                    targetIndex: targetIndex,
                                    progress: progress)
            selectedIndex = segmentBar.selectedIndex
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if _isFirstDecelerate {
            _isFirstDecelerate = false
            _isDecelerate = decelerate
        }
        if !_isDecelerate { scrollViewDidEndDecelerating(scrollView) }
    }

    // 手指滑动动画停止时会调用该方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _isFirstDecelerate = true
        _isMainScrolling = false
        _isDidClickAnimating = false
        
        let offsetX = scrollView.rtl_contentOffset.x
        updateSelectedIndex(offsetX)
        
        segmentBar.switchPage(selectedIndex, isAnimated: false)
    }
}

// MARK: - 创建+弹出
extension MedalRankingPopViewController: MedalRouterCompatible {
    @objc static func show(from superVC: UIViewController?) {
        guard let superVC else { return }
        
        let popVC = MedalRankingPopViewController()
        popVC.fromVC = superVC as? MedalRouterCompatible ?? nil
        
        let navCtr = BaseNavigationController(rootViewController: popVC)
        navCtr.modalPresentationStyle = .overFullScreen
        
        superVC.present(navCtr, animated: false) {
            popVC.show()
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            if (self.fromVC?.isPop ?? false) == false {
                self.view.layer.backgroundColor = .rgb(0, 0, 0, a: 0.5)
            }
            self.contentView.frame.origin.y = Env.screenHeight - self.contentView.frame.height
        }, completion: nil)
    }
    
    var isPop: Bool { true }
    
    func close() {
        let fromVC = self.fromVC
        UIView.animate(withDuration: 0.3) {
            self.view.layer.backgroundColor = .rgb(0, 0, 0, a: 0)
            self.contentView.frame.origin.y = Env.screenHeight
        } completion: { _ in
            self.dismiss(animated: false) { [weak fromVC] in
                MedalRouter.currentVC = fromVC
            }
        }
    }
}
