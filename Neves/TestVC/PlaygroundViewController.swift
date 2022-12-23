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
        
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            
            
//            var a = 0
//            var b = 0
//            let c = 7
//
//            while a < c {
//                defer {
//                    JPrint("a", a)
//                }
//
//                if b == 4 {
//                    a += 1
//                    continue
//                }
//
//                a += 1
//                b += 1
//            }
//            JPrint("a", a)
//            JPrint("b", b)
            
            var aa = [1, 2, 3, 5, 88, 33,24 ,453,6 ,646,4653,46,333]
            let bb = Array(aa.prefix(7))
            JPrint("bb", bb)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }

}

extension PlaygroundViewController {
    
}
 
