//
//  TestTryCatchViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/2/17.
//

import UIKit

class TestTryCatchViewController: TestBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var ooo = 3
        do {
            JPrint("111")
            ooo = try abc(true)
            JPrint("222")
        } catch {
            JPrint("错了")
        }
        
        JPrint("333 \(ooo)")
    }

    func abc(_ isThrow: Bool) throws -> Int {
        if isThrow {
            throw NSError()
        }
        return 5
    }
}
