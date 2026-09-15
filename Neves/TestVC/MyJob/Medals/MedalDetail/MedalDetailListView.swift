//
//  MedalDetailListView.swift
//  Neves
//
//  Created by aa on 2023/7/7.
//

import UIKit
import SVGAPlayer_Optimized

protocol MedalDetailListViewDelegate: AnyObject {
    func beginScrollHandle(_ listView: MedalDetailListView)
    func didScrollHandle(_ listView: MedalDetailListView)
    func endScrollHandle(_ listView: MedalDetailListView)
}

class MedalDetailListView: UICollectionView {
    weak var scrollDelegate: MedalDetailListViewDelegate?
    private let closeAction: () -> ()
    
    private var cellModels: [MedalDetailCellModel] = []
    private var loadingEntity: SVGAVideoEntity? = nil
    
    private var _isFirstDecelerate = true
    private var _isDecelerate = false
    
    init(closeAction: @escaping () -> ()) {
        self.closeAction = closeAction
        
        let layout = RTLFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = MedalDetailCell.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        
        super.init(frame: Env.screenBounds, collectionViewLayout: layout)
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        dataSource = self
        delegate = self
        register(MedalDetailCell.self, forCellWithReuseIdentifier: "MedalDetailCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let diffY = HalfDiffValue(Env.screenHeight, 227.px)
        guard location.y < diffY || location.y > (diffY + 227.px) else { return }
        closeAction()
    }
}

// MARK: - Func
extension MedalDetailListView {
    func updateData(_ loadingEntity: SVGAVideoEntity?,
                    _ cellModels: [MedalDetailCellModel],
                    _ targetIndex: Int) {
        self.loadingEntity = loadingEntity
        self.cellModels = cellModels
        
        reloadData()
        contentOffset = [Env.screenWidth * CGFloat(targetIndex), 0]
    }
    
    func scrollTo(_ index: Int, animated: Bool) {
        guard index >= 0 && index < cellModels.count else {
            scrollDelegate?.endScrollHandle(self)
            return
        }
        
        scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        if !animated {
            scrollDelegate?.endScrollHandle(self)
        }
    }
}

// MARK: - <UICollectionViewDataSource>
extension MedalDetailListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = cellModels[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedalDetailCell", for: indexPath) as! MedalDetailCell
        cell.getLoadingEntity = { [weak self] in self?.loadingEntity }
        cellModel~~~cell
        return cell
    }
}

// MARK: - <UICollectionViewDelegate>
extension MedalDetailListView: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.beginScrollHandle(self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScrollHandle(self)
        
//        print("jpjpjp scrolling contentOffset x: \(scrollView.contentOffset.x)")
//        print("jpjpjp scrolling rtl_contentOffset x: \(scrollView.rtl_contentOffset.x)")
//        print("jpjpjp scrolling contentSize w: \(scrollView.contentSize.width)")
//        let offsetX = scrollView.rtl_contentOffset.x
//        let viewWidth = scrollView.bounds.width
//        let currentIndex = Int((offsetX + viewWidth * 0.5) / viewWidth)
//        print("jpjpjp scrolling currentIndex: \(currentIndex)")
//        print("jpjpjp ---------------")
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _isFirstDecelerate = true
        scrollDelegate?.endScrollHandle(self)
        
//        print("jpjpjp scrollend contentOffset x: \(scrollView.contentOffset.x)")
//        print("jpjpjp scrollend rtl_contentOffset x: \(scrollView.rtl_contentOffset.x)")
//        print("jpjpjp scrollend contentSize w: \(scrollView.contentSize.width)")
//        let offsetX = scrollView.rtl_contentOffset.x
//        let viewWidth = scrollView.bounds.width
//        let currentIndex = Int((offsetX + viewWidth * 0.5) / viewWidth)
//        print("jpjpjp scrollend currentIndex: \(currentIndex)")
//        print("jpjpjp ---------------")
    }
}
