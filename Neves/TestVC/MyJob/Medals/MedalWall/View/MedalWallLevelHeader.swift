//
//  MedalWallLevelHeader.swift
//  Falla
//
//  Created by aa on 2023/7/26.
//

import UIKit

class MedalWallLevelHeader: UICollectionReusableView {
    static var headerID: String { "MedalWallLevelHeader" }
    static var size: CGSize = [Env.screenWidth, 50.px]
    
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16.px)
            make.width.height.equalTo(24.px)
        }
        
        titleLabel.font = .systemFont(ofSize: 16.px, weight: .medium)
        titleLabel.textColor = .rgb(30, 30, 30)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconView.snp.trailing).offset(4.px)
        }
        
        countLabel.font = .systemFont(ofSize: 12.px)
        countLabel.textColor = .rgb(153, 153, 153)
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(4.px)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
