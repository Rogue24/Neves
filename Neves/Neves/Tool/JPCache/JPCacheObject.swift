//
//  JPCacheObject.swift
//  Neves
//
//  Created by aa on 2022/6/29.
//

protocol JPCacheObject: AnyObject {
    associatedtype Key: JPCacheKey
    var jp_key: Key { get }
}

extension JPCacheObject {
    var jp_keyStr: NSString { jp_key.jp_keyStr }
}
