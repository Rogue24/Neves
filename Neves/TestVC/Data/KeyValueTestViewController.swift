//
//  KeyValueTestViewController.swift
//  Neves
//
//  Created by aa on 2022/6/22.
//

class JPMoguBanner: NSObject, Convertible, NSCoding {
    var title: String = ""
    var image: String = ""
    var link: String = ""
    
    required override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        image = coder.decodeObject(forKey: "image") as? String ?? ""
        link = coder.decodeObject(forKey: "link") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(image, forKey: "image")
        coder.encode(link, forKey: "link")
    }
    
    static func data2Model(_ data: Data) async -> [JPMoguBanner]? {
        guard let result = try? JSON(data)["data"]["banner"]["list"].rawData() else {
            return nil
        }
        return result.kj.modelArray(JPMoguBanner.self)
    }
}

@available(iOS 15.0, *)
class KeyValueTestViewController: TestBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = UIButton(type: .system)
        btn1.titleLabel?.font = .systemFont(ofSize: 15)
        btn1.setTitle("查看缓存", for: .normal)
        btn1.setTitleColor(.randomColor, for: .normal)
        btn1.backgroundColor = .randomColor
        btn1.frame = [50, 200, 80, 40]
        btn1.addTarget(self, action: #selector(logCache), for: .touchUpInside)
        view.addSubview(btn1)
        
        let btn2 = UIButton(type: .system)
        btn2.titleLabel?.font = .systemFont(ofSize: 15)
        btn2.setTitle("刷新缓存", for: .normal)
        btn2.setTitleColor(.randomColor, for: .normal)
        btn2.backgroundColor = .randomColor
        btn2.frame = [50, 300, 80, 40]
        btn2.addTarget(self, action: #selector(updateCache), for: .touchUpInside)
        view.addSubview(btn2)
    }
    
    @objc func logCache() {
        if let moguBanner = KVM.moguBanner {
            JPrint("有缓存", moguBanner.title)
        } else {
            JPrint("没有缓存")
        }
    }
    
    @objc func updateCache() {
        Task {
            JPProgressHUD.show()
            defer { JPProgressHUD.dismiss() }
            
            guard let data = await MoguBanner.requestData() else {
                JPrint("获取数据失败")
                return
            }
            
            guard let models = await JPMoguBanner.data2Model(data) else {
                JPrint("解析数据失败")
                return
            }
            
            guard models.count > 0, let model = models.randomElement() else {
                JPrint("笑死，压根没数据")
                return
            }
            
            KVM.moguBanner = model
            JPrint("已更新", model.title)
        }
    }
}
