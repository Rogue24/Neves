//
//  PropertyWrapperTestVC.swift
//  Neves
//
//  Created by aa on 2021/7/9.
//
//  属性包装器的使用：https://www.jianshu.com/p/8a019631b4db

import Foundation

/// 封装一个UserDefault配置文件
struct UserDefaultsConfig {
    /// 告诉编译器 我要包裹的是hadShownGuideView这个值。
    /// 实际写法就是在UserDefault包裹器的初始化方法前加了个@
    /// hadShownGuideView 属性的一些key和默认值已经在 UserDefault包裹器的构造方法中实现
    @UserDefault(.had_shown_guide_view) static var hadShownGuideView: Bool = false
    
    @UserDefault(.name) static var name: String = "sb"
}
/// ==================================================================================================

@propertyWrapper struct ObserveChangeValue<T: Equatable> {
    
    private var value: T
    
    typealias ValueDidChangedCallback = (_ oldValue: T, _ newValue: T) -> ()
    private let callback: ValueDidChangedCallback?
    
    /**
     * 只要构造函数是 init(wrappedValue: T) 或者 init(wrappedValue: T, ...其他参数...)
     * 这样外部属性初始化时就可以直接在”=“后面设置默认值
     *
     * 🌰：
     * 1. @ObserveChangeValue(wrappedValue: "LiLei", valueDidChangedCallback: { ... }) var name
     *  - 设置了wrappedValue就是设置了默认值，这样就不能再在”=“后面设置默认值了
     *
     * 2. @ObserveChangeValue(valueDidChangedCallback: { ... }) var name = "LiLei"
     *  - 在”=“后面设置默认值就是设置了wrappedValue，【1】跟【2】只能使用其中一种
     *
     * 3. @ObserveChangeValue var name = "LiLei"
     *  - 这里是因为 valueDidChangedCallback 有默认参数，所以可以不声明构造函数
     */
    init(wrappedValue: T, valueDidChangedCallback: ValueDidChangedCallback? = nil) {
        self.value = wrappedValue
        self.callback = valueDidChangedCallback
    }
    
    /// 对外部属性的操作就是对这个wrappedValue的操作
    var wrappedValue: T {
        get { value }
        set {
            guard value != newValue else { return }
            let oldValue = value
            value = newValue
            callback?(oldValue, newValue)
        }
    }
    
    /// 实现这个属性，外部就可以用 $外部属性名 访问该值
    var projectedValue: String { "how are you?" }
    
}

class PropertyWrapperTestVC: TestBaseViewController {
    
    @UserDefault(.nickname) var nickname: String = "shuaige"
    
    @ObserveChangeValue(valueDidChangedCallback: { (oldValue, newValue) in
        JPrint("oldValue", oldValue)
        JPrint("newValue", newValue)
    }) var myName = "shuaigeping"
    
    @ObserveChangeValue var taName = "zhoujianping" // 这样相当于直接调用了 init(wrappedValue: "zhoujianping")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JPrint("nickname", nickname)
        JPrint("$nickname", $nickname ?? "??")
        
        JPrint("myName", myName)
        JPrint("$myName", $myName)
        
        JPrint("taName", taName)
        JPrint("$taName", $taName)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        nickname = "shuaige \(formatter.string(from: Date()))"
        JPrint("nickname", nickname)
        JPrint("-------------")
        
        myName = "shuaigeping \(formatter.string(from: Date()))"
        JPrint("myName", myName)
        JPrint("-------------")
        
        taName = "zhoujianping \(formatter.string(from: Date()))"
        JPrint("taName", taName)
        JPrint("-------------")
    }
}

//@propertyWrapper struct Store<[Update]> {
//
//    /// wrappedValue是@propertyWrapper必须要实现的属性
//    /// 当操作我们要包裹的属性时  其具体set get方法实际上走的都是wrappedValue 的set get 方法。
//    var wrappedValue: [Update] {
//        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
//        set { UserDefaults.standard.set(newValue, forKey: key) }
//    }
//
//    var projectedValue: String { "hello?" }
//}
