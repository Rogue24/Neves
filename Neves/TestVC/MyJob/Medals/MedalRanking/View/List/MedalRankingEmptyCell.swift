//
//  MedalRankingEmptyCell.swift
//  Falla
//
//  Created by aa on 2023/7/13.
//

import UIKit
import SnapKit

class MedalRankingEmptyCell: UICollectionViewCell {
    static func size(_ showType: MedalRanking.ShowType, _ topInsert: CGFloat) -> CGSize {
        switch showType {
        case .fullScreen:
            return [Env.screenWidth, Env.screenHeight - topInsert]
        case .pop:
            let contentSize = MedalRankingPopViewController.contentSize
            return [contentSize.width, contentSize.height - 52.px - topInsert]
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5.px
        stackView.alignment = .center
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let imgView = UIImageView(image: UIImage(named: "empty_new_default"))
        imgView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(170.px)
        }
        
        label.font = .systemFont(ofSize: 12.px)
        label.textColor = .rgb(191, 191, 191)
        stackView.addArrangedSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
