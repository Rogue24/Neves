//
//  CosmicExplorationManager.Exploring.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

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
