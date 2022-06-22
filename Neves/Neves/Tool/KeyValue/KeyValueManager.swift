//
//  KeyValueManager.swift
//  Neves
//
//  Created by aa on 2022/6/21.
//  Copyright © 2022 CocoaPods. All rights reserved.
//
//  封装来自：https://www.jianshu.com/p/b371ce24dd0c
//  MMKV使用手册：https://github.com/Tencent/MMKV/wiki/iOS_tutorial_cn

import MMKV

var KVM: KeyValueManager { KeyValueManager.shared }

@dynamicMemberLookup
class KeyValueManager: NSObject {
    static let shared = KeyValueManager()
    let keyStore = KeyStore()
    var mmkv: MMKV? { MMKV.default() }
}

// MARK: - Register & Unregiser
extension KeyValueManager {
    func register(_ uid: Int) {
        unregiser()
        
        let rootDir = File.cacheFilePath(Bundle.main.appName) + "/" + "mmkv_\(uid)"
        MMKV.initialize(rootDir: rootDir)
        MMKV.register(self)
        MMKV.enableAutoCleanUp(maxIdleMinutes: 10) // 每隔10分钟自动清理内存缓存
    }
    
    func unregiser() {
        MMKV.unregiserHandler()
    }
}

// MARK: - Subscripts
extension KeyValueManager {
    typealias Key = KeyStore.Key
    
    // MARK: String
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<String>>) -> String? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.string(forKey: key.key, defaultValue: key.defaultValue)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Int64
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<Int64>>) -> Int64? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.int64(forKey: key.key, defaultValue: key.defaultValue ?? Int64.min)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: UInt64
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<UInt64>>) -> UInt64? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.uint64(forKey: key.key, defaultValue: key.defaultValue ?? UInt64.min)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Bool
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<Bool>>) -> Bool? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.bool(forKey: key.key, defaultValue: key.defaultValue ?? false)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Float
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<Float>>) -> Float? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.float(forKey: key.key, defaultValue: key.defaultValue ?? Float.nan)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Double
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<Double>>) -> Double? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.double(forKey: key.key, defaultValue: key.defaultValue ?? Double.nan)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Date
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<Date>>) -> Date? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.date(forKey: key.key, defaultValue: key.defaultValue)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Data
    subscript(dynamicMember keyPath: KeyPath<KeyStore, Key<Data>>) -> Data? {
        get {
            let key = keyStore[keyPath: keyPath]
            return mmkv?.data(forKey: key.key, defaultValue: key.defaultValue)
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
    
    // MARK: Object
    subscript<T: NSCoding & NSObjectProtocol>(dynamicMember keyPath: KeyPath<KeyStore, Key<T>>) -> T? {
        get {
            let key = keyStore[keyPath: keyPath]
            mmkv?.object(of: T.self, forKey: key.key)
            return mmkv?.object(of: T.self, forKey: key.key) as? T
        }
        set {
            let key = keyStore[keyPath: keyPath]
            if let value = newValue {
                mmkv?.set(value, forKey: key.key)
            } else {
                mmkv?.removeValue(forKey: key.key)
            }
        }
    }
}

// MARK: - MMKVHandler
extension KeyValueManager: MMKVHandler {
    func onMMKVCRCCheckFail(_ mmapID: String!) -> MMKVRecoverStrategic {
        return .onErrorRecover
    }
    
    func onMMKVFileLengthError(_ mmapID: String!) -> MMKVRecoverStrategic {
        return .onErrorRecover
    }
    
    func mmkvLog(with level: MMKVLogLevel, file: UnsafePointer<Int8>!, line: Int32, func funcname: UnsafePointer<Int8>!, message: String!) {
        // 暂时不打印
//        JPrint("MMKV", level.logType, "message:", message ?? "nothing")
    }
}

// MARK: - MMKVLogLevel
extension MMKVLogLevel {
    var logType: String {
        switch self {
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .warning:
            return "warning"
        case .error:
            return "error"
        case .none:
            return "none"
        @unknown default:
            return "unknown"
        }
    }
}
