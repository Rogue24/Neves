//
//  WidgetViewController.swift
//  Neves
//
//  Created by 周健平 on 2020/11/1.
//

import UIKit

class WidgetViewController: TestBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        let vc = SwiftUIBridge.addWidgetView()
//        addChild(vc)
//
//        vc.view.backgroundColor = .clear
//        vc.view.frame = [100, 200, 250, 250]
//        view.addSubview(vc.view)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addFunAction { [weak self] in
            let vc = WidgetView().intoVC()
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
