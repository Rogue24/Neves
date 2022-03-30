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
    
}

// MARK: - 选中状态
extension CosmicExplorationManager {
    func toSelectPlanet(_ planet: CosmicExploration.Planet) {
        var targetPlanet: CosmicExploration.PlanetModel? = nil
        planetModels.forEach {
            guard $0.planet == planet else {
                $0.isSelected = false
                return
            }
            
            if $0.isSelected {
                $0.isSelected = false
            } else {
                $0.isSelected = true
                targetPlanet = $0
            }
        }
        selectedPlanet = targetPlanet
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
