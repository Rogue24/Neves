//
//  MoguBanner.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//
//  系统JSON的使用例子：https://www.jianshu.com/p/9e6f8dc66a50
//  SwiftyJSON的使用参考：https://blog.csdn.net/gf771115/article/details/111479203

struct MoguBanner: Convertible, Codable, Hashable {
    let identifier = UUID()
    
    var title: String = ""
    var image: String = ""
    var link: String = ""
    
    enum CodingKeys: String, CodingKey {
        case title, image, link
    }
    
    static func build(fromDic dic: [String: Any]) -> MoguBanner {
        var banner = self.init()
        banner.title = dic["title"] as? String ?? ""
        banner.image = dic["image"] as? String ?? ""
        banner.link = dic["link"] as? String ?? ""
        return banner
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: MoguBanner, rhs: MoguBanner) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
//    init() {}
//
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        title = try c.decode(String.self, forKey: .title)
//        image = try c.decode(String.self, forKey: .image)
//        link = try c.decode(String.self, forKey: .link)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var c = encoder.container(keyedBy: CodingKeys.self)
//        try c.encode(title, forKey: .title)
//        try c.encode(image, forKey: .image)
//        try c.encode(link, forKey: .link)
//    }
}

// MARK: - Encode & Decode
extension MoguBanner {
    func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }
    
    static func decode(_ data: Data?) -> MoguBanner? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(MoguBanner.self, from: data)
    }
}

// MARK: - Request JSON Data
@available(iOS 15.0, *)
extension MoguBanner {
    static func requestData() async -> Data? {
        guard let url = URL(string: "http://123.207.32.32:8000/home/multidata"),
              let (data, _) = try? await URLSession.shared.data(from: url)
        else {
            let path = Bundle.jp.resourcePath(withName: "MoguBanner", type: "json")
            return try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        return data
    }
    
    enum Coder {
        case system
        case swiftyJSON
        case kakaJSON
    }
    
    static func requestDataModel(coder: Coder = .kakaJSON) async -> [MoguBanner] {
        guard let data = await requestData() else { return [] }
        switch coder {
        case .system:
            return await system_data2Model(data)
        case .swiftyJSON:
            return await swiftyJSON_data2Model(data)
        case .kakaJSON:
            return await kakaJSON_data2Model(data)
        }
    }
}

// MARK: - JSON Data -> Model
@available(iOS 15.0, *)
extension MoguBanner {
    // MARK: System
    static func system_data2Model(_ data: Data) async -> [MoguBanner] {
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
    static func swiftyJSON_data2Model(_ data: Data) async -> [MoguBanner] {
        guard let result = JSON(data)["data"]["banner"]["list"].arrayObject as? [[String: Any]]
        else { return [] }
        
        return result.map { MoguBanner.build(fromDic: $0) }
    }
    
    // MARK: KakaJSON
    static func kakaJSON_data2Model(_ data: Data) async -> [MoguBanner] {
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
extension MoguBanner {
    // MARK: System
    static func system_data2JSONString(_ data: Data) async -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let data = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed),
              let result = String(data: data, encoding: .utf8)
        else { return "fail" }
        return result
    }
    
    // MARK: SwiftyJSON
    static func swiftyJSON_data2JSONString(_ data: Data) async -> String {
        // 自动格式化
        guard let result = JSON(data).rawString() else { return "fail" }
        return result
    }
    
    // MARK: KakaJSON
    static func kakaJSON_model2JSONString(_ banners: [MoguBanner]) async -> String  {
        banners.kj.JSONString()
    }
}



