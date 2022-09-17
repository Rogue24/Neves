//
//  JSONTestViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  系统JSON的使用例子：https://www.jianshu.com/p/9e6f8dc66a50
//  SwiftyJSON的使用参考：https://blog.csdn.net/gf771115/article/details/111479203

@available(iOS 15.0, *)
class JSONTestViewController: TestBaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            self.test()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
    func test() {
        Task {
            JPProgressHUD.show()
            defer { JPProgressHUD.dismiss() }
            
            guard let data = await MoguBanner.requestData() else {
                JPrint("获取数据失败")
                return
            }
            
            let models1 = await MoguBanner.system_data2Model(data)
            JPrint("System 获取数据：", models1.count, "个")

            let models2 = await MoguBanner.swiftyJSON_data2Model(data)
            JPrint("SwiftyJSON + System 获取数据：", models2.count, "个")
            
            let models3 = await MoguBanner.kakaJSON_data2Model(data)
            JPrint("SwiftyJSON + KakaJSON 获取数据：", models3.count, "个")
            
            let str1 = await MoguBanner.system_data2JSONString(data)
            JPrint("System Data转JSON字符串：", str1)
            
            let str2 = await MoguBanner.swiftyJSON_data2JSONString(data)
            JPrint("SwiftyJSON Data转JSON字符串：", str2)
            
            let str3 = await MoguBanner.kakaJSON_model2JSONString(models3)
            JPrint("KakaJSON Model转JSON字符串：", str3)
        }
    }
    
}




