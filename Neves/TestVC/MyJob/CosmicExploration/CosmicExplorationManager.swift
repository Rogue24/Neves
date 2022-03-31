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
    
    private(set) var stage: CosmicExploration.Stage = .idle
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
            stage = .supplying(5)
            
        case let .supplying(second):
            if second > 0 {
                stage = .supplying(second - 1)
            } else {
                toSelectPlanet(nil)
                stage = .exploring(5)
            }
            
        case let .exploring(second):
            toSelectPlanet(nil)
            if second > 0 {
                stage = .exploring(second - 1)
            } else {
                stage = .finish(true, 10)
            }
            
        case let .finish(isDiscover, second):
            toSelectPlanet(nil)
            if second > 0 {
                stage = .finish(isDiscover, second - 1)
                toSelectPlanet(nil)
            } else {
                stage = .idle
            }
        }
        
        debugStage(stage)
        
        self.stage = stage
        playView?.updateStage(stage)
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


