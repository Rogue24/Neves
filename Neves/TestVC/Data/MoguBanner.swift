//
//  MoguBanner.swift
//  Neves
//
//  Created by aa on 2022/2/11.
//

struct MoguBanner: Convertible, Codable {
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

extension MoguBanner {
    func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }
    
    static func decode(_ data: Data?) -> MoguBanner? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(MoguBanner.self, from: data)
    }
}
