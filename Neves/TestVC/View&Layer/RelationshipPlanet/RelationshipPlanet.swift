//
//  RelationshipPlanet.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

enum RelationshipPlanet {
    static let universeSize: CGSize = [PortraitScreenWidth, 604.px]
    
    static let peopleIconWH: CGFloat = 30.px
    static let peopleW: CGFloat = peopleIconWH + (10 + 100).px
    static let peopleH: CGFloat = peopleIconWH
    
    static let planetRadius: CGFloat = 165.px // 330 这个半径是到了头像的中点
    static let planetW: CGFloat = (planetRadius + peopleW - peopleIconWH * 0.5) * 2
    static let planetH: CGFloat = (planetRadius + peopleH - peopleIconWH * 0.5) * 2
    static let planetCirclePoint: CGPoint = [planetW * 0.5, planetH * 0.5]
    static let planetImgWH: CGFloat = 300.px
    static let planetSwitchDuration: TimeInterval = 1
    
    static let singlePlanetMaxPeopleCount: Int = 15
    
    enum Style {
        /// 挚友
        case bosomFriend
        /// 闺蜜
        case confidante
        /// 死党
        case bestFriend
        /// 师徒
        case masterApprentice
        
        var title: String {
            switch self {
            case .bosomFriend: return "挚友"
            case .confidante: return "闺蜜"
            case .bestFriend: return "死党"
            case .masterApprentice: return "师徒"
            }
        }
        
        var planetImgName: String {
            switch self {
            case .bosomFriend: return "gxq_rk_zhiyou"
            case .confidante: return "gxq_rk_guimi"
            case .bestFriend: return "gxq_rk_sidang"
            case .masterApprentice: return "gxq_rk_shitu"
            }
        }
        
        var ringLottieName: String {
            switch self {
            case .bosomFriend: return "gxq_rk_shitu_zhiyou"
            case .confidante: return "gxq_rk_shitu_guimi"
            case .bestFriend: return "gxq_rk_shitu_sidang"
            case .masterApprentice: return "gxq_rk_shitu_shitu"
            }
        }
        
        var soundWaveLottieName: String {
            switch self {
            case .bosomFriend: return "gxq_shengbo_zhiyou"
            case .confidante: return "gxq_shengbo_guimi"
            case .bestFriend: return "gxq_shengbo_sidang"
            case .masterApprentice: return "gxq_shengbo_shitu"
            }
        }
    }
    
    enum Location {
        case main
        case rightTop
        case rightMid
        case rightBottom
    }
    
    struct Layout {
        let location: Location
        let scale: CGFloat
        let center: CGPoint
        let imageAlpha: CGFloat
        let titleAlpha: CGFloat
        let titleScale: CGFloat
        
        func titleColors(style: Style) -> [UIColor] {
            switch location {
            case .main:
                switch style {
                case .bosomFriend: return [.rgb(62, 43, 93), .rgb(62, 43, 93)]
                case .confidante: return [.rgb(106, 49, 31), .rgb(106, 49, 31)]
                case .bestFriend: return [.rgb(51, 77, 52), .rgb(51, 77, 52)]
                case .masterApprentice: return [.rgb(36, 53, 79), .rgb(36, 53, 79)]
                }
                
            default:
                switch style {
                case .bosomFriend: return [.rgb(120, 152, 255), .rgb(211, 105, 255)]
                case .confidante: return [.rgb(255, 105, 150), .rgb(255, 184, 149)]
                case .bestFriend: return [.rgb(120, 255, 246), .rgb(255, 230, 105)]
                case .masterApprentice: return [.rgb(117, 138, 255), .rgb(116, 211, 255)]
                }
            }
        }
        
        static let main = Layout(location: .main,
                                 scale: 1,
                                 center: [0, 185.px + planetImgWH * 0.5],
                                 imageAlpha: 1,
                                 titleAlpha: 1,
                                 titleScale: 1)
        
        static let rightTop = Layout(location: .rightTop,
                                     scale: 70.px / planetImgWH,
                                     center: [universeSize.width - 95.px - 70.px * 0.5,
                                              CGFloat(85.px + 70.px * 0.5)],
                                     imageAlpha: 0.3,
                                     titleAlpha: 0.3,
                                     titleScale: 12.px / 23.px)
        
        static let rightMid = Layout(location: .rightMid,
                                     scale: 140.px / planetImgWH,
                                     center: [universeSize.width - (140.px * 0.5 - 45.px),
                                              CGFloat(185.px + 140.px * 0.5)],
                                     imageAlpha: 0.5,
                                     titleAlpha: 0.7,
                                     titleScale: 18.px / 23.px)
        
        static let rightBottom = Layout(location: .rightBottom,
                                        scale: 100.px / planetImgWH,
                                        center: [universeSize.width - 30.px - 100.px * 0.5,
                                                 CGFloat(464.px + 100.px * 0.5)],
                                        imageAlpha: 0.4,
                                        titleAlpha: 0.3,
                                        titleScale: 15.px / 23.px)
    }
}
