//
//  TestDoCatchViewController.swift
//  Neves
//
//  Created by aa on 2022/5/26.
//

class TestDoCatchViewController: TestBaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            
            self.aaa(true)
            JPrint("----------")
            self.aaa(false)
        }
    }
    
    func aaa(_ x: Bool) {
        do {
            JPrint("aaa 111")
            try bbb(x)
            JPrint("aaa 222")
//            return
        } catch {
            JPrint("aaa 333")
//            return
        }
        // do-catch后面的还是会继续跑，除非在do-catch的{}里面return
        JPrint("aaa 444")
    }
    
    func bbb(_ x: Bool) throws {
        if x {
            JPrint("bbb 111")
            throw NSError(domain: "", code: 123)
        }
        JPrint("bbb 222")
    }
    
//    [04:23:04:48]: aaa 111
//    [04:23:04:48]: bbb 111
//    [04:23:04:48]: aaa 333
//    [04:23:04:48]: aaa 444
//    [04:23:04:48]: ----------
//    [04:23:04:48]: aaa 111
//    [04:23:04:48]: bbb 222
//    [04:23:04:48]: aaa 222
//    [04:23:04:48]: aaa 444
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
}
