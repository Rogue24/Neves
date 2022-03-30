//
//  CosmicExplorationRecordView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationRecordView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewRightConstraint: NSLayoutConstraint!
    
    static let cellW: CGFloat = 15.px
    static let cellSpace: CGFloat = 5.px
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 11.px
        layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 11.px)
        
        titleLabelLeftConstraint.constant = 10.px
        titleLabelRightConstraint.constant = 6.px
        collectionViewWidthConstraint.constant = Self.cellW * 8 + Self.cellSpace * 8
        collectionViewRightConstraint.constant = 10.px
        
        collectionView.jp.contentInsetAdjustmentNever()
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = Self.cellSpace
            flowLayout.minimumInteritemSpacing = Self.cellSpace
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: Self.cellSpace, bottom: 0, right: 0)
            flowLayout.itemSize = [Self.cellW, 22.px]
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CosmicExplorationRecordView.Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
    }
    
    class Cell: UICollectionViewCell {
        
        let imageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView.image = UIImage(named: "spaceship_planet_s02")
            imageView.contentMode = .scaleAspectFit
            imageView.frame.size = [CosmicExplorationRecordView.cellW, 22.px]
            contentView.addSubview(imageView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}

extension CosmicExplorationRecordView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CosmicExplorationRecordView.Cell
        
        return cell
    }
    
}
