//
//  DynamicMemberLookupTestViewController.swift
//  Neves
//
//  Created by aa on 2022/6/21.
//
//  学自：https://zhuanlan.zhihu.com/p/415217937

var MyKVM: MyKeyValueManager { MyKeyValueManager.shared }

@dynamicMemberLookup
class MyKeyValueManager {
    struct KeyValue<T> {
        let key: String
        let defaultValue: T?
        var value: T?
        
        init(key: String, defaultValue: T?) {
            self.key = key
            self.defaultValue = defaultValue
        }
    }
    
    struct KeyValueStore {
        var name = KeyValue(key: "name", defaultValue: "zhoujianping")
    }
    
    static let shared = MyKeyValueManager()
    private var store = KeyValueStore()
    
    subscript(dynamicMember keyPath: WritableKeyPath<KeyValueStore, KeyValue<String>>) -> String? {
        set {
            var keyValue = store[keyPath: keyPath]
            keyValue.value = newValue
            store[keyPath: keyPath] = keyValue
        }
        get {
            let keyValue = store[keyPath: keyPath]
            return keyValue.value ?? keyValue.defaultValue
        }
    }
}

class DynamicMemberLookupTestViewController: TestBaseViewController {
    
    let myLabel: UILabel = {
        Setter(UILabel())
            .backgroundColor(.randomColor)
            .font(.systemFont(ofSize: 25))
            .textAlignment(.center)
            .textColor(.randomColor)
            .text("zhoujianping")
            .frame([50, 120, 150, 50])
            .subject
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(myLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            
            JPrint("--------------------")
            JPrint("1", MyKVM.name ?? "null")
            MyKVM.name = "\(Int(Date().timeIntervalSince1970))"
            JPrint("2", MyKVM.name ?? "null")
            
            var newFrame = self.myLabel.frame
            newFrame.origin.x += 1
            newFrame.origin.y += 1
            _ = Setter(self.myLabel)
                    .backgroundColor(.randomColor)
                    .textColor(.randomColor)
                    .frame(newFrame)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
}
