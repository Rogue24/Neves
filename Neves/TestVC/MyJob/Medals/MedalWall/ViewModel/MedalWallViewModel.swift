//
//  MedalWallViewModel.swift
//  Neves
//
//  Created by aa on 2023/7/6.
//

class MedalWallViewModel {
    let uid: Int
    let nobility: Int
    let svip: Int
    let nickname: String
    let avatarurl: String
    
    let quarter: String
    let medalPoint: Int
    let medalPointRank: Int
    let listVMs: [MedalWallListViewModel]
    
    lazy var rq_avatarurl = avatarurl.rq_100x100
    
    init(_ uid: Int,
         _ nobility: Int,
         _ svip: Int,
         _ nickname: String,
         _ avatarurl: String,
         _ dict: [String: Any])
    {
        self.uid = uid
        self.nobility = nobility
        self.svip = svip
        self.nickname = nickname
        self.avatarurl = avatarurl
        
        self.medalPoint = dict["medalPoint"] as? Int ?? 0
        self.medalPointRank = dict["medalPointRank"] as? Int ?? 0
        
        if let quarter = dict["quarter"] as? String, quarter.count > 0 {
            self.quarter = "(\(quarter))"
        } else {
            self.quarter = ""
        }
        
        var listVMs = (dict["medalList"] as? [[String: Any]] ?? []).compactMap {
            MedalWallListViewModel($0)
        }
        listVMs = listVMs.sorted { $0.level > $1.level }
        listVMs.first?.isSelected = true
        self.listVMs = listVMs
    }
}

class MedalWallListViewModel: Equatable {
    static func == (lhs: MedalWallListViewModel, rhs: MedalWallListViewModel) -> Bool {
        lhs.level == rhs.level
    }
    
    let level: MedalLevel
    let count: Int
    let medals: [JKRUserMedalsList]
    
    var isSelected: Bool = false
    var offsetY: CGFloat = 0
    
    init?(_ dict: [String: Any]) {
        guard let level = MedalLevel(rawValue: dict["lv"] as? String ?? ""),
              let count = dict["count"] as? Int, count > 0 else { return nil }
        self.level = level
        self.count = count
        if let list = dict["list"] as? [[String: Any]], list.count > 0 {
            self.medals = list.map { JKRUserMedalsList.mj_object(withKeyValues: $0) }
        } else {
            self.medals = []
        }
        
    }
}

