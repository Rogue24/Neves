//
//  URL.Extension.swift
//  Neves
//
//  Created by aa on 2022/3/24.
//

extension URL: JPCompatible {}
extension JP where Base == URL {
    static var hitokoto: Base { Base(string: "https://v1.hitokoto.cn")! }
}
