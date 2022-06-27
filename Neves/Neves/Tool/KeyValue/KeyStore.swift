//
//  KeyStore.swift
//  Neves
//
//  Created by aa on 2022/6/22.
//

typealias KeyStore = KeyValueManager.KeyStore

extension KeyValueManager {
    struct KeyStore {
        struct Key<T> {
            let valueType: T.Type = T.self
            let key: String
            let defaultValue: T?
            init(_ key: String, defaultValue: T? = nil) {
                self.key = key
                self.defaultValue = defaultValue
            }
        }
    }
}

// MARK: - Key注册表
extension KeyStore {
    
    var moguBanner: Key<JPMoguBanner> { Key("moguBanner") }
    
}
