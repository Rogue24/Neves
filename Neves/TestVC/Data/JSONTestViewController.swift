//
//  JSONTestViewController.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  系统JSON的使用例子：https://www.jianshu.com/p/9e6f8dc66a50
//  SwiftyJSON的使用参考：https://blog.csdn.net/gf771115/article/details/111479203

import Foundation

@available(iOS 15.0, *)
class JSONTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Task {
            JPProgressHUD.show()
            defer { JPProgressHUD.dismiss() }

            guard let data = await requestData() else {
                JPrint("获取数据失败")
                return
            }

            let models1 = await system_data2Model(data)
            JPrint("System 获取数据：", models1.count, "个")

            let models2 = await swiftyJSON_data2Model(data)
            JPrint("SwiftyJSON + System 获取数据：", models2.count, "个")

            let models3 = await kakaJSON_data2Model(data)
            JPrint("SwiftyJSON + KakaJSON 获取数据：", models3.count, "个")
            
            let str1 = await system_data2JSONString(data)
            JPrint("System Data转JSON字符串：", str1)
            
            let str2 = await swiftyJSON_data2JSONString(data)
            JPrint("SwiftyJSON Data转JSON字符串：", str2)

            let str3 = await kakaJSON_model2JSONString(models3)
            JPrint("KakaJSON Model转JSON字符串：", str3)
        }
    }
    
}

// MARK: - Request JSON Data
@available(iOS 15.0, *)
extension JSONTestViewController {
    func requestData() async -> Data? {
        guard let url = URL(string: "http://123.207.32.32:8000/home/multidata"),
              let (data, _) = try? await URLSession.shared.data(from: url)
        else {
            return nil
        }
        return data
    }
}

// MARK: - JSON Data -> Model
@available(iOS 15.0, *)
extension JSONTestViewController {
    // MARK: System
    func system_data2Model(_ data: Data) async -> [MoguBanner] {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let result0 = json as? [String: Any],
              let result1 = result0["data"] as? [String: Any],
              let result2 = result1["banner"] as? [String: Any],
              let result3 = result2["list"] as? [[String: Any]]
        else { return [] }
        
        return result3.map { MoguBanner.build(fromDic: $0) }
        
        // Decode方式：Dictionary -> Data -> Model
//        return result3.map {
//            guard let d = try? JSONSerialization.data(withJSONObject: $0, options: .fragmentsAllowed),
//                  let m = MoguBanner.decode(d)
//            else {
//                JPrint("解析错误")
//                return MoguBanner()
//            }
//            return m
//        }
    }
    
    // MARK: SwiftyJSON
    func swiftyJSON_data2Model(_ data: Data) async -> [MoguBanner] {
        guard let result = JSON(data)["data"]["banner"]["list"].arrayObject as? [[String: Any]]
        else { return [] }
        
        return result.map { MoguBanner.build(fromDic: $0) }
    }
    
    // MARK: KakaJSON
    func kakaJSON_data2Model(_ data: Data) async -> [MoguBanner] {
        guard let result = try? JSON(data)["data"]["banner"]["list"].rawData()
        else { return [] }
        
        // 扩展函数
        return result.kj.modelArray(MoguBanner.self)
        
        // 全局函数
//        return modelArray(from: result, MoguBanner.self)
    }
}

// MARK: - Data/Model -> JSON String
@available(iOS 15.0, *)
extension JSONTestViewController {
    // MARK: System
    func system_data2JSONString(_ data: Data) async -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let data = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed),
              let result = String(data: data, encoding: .utf8)
        else { return "fail" }
        return result
    }
    
    // MARK: SwiftyJSON
    func swiftyJSON_data2JSONString(_ data: Data) async -> String {
        // 自动格式化
        guard let result = JSON(data).rawString() else { return "fail" }
        return result
    }
    
    // MARK: KakaJSON
    func kakaJSON_model2JSONString(_ banners: [MoguBanner]) async -> String  {
        banners.kj.JSONString()
    }
}


