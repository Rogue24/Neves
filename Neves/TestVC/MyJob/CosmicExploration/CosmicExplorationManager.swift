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
    private(set) var selectedPlanet: CosmicExploration.PlanetModel? = nil {
        didSet {
            guard (selectedPlanet == nil && oldValue != nil) ||
                  (selectedPlanet != nil && oldValue == nil) else { return }
            playView?.bottomView.updateIsActived(isActived)
        }
    }
    
    private var exploringWorkItems: [DispatchWorkItem] = []
    private(set) var isExploring = false
    
    var targetPlanet: CosmicExploration.PlanetModel? = nil
    var winningPlanet: CosmicExploration.PlanetModel? = nil
    
    init() {
        resetData()
    }
    
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
    
    func findPlanetModel(for plant: CosmicExploration.Planet) -> CosmicExploration.PlanetModel? {
        planetModels.first(where: { $0.planet == plant })
    }
    
    var isShowedPrizes = false
    
    private(set) var stage: CosmicExploration.Stage = .idle {
        didSet {
            updateStage(oldValue)
        }
    }
    
    private var timer: DispatchSourceTimer?
}

// MARK: - 选中状态
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

// MARK: - 补给
extension CosmicExplorationManager {
    func addSupply(for type: CosmicExploration.SupplyType) {
        guard let planetModel = selectedPlanet else { return }
        planetModel.addSupply(for: type)
    }
    
    func addSupplyFromOther(toPlant plant: CosmicExploration.Planet) {
        playView?.addSupplyFromOther(toPlant: plant)
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


// MARK: - 抽奖随机过程！
extension CosmicExplorationManager {
    func resetExploring(_ isExploring: Bool) {
        guard self.isExploring != isExploring else { return }
        self.isExploring = isExploring

        guard isExploring, let targetPlanet = self.targetPlanet else {
            exploringWorkItems.forEach { $0.cancel() }
            exploringWorkItems = []
            for planetModel in planetModels where !planetModel.isWinning {
                planetModel.isTarget = false
            }
            return
        }
        
        JPrint("目标", targetPlanet.planet.name)

        var exploringPlanetModels: [CosmicExploration.PlanetModel] = []

        let planetModels1 = randomPlanetModels(without: nil)
        exploringPlanetModels += planetModels1
        
        let planetModels2 = randomPlanetModels(without: planetModels1.last.map { [$0.planet] } ?? nil)
        exploringPlanetModels += planetModels2

        var planetModels3 = randomPlanetModels(without: planetModels2.last.map { [$0.planet] } ?? nil)
        if let index = planetModels3.firstIndex(where: { $0.planet == targetPlanet.planet }) {
            planetModels3.remove(at: index)
        } else {
            planetModels3.removeLast()
        }
        planetModels3.append(targetPlanet)
        exploringPlanetModels += planetModels3

        let maxIndex = exploringPlanetModels.count - 1
        let slowIndex = 11
        var beginTime: Double = 0
        
        JPrint("开始")
        for (i, planetModel) in exploringPlanetModels.enumerated() {
            let delay: TimeInterval = i < maxIndex ? (i >= slowIndex ? 0.45 : 0.25) : 0
            JPrint(index, "---", planetModel.planet.name, "开始时间:", beginTime, "消失延时:", delay)
            
            if let workItem = exploringAnimtion(planetModel: planetModel,
                                                beginTime: beginTime,
                                                endDelay: delay) {
                exploringWorkItems.append(workItem)
            }
            
            beginTime += (i >= slowIndex ? 0.45 : 0.25)
        }
    }
    
    func exploringAnimtion(planetModel: CosmicExploration.PlanetModel,
                           beginTime: Double,
                           endDelay: TimeInterval) -> DispatchWorkItem? {
        let task: () -> () = { [weak self] in
            guard let self = self else { return }
            
            switch self.stage {
            case .exploring:
                break
            default:
                return
            }
            
            if endDelay == 0 {
                JPrint("搞定")
                planetModel.isTarget = true
            } else {
                planetModel.planetView?.startExploringAnimtion(endDelay: endDelay)
            }
        }
        
        if beginTime > 0 {
            return Asyncs.mainDelay(beginTime, task)
        } else {
            task()
            return nil
        }
    }

    func randomPlanetModels(without planets: Set<CosmicExploration.Planet>?) -> [CosmicExploration.PlanetModel] {
        var randomPlanets = Set(planetModels.map { $0.planet })
        if let planets = planets {
            randomPlanets = randomPlanets.subtracting(planets)
        }
        
        var randomPlanetModels: [CosmicExploration.PlanetModel] = []
        for plant in Array(randomPlanets) {
            guard let plantModel = findPlanetModel(for: plant) else { continue }
            randomPlanetModels.append(plantModel)
        }
        
        return randomPlanetModels
    }
}

// MARK: - 中奖状态
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
    
    func updateTargetPlanet() {
        if let winningPlanet = self.winningPlanet, winningPlanet.isWinning {
            winningPlanet.planetView?.updateIsWinning(true, animated: false)
        } else if let targetPlanet = self.targetPlanet, targetPlanet.isTarget {
            targetPlanet.planetView?.startExploringAnimtion(endDelay: 0)
        }
    }
}

// MARK: - 更新探索阶段
extension CosmicExplorationManager {
    func begin() {
        switch stage {
        case .idle:
            stage = .supplying(30)
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
            break
            
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


