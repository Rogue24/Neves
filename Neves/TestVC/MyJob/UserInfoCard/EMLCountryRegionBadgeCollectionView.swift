//
//  EMLCountryRegionBadgeCollectionView.swift
//  Falla
//
//  Created by aa on 2025/6/20.
//

import UIKit
import SnapKit

class EMLCountryRegionBadgeCollectionView: UICollectionView {
    private var models: [EMLCountryRegionBadgeModel] = []
    private let flowLayout: RTLFlowLayout
    
    init(width: CGFloat) {
        let flowLayout = RTLFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = [136.px, 47.px]
        flowLayout.minimumLineSpacing = 8.px
        flowLayout.minimumInteritemSpacing = 0
        self.flowLayout = flowLayout
        super.init(frame: [0, 0, width, (5 + 47 + 5).px], collectionViewLayout: flowLayout)
        
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        register(Cell.self, forCellWithReuseIdentifier: "cell")
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(_ models: [EMLCountryRegionBadgeModel]) {
        self.models = models
        
        let contentW = CGFloat(models.count) * flowLayout.itemSize.width + CGFloat(models.count - 1) * flowLayout.minimumLineSpacing
        var margin = HalfDiffValue(bounds.width, contentW)
        if margin < 12.px { margin = 12.px }
        flowLayout.sectionInset = UIEdgeInsets(top: 5.px, left: margin, bottom: 5.px, right: margin)
        
        reloadData()
    }
}

extension EMLCountryRegionBadgeCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.bgImgView.image = model.getBadgeCardImage()
        cell.titleLabel.text = model.getBadgeRangeTitle()
        cell.subtitleLabel.text = model.getBadgeRankingTitle()
        cell.iconView.jkr_setImage(with: URL(string: model.url.rq_40x40),
                                   placeholder: "country_medal_icon_default".fa.image,
                                   loadErrorPlaceholder: "country_medal_icon_default".fa.image,
                                   options: .setImageWithFadeAnimation)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CountryRegionRankingBadgesView.show(on: viewController?.view, models: models, defaultIndex: indexPath.item)
    }
}

private extension EMLCountryRegionBadgeCollectionView {
    class Cell: UICollectionViewCell {
        let bgImgView = UIImageView()
        let iconView = UIImageView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            bgImgView.contentMode = .scaleToFill
            contentView.addSubview(bgImgView)
            bgImgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            contentView.addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.width.height.equalTo(32.px)
                make.leading.equalTo(4.px)
                make.centerY.equalToSuperview()
            }
            
            titleLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
            titleLabel.textColor = .white
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(2.px)
                make.trailing.equalToSuperview().offset(-4.px)
                make.top.equalTo(9.px)
                make.height.equalTo(12.px)
            }
            
            subtitleLabel.font = .systemFont(ofSize: 12.px, weight: .bold)
            subtitleLabel.textColor = .rgb(255, 242, 118)
            contentView.addSubview(subtitleLabel)
            subtitleLabel.snp.makeConstraints { make in
                make.leading.trailing.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(4.px)
                make.height.equalTo(14.px)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
