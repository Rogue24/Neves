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
    
    let hostView = CosmicExplorationHostView()
    var planetViews: [CosmicExplorationPlanetView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        knapsackBtnWidthConstraint.constant = 54.px
        knapsackBtnBottomConstraint.constant = 14.px
        
        addSubview(hostView)
        
        planetViews = CosmicExplorationManager.shared.planetModels.map { model in
            let planetView = CosmicExplorationPlanetView(model)
            planetView.delegate = self
            addSubview(planetView)
            model.planetView = planetView
            return planetView
        }
        
    }
    
    private(set) var stage: CosmicExploration.Stage = .idle
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

extension CosmicExplorationTurntableView {
    func updateStage(_ stage: CosmicExploration.Stage, animated: Bool) {
        guard self.stage != stage else { return }
        self.stage = stage
        
        hostView.updateStage(stage, animated: animated)
        
        var isEnabled = true
        switch stage {
        case .idle:
            isEnabled = true

        case let .supplying(second):
            isEnabled = true

        case .startExploring:
            isEnabled = false

        case let .exploring(second):
            isEnabled = false

        case let .finish(isDiscover, second):
            isEnabled = false
        }
        
        isUserInteractionEnabled = isEnabled
    }
}
