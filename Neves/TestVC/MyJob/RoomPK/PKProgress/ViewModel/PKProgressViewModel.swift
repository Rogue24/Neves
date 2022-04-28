//
//  PKProgressViewModel.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

import UIKit

class PKProgressViewModel<T: PKRankModelCompatible>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let contentView = PKProgressView.loadFromNib()
    
    private(set) var leftRankModels: [T] = []
    private(set) var rightRankModels: [T] = []
    
    override init() {
        super.init()
        setupCollectionView(contentView.leftCollectionView)
        setupCollectionView(contentView.rightCollectionView)
    }
    
    deinit {
        JPrint("PKProgressViewModel 寿寝正终")
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let models = getRankModels(for: collectionView)
        return models.count > 0 ? models.count : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let models = getRankModels(for: collectionView)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PKProgressRankCell<T>
        cell.model = models.count > 0 ? models[indexPath.item] : nil
        return cell
    }
    
}

// MARK: - 私有API
private extension PKProgressViewModel {
    func setupCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(PKProgressRankCell<T>.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func getRankModels(for collectionView: UICollectionView) -> [T] {
        collectionView == contentView.leftCollectionView ? leftRankModels : rightRankModels
    }
}

// MARK: - 添加视图
extension PKProgressViewModel {
    func addProgressView(on superview: UIView, top: CGFloat) {
        superview.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(90)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(top)
        }
    }
}

// MARK: - 刷新榜单
extension PKProgressViewModel {
    func updateRankData(leftRankModels: [T], rightRankModels: [T]) {
        self.leftRankModels = leftRankModels
        self.rightRankModels = rightRankModels
        contentView.leftCollectionView.reloadData()
        contentView.rightCollectionView.reloadData()
    }
}

// MARK: - 刷新进度
extension PKProgressViewModel {
    func updateProgress(leftValue: Int, rightValue: Int, animated: Bool = false) {
        let totalValue = leftValue + rightValue
        let progress = totalValue > 0 ? (CGFloat(leftValue) / CGFloat(totalValue)) : 0.5
        
        guard animated else {
            contentView.update(leftCount: leftValue,
                               rightCount: rightValue,
                               progress: progress)
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.update(leftCount: leftValue,
                                    rightCount: rightValue,
                                    progress: progress)
        }
    }
    
    func startPK() {
        contentView.playStartAnim()
        contentView.stopPeakingAnim()
        contentView.showOrHideBottomImgView(false)
    }
    
    func startPeakPK() {
        contentView.playStartPeakAnim()
        contentView.playPeakingAnim()
        contentView.showOrHideBottomImgView(true)
    }
    
    func endPk() {
        contentView.stopPeakingAnim()
        contentView.showOrHideBottomImgView(false)
    }
}


