//
//  MedalWallUserCell.swift
//  Falla
//
//  Created by aa on 2023/7/6.
//

import UIKit
import SnapKit
import Kingfisher

class MedalWallUserCell: UICollectionViewCell {
    static let cellID = "MedalWallUserCell"
    static let size: CGSize = [MedalWallCollectionView.size.width, 107.px]
    
    let avatarView = AnimatedImageView()
    let nameLabel = JKRShimmeringLabel()
    
    private var uid: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        avatarView.contentMode = .scaleAspectFill
        avatarView.backgroundColor = .black
        avatarView.layer.cornerRadius = 29.5.px
        avatarView.layer.masksToBounds = true
        avatarView.image = UIImage(named: "header_no")
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatarView)))
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(10.px)
            make.width.height.equalTo(59.px)
            make.centerX.equalToSuperview()
        }
        
        nameLabel.font = .systemFont(ofSize: 14.px, weight: .medium)
        nameLabel.textColor = .rgb(51, 51, 51)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(5.px)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MedalWallUserCell {
    @objc func tapAvatarView() {
        guard uid > 0 else { return }
        MedalRouter.profile(uid).jump()
    }
}

extension MedalWallUserCell {
    func updateData(_ mwVM: MedalWallViewModel) {
        avatarView.kf.setImage(
            with: URL(string: mwVM.rq_avatarurl),
            placeholder: UIImage(named: "header_no"),
            options: [.transition(.fade(0.2))]
        )
        
        nameLabel.text = mwVM.nickname
        nameLabel.shimmerMask = JKRShimmeringMask.nickNameMask(withVip: mwVM.nobility, svip: mwVM.svip)
        
        uid = mwVM.uid
    }
}