// MARK: - 源数据
/*
 {
     "data":{
         "banner":{
             "context":{
                 "currentTime":1538014774
             },
             "isEnd":true,
             "list":[
                 {
                     "acm":"3.mce.2_10_1jhwa.43542.0.ccy5br4OlfK0Q.pos_0-m_454801-sd_119",
                     "height":390,
                     "height923":390,
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180926_45fkj8ifdj4l824l42dgf9hd0h495_750x390.jpg",
                     "image923":"https://s10.mogucdn.com/mlcdn/c45406/180926_7d5c521e0aa3h38786lkakebkjlh8_750x390.jpg",
                     "link":"https://act.mogujie.com/huanxin0001?acm=3.mce.2_10_1jhwa.43542.0.ccy5br4OlfK0Q.pos_0-m_454801-sd_119",
                     "title":"\u7115\u65b0\u5973\u88c5\u8282",
                     "width":750,
                     "width923":750
                 },
                 {
                     "acm":"3.mce.2_10_1ji16.43542.0.ccy5br4OlfK0R.pos_1-m_454889-sd_119",
                     "height":390,
                     "height923":390,
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180926_31eb9h75jc217k7iej24i2dd0jba3_750x390.jpg",
                     "image923":"https://s10.mogucdn.com/mlcdn/c45406/180926_14l41d2ekghbeh771g3ghgll54224_750x390.jpg",
                     "link":"https://act.mogujie.com/ruqiu00001?acm=3.mce.2_10_1ji16.43542.0.ccy5br4OlfK0R.pos_1-m_454889-sd_119",
                     "title":"\u5165\u79cb\u7a7f\u642d\u6307\u5357",
                     "width":750,
                     "width923":750
                 },
                 {
                     "acm":"3.mce.2_10_1jfj8.43542.0.ccy5br4OlfK0S.pos_2-m_453270-sd_119",
                     "height":390,
                     "height923":390,
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180919_3f62ijgkj656k2lj03dh0di4iflea_750x390.jpg",
                     "image923":"https://s10.mogucdn.com/mlcdn/c45406/180919_47iclhel8f4ld06hid21he98i93fc_750x390.jpg",
                     "link":"https://act.mogujie.com/huanji001?acm=3.mce.2_10_1jfj8.43542.0.ccy5br4OlfK0S.pos_2-m_453270-sd_119",
                     "title":"\u79cb\u5b63\u62a4\u80a4\u5927\u4f5c\u6218",
                     "width":750,
                     "width923":750
                 },
                 {
                     "acm":"3.mce.2_10_1jepe.43542.0.ccy5br4OlfK0T.pos_3-m_452733-sd_119",
                     "height":390,
                     "height923":390,
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180917_18l981g6clk33fbl3833ja357aaa0_750x390.jpg",
                     "image923":"https://s10.mogucdn.com/mlcdn/c45406/180917_0hgle1e2c350a57ekhbj4f10a6b03_750x390.jpg",
                     "link":"https://act.mogujie.com/liuxing00001?acm=3.mce.2_10_1jepe.43542.0.ccy5br4OlfK0T.pos_3-m_452733-sd_119",
                     "title":"\u6d41\u884c\u62a2\u5148\u4e00\u6b65",
                     "width":750,
                     "width923":750
                 }
             ],
             "nextPage":1
         },
         "dKeyword":{
             "context":{
                 "currentTime":1538014774
             },
             "isEnd":true,
             "list":[
                 {
                     "acm":"3.mce.2_10_1ag5u.6348.0.ccy5br4OlfK0P.pos_0-m_243725-sd_119",
                     "defaultKeyWord":"\u5957\u88c5"
                 }
             ],
             "nextPage":1
         },
         "keywords":{
             "context":{
                 "currentTime":1538014774
             },
             "isEnd":true,
             "list":[
                 {
                     "acm":"3.mce.2_10_185r2.5868.0.ccy5br4OlfK1Y.pos_0-m_190323-sd_119",
                     "is_red":"1",
                     "words":"\u8fde\u8863\u88d9"
                 },
                 {
                     "acm":"3.mce.2_10_185r4.5868.0.ccy5br4OlfK1Z.pos_1-m_190324-sd_119",
                     "is_red":"0",
                     "words":"\u5c0f\u767d\u978b"
                 },
                 {
                     "acm":"3.mce.2_10_185r6.5868.0.ccy5br4OlfK10.pos_2-m_190325-sd_119",
                     "is_red":"1",
                     "words":"\u7701\u5fc3\u5957\u88c5"
                 },
                 {
                     "acm":"3.mce.2_10_185r8.5868.0.ccy5br4OlfK11.pos_3-m_190326-sd_119",
                     "is_red":"0",
                     "words":"\u788e\u82b1\u8fde\u8863\u88d9"
                 },
                 {
                     "acm":"3.mce.2_10_185ra.5868.0.ccy5br4OlfK12.pos_4-m_190327-sd_119",
                     "is_red":"1",
                     "words":"\u660e\u661f\u540c\u6b3e"
                 },
                 {
                     "acm":"3.mce.2_10_185rc.5868.0.ccy5br4OlfK13.pos_5-m_190328-sd_119",
                     "is_red":"1",
                     "words":"\u9ad8\u8ddf\u978b"
                 },
                 {
                     "acm":"3.mce.2_10_185re.5868.0.ccy5br4OlfK14.pos_6-m_190329-sd_119",
                     "is_red":"0",
                     "words":"\u7f8e\u5986"
                 },
                 {
                     "acm":"3.mce.2_10_185rg.5868.0.ccy5br4OlfK15.pos_7-m_190330-sd_119",
                     "is_red":"1",
                     "words":"\u58a8\u955c"
                 }
             ],
             "nextPage":1
         },
         "recommend":{
             "context":{
                 "currentTime":1538014774
             },
             "isEnd":true,
             "list":[
                 {
                     "acm":"3.mce.2_10_1dggc.13730.0.ccy5br4OlfK0U.pos_0-m_313898-sd_119",
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180913_036dli57aah85cb82l1jj722g887g_225x225.png",
                     "link":"http://act.meilishuo.com/10dianlingquan?acm=3.mce.2_10_1dggc.13730.0.ccy5br4OlfK0U.pos_0-m_313898-sd_119",
                     "sort":1,
                     "title":"\u5341\u70b9\u62a2\u5238"
                 },
                 {
                     "acm":"3.mce.2_10_1dgge.13730.0.ccy5br4OlfK0V.pos_1-m_313899-sd_119",
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180913_25e804lk773hdk695c60cai492111_225x225.png",
                     "link":"https://act.mogujie.com/tejiazhuanmai09?acm=3.mce.2_10_1dgge.13730.0.ccy5br4OlfK0V.pos_1-m_313899-sd_119",
                     "sort":2,
                     "title":"\u597d\u7269\u7279\u5356"
                 },
                 {
                     "acm":"3.mce.2_10_1b610.13730.0.ccy5br4OlfK0W.pos_2-m_260486-sd_119",
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180913_387kgl3j21ff29lh04181iek48a6h_225x225.png",
                     "link":"http://act.meilishuo.com/neigouful001?acm=3.mce.2_10_1b610.13730.0.ccy5br4OlfK0W.pos_2-m_260486-sd_119",
                     "sort":3,
                     "title":"\u5185\u8d2d\u798f\u5229"
                 },
                 {
                     "acm":"3.mce.2_10_1dggg.13730.0.ccy5br4OlfK0X.pos_3-m_313900-sd_119",
                     "image":"https://s10.mogucdn.com/mlcdn/c45406/180913_8d4e5adi8llg7c47lgh2291akiec7_225x225.png",
                     "link":"http://act.meilishuo.com/wap/yxzc1?acm=3.mce.2_10_1dggg.13730.0.ccy5br4OlfK0X.pos_3-m_313900-sd_119",
                     "sort":4,
                     "title":"\u521d\u79cb\u4e0a\u65b0"
                 }
             ],
             "nextPage":1
         }
     },
     "returnCode":"SUCCESS",
     "success":true
 }
 */
