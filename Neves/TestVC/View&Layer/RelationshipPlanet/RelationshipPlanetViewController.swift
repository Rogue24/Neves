//
//  RelationshipPlanetViewController.swift
//  Neves
//
//  Created by aa on 2021/8/30.
//

import UIKit

class RelationshipPlanetViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let universeView = UniverseView()
        universeView.y = PortraitScreenHeight - DiffTabBarH - universeView.height - 80
        view.addSubview(universeView)
    }
    
}
