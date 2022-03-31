//
//  PlaygroundViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  公告：这是【临时游玩】的场所！游玩结束后记得【清空代码】！！！

import UIKit

class PlaygroundViewController: TestBaseViewController {
    
    let arr: [Int] = [1, 2, 3, 4 ,5]
    var sset: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            JPrint("replaceMe", self)
            
            
            JPrint("------")
//            self.sset = Set(self.arr)
//
//            let abc = Array(self.sset)
//
//            JPrint(self.sset)
//            for _ in 0 ..< self.sset.count {
//                let a = self.sset.removeFirst()
//                JPrint(a)
//            }
//
//            JPrint(abc)
            
            
            let abc = [1, 2]
            
            let ee = Array(abc.prefix(3))
            JPrint(ee)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }

}

extension PlaygroundViewController {
    
}
 
