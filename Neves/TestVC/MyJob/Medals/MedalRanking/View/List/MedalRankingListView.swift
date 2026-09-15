//
//  MedalRankingListView.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//

import UIKit

protocol MedalRankingListViewDelegate: AnyObject {
    func didScrollHandle(_ listView: MedalRankingListView)
    func endScrollHandle(_ listView: MedalRankingListView)
}

class MedalRankingListView: UICollectionView {
    private let showType: MedalRanking.ShowType
    
    let headerView: MedalRankingHeaderView
    private let bgView: MedalRankingListBgView
    
    private let topInset: CGFloat
    private var cellSize: CGSize
    private var footerSize: CGSize
    
    private var _isFirstDecelerate = true
    private var _isDecelerate = false
    
    private(set) var listVM: MedalRankingListViewModel? = nil {
        didSet {
            if let listVM, listVM.userVMs.count > 0 {
                cellSize = MedalRankingUserCell.size
                let total = listVM.topUserVMs.count + listVM.userVMs.count
                footerSize = [Env.screenWidth, total >= 30 ? 38.px : 0]
            } else {
                cellSize = MedalRankingEmptyCell.size(showType, topInset)
                footerSize = [Env.screenWidth, 0]
            }
        }
    }
    
    weak var scrollDelegate: MedalRankingListViewDelegate? = nil
    
    init(_ showType: MedalRanking.ShowType, _ listType: MedalRanking.ListType) {
        self.showType = showType
        
        self.headerView = MedalRankingHeaderView(showType, listType)
        self.bgView = MedalRankingListBgView(showType)
        
        let headerH = MedalRankingHeaderView.size(showType).height
        self.topInset = showType == .fullScreen ? (headerH - 16.px + 4.5.px) : headerH
        self.cellSize = MedalRankingEmptyCell.size(showType, self.topInset)
        self.footerSize = [Env.screenWidth, 0]
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: self.topInset, left: 0, bottom: 0, right: 0)
        
        super.init(frame: Env.screenBounds, collectionViewLayout: layout)
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .never
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: MedalRankingMyView.size.height, right: 0)
        alwaysBounceVertical = true
        
        addSubview(headerView)
        addSubview(bgView)
        
        register(MedalRankingEmptyCell.self, forCellWithReuseIdentifier: "MedalRankingEmptyCell")
        register(MedalRankingUserCell.self, forCellWithReuseIdentifier: "cell")
        register(Footer.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MedalRankingListView {
    class Footer: UICollectionReusableView {
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            label.font = .systemFont(ofSize: 12.px)
            label.textColor = .rgb(153, 153, 153)
            label.textAlignment = .center
            label.text = "仅展示前30条信息"
            addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            let line1 = UIView()
            line1.backgroundColor = .rgb(229, 229, 229)
            addSubview(line1)
            line1.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(label.snp.left).offset(-17.px)
                make.height.equalTo(0.5)
                make.width.equalTo(91.px)
            }
            
            let line2 = UIView()
            line2.backgroundColor = .rgb(229, 229, 229)
            addSubview(line2)
            line2.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(label.snp.right).offset(17.px)
                make.height.equalTo(0.5)
                make.width.equalTo(91.px)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension MedalRankingListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let listVM, listVM.userVMs.count > 0 {
            return listVM.userVMs.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let listVM, listVM.userVMs.count > 0 else {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MedalRankingEmptyCell", for: indexPath) as! MedalRankingEmptyCell
            cell.label.text = listVM == nil ? "正在刷新..." : "暂无数据"
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MedalRankingUserCell
        cell.updateUI(listVM.userVMs[indexPath.item])
        cell.isLast = indexPath.item >= (listVM.userVMs.count - 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard footerSize.height > 0, kind == UICollectionView.elementKindSectionFooter else { return .init() }
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! Footer
        footer.layer.zPosition = 1
        return footer
    }
}

extension MedalRankingListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        footerSize
    }
}

extension MedalRankingListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.zPosition = 1
    }
}

// MARK: - UIScrollViewDelegate
extension MedalRankingListView {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScrollHandle(self)
        
        let offsetY = scrollView.contentOffset.y
        headerView.updateOffsetY(offsetY)
        bgView.updateOffsetY(offsetY)
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
        
        let offsetY = scrollView.contentOffset.y
        headerView.updateOffsetY(offsetY)
        bgView.updateOffsetY(offsetY)
    }
}

extension MedalRankingListView {
    func updateData(_ listVM: MedalRankingListViewModel?) {
        headerView.updateData(listVM)
        self.listVM = listVM
        reloadSections(IndexSet(integer: 0))
    }
}
