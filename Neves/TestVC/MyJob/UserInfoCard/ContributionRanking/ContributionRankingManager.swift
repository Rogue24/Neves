//
//  ContributionRankingManager.swift
//  Falla
//
//  Created by aa on 2026/4/29.
//

/**
 * **外部用到的属性和方法**
 *
 * contribLabel -- 控件名
 * contribLabelFrame -- 控件在麦位的frame
 * contribRankNO -- 排名（服务器字段）
 * contrib_ranking -- 排名（自定义属性）
 * contrib_strokeAttStr -- 描边（自定义属性）
 *
 * 房间贡献排名相关API（CrShared）：
 * - func contrib_updateRanking(_ dict: [AnyHashable: Any]?)
 * - var contrib_top1Avatar: String
 * - var contrib_rankingInfo: [Int: Int]
 * - func contrib_ranking(_ uid: Int) -> Int
 */

import Foundation

class ContributionRankingManager {
    private var model = ContributionRankingModel(gid: 0)
    var gid: Int { model.gid }
    var ts: Int { model.ts }
    var rankInfo: [Int: Int] { model.rankInfo }
    var topAvatar: String { model.topAvatar }
    var micRankLabelLimit: Int { model.micRankLabelLimit }
    
    func setup() {
        model = ContributionRankingModel(gid: 103030)
    }
    
    func clear() {
        guard gid > 0 else { return }
        model = ContributionRankingModel(gid: 0)
    }
}

extension ContributionRankingManager {
    func update(_ dict: [AnyHashable: Any]?, broadcastIfDiff isBroadcast: Bool = true) {
        guard gid > 0, let dict,
              let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
              let model = try? JSONDecoder().decode(ContributionRankingModel.self, from: jsonData),
              model.gid == gid, model.ts > ts
        else { return }
        
        let isDiffRanking: Bool
        let isDiffTop1: Bool
        if isBroadcast {
            isDiffRanking = rankInfo != model.rankInfo
            isDiffTop1 = topAvatar != model.topAvatar
        } else {
            isDiffRanking = false
            isDiffTop1 = false
        }
        
        self.model = model
        
        if isDiffRanking {
            NotificationCenter.jp.post(key: .ChatRoomContributionRankingUpdated)
        }
        
        if isDiffTop1 {
            NotificationCenter.jp.post(key: .ChatRoomContributionTop1Updated)
        }
    }
    
    func getRanking(_ uid: Int) -> Int {
        guard gid > 0 else { return 0 }
        return rankInfo[uid] ?? 0
    }
    
    func getRankings(_ uids: [Int]) -> [Int] {
        guard gid > 0 else { return [] }
        let rankInfo = self.rankInfo
        return uids.map { rankInfo[$0] ?? 0 }
    }
    
    func getRankingMap(_ uids: [Int]) -> [Int: Int] {
        guard gid > 0 else { return [:] }
        let rankInfo = self.rankInfo
        return Dictionary(
            uniqueKeysWithValues: uids.map {
                ($0, rankInfo[$0] ?? 0)
            }
        )
    }
}

private extension ContributionRankingManager {
    struct ContributionRankingModel: Decodable {
        /// 房间 id
        let gid: Int
        /// 时间戳
        let ts: Int
        /// 排名信息（key: 用户 id，value: 排名）
        let rankInfo: [Int: Int]
        /// 第一名头像
        let topAvatar: String
        /// 麦位能显示前x排名（0即麦位上不展示标签）
        let micRankLabelLimit: Int
        
        enum CodingKeys: String, CodingKey {
            case gid, ts, rankInfo, topAvatar, micRankLabelLimit
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            gid = (try? container.decodeIfPresent(Int.self, forKey: .gid)) ?? 0
            ts = (try? container.decodeIfPresent(Int.self, forKey: .ts)) ?? 0
            rankInfo = (try? container.decodeIfPresent([Int: Int].self, forKey: .rankInfo)) ?? [:]
            topAvatar = (try? container.decodeIfPresent(String.self, forKey: .topAvatar)) ?? ""
            micRankLabelLimit = (try? container.decodeIfPresent(Int.self, forKey: .micRankLabelLimit)) ?? 0
        }
        
        init(gid: Int, ts: Int = 0, rankInfo: [Int: Int] = [:], topAvatar: String = "", micRankLabelLimit: Int = 0) {
            self.gid = gid
            self.ts = ts
            self.rankInfo = rankInfo
            self.topAvatar = topAvatar
            self.micRankLabelLimit = micRankLabelLimit
        }
    }
}

#if DEBUG
extension ContributionRankingManager {
    func testUpdate(rankInfo: [Int: Int], topAvatar: String) {
        guard gid > 0 else { return }
        
        let isDiffRanking = self.rankInfo != rankInfo
        let isDiffTop1 = self.topAvatar != topAvatar
        self.model = ContributionRankingModel(gid: gid, ts: ts + 1, rankInfo: rankInfo, topAvatar: topAvatar)
        
        if isDiffRanking {
            NotificationCenter.jp.post(key: .ChatRoomContributionRankingUpdated)
        }
        
        if isDiffTop1 {
            NotificationCenter.jp.post(key: .ChatRoomContributionTop1Updated)
        }
    }
}
#endif
