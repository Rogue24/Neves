//
//  UserInfoCardTestViewController.swift
//  Neves
//
//  Created by aa on 2026/9/17.
//

import UIKit
import FunnyButton

class UserInfoCardTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.delegate = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction(name: "Go Medal Ranking") { [weak self] in
            guard let self else { return }
            
        }
        addFunnyAction(name: "Pop Medal Ranking") { [weak self] in
            guard let self else { return }
            
        }
        addFunnyAction(name: "Pop Medal Wall") { [weak self] in
            guard let self else { return }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunnyActions()
        JPHUD.dismiss()
    }
}

