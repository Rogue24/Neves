//
//  JPCache.swift
//  Neves
//
//  Created by aa on 2022/6/29.
//
//  NSCache使用介绍：https://blog.csdn.net/weixin_46926959/article/details/121122830

class JPCache<Object: JPCacheObject>: NSObject & NSCacheDelegate {
    typealias Key = Object.Key
    
    private var keys: Set<Key> = []
//    private let cache = NSCache<NSString, Object>()
    private let cache = MyCache<NSString, Object>()
    
    private var lock: pthread_mutex_t = {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        // PTHREAD_MUTEX_RECURSIVE 递归：允许【同一个线程】对同一把🔐进行【重复】加🔐，
        // 特别之处是可以是对【同一个线程】重复加🔐（也就是上一次加的🔐还没解开前再次加🔐的情景），要是普通的🔐就会造成【死锁】。
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        
        var lock = pthread_mutex_t()
        pthread_mutex_init(&lock, &attr)
        pthread_mutexattr_destroy(&attr)
        return lock
    }()
    
    init(countLimit: Int) {
        super.init()
        cache.countLimit = countLimit
        cache.delegate = self
    }
    
    deinit {
        print("I am die.")
        cache.delegate = nil
        pthread_mutex_destroy(&lock)
    }
    
    // MARK: - NSCacheDelegate 即将回收对象
    /// 发生【内存警告】时，`NSCache`会自动回收部分数据，只能通过该代理得知哪些数据被回收。
    /// ⚠️另外倘若接收到【内存警告】的同时调用`removeAllObjects`，该`cache`将不可再用，无法再往里面存数据。
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
//        print("willEvictObject: \(obj)")
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        
        guard let cacheObj = obj as? Object else { return }
        keys.remove(cacheObj.jp_key)
        
        guard let userInfo = obj as? JPUserInfo else { return }
        print("即将回收 id: \(userInfo.uid), nickName: \(userInfo.nickName)")
    }
}

// MARK: - 增
extension JPCache {
    func setObject(_ obj: Object) {
        pthread_mutex_lock(&lock)
        cache.setObject(obj, forKey: obj.jp_keyStr)
        keys.insert(obj.jp_key)
        pthread_mutex_unlock(&lock)
    }
    
    func setObjects(_ objs: [Object]) {
        pthread_mutex_lock(&lock)
        for obj in objs {
            cache.setObject(obj, forKey: obj.jp_keyStr)
            keys.insert(obj.jp_key)
        }
        pthread_mutex_unlock(&lock)
    }
}

// MARK: - 删
extension JPCache {
    func removeObject(forKey key: Key) {
        cache.removeObject(forKey: key.jp_keyStr)
    }
    
    func removeAllObjects() {
        cache.removeAllObjects()
    }
}

// MARK: - 改
extension JPCache {
    typealias UpdateAction = (Object) -> ()
    
    @discardableResult
    func updateObject(forKey key: Key, action: UpdateAction) -> Bool {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        if let obj = cache.object(forKey: key.jp_keyStr) {
            action(obj)
            return true
        } else {
            return false
        }
    }
    
    func batchUpdateObjects(forKeys keys: Set<Key>, action: UpdateAction) {
        pthread_mutex_lock(&lock)
        keys.forEach { key in
            guard let obj = cache.object(forKey: key.jp_keyStr) else { return }
            action(obj)
        }
        pthread_mutex_unlock(&lock)
    }
    
    func updateAllObjects(action: UpdateAction) {
        pthread_mutex_lock(&lock)
        let keys = self.keys
        keys.forEach { key in
            if let obj = cache.object(forKey: key.jp_keyStr) {
                action(obj)
            } else {
                self.keys.remove(key)
            }
        }
        pthread_mutex_unlock(&lock)
    }
}

// MARK: - 查
extension JPCache {
    var totalCount: Int {
        pthread_mutex_lock(&lock)
        let count = keys.count
        pthread_mutex_unlock(&lock)
        return count
    }
    
    var allObjects: [Object] {
        pthread_mutex_lock(&lock)
        var objects: [Object] = []
        let keys = self.keys
        for key in keys {
            if let obj = cache.object(forKey: key.jp_keyStr) {
                objects.append(obj)
            } else {
                self.keys.remove(key)
            }
        }
        pthread_mutex_unlock(&lock)
        return objects
    }
    
    func object(forKey key: Key) -> Object? {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        if let obj = cache.object(forKey: key.jp_keyStr) {
            keys.insert(key)
            return obj
        } else {
            keys.remove(key)
            return nil
        }
    }
}
