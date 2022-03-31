//
//  CosmicExplorationPrizeView.swift
//  Neves
//
//  Created by aa on 2022/3/31.
//

import UIKit

class CosmicExplorationPrizeView: UIView {
    
    let contentView = UIView(frame: [0, 87.5.px, PortraitScreenWidth, 200.px])
    
    lazy var collectionView = UICollectionView(frame: [0, 54.px, PortraitScreenWidth, 80.px], collectionViewLayout: UICollectionViewFlowLayout())
    
    let confirmView = UIView(frame: [HalfDiffValue(PortraitScreenWidth, 115.px), (200 - 35 - 12).px, 115.px, 35.px])
    let countdownLabel = UILabel(frame: [(115 - 42 - 3).px, 0, 42.px, 35.px])
    
    var timer: DispatchSourceTimer?
    var second = 5 {
        didSet {
            if second <= 0 {
                hide(animated: true)
            } else {
                countdownLabel.text = "（\(second)s）"
            }
        }
    }
    
    init?(_ second: Int) {
        guard second > 0 else { return nil }
        self.second = second
        super.init(frame: CGRect(origin: .zero, size: [PortraitScreenWidth, PortraitScreenWidth]))
        
        let bgImgView = UIImageView(frame: contentView.bounds)
        bgImgView.image = UIImage(named: "spaceship_victory_bg")
        contentView.addSubview(bgImgView)
        
        let titleImgView = UIImageView(frame: [HalfDiffValue(contentView.width, 280.px), 10.px, 280.px, 34.px])
        titleImgView.image = UIImage(named: "space_victory_title")
        contentView.addSubview(titleImgView)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = [65.px, 80.px]
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
        }
        collectionView.jp.contentInsetAdjustmentNever()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "CosmicExplorationPrizeCell", bundle: nil), forCellWithReuseIdentifier: "CosmicExplorationPrizeCell")
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        
        let continueImgView = UIImageView(frame: confirmView.bounds)
        continueImgView.image = UIImage(named: "spacesihp_continue_btn")
        confirmView.addSubview(continueImgView)
        
        countdownLabel.font = .systemFont(ofSize: 13.px)
        countdownLabel.textColor = .rgb(187, 236, 255)
        countdownLabel.textAlignment = .center
        countdownLabel.text = "（\(second)s）"
        confirmView.addSubview(countdownLabel)
            
        confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmViewDidClick)))
        contentView.addSubview(confirmView)
        
        addSubview(contentView)
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeTimer()
    }
    
}


extension CosmicExplorationPrizeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CosmicExplorationPrizeCell", for: indexPath)
        
        return cell
    }
}

extension CosmicExplorationPrizeView {
    func show(animated: Bool) {
        layoutIfNeeded()
        let horInset = HalfDiffValue(PortraitScreenWidth, collectionView.contentSize.width)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horInset, bottom: 0, right: 0)
        collectionView.contentOffset = [-horInset, 0]
        
        if animated {
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: []) {
                self.contentView.transform = CGAffineTransform.identity
                self.contentView.alpha = 1
            } completion: { _ in }
        } else {
            contentView.transform = CGAffineTransform.identity
            contentView.alpha = 1
        }
        
        addTimer()
    }
    
    func hide(animated: Bool) {
        removeTimer()
        
        guard animated else {
            removeFromSuperview()
            return
        }
        
        let cellCount = collectionView.visibleCells.count
        let toCenter: CGPoint = [PortraitScreenWidth - 27.px, PortraitScreenWidth - 26.px]
        
        for (i, cell) in collectionView.visibleCells.enumerated() {
            let pCell = cell as! CosmicExplorationPrizeCell
            
            let giftIcon = UIImageView(image: pCell.giftIcon.image)
            giftIcon.frame = pCell.convert(pCell.giftIcon.frame, to: self)
            addSubview(giftIcon)
            
            pCell.giftIcon.isHidden = true
            
            UIView.animate(withDuration: 0.2) {
                giftIcon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: []) {
                    giftIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    giftIcon.center = toCenter
                } completion: { _ in }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.6) {
                giftIcon.alpha = 0
            } completion: { _ in
                guard i == cellCount - 1 else { return }
                self.removeFromSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: []) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.contentView.alpha = 0
        } completion: { _ in
            guard cellCount == 0 else { return }
            self.removeFromSuperview()
        }
    }
    
    @objc func confirmViewDidClick() {
        hide(animated: true)
    }
}

extension CosmicExplorationPrizeView {
    func addTimer() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now() + 1, repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.second -= 1
        }
        timer.resume()
        self.timer = timer
    }
    
    func removeTimer() {
        timer?.cancel()
        timer = nil
    }
}


