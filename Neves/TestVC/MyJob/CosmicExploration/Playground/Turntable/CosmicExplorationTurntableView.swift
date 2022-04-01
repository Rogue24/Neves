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
    weak var prizeView: CosmicExplorationPrizeView? = nil
    
    private var isSupplying = false {
        didSet {
            guard isSupplying != oldValue else { return }
            planetViews.forEach { $0.isUserInteractionEnabled = isSupplying }
        }
    }
    
    private var exploringWorkItems: [DispatchWorkItem] = []
    private var isExploring = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        knapsackBtnWidthConstraint.constant = 54.px
        knapsackBtnBottomConstraint.constant = 14.px
        
        addSubview(hostView)
        
        planetViews = CosmicExplorationManager.shared.planetModels.map { model in
            let planetView = CosmicExplorationPlanetView(model)
            planetView.isUserInteractionEnabled = false
            planetView.delegate = self
            addSubview(planetView)
            model.planetView = planetView
            return planetView
        }
    }
    
    func findPlanetView(for plant: CosmicExploration.Planet) -> CosmicExplorationPlanetView? {
        planetViews.first(where: { $0.planet == plant })
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

extension CosmicExplorationTurntableView {
    func updateStage(_ stage: CosmicExploration.Stage, _ oldStage: CosmicExploration.Stage, animated: Bool) {
        guard stage != oldStage else { return }
        
        hostView.updateStage(stage, oldStage, animated: animated)
        
        var isSupplying = false
        
        switch stage {
        case .idle:
            hidePrizes(animated: animated)
            
        case .supplying:
            hidePrizes(animated: animated)
            isSupplying = true
            
        case .exploring:
            hidePrizes(animated: animated)

        case let .finish(isDiscover, second):
            switch oldStage {
            case .finish:
                break
            default:
                guard isDiscover, !CosmicExplorationManager.shared.isShowedPrizes else { break }
                CosmicExplorationManager.shared.isShowedPrizes = true
                showPrizes(Int(second > 5 ? 5 : second), animated: animated)
            }
        }
        
        self.isSupplying = isSupplying
    }
    
}

// MARK: - 奖品
extension CosmicExplorationTurntableView {
    func showPrizes(_ second: Int, animated: Bool) {
        guard prizeView == nil else { return }
        
        guard let prizeView = CosmicExplorationPrizeView(second) else { return }
        addSubview(prizeView)
        self.prizeView = prizeView
        prizeView.show(animated: animated)
    }
    
    func hidePrizes(animated: Bool) {
        prizeView?.hide(animated: animated)
        prizeView = nil
    }
}
