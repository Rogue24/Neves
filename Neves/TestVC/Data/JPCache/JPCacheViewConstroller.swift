//
//  JPCacheViewConstroller.swift
//  Neves
//
//  Created by aa on 2022/6/29.
//

class JPCacheViewConstroller: TestBaseViewController {
    
    let sOn = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeBtn("函数11", [20.px, 450.px], #selector(fun11))
        makeBtn("函数12", [100.px, 450.px], #selector(fun12))
        makeBtn("函数13", [180.px, 450.px], #selector(fun13))
        
        sOn.frame.origin = [270.px, 450.px]
        sOn.isOn = true
        sOn.addTarget(self, action: #selector(switchhhh), for: .touchUpInside)
        view.addSubview(sOn)

        makeBtn("函数21", [20.px, 500.px], #selector(fun21))
        makeBtn("函数22", [100.px, 500.px], #selector(fun22))
        makeBtn("函数23", [180.px, 500.px], #selector(fun23))

        makeBtn("函数31" , [20.px, 550.px], #selector(fun31))
        makeBtn("函数32", [100.px, 550.px], #selector(fun32))
        makeBtn("函数33", [180.px, 550.px], #selector(fun33))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunnyActions()
    }

    func makeBtn(_ title: String, _ origin: CGPoint, _ action: Selector) {
        let btn: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.yellow, for: .normal)
            btn.backgroundColor = .purple
            btn.frame = CGRect(origin: origin, size: [70.px, 30.px])
            btn.addTarget(self, action: action, for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn)
    }
    
}

extension JPCacheViewConstroller {
    @objc func switchhhh() {
        JPrint("switchhhh")
    }
}

extension JPCacheViewConstroller {
    @objc func fun11() {
        JPrint("fun11")
        
        let nowTime = Int(Date().timeIntervalSince1970)
        
        var userInfos = [JPUserInfo]()
        for i in 0..<10 {
            let userInfo = JPUserInfo()
            userInfo.uid = Int.random(in: 0...20)
            userInfo.nickName = "jp_\(nowTime + i)"
            userInfos.append(userInfo)
            print("将要添加 id: \(userInfo.uid), nickName: \(userInfo.nickName)")
        }
        
        JPUserInfoCacheTool.asyncExecute { cache in
            cache.setObjects(userInfos)
        }
    }
    
    @objc func fun12() {
        JPrint("fun12")
        
        JPUserInfoCacheTool.asyncExecute { cache in
            let allObjs = cache.allObjects
            if allObjs.count > 0 {
                allObjs.forEach {
                    print("当前缓存 id: \($0.uid), nickName: \($0.nickName)")
                }
            } else {
                print("木有数据")
            }
        }
    }
    
    @objc func fun13() {
        JPrint("fun13")
        
        JPUserInfoCacheTool.asyncExecute { cache in
            let key = Int.random(in: 0...20)
            let updateResult = cache.updateObject(forKey: key) { userInfo in
                userInfo.nickName += "_updated_\(Int(Date().timeIntervalSince1970))"
            }
            if updateResult {
                print("更新成功 id: \(key)")
            } else {
                print("还没有创建过该对象 id: \(key)")
            }
        }
    }
}

extension JPCacheViewConstroller {
    @objc func fun21() {
        JPrint("fun21")
        
        JPUserInfoCacheTool.asyncExecute { cache in
            cache.removeAllObjects()
        }
    }
    
    @objc func fun22() {
        JPrint("fun22")
        
        JPUserInfoCacheTool.asyncExecute { cache in
            cache.updateAllObjects { userInfo in
                userInfo.nickName += "_updated_\(Int(Date().timeIntervalSince1970))"
            }
        }
    }
    
    @objc func fun23() {
        JPrint("fun23")
        
        JPUserInfoCacheTool.cache = JPUserInfoCache(countLimit: 10)
    }
}

extension JPCacheViewConstroller {
    @objc func fun31() {
        JPrint("fun31")
    }
    
    @objc func fun32() {
        JPrint("fun32")
    }
    
    @objc func fun33() {
        JPrint("fun33")
    }
}

