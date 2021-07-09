//
//  PropertyWrapperTestVC.swift
//  Neves
//
//  Created by aa on 2021/7/9.
//

import Foundation
import Combine

/// 先告诉编译器 下面这个UserDefault是一个属性包裹器
@propertyWrapper struct UserDefault<T> {
    /// 这里的属性key 和 defaultValue 还有init方法都是实际业务中的业务代码
    /// 我们不需要过多关注
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    /// wrappedValue是@propertyWrapper必须要实现的属性
    /// 当操作我们要包裹的属性时  其具体set get方法实际上走的都是wrappedValue 的set get 方法。
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    var projectedValue: String { "hello?" }
}

/// 封装一个UserDefault配置文件
struct UserDefaultsConfig {
    /// 告诉编译器 我要包裹的是hadShownGuideView这个值。
    /// 实际写法就是在UserDefault包裹器的初始化方法前加了个@
    /// hadShownGuideView 属性的一些key和默认值已经在 UserDefault包裹器的构造方法中实现
    @UserDefault("had_shown_guide_view", defaultValue: false)
    static var hadShownGuideView: Bool
    
    @UserDefault("name", defaultValue: "sb")
    static var name: String
}

class PropertyWrapperTestVC: TestBaseViewController {
    
    @UserDefault("nickname", defaultValue: "shuaige")
    var nickname: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JPrint("nickname", nickname)
        JPrint("??", $nickname)
        
        let publisher = view.publisher(for: \.backgroundColor, options: .new)
        let canceler = publisher.sink {
            guard let color = $0 else { return }
            JPrint("color \(color)")
        }
        
        Asyncs.mainDelay(10) {
            JPrint("取消订阅")
            canceler.cancel()
        }
        
//        let tableView = UITableView(frame: PortraitScreenBounds, style: .grouped)
//        tableView.jp.contentInsetAdjustmentNever()
//        tableView.dataSource = self
//        tableView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.backgroundColor = .randomColor
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        nickname = "shuaige \(formatter.string(from: Date()))"
        JPrint("nickname", nickname)
    }
}

//extension PropertyWrapperTestVC: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//}


struct Update: Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var text: String
    var date: String
}

let updateData = [
    Update(image: "Card1", title: "SwiftUI Advanced", text: "Take your SwiftUI app to the App Store with advanced techniques like API data, packages and CMS.", date: "JAN 1"),
    Update(image: "Card2", title: "Webflow", text: "Design and animate a high converting landing page with advanced interactions, payments and CMS", date: "OCT 17"),
    Update(image: "Card3", title: "ProtoPie", text: "Quickly prototype advanced animations and interactions for mobile and Web.", date: "AUG 27"),
    Update(image: "Card4", title: "SwiftUI", text: "Learn how to code custom UIs, animations, gestures and components in Xcode 11", date: "JUNE 26"),
    Update(image: "Card5", title: "Framer Playground", text: "Create powerful animations and interactions with the Framer X code editor", date: "JUN 11")
]

class UpdateStore: ObservableObject {
    @Published var updates: [Update] = updateData
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
