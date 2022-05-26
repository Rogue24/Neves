//
//  PlaygroundViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  公告：这是【临时游玩】的场所！游玩结束后记得【清空代码】！！！

import UIKit

class PlaygroundViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addFunAction { [weak self] in
            guard let self = self else { return }
            JPrint("replaceMe", self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }

}

extension PlaygroundViewController {
    
}
 
