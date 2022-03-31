//
//  CosmicExplorationTestViewController.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            guard CosmicExplorationManager.shared.playView == nil else {
                if let model = CosmicExplorationManager.shared.selectedPlanet {
                    CosmicExplorationManager.shared.addSupplyFromOther(toPlant: model.planet)
                }
                
                CosmicExplorationManager.shared.gotoNextStage()
                return
            }
            
            CosmicExplorationManager.shared.playView = CosmicExplorationPlayView.show(on: self.view)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
}
