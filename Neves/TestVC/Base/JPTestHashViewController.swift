//
//  JPTestHashViewController.swift
//  Neves
//
//  Created by aa on 2021/6/2.
//

class JPTestHashViewController: TestBaseViewController {
    
    var set1 = Set<JPPerson>()
    var set2 = Set<JPDog>()
    
    lazy var per1: JPPerson = {
        let per = JPPerson()
        per.a = 1
        per.b = 2
        return per
    }()
    
    lazy var dog1: JPDog = {
        let dog = JPDog()
        dog.a = 1
        dog.b = 2
        return dog
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = UIButton(type: .system)
        btn1.backgroundColor = .randomColor
        btn1.setTitle("test1", for: .normal)
        btn1.setTitleColor(.randomColor, for: .normal)
        btn1.sizeToFit()
        btn1.origin = [50, 150]
        btn1.addTarget(self, action: #selector(test1), for: .touchUpInside)
        view.addSubview(btn1)
        
        let btn2 = UIButton(type: .system)
        btn2.backgroundColor = .randomColor
        btn2.setTitle("test2", for: .normal)
        btn2.setTitleColor(.randomColor, for: .normal)
        btn2.sizeToFit()
        btn2.origin = [50, 220]
        btn2.addTarget(self, action: #selector(test2), for: .touchUpInside)
        view.addSubview(btn2)
    }
    
    @objc func test1() {
        let per2 = JPPerson()
        per2.a = 1
        per2.b = 2
        
        let per1Hash = per1.hash
        let per2Hash = per2.hash
        
        JPrint("per1", String(format: "%p", per1), per1Hash)
        JPrint("per2", String(format: "%p", per2), per2Hash)
        
        if per1 == per2 {
            JPrint("per1 per2 == 相等")
        } else {
            JPrint("per1 per2 == 不相等")
        }
        
        if per1Hash == per2Hash {
            JPrint("per1 per2 hash 相等")
        } else {
            JPrint("per1 per2 hash 不相等")
        }
        
        if per1.isEqual(per2) {
            JPrint("per1 per2 isEqual 一样")
        } else {
            JPrint("per1 per2 isEqual 不一样")
        }
        
        JPrint("per1 per2 add to set")
        set1.insert(per1)
        set1.insert(per2)
        
        JPrint("set1 111", set1)
        
        for _ in 0 ..< 5 {
            per1.a = per1.a == 1 ? 2 : 1
            set1.insert(per1)
        }
        
        JPrint("set1 222", set1)
        
        JPrint("---------------------", set1.count)
    }
    
    @objc func test2() {
        let dog2 = JPDog()
        dog2.a = 1
        dog2.b = 2
        
        let dog1Hash = dog1.hash
        let dog2Hash = dog2.hash
        
        JPrint("dog1", String(format: "%p", dog1), dog1Hash)
        JPrint("dog2", String(format: "%p", dog2), dog2Hash)
        
        if dog1 == dog2 {
            JPrint("dog1 dog2 == 相等")
        } else {
            JPrint("dog1 dog2 == 不相等")
        }
        
        if dog1Hash == dog2Hash {
            JPrint("dog1 dog2 hash 相等")
        } else {
            JPrint("dog1 dog2 hash 不相等")
        }
        
        if dog1.isEqual(dog2) {
            JPrint("dog1 dog2 isEqual 一样")
        } else {
            JPrint("dog1 dog2 isEqual 不一样")
        }
        
        JPrint("dog1 dog2 add to set")
        set2.insert(dog1)
        set2.insert(dog2)
        
        JPrint("set2 111", set2)
        
        for _ in 0 ..< 5 {
            dog1.a = dog1.a == 1 ? 2 : 1
            set2.insert(dog1)
        }
        
        JPrint("set2 222", set2)
        
        JPrint("---------------------", set2.count)
    }
}
