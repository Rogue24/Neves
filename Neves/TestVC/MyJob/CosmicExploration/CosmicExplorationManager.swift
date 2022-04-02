//
//  CosmicExplorationManager.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationManager {
    
    static let shared = CosmicExplorationManager()
    
    weak var playView: CosmicExplorationPlayView?
    
    private(set) var planetModels: [CosmicExploration.PlanetModel] = []
    private(set) var supplyInfoModels: [CosmicExploration.SupplyInfoModel] = []
    
    var isActived: Bool { selectedPlanet != nil }
    var selectedPlanet: CosmicExploration.PlanetModel? = nil {
        didSet {
            guard (selectedPlanet == nil && oldValue != nil) ||
                  (selectedPlanet != nil && oldValue == nil) else { return }
            playView?.bottomView.updateIsActived(isActived)
        }
    }
    
    private var timer: DispatchSourceTimer?
    
    var isExploring = false
    var exploringPlanetModels: [CosmicExploration.PlanetModel] = []
    var exploringPlanetModel: CosmicExploration.PlanetModel? = nil
    var exploringWorkItem: DispatchWorkItem? = nil
    
    var targetPlanet: CosmicExploration.PlanetModel? = nil
    var winningPlanet: CosmicExploration.PlanetModel? = nil
    
    var isShowedPrizes = false
    
    private(set) var stage: CosmicExploration.Stage = .idle {
        didSet { updateStage(oldValue) }
    }
    
    init() {
        resetData()
    }
    
    func findPlanetModel(for plant: CosmicExploration.Planet) -> CosmicExploration.PlanetModel? {
        planetModels.first(where: { $0.planet == plant })
    }
    
}

// MARK: - 初始化
extension CosmicExplorationManager {
    func resetData() {
        planetModels = [
            .init(.mercury(10)),
            .init(.venus(20)),
            .init(.mars(5)),
            .init(.jupiter(15)),
            .init(.saturn(25)),
            .init(.uranus(0)),
        ]
        
        supplyInfoModels = [
            .init(type: .supply1, singleVotes: 1000, iconUrl: ""),
            .init(type: .supply2, singleVotes: 2000, iconUrl: ""),
            .init(type: .supply3, singleVotes: 5000, iconUrl: ""),
            .init(type: .supply4, singleVotes: 10000, iconUrl: ""),
        ]
    }
    
    func resetTargetPlanet() {
        if let winningPlanet = self.winningPlanet, winningPlanet.isWinning {
            winningPlanet.planetView?.updateIsWinning(true, animated: false)
        } else if let targetPlanet = self.targetPlanet, targetPlanet.isTarget {
            targetPlanet.planetView?.startExploringAnimtion()
        }
    }
}

// MARK: - 选中配置
extension CosmicExplorationManager {
    func selectPlanet(_ targetPlanet: CosmicExploration.Planet?) {
        if selectedPlanet == nil, targetPlanet == nil { return }
        
        var selectedPlanet: CosmicExploration.PlanetModel? = nil
        planetModels.forEach {
            guard let planet = targetPlanet, $0.planet == planet else {
                $0.isSelected = false
                return
            }
            $0.isSelected.toggle()
            if $0.isSelected { selectedPlanet = $0 }
        }
        
        self.selectedPlanet = selectedPlanet
    }
}

// MARK: - 中奖配置
extension CosmicExplorationManager {
    func resetWinningPlanet(_ targetPlanet: CosmicExploration.Planet?) {
        if winningPlanet == nil, targetPlanet == nil { return }
        
        var winningPlanet: CosmicExploration.PlanetModel? = nil
        planetModels.forEach {
            guard let planet = targetPlanet, $0.planet == planet else {
                $0.isWinning = false
                return
            }
            $0.isWinning = true
            winningPlanet = $0
        }
        
        self.winningPlanet = winningPlanet
    }
}

// MARK: - 更新探索阶段
extension CosmicExplorationManager {
    func begin() {
        switch stage {
        case .idle:
            stage = .supplying(5) // 30
            addSupplyingTimer()
        default:
            break
        }
    }
    
    func debugStage(_ stage: CosmicExploration.Stage) {
        switch stage {
        case .idle:
            JPrint("空闲阶段")
        case let .supplying(second):
            JPrint("补给阶段", second)
        case let .exploring(second):
            JPrint("探索阶段", second)
        case let .finish(isDiscover, second):
            JPrint("探索结束", isDiscover, second)
        }
    }
    
    func updateStage(_ oldStage: CosmicExploration.Stage) {
        debugStage(stage)
        
        var isExploring = false
        
        switch stage {
        case .idle:
            planetModels.forEach { $0.removeSupplies() }
            
        case .supplying:
            break
            
        case .exploring:
            isExploring = true
            
        case let .finish(isDiscover, _):
            switch oldStage {
            case .finish:
                break
            default:
                isShowedPrizes = !isDiscover
            }
        }
        
        resetExploring(isExploring)
        
        guard let playView = self.playView else { return }
        playView.updateStage(stage, oldStage)
    }
}

// MARK: - 计时器
extension CosmicExplorationManager {
    func addSupplyingTimer() {
        addTimer { [weak self] in
            guard let self = self else { return }
            switch self.stage {
            case let .supplying(second):
                if second > 0 {
                    self.stage = .supplying(second - 1)
                } else {
                    self.removeTimer()
                    
                    self.selectPlanet(nil)
                    self.targetPlanet = self.planetModels.randomElement()
                    
                    self.stage = .exploring(5)
                    self.addExploringTimer()
                }
                
            default:
                self.removeTimer()
            }
        }
    }
    
    func addExploringTimer() {
        addTimer { [weak self] in
            guard let self = self else { return }
            switch self.stage {
            case let .exploring(second):
                if second > 0 {
                    self.stage = .exploring(second - 1)
                } else {
                    self.removeTimer()
                    
                    self.resetWinningPlanet(self.targetPlanet?.planet)
                    self.targetPlanet = nil
                    self.stage = .finish(true, 10)
                    
                    self.addFinalTimer()
                }
                
            default:
                self.removeTimer()
            }
        }
    }
    
    func addFinalTimer() {
        addTimer { [weak self] in
            guard let self = self else { return }
            switch self.stage {
            case let .finish(isDiscover, second):
                if second > 0 {
                    self.stage = .finish(isDiscover, second - 1)
                } else {
                    self.removeTimer()
                    
                    self.resetWinningPlanet(nil)
                    self.stage = .idle
                }
                
            default:
                self.removeTimer()
            }
        }
    }
    
    func addTimer(_ eventHandler: @escaping () -> ()) {
        removeTimer()
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now() + 1, repeating: .seconds(1))
        timer.setEventHandler(handler: eventHandler)
        timer.resume()
        self.timer = timer
    }
    
    func removeTimer() {
        timer?.cancel()
        timer = nil
    }
}

// MARK: - 补给操作
extension CosmicExplorationManager {
    func addSupply(for type: CosmicExploration.SupplyType) {
        guard let planetModel = selectedPlanet else { return }
        planetModel.addSupply(for: type)
    }
    
    func addSupplyFromOther(toPlant plant: CosmicExploration.Planet) {
        playView?.addSupplyFromOther(toPlant: plant)
    }
}
