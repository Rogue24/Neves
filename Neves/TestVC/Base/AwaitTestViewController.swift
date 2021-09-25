//
//  AwaitTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/6/9.
//

@available(iOS 15.0.0, *)
class AwaitTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bbb: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("Tap me", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [100, 150, 100, 80]
            btn.addTarget(self, action: #selector(tttt), for: .touchUpInside)
            return btn
        }()
        view.addSubview(bbb)
        
//        Module.Task
        
        
//        Task(priority: .low) {

//        }
        
    }
    
    
    
    @objc func tttt() {
//        Task {
//            do {
//                let str = try await loadData()
//                print(str)
//            } catch {
//                print("error \(error)")
//            }
//            print("1111")
//        }
    }
    
    func loadData() async throws -> String {

        let (data, _) = try await URLSession.shared.data(from: URL(string: "https://v1.hitokoto.cn")!)

//        let data = try await Data(contentsOf: URL(string: "https://v1.hitokoto.cn")!)

        guard let dict = JSON(data).dictionary,
              let hitokoto = dict["hitokoto"]?.string else {
            return "文案请求失败: 数据解析失败"
        }

        return hitokoto

    }
    
    
    
}

