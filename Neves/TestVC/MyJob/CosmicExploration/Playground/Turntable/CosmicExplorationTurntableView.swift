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
    
    var exploringWorkItems: [DispatchWorkItem] = []
    var isExploring = false
    
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
        let oldStage = self.stage
        guard self.stage != stage else { return }
        self.stage = stage
        
        hostView.updateStage(stage, animated: animated)
        
        var isEnabled = false
        var isExploring = false
        
        switch stage {
        case .idle:
            break

        case let .supplying(second):
            isEnabled = true
            
        case let .exploring(second):
            isExploring = true

        case let .finish(isDiscover, second):
            break
            
        }
        
        planetViews.forEach { $0.isUserInteractionEnabled = isEnabled }
        exploringAnim(isExploring)
    }
    
    func exploringAnim(_ isExploring: Bool) {
        guard self.isExploring != isExploring else { return }
        self.isExploring = isExploring
        
        guard isExploring else {
            exploringWorkItems.forEach { $0.cancel() }
            exploringWorkItems = []
            for planetView in planetViews {
                planetView.stopExploringAnimtion()
            }
            return
        }
        
        let targetPlantView = planetViews.randomElement()!
        JPrint("目标", targetPlantView.planet.name)
        
        var allPlant: [CosmicExplorationPlanetView] = []
        
        let planetViews1 = randomPlanetViews(without: nil)
        allPlant += planetViews1
        
        let planetViews2 = randomPlanetViews(without: planetViews1.last)
        allPlant += planetViews2
        
        var planetViews3 = randomPlanetViews(without: planetViews2.last)
        if let index = planetViews3.firstIndex(of: targetPlantView) {
            planetViews3.remove(at: index)
        } else {
            planetViews3.removeLast()
        }
        planetViews3.append(targetPlantView)
        allPlant += planetViews3
        
        let maxIndex = allPlant.count - 1
        let slowIndex = 11
        var beginTime: Double = 0
        
        JPrint("开始")
        for (i, planetView) in allPlant.enumerated() {
            let thisTime = beginTime
            let index = i
            exploringWorkItems.append(Asyncs.mainDelay(thisTime) { [weak self] in
                guard let self = self else { return }
                switch self.stage {
                case .exploring:
                    break
                default:
                    return
                }
                
                let delay: TimeInterval = index < maxIndex ? (index >= slowIndex ? 0.45 : 0.25) : 0
                planetView.startExploringAnimtion(endDelay: delay)
                
                JPrint(index, "---", planetView.planet.name, "开始时间:", thisTime, "消失延时:", delay)
                if delay == 0 {
                    JPrint("搞定")
                }
            })
            beginTime += i >= slowIndex ? 0.45 : 0.25
        }
    }
    
    func randomPlanetViews(without planetView: CosmicExplorationPlanetView?) -> [CosmicExplorationPlanetView] {
        var randomPlanetViews = Array(Set(planetViews))
        if let planetView = planetView, let index = randomPlanetViews.firstIndex(of: planetView) {
            randomPlanetViews.remove(at: index)
        }
        return randomPlanetViews
    }
}
