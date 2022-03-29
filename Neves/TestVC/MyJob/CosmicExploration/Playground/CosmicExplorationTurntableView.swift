//
//  CosmicExplorationTurntableView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationTurntableView: UIView {
    
    @IBOutlet weak var knapsackBtn: NoHighlightButton!
    
    @IBOutlet weak var knapsackBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var knapsackBtnBottomConstraint: NSLayoutConstraint!
    
    var starViews: [CosmicExplorationStarView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        knapsackBtnWidthConstraint.constant = 54.px
        knapsackBtnBottomConstraint.constant = 14.px
        
        starViews = CosmicExplorationManager.shared.planetModels.map { model in
            let starView = CosmicExplorationStarView(model)
            addSubview(starView)
            model.starView = starView
            return starView
        }
        
    }
    
}
