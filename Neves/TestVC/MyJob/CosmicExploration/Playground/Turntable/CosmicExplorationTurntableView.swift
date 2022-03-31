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
    
    
    private var stage: CosmicExploration.Stage = .idle
    
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
    func updateStage(_ stage: CosmicExploration.Stage, animated: Bool) {
        guard self.stage != stage else { return }
        defer { self.stage = stage }
        
        hostView.updateStage(stage, animated: animated)
        
        var isSupplying = false
        var isExploring = false
        var isDiscover = false
        var second = 0
        
        switch stage {
        case .idle:
            break
            
        case .supplying:
            switch self.stage {
            case .supplying:
                return
            default:
                break
            }
            
            isSupplying = true
            
        case .exploring:
            switch self.stage {
            case .exploring:
                return
            default:
                break
            }
            
            isExploring = true

        case let .finish(isDis, sec):
            isDiscover = isDis
            second = Int(sec)
        }
        
        self.isSupplying = isSupplying
        
        exploringAnim(isExploring)
        
        showOrHidePrizes(isDiscover, second > 5 ? 5 : second, animated: animated)
    }
    
}

// MARK: - 奖品
extension CosmicExplorationTurntableView {
    func showOrHidePrizes(_ isShow: Bool, _ second: Int, animated: Bool) {
        guard isShow else {
            prizeView?.hide(animated: animated)
            prizeView = nil
            return
        }
        
        guard prizeView == nil else { return }
        
        guard let prizeView = CosmicExplorationPrizeView(second) else { return }
        addSubview(prizeView)
        self.prizeView = prizeView
        prizeView.show(animated: animated)
    }
}

// MARK: - 随机动画
extension CosmicExplorationTurntableView {
    
    // TODO: 从最后一个开始添加，根据剩余时长
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
