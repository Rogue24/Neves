//
//  CosmicExplorationTurntableView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

protocol CosmicExplorationTurntableViewDelegate {
    func turntableView(_ turntableView: CosmicExplorationTurntableView, betFrom giftType: Int, to frame: CGRect)
}

class CosmicExplorationTurntableView: UIView {
    
    @IBOutlet weak var knapsackBtn: NoHighlightButton!
    
    @IBOutlet weak var knapsackBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var knapsackBtnBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: (AnyObject & CosmicExplorationTurntableViewDelegate)? = nil
    var starViews: [CosmicExplorationStarView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        knapsackBtnWidthConstraint.constant = 54.px
        knapsackBtnBottomConstraint.constant = 14.px
        
        starViews = CosmicExplorationManager.shared.planetModels.map { model in
            let starView = CosmicExplorationStarView(model)
            starView.delegate = self
            addSubview(starView)
            model.starView = starView
            return starView
        }
        
    }
    
}

extension CosmicExplorationTurntableView: CosmicExplorationStarViewDelegate {
    func starView(_ starView: CosmicExplorationStarView, betFrom giftType: Int, to frame: CGRect) {
        guard let delegate = self.delegate, let superView = self.superview else { return }
        delegate.turntableView(self, betFrom: giftType, to: convert(frame, to: superView))
    }
}
