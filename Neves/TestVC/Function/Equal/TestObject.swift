//
//  TestObject.swift
//  Neves
//
//  Created by 周健平 on 2021/8/19.
//

import Foundation

class TestObject1: Equatable {
    
    static func == (lhs: TestObject1, rhs: TestObject1) -> Bool {
        JPrint("TestObject1 执行了 ‘==’")
        return lhs.a == rhs.a && lhs.b == rhs.b
    }
    
    var a: Int
    var b: Int
    
    init(a: Int, b: Int) {
        self.a = a
        self.b = b
    }
    
}

@objcMembers class TestObject2: NSObject {
    
//    static func == (lhs: TestObject2, rhs: TestObject2) -> Bool {
//        JPrint("TestObject2 执行了 ‘==’")
//        return lhs.a == rhs.a && lhs.b == rhs.b
//    }
    
    override func isEqual(_ object: Any?) -> Bool {
        JPrint("TestObject2 执行了 ‘isEqual’")
        return super.isEqual(object)
    }
    
    var a: Int
    var b: Int
    
    init(a: Int, b: Int) {
        self.a = a
        self.b = b
    }
    
}
