//
//  PKRankModelCompatible.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

protocol PKRankModelCompatible {
    func getUserIconUrl() -> String
    func getRanking() -> Int
}

struct PKRankModel: PKRankModelCompatible {
    let userIconUrl: String
    let ranking: Int
    
    func getUserIconUrl() -> String { userIconUrl }
    func getRanking() -> Int { ranking }
}
