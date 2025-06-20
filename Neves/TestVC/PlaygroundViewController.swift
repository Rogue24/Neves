//
//  PlaygroundViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  公告：这是【临时游玩】的场所！游玩结束后记得【清空代码】！！！

import UIKit
import FunnyButton

class PlaygroundViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction { [weak self] in
            guard let self else { return }
            self.myTest()
        }
    }
    
}

private extension PlaygroundViewController {
    
    func myTest() {
        JPrint("try some test...")
        
    }
    
}
