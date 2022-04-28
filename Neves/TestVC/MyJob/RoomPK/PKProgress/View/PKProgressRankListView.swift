//
//  PKProgressRankView.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

class PKProgressRankListView: UICollectionView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        jp.contentInsetAdjustmentNever()
        clipsToBounds = false
        collectionViewLayout = PKProgressRankListLayout()
    }
    
    func setupRightAligned() {
        guard let layout = collectionViewLayout as? PKProgressRankListLayout else { return }
        layout.isRightAligned = true
        layout.invalidateLayout()
    }
}

class PKProgressRankListLayout: UICollectionViewFlowLayout {
    var isRightAligned = false
    
    override init() {
        super.init()
        itemSize = [21, 21]
        minimumLineSpacing = 10
        minimumInteritemSpacing = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var attris: [UICollectionViewLayoutAttributes]? = nil
    
    override func prepare() {
        super.prepare()
        
        attris = nil
        
        guard let collectionView = self.collectionView else { return }
        let count = collectionView.numberOfItems(inSection: 0)
        guard count > 0 else { return }
        
        var kAttris: [UICollectionViewLayoutAttributes] = []
        for i in 0 ..< count {
            let index = count - 1 - i
            let indexPath = IndexPath(item: index, section: 0)
            guard let attr = layoutAttributesForItem(at: indexPath) else { continue }
            
            var frame = attr.frame
            if isRightAligned {
                if let lastAttr = kAttris.last {
                    frame.origin.x = lastAttr.frame.origin.x - minimumLineSpacing - frame.width
                } else {
                    frame.origin.x = collectionView.frame.width - frame.width
                }
            } else {
                if let lastAttr = kAttris.last {
                    frame.origin.x = lastAttr.frame.maxX + minimumLineSpacing
                } else {
                    frame.origin.x = 0
                }
            }
            attr.frame = frame
            
            kAttris.append(attr)
        }
        
        attris = kAttris
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attris
    }
}
