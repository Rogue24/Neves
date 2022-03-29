//
//  CosmicExplorationManager.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationManager {
    
    static let shared = CosmicExplorationManager()
    
    private(set) var planetModels: [CosmicExploration.PlanetModel] = []
    
    private(set) var giftInfos: [CosmicExploration.GiftInfo] = []
    
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
        
        giftInfos = [
            .info1(1000, ""),
            .info2(2000, ""),
            .info3(5000, ""),
            .info4(10000, ""),
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
    
    func planetBet(for giftType: Int) {
        guard let planetModel = selectedPlanetModel else { return }
        planetModel.bet(giftType)
    }
    
}
