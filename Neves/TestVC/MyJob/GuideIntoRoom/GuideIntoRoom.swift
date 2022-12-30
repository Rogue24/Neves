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
    
    var topInset: CGFloat {
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
    
    var bottomInset: CGFloat {
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
}

protocol GuideIntoRoomContentViewCompatible: UIView {
    var viewSize: CGSize { set get }
}

