//
//  Syncs.swift
//  Neves
//
//  Created by aa on 2021/10/22.
//

struct Syncs {
    
    /// 返回主队列执行
    public static func main(_ task: @escaping MyTask) {
        if Thread.isMainThread {
            task()
            return
        }
        
        DispatchQueue.main.sync(execute: task)
    }
    
}
