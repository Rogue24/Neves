//
//  MedalDetailListViewController.swift
//  Falla
//
//  Created by aa on 2023/7/6.
//

import UIKit
import SnapKit
import SVGAPlayer_Optimized

@objcMembers
class MedalDetailListViewController: UIViewController {
    private(set) static var isShowTitleOnly = false
    
    private let leftBtn = NoHighlightButton(type: .custom)
    private let rightBtn = NoHighlightButton(type: .custom)
    private lazy var listView = MedalDetailListView() { [weak self] in
        self?.close()
    }
    
    private var dataCount: Int = 0
    private var currentIndex: Int = -1 {
        didSet {
            guard currentIndex != oldValue, oldValue >= 0 else { return }
            updateBtns()
            indexDidChanged?(currentIndex)
        }
    }
    private var indexDidChanged: ((_ currentIndex: Int) -> Void)? = nil
    
    private var isScrolling = false {
        didSet {
            guard isScrolling != oldValue else { return }
            let alpha: CGFloat = isScrolling ? 0 : 1
            UIView.animate(withDuration: 0.15) {
                self.leftBtn.alpha = alpha
                self.rightBtn.alpha = alpha
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(0, 0, 0, a: 0.5)
        view.alpha = 0
        
        listView.alpha = 0
        view.addSubview(listView)
        
        leftBtn.isHidden = true
        leftBtn.setImage(UIImage(named: "medal_ranking_arr_left_h"), for: .normal)
        leftBtn.addTarget(self, action: #selector(goLeft), for: .touchUpInside)
        view.addSubview(leftBtn)
        leftBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(HalfDiffValue(Env.screenWidth, 227.px))
            make.height.equalTo(227.px)
        }
        
        rightBtn.isHidden = true
        rightBtn.setImage(UIImage(named: "medal_ranking_arr_right_h"), for: .normal)
        rightBtn.addTarget(self, action: #selector(goRight), for: .touchUpInside)
        view.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(HalfDiffValue(Env.screenWidth, 227.px))
            make.height.equalTo(227.px)
        }
    }
    
//    deinit {
//        print("jpjpjp MedalDetailListViewController 死")
//    }
}

// MARK: - Actions
private extension MedalDetailListViewController {
    @objc func goLeft() {
        let index = Env.isRTL ? (currentIndex + 1) : (currentIndex - 1)
        listView.scrollTo(index, animated: true)
    }
    
    @objc func goRight() {
        let index = Env.isRTL ? (currentIndex - 1) : (currentIndex + 1)
        listView.scrollTo(index, animated: true)
    }
}

// MARK: - Func
private extension MedalDetailListViewController {
    func updateBtns() {
        if !leftBtn.isHidden {
            let isEnabled = Env.isRTL ? (currentIndex < (dataCount - 1)) : (currentIndex > 0)
            if leftBtn.isUserInteractionEnabled != isEnabled {
                leftBtn.isUserInteractionEnabled = isEnabled
                leftBtn.setImage(UIImage(named: isEnabled ? "medal_ranking_arr_left_h" : "medal_ranking_arr_left"), for: .normal)
                UIView.transition(with: leftBtn, duration: 0.15, options: .transitionCrossDissolve) {}
            }
        }
        
        if !rightBtn.isHidden {
            let isEnabled = Env.isRTL ? (currentIndex > 0) : (currentIndex < (dataCount - 1))
            if rightBtn.isUserInteractionEnabled != isEnabled {
                rightBtn.isUserInteractionEnabled = isEnabled
                rightBtn.setImage(UIImage(named: isEnabled ? "medal_ranking_arr_right_h" : "medal_ranking_arr_right"), for: .normal)
                UIView.transition(with: rightBtn, duration: 0.15, options: .transitionCrossDissolve) {}
            }
        }
    }
    
    func showContent() {
        leftBtn.isHidden = dataCount <= 1
        rightBtn.isHidden = dataCount <= 1
        updateBtns()
        
        let cell = listView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? MedalDetailCell
        cell?.bgView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1) {
            cell?.bgView.transform = .identity
            self.listView.alpha = 1
        } completion: { _ in
            self.listView.scrollDelegate = self
        }
    }
    
    func loadData(_ userMedalList: [JKRUserMedalsList], _ targetIndex: Int) {
        SVGAParser().parse(withNamed: "hudloading", in: nil) { [weak self] loadingEntity in
            var cellModels: [MedalDetailCellModel] = []
            Asyncs.async {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                cellModels = userMedalList.map { MedalDetailCellModel($0, formatter) }
            } mainTask: { [weak self] in
                guard let self else { return }
                self.dataCount = cellModels.count
                self.currentIndex = targetIndex
                self.listView.updateData(loadingEntity, cellModels, targetIndex)
                Asyncs.mainDelay(0.03) {
                    self.showContent()
                }
            }
        }
    }
    
    func loadData(_ roomMedalList: [JKRChatRoomMedalModel], _ targetIndex: Int) {
        SVGAParser().parse(withNamed: "hudloading", in: nil) { [weak self] loadingEntity in
            var cellModels: [MedalDetailCellModel] = []
            Asyncs.async {
                cellModels = roomMedalList.map { MedalDetailCellModel($0) }
            } mainTask: { [weak self] in
                guard let self else { return }
                self.dataCount = cellModels.count
                self.currentIndex = targetIndex
                self.listView.updateData(loadingEntity, cellModels, targetIndex)
                Asyncs.mainDelay(0.03) {
                    self.showContent()
                }
            }
        }
    }
}

// MARK: - <MedalDetailListViewDelegate>
extension MedalDetailListViewController: MedalDetailListViewDelegate {
    func beginScrollHandle(_ listView: MedalDetailListView) {
        isScrolling = true
    }
    
    func didScrollHandle(_ listView: MedalDetailListView) {
        
    }
    
    func endScrollHandle(_ listView: MedalDetailListView) {
        let offsetX = listView.contentOffset.x
        let viewWidth = listView.bounds.width
        currentIndex = Int((offsetX + viewWidth * 0.5) / viewWidth)
        isScrolling = false
    }
}

// MARK: - 创建+弹出
extension MedalDetailListViewController {
    @discardableResult @objc
    static func show(from superVC: UIViewController?, userMedalList: [JKRUserMedalsList], targetIndex: Int, indexDidChanged: ((_ currentIndex: Int) -> Void)? = nil) -> MedalDetailListViewController? {
        guard let superVC else { return nil }
        isShowTitleOnly = false
        
        let popVC = MedalDetailListViewController()
        popVC.modalPresentationStyle = .overFullScreen
        popVC.indexDidChanged = indexDidChanged
        superVC.present(popVC, animated: false) {
            popVC.show()
            popVC.loadData(userMedalList, targetIndex)
        }
        return popVC
    }
    
    @discardableResult @objc
    static func show(from superVC: UIViewController?, roomMedalList: [JKRChatRoomMedalModel], targetIndex: Int, indexDidChanged: ((_ currentIndex: Int) -> Void)? = nil) -> MedalDetailListViewController? {
        guard let superVC else { return nil }
        isShowTitleOnly = true
        
        let popVC = MedalDetailListViewController()
        popVC.modalPresentationStyle = .overFullScreen
        popVC.indexDidChanged = indexDidChanged
        superVC.present(popVC, animated: false) {
            popVC.show()
            popVC.loadData(roomMedalList, targetIndex)
        }
        return popVC
    }
    
    func show() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.alpha = 1
        }, completion: nil)
    }
    
    func close() {
        let cell = listView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? MedalDetailCell
        UIView.animate(withDuration: 0.25) {
            cell?.bgView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.view.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}
