//
//  MemorySizeTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2020/11/7.
//

import UIKit

class Alien {
    let a: Int = 1
}

struct Earth {
    let a: Int
    let b: Bool = false
    
    class Human {
        let a: Int = 1
    }
    
    class Animal {
        let a: Bool = false
        let b: Int = 2
        let c: Int = 3
    }
}

class Dog: Earth.Animal {
    
}

extension Earth.Animal {
    enum aaa {
        case d,c,e
    }
    
    struct Cat {
        let age: Int
    }
    
//    var name: String = ""
    
}

struct C { // 改成class就知道区别了
    var x: Int = 1
}
class D {
    var c: C = C()
}

class MemorySizeTestViewController: TestBaseViewController {

    let d = D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var c = d.c
        JPrint(c.x)
        JPrint(d.c.x)
        JPrint("-----")
        
        c.x += 1
        JPrint(c.x)
        JPrint(d.c.x)
        JPrint("-----")
        
        d.c.x += 1
        JPrint(c.x)
        JPrint(d.c.x)
        JPrint("-----")
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let al = Alien()
        let hu = Earth.Human()
        let an = Earth.Animal()
        
        JPrint(Mems.size(ofRef: al))
        JPrint("--------")
        
        JPrint(MemoryLayout<Earth>.size)
        JPrint(MemoryLayout<Earth>.stride)
        JPrint(MemoryLayout<Earth>.alignment)
        JPrint("--------")
        
        JPrint(Mems.size(ofRef: hu))
        JPrint("--------")
        
        JPrint(Mems.size(ofRef: an))
        JPrint("--------")
        
        let d = Dog()
        JPrint(Mems.size(ofRef: d))
        JPrint("--------")
        
        JPrint(MemoryLayout<JP<Self>>.size)
        JPrint(MemoryLayout<JP<Self>>.stride)
        JPrint(MemoryLayout<JP<Self>>.alignment)
        JPrint("--------")
        
        JPrint(MemoryLayout<JP<Bool>>.size)
        JPrint(MemoryLayout<JP<Bool>>.stride)
        JPrint(MemoryLayout<JP<Bool>>.alignment)
        JPrint("--------")
    }

}
