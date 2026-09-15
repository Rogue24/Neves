//
//  MedalWallCollectionView.swift
//  Neves
//
//  Created by aa on 2023/7/6.
//

import UIKit
import Kingfisher

class MedalWallCollectionView: UICollectionView {
    static let size: CGSize = [Env.screenWidth, MedalWallPopViewController.contentSize.height - MedalWallNavigationBar.size.height]
    static let medalIntegralCellSize: CGSize = [MedalWallCollectionView.size.width - 32.px - 1, 54.px]
    
    weak var mwVM: MedalWallViewModel?
    
    init() {
        let layout = RTLFlowLayout()
        layout.scrollDirection = .vertical
        
        super.init(frame: .zero, collectionViewLayout: layout)
        contentInsetAdjustmentBehavior = .never
        alwaysBounceVertical = true
        contentInset = .init(top: 0, left: 0, bottom: Env.safeAreaInsets.bottom, right: 0)
        backgroundColor = .white
        
        register(MedalWallUserCell.self, forCellWithReuseIdentifier: MedalWallUserCell.cellID)
        register(UINib(nibName: "EMLProfileMedalIntegralCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EMLProfileMedalIntegralCollectionViewCell")
        register(MedalWallLevelHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MedalWallLevelHeader.headerID)
        register(MedalWallIconCell.self, forCellWithReuseIdentifier: MedalWallIconCell.cellID)
        
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource
extension MedalWallCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2 + (mwVM?.listVMs.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        default:
            guard let mwVM else { return 0 }
            return mwVM.listVMs[section - 2].medals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard indexPath.section > 1, kind == UICollectionView.elementKindSectionHeader else { return .init() }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MedalWallLevelHeader.headerID, for: indexPath) as! MedalWallLevelHeader
        if let mwVM {
            let listVM = mwVM.listVMs[indexPath.section - 2]
            header.iconView.image = UIImage(named: listVM.level.smallIconName)
            header.titleLabel.text = "\(listVM.level.rawValue)级勋章"
            header.countLabel.text = "(\(listVM.count))"
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MedalWallUserCell.cellID, for: indexPath) as! MedalWallUserCell
            if let mwVM {
                cell.updateData(mwVM)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EMLProfileMedalIntegralCollectionViewCell", for: indexPath) as! EMLProfileMedalIntegralCollectionViewCell
            if let mwVM {
                cell.medalPoint = mwVM.medalPoint
                cell.medalPointRank = mwVM.medalPointRank
                cell.delegate = self
            } else {
                cell.delegate = nil
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MedalWallIconCell.cellID, for: indexPath) as! MedalWallIconCell
            if let mwVM {
                let listVM = mwVM.listVMs[indexPath.section - 2]
                let medal = listVM.medals[indexPath.item]
                cell.imgView.kf.setImage(
                    with: URL(string: medal.iconL.rq_100x100),
                    options: [.transition(.fade(0.2))]
                )
                cell.indexPath = indexPath
                cell.didClickHandler = { [weak self] idp in
                    self?.medalDidClick(idp)
                }
            } else {
                cell.indexPath = nil
                cell.didClickHandler = nil
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MedalWallCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return MedalWallUserCell.size
        case 1:
            return Self.medalIntegralCellSize
        default:
            return MedalWallIconCell.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return .zero
        case 1:
            return .init(top: 0, left: 16.px, bottom: 15.px, right: 16.px)
        default:
            return .init(top: 10.px, left: 21.px, bottom: 10.px, right: 21.px)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 0
        default:
            return 10.px
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 0
        default:
            return 20.px
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0, 1:
            return .zero
        default:
            return MedalWallLevelHeader.size
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        .zero
    }
}

// MARK: - EMLProfileMedalIntegralCollectionViewCellDelegate
extension MedalWallCollectionView: EMLProfileMedalIntegralCollectionViewCellDelegate {
    func clickMedalRankingButton() {
        guard mwVM != nil else { return }
        MedalRouter.ranking(true).jump()
    }
}

// MARK: - update medal wall data
extension MedalWallCollectionView {
    func updateData(_ mwVM: MedalWallViewModel?) {
        self.mwVM = mwVM
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {}
        reloadData()
    }
}

// MARK: - show medal detail
extension MedalWallCollectionView {
    func medalDidClick(_ indexPath: IndexPath) {
        guard let mwVM else { return }
        let listVM = mwVM.listVMs[indexPath.section - 2]
        
        var targetIndex = -1
        var currentIndex = 0
        let medalList = mwVM.listVMs.flatMap { vm in
            let medals = vm.medals
            if targetIndex < 0 {
                if listVM == vm {
                    targetIndex = currentIndex + indexPath.item
                } else {
                    currentIndex += medals.count
                }
            }
            return medals
        }
        
        MedalRouter.detailList(medalList, targetIndex, nil).jump()
    }
}
