//
//  JPUserInfoCacheTool.swift
//  Neves
//
//  Created by aa on 2022/6/28.
//

typealias JPUserInfoCache = JPCache<JPUserInfo>

private let userInfoQueue = DispatchQueue(label: "com.neves.userInfoCache", qos: .default, attributes: [.concurrent])

@objcMembers
class JPUserInfoCacheTool {
    static var cache: JPUserInfoCache = JPUserInfoCache(countLimit: 10)
}

extension JPUserInfoCacheTool {
    typealias CacheAction = (_ cache: JPUserInfoCache) -> ()
    
    static func syncExecute(_ action: @escaping CacheAction) {
        execute(action, isAsync: false)
    }
    
    static func asyncExecute(_ action: @escaping CacheAction) {
        execute(action, isAsync: true)
    }

    static func execute(_ action: @escaping CacheAction, isAsync: Bool) {
        if isAsync {
            userInfoQueue.async {
                execute(action)
            }
        } else {
            userInfoQueue.sync {
                execute(action)
            }
        }
    }

    private static func execute(_ action: @escaping CacheAction) {
        autoreleasepool {
            action(cache)
        }
    }
}

extension JPUserInfoCacheTool {
    static func cleanAll() {
        userInfoQueue.async {
            cache.removeAllObjects()
        }
    }
}
