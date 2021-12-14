//
//  FunFloatButton.Playground.swift
//  Neves
//
//  Created by 周健平 on 2021/12/15.
//

extension FunFloatButton {
    
    func tapMeWhatToDo() {
        JPrint("点我干森莫？")
        
        test1()
    }
    
}

extension FunFloatButton {
    
    class People {
        let dog: Dog
        
        init(_ dog: Dog) {
            self.dog = dog
        }
        
        deinit {
            JPrint("爷死了")
        }
    }
    
    class Dog {
        deinit {
            JPrint("狗死了")
        }
    }
    
    static let d = Dog()
    
    func test1() {
        let p = People(Self.d)
        JPrint(p)
        // p引用d，但d没引用p，而且d是静态变量死不了，所以该函数结束后p就死了
    }
    
}
