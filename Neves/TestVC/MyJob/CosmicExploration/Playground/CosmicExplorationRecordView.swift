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
    @IBOutlet weak var collectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = .systemFont(ofSize: 11.px)
        
        titleLabelLeftConstraint.constant = 10.px
        collectionViewLeftConstraint.constant = 6.px
        collectionViewRightConstraint.constant = 10.px
    }
    
}
