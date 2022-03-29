//
//  CosmicExplorationTestViewController.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationTestViewController: TestBaseViewController {
    
    let playView = CosmicExplorationPlayView.loadFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            
            guard self.playView.superview == nil else { return }
            
            self.playView.frame = PortraitScreenBounds
            self.playView.layoutIfNeeded()
            self.view.addSubview(self.playView)
            
            self.playView.show()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
}
