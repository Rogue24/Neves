//
//  MedalLevel.swift
//  Neves
//
//  Created by aa on 2023/7/12.
//

import Foundation

enum MedalLevel: String, Comparable {
    static func < (lhs: MedalLevel, rhs: MedalLevel) -> Bool {
        lhs.sortValue < rhs.sortValue
    }
    
    case C
    case B
    case A
    case S
    case SS
    case SSS
    
    var sortValue: Int {
        switch self {
        case .C: return 0
        case .B: return 1
        case .A: return 2
        case .S: return 3
        case .SS: return 4
        case .SSS: return 5
        }
    }
    
    var iconName: String {
        switch self {
        case .C: return "medal_ranking_level_c"
        case .B: return "medal_ranking_level_b"
        case .A: return "medal_ranking_level_a"
        case .S: return "medal_ranking_level_s"
        case .SS: return "medal_ranking_level_ss"
        case .SSS: return "medal_ranking_level_sss"
        }
    }
    
    var smallIconName: String {
        switch self {
        case .C: return "medal_ranking_level_c_s"
        case .B: return "medal_ranking_level_b_s"
        case .A: return "medal_ranking_level_a_s"
        case .S: return "medal_ranking_level_s_s"
        case .SS: return "medal_ranking_level_ss_s"
        case .SSS: return "medal_ranking_level_sss_s"
        }
    }
}


