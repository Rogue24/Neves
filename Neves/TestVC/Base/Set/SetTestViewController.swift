//
//  SetTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/6/1.
//

struct WeakObject<T: AnyObject>: Hashable {
    
    
    private let identifier: ObjectIdentifier
    weak var object: T?

    init(_ object: T) {
        self.identifier = ObjectIdentifier(object)
        self.object = object
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

/// https://www.136.la/shida/show-411739.html
/// https://www.jianshu.com/p/0b688dd4c67c
struct MyObject<T: Hashable>: Hashable {
    
    let obj: T
    
    init(_ obj: T) {
        self.obj = obj
    }
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(obj)
//        obj.hash(into: &hasher)
//    }
    
//    var hashValue: Int {
//        obj.hashValue
//    }
    
    static func == (lhs: MyObject, rhs: MyObject) -> Bool {
        lhs.obj.hashValue == rhs.obj.hashValue
    }
    
//    static func == (lhs: MyObject, rhs: MyObject) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
    
}

/// 问题：某个类自身hashValue值不一样，但重写的”==”却一样（返回true）的话，放进Set会报错：
/// Fatal error: Duplicate elements of type 'JJObject' were found in a Set.
/// This usually means either that the type violates Hashable's requirements, or
/// that members of such a set were mutated after insertion.
/// 致命错误：在集合中发现类型为“JJObject”的重复元素。
/// 这通常意味着类型违反了Hashable的要求，或者
/// 这种集合的成员在插入后发生了变异。
///
/// 解决方案：套一层struct，遵守Hashable
struct JJObject: Hashable {
    
    let obj: JPObject
    
    init(_ obj: JPObject) {
        self.obj = obj
    }
    
    // obj自身hashValue不一样，只要”==”返回false就没问题，可以不用实现这个Hashable的方法（目前发现的确可以不写）
    // 如果写了，要小心会崩/错误的情况：
    func hash(into hasher: inout Hasher) {
        // 用x进行结合：不同的obj，但如果x都一样，那么JJObject生成的hashValue都会一样
        // ❌ 如果”==”没有重写，或者使用自身的hashValue作对比（方式1），那么如果已经放进Set，修改了x后再放进Set【会崩】
        // ❌ 如果”==”使用obj的hashValue作对比（方式2），虽然不会崩，但使用不同的JJObject套住同样的obj，有可能都会放进Set【重复元素错误】
        hasher.combine(obj.x)
        
        // ✅ 一般用obj本身进行结合（即对象的hashValue）
//        hasher.combine(obj)
    }
    
    // 已废弃
//    var hashValue: Int {
//        obj.hashValue
//    }
    
    // ❌ 自身hashValue不一样，这里返回true的话【放进Set会崩】
//    static func == (lhs: JJObject, rhs: JJObject) -> Bool {
//        lhs.obj.x == rhs.obj.x
//    }
    // ✅ 方式1：
//    static func == (lhs: JJObject, rhs: JJObject) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
    // ✅ 方式2：
//    static func == (lhs: JJObject, rhs: JJObject) -> Bool {
//        lhs.obj.hashValue == rhs.obj.hashValue
//    }
}

class SetTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .system)
        btn.setTitle("测试", for: .normal)
        btn.backgroundColor = .randomColor
        btn.setTitleColor(.randomColor, for: .normal)
        btn.frame = [100, 200, 100, 50]
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(test), for: .touchUpInside)
    }
    
    var objs = Set<MyObject<JPObject>>()
    let subObj1 = JPObject(x: 2)
    let subObj2 = JPObject(x: 2)
    
    var objs2 = Set<JPObject>()
    var objs3 = Set<JJObject>()
    
    // 必崩
    @objc func test2() {
        objs2.insert(subObj1)
        objs2.insert(subObj2)
        for _ in 0 ..< 100000 {
            subObj1.x = subObj1.x == 1 ? 2 : 1
            objs2.insert(subObj1)
        }
        JPrint("----", objs2.count)
    }
    
    @objc func test() {
        
        let obj1 = JJObject(subObj1)
        let obj2 = JJObject(subObj2)
        let obj3 = JJObject(subObj1)
        
        JPrint("obj1", obj1.hashValue, obj1.obj.hashValue)
        JPrint("obj2", obj2.hashValue, obj2.obj.hashValue)
        JPrint("obj3", obj3.hashValue, obj3.obj.hashValue)
        
        if obj1 == obj2 {
            JPrint("一样")
        } else {
            JPrint("不一样")
        }

        if obj1.obj == obj2.obj {
            JPrint("孩子一样")
        } else {
            JPrint("孩子不一样")
        }
        
        objs3.insert(obj1)
        objs3.insert(obj2)
        
        if objs3.count == 2 {
            JPrint("cao")
        }
        
//        JPrint("1", objs.map { $0.hashValue })
//        JPrint("1", objs.map { $0.obj.hashValue })
        
        objs3.insert(obj1)
//        JPrint("2", objs.map { $0.hashValue })
//        JPrint("2", objs.map { $0.obj.hashValue })
        
        if objs3.count == 2 {
            JPrint("cao")
        }
        
        objs3.insert(obj3)
//        JPrint("3", objs.map { $0.hashValue })
//        JPrint("3", objs.map { $0.obj.hashValue })
        
        if objs3.count == 2 {
            JPrint("cao")
        }
        
//        objs.insert(obj4)
//        JPrint("4", objs.map { $0.hashValue })
//        JPrint("4", objs.map { $0.obj.hashValue })
        
//        for i in 0 ..< 99999 {
        for i in 0 ..< 100000 {
            obj1.obj.x = obj1.obj.x == 1 ? 2 : 1
            if i == 2 {
                JPrint("obj1", obj1.hashValue, obj1.obj.hashValue)
                JPrint("obj2", obj2.hashValue, obj2.obj.hashValue)
                JPrint("obj3", obj3.hashValue, obj3.obj.hashValue)
            }
            objs3.insert(obj1)
        }
        
        JPrint("objs3 1", objs3.map { $0.hashValue })
        JPrint("objs3 1", objs3.map { $0.obj.hashValue })
        
//        obj1.obj.x = 2
//        objs3.insert(obj1)
//        JPrint("objs3 2", objs3.map { $0.hashValue })
//        JPrint("objs3 2", objs3.map { $0.obj.hashValue })
        
        obj1.obj.x = 1
        objs3.insert(obj1)
        JPrint("objs3 3", objs3.map { $0.hashValue })
        JPrint("objs3 3", objs3.map { $0.obj.hashValue })
        
        JPrint("----", objs3.count)
    
    }
    
    @objc func test3() {
        
        let obj1 = MyObject(subObj1)
        let obj2 = MyObject(subObj2)
        let obj3 = MyObject(subObj1)
//        let obj4 = MyObject(JPObject(x: 2))
        
        JPrint("obj1", obj1.hashValue, obj1.obj.hashValue)
        JPrint("obj2", obj2.hashValue, obj2.obj.hashValue)
        JPrint("obj3", obj3.hashValue, obj3.obj.hashValue)
//        JPrint("obj4", obj4.hashValue, obj4.obj.hashValue)
        
        
//        if obj1 == obj4 {
//            JPrint("一样")
//        } else {
//            JPrint("不一样")
//        }
//
//        if obj1.obj == obj4.obj {
//            JPrint("孩子一样")
//        } else {
//            JPrint("孩子不一样")
//        }
        
        objs.insert(obj1)
        for _ in 0 ..< 100000 {
            obj1.obj.x = obj1.obj.x == 1 ? 2 : 1
            objs.insert(obj1)
        }
        
        objs.insert(obj2)
//        JPrint("1", objs.map { $0.hashValue })
//        JPrint("1", objs.map { $0.obj.hashValue })
        
        objs.insert(obj1)
//        JPrint("2", objs.map { $0.hashValue })
//        JPrint("2", objs.map { $0.obj.hashValue })
        
        objs.insert(obj3)
//        JPrint("3", objs.map { $0.hashValue })
//        JPrint("3", objs.map { $0.obj.hashValue })
        
//        objs.insert(obj4)
//        JPrint("4", objs.map { $0.hashValue })
//        JPrint("4", objs.map { $0.obj.hashValue })
        
        
        
//        JPrint("obj1", obj1.hashValue, obj1.obj.hashValue)
//        JPrint("obj2", obj2.hashValue, obj2.obj.hashValue)
        JPrint("----", objs.count)
    
    }
    
//    class MyObject: NSObject {
//        let obj: JPObject
//        init(_ obj: JPObject) {
//            self.obj = obj
//        }
//
//        override func isEqual(_ object: Any?) -> Bool {
//
//            if let myObj = object as? MyObject {
//
//                return obj.hash == myObj.hash
//            }
//
//            return false
//        }
//    }
    
    
    
    
    
//    class MyObject: NSObject {
//        let x: Int
//        init(_ x: Int) {
//            self.x = x
//        }
//
//        override func isEqual(_ object: Any?) -> Bool {
//
//            if let myObj = object as? MyObject {
//                if self == myObj {
//                    return true
//                }
//                return self.x == myObj.x
//            }
//
//            return false
//        }
//    }
//
//    func test2() {
//        var objs = Set<MyObject>()
//
//        let obj1 = MyObject(2)
//        let obj2 = MyObject(2)
//
//        if obj1 == obj2 {
//            JPrint("一样")
//        } else {
//            JPrint("不一样")
//        }
//
//        objs.insert(obj1)
//        objs.insert(obj2)
//        JPrint("1", objs)
//
//        objs.insert(obj1)
//        JPrint("2", objs)
//
//        JPrint("----")
//    }
}
