//
//  JPCacheKey.swift
//  Neves
//
//  Created by aa on 2022/6/29.
//

protocol JPCacheKey: Hashable {
    var jp_keyStr: NSString { get }
}

extension Int: JPCacheKey {
    var jp_keyStr: NSString { "\(self)" as NSString }
}
