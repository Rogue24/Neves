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
    
    private(set) var stage: CosmicExploration.Stage = .idle {
        didSet {
            updateStage(oldValue)
        }
    }
    private var timer: DispatchSourceTimer?
}

// MARK: - 选中状态
extension CosmicExplorationManager {
    func toSelectPlanet(_ targetPlanet: CosmicExploration.Planet?) {
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

// MARK: - 探索阶段
extension CosmicExplorationManager {
    func gotoNextStage() {
        var stage = self.stage
        
        switch stage {
        case .idle:
            toSelectPlanet(nil)
            stage = .supplying(5)
            
        case let .supplying(second):
            if second > 0 {
                stage = .supplying(second - 1)
            } else {
                toSelectPlanet(nil)
                targetPlanet = planetModels.randomElement()
                stage = .exploring(5)
            }
            
        case let .exploring(second):
            if second > 0 {
                stage = .exploring(second - 1)
            } else {
                setWinningPlanet(targetPlanet?.planet)
                stage = .finish(true, 10)
            }
            
        case let .finish(isDiscover, second):
            if second > 0 {
                stage = .finish(isDiscover, second - 1)
            } else {
                setWinningPlanet(nil)
                stage = .idle
            }
        }
        
        self.stage = stage
    }
    
    
}

// MARK: - 计时器
extension CosmicExplorationManager {
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
    // TODO: 从最后一个开始添加，根据剩余时长
    func exploringAnim(_ isExploring: Bool) {
//        guard self.isExploring != isExploring else { return }
//        self.isExploring = isExploring
//
//        guard isExploring else {
//            exploringWorkItems.forEach { $0.cancel() }
//            exploringWorkItems = []
//            for planetModel in planetModels {
//                planetModel.planetView?.stopExploringAnimtion()
//            }
//            return
//        }
//
//        let targetPlantView = planetViews.randomElement()!
//        JPrint("目标", targetPlantView.planet.name)
//
//        var allPlant: [CosmicExplorationPlanetView] = []
//
//        let planetViews1 = randomPlanetViews(without: nil)
//        allPlant += planetViews1
//
//        let planetViews2 = randomPlanetViews(without: planetViews1.last)
//        allPlant += planetViews2
//
//        var planetViews3 = randomPlanetViews(without: planetViews2.last)
//        if let index = planetViews3.firstIndex(of: targetPlantView) {
//            planetViews3.remove(at: index)
//        } else {
//            planetViews3.removeLast()
//        }
//        planetViews3.append(targetPlantView)
//        allPlant += planetViews3
//
//        let maxIndex = allPlant.count - 1
//        let slowIndex = 11
//        var beginTime: Double = 0
//
//        JPrint("开始")
//        for (i, planetView) in allPlant.enumerated() {
//            let thisTime = beginTime
//            let index = i
//            exploringWorkItems.append(Asyncs.mainDelay(thisTime) { [weak self] in
//                guard let self = self else { return }
//                switch self.stage {
//                case .exploring:
//                    break
//                default:
//                    return
//                }
//
//                let delay: TimeInterval = index < maxIndex ? (index >= slowIndex ? 0.45 : 0.25) : 0
//                planetView.startExploringAnimtion(endDelay: delay)
//
//                JPrint(index, "---", planetView.planet.name, "开始时间:", thisTime, "消失延时:", delay)
//                if delay == 0 {
//                    JPrint("搞定")
//                }
//            })
//            beginTime += i >= slowIndex ? 0.45 : 0.25
//        }
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
    func setWinningPlanet(_ targetPlanet: CosmicExploration.Planet?) {
        if winningPlanet == nil, targetPlanet == nil { return }
        
        var winningPlanet: CosmicExploration.PlanetModel? = nil
        planetModels.forEach {
            guard let planet = targetPlanet, $0.planet == planet else {
                $0.isWinning = false
                return
            }
            $0.isWinning.toggle()
            if $0.isWinning { winningPlanet = $0 }
        }
        
        self.winningPlanet = winningPlanet
    }
}

// MARK: - 更新阶段
extension CosmicExplorationManager {
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
        
        switch stage {
        case .idle:
            break
            
        case let .supplying(second):
            break
            
        case let .exploring(second):
            break
            
        case let .finish(isDiscover, second):
            break
        }
        
        playView?.updateStage(stage, oldStage)
    }
}


