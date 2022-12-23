//
//  Task.Extension.swift
//  Neves
//
//  Created by 周健平 on 2022/12/23.
//

extension Task where Success == Never, Failure == Never {
    
    public static func sleep(seconds duration: Double) async throws {
//        let nanoseconds = UInt64(duration * Double(NSEC_PER_SEC))
        let nanoseconds = UInt64(duration * 1_000_000_000)
        try await sleep(nanoseconds: nanoseconds)
    }
    
}
