//
//  CosmicExplorationTestViewController.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationTestViewController: TestBaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
}
