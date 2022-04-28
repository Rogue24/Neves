//
//  CosmicExplorationTestViewController.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .custom)
        btn.frame = [50, 100, 150, 80]
        btn.backgroundColor = .randomColor
        btn.addTarget(self, action: #selector(what), for: .touchUpInside)
        view.addSubview(btn)
        
        let v = JPView(frame: [200, 250, 150, 80])
        v.backgroundColor = .randomColor
        view.addSubview(v)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            guard CosmicExplorationManager.shared.playView == nil else {
                if let model = CosmicExplorationManager.shared.selectedPlanet {
                    CosmicExplorationManager.shared.addSupplyFromOther(toPlant: model.planet)
                }
                
                CosmicExplorationManager.shared.begin()
                return
            }
            
            CosmicExplorationManager.shared.playView = CosmicExplorationPlayView.show(on: self.view)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
    }
    
    @objc func what() {
        JPrint("what?")
    }
    
    class JPView: UIView {
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            super.touchesBegan(touches, with: event)
            
        }
        
    }
}


