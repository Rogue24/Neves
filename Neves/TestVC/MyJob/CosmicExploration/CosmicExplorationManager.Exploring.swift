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
            cancelExploringAnimtion()
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
        
        self.exploringPlanetModels = exploringPlanetModels
        
        JPrint("开始")
        beginExploringAnimtion(index: 0, slowIndex: 11, maxIndex: exploringPlanetModels.count - 1)
    }
    
    func beginExploringAnimtion(index: Int, slowIndex: Int, maxIndex: Int) {
        exploringPlanetModel?.planetView?.stopExploringAnimtion()
        exploringPlanetModel = nil
        
        exploringWorkItem?.cancel()
        exploringWorkItem = nil
        
        guard let planetModel = exploringPlanetModels.first else { return }
        exploringPlanetModels.removeFirst()
        
        planetModel.planetView?.startExploringAnimtion()
        
        guard exploringPlanetModels.count > 0 else {
            JPrint("结束")
            return
        }
        
        exploringPlanetModel = planetModel
        
        let delay: TimeInterval = index < maxIndex ? (index >= slowIndex ? 0.45 : 0.25) : 0
        let nextIndex = index + 1
        exploringWorkItem = Asyncs.mainDelay(delay) { [weak self] in
            guard let self = self else { return }
            self.beginExploringAnimtion(index: nextIndex, slowIndex: slowIndex, maxIndex: maxIndex)
        }
    }
    
    func cancelExploringAnimtion() {
        exploringPlanetModels = []
        exploringPlanetModel = nil
        exploringWorkItem?.cancel()
        exploringWorkItem = nil
        for planetModel in planetModels where !planetModel.isWinning {
            planetModel.isTarget = false
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
