//
//  EqualTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/8/19.
//

import Foundation

class EqualTestViewController: TestBaseViewController {
    
    let testObj11 = TestObject1(a: 1, b: 3)
    let testObj12 = TestObject1(a: 1, b: 3)
    
    let testObj21 = TestObject2(a: 1, b: 3)
    let testObj22 = TestObject2(a: 1, b: 3)
    
    let testObj31: OCTestObject = {
        let obj = OCTestObject()
        obj.a = 4
        obj.b = 4
        return obj
    }()
    let testObj32: OCTestObject = {
        let obj = OCTestObject()
        obj.a = 4
        obj.b = 4
        return obj
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let a = testObj11 == testObj12
        let b = testObj21 == testObj22
        let c = testObj31 == testObj32
        
        JPrint(a, b, c)
    }
}
