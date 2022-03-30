//
//  CosmicExplorationManager.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationManager {
    
    static let shared = CosmicExplorationManager()
    
    private(set) var planetModels: [CosmicExploration.PlanetModel] = []
    
    private(set) var supplyInfoModels: [CosmicExploration.SupplyInfoModel] = []
    
    weak var playView: CosmicExplorationPlayView?
    
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
    
    var selectedPlanetModel: CosmicExploration.PlanetModel? = nil {
        didSet {
            guard (selectedPlanetModel == nil && oldValue != nil) || (selectedPlanetModel != nil && oldValue == nil) else { return }
            playView?.bottomView.updateActived(isActived)
        }
    }
    
    var isActived: Bool { selectedPlanetModel != nil }
    
    func selectPlanet(_ planet: CosmicExploration.Planet) {
        var selectedModel: CosmicExploration.PlanetModel? = nil
        planetModels.forEach {
            guard $0.planet == planet else {
                $0.isSelected = false
                return
            }
            
            if $0.isSelected {
                $0.isSelected = false
            } else {
                $0.isSelected = true
                selectedModel = $0
            }
        }
        selectedPlanetModel = selectedModel
    }
    
    func addSupply(_ type: CosmicExploration.SupplyType) {
        guard let planetModel = selectedPlanetModel else { return }
        planetModel.addSupply(type)
    }
    
    func addSupplyFromOther(toPlant plant: CosmicExploration.Planet) {
        playView?.addSupplyFromOther(toPlant: plant)
    }
}
