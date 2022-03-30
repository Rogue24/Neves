//
//  CosmicExplorationTurntableView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

protocol CosmicExplorationTurntableViewDelegate {
    func turntableView(_ turntableView: CosmicExplorationTurntableView,
                       updateSuppliesFromSupplyType supplyType: CosmicExploration.SupplyType,
                       toItemFrame itemFrame: CGRect)
}

class CosmicExplorationTurntableView: UIView {
    
    @IBOutlet weak var knapsackBtn: NoHighlightButton!
    
    @IBOutlet weak var knapsackBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var knapsackBtnBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: (AnyObject & CosmicExplorationTurntableViewDelegate)? = nil
    var planetViews: [CosmicExplorationPlanetView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        knapsackBtnWidthConstraint.constant = 54.px
        knapsackBtnBottomConstraint.constant = 14.px
        
        planetViews = CosmicExplorationManager.shared.planetModels.map { model in
            let planetView = CosmicExplorationPlanetView(model)
            planetView.delegate = self
            addSubview(planetView)
            model.planetView = planetView
            return planetView
        }
        
    }
    
}

extension CosmicExplorationTurntableView: CosmicExplorationPlanetViewDelegate {
    func planetView(_ planetView: CosmicExplorationPlanetView,
                    updateSuppliesFromSupplyType supplyType: CosmicExploration.SupplyType,
                    toItemFrame itemFrame: CGRect) {
        guard let delegate = self.delegate, let superView = self.superview else { return }
        let toItemFrame = convert(itemFrame, to: superView)
        delegate.turntableView(self, updateSuppliesFromSupplyType: supplyType, toItemFrame: toItemFrame)
    }
}
