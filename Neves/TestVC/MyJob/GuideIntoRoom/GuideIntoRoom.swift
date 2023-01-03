//
//  GuideIntoRoom.swift
//  Neves
//
//  Created by aa on 2022/12/28.
//

enum GuideIntoRoomType {
    case blindDate
    case joyParty
    case fm
    case gameTeam(_ id: UInt32)
    
    var isBlindDate: Bool {
        switch self {
        case .blindDate:
            return true
        default:
            return false
        }
    }
    
    var isJoyParty: Bool {
        switch self {
        case .joyParty:
            return true
        default:
            return false
        }
    }
    
    var isFm: Bool {
        switch self {
        case .fm:
            return true
        default:
            return false
        }
    }
    
    var isGameTeam: Bool {
        switch self {
        case .gameTeam:
            return true
        default:
            return false
        }
    }
    
    var title: String {
        switch self {
        case .blindDate:
            return "匹配选择心动的Ta"
        case .joyParty:
            return "挑选陪你一起玩的人"
        case .fm:
            return "来听我闲聊唠嗑吧"
        case .gameTeam:
            return "选人组队一起开黑"
        }
    }
    
    func subtitle(_ userCount: Int) -> String {
        switch self {
        case .blindDate:
            return "\(userCount)人正在匹配"
        case .joyParty:
            return "\(userCount)人正在交友"
        case .fm:
            return "\(userCount)人正在闲聊"
        case .gameTeam:
            return "\(userCount)人正在组队"
        }
    }
    
    var btnTitle: String {
        switch self {
        case .blindDate:
            return "🥰 看看嘉宾"
        case .joyParty:
            return "🎉 去看看"
        case .fm:
            return "🎧 去听听"
        case .gameTeam:
            return "🕹️ 去组队"
        }
    }
    
    var contentTopInset: CGFloat {
        switch self {
        case .blindDate:
            return 25
        case .joyParty:
            return 25
        case .fm:
            return 10
        case .gameTeam:
            return 30
        }
    }
    
    var contentBottomInset: CGFloat {
        switch self {
        case .blindDate:
            return 15
        case .joyParty:
            return 15
        case .fm:
            return 15
        case .gameTeam:
            return 38
        }
    }
    
    var bgImage: UIImage {
        switch self {
        case var .gameTeam(id):
            if id < 1 {
                id = 1
            } else if id > 3 {
                id = 3
            }
            return UIImage(named: "roomguide_gamebg_\(id)")!
        default:
            return UIImage(named: "roomguide_bg_\(UInt32.random(in: 1...10))")!
        }
    }
}

protocol GuideIntoRoomContentViewCompatible: UIView {
    var viewSize: CGSize { set get }
}

