//
//  MedalWallIconCell.swift
//  Neves
//
//  Created by aa on 2023/7/26.
//

import UIKit
import SnapKit

class MedalWallIconCell: UICollectionViewCell {
    static let cellID = "MedalWallIconCell"
    static let size: CGSize = [68.px, 68.px]
    
    let imgView = UIImageView()
    
    var indexPath: IndexPath?
    var didClickHandler: ((_ idp: IndexPath) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView.contentMode = .scaleAspectFit
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImgView)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapImgView() {
        guard let indexPath else { return }
        didClickHandler?(indexPath)
    }
}
