//
//  CosmicExploration.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

enum CosmicExploration {
    
    enum Planet: CaseIterable {
        /// 水星
        case mercury
        /// 金星
        case venus
        /// 火星
        case mars
        /// 木星
        case jupiter
        /// 土星
        case saturn
        /// 天王星
        case uranus
        
        var bgImg: UIImage? {
            switch self {
            case .mercury:
                return UIImage(named: "spaceship_planet01")
            case .venus:
                return UIImage(named: "spaceship_planet02")
            case .mars:
                return UIImage(named: "spaceship_planet03")
            case .jupiter:
                return UIImage(named: "spaceship_planet04")
            case .saturn:
                return UIImage(named: "spaceship_planet05")
            case .uranus:
                return UIImage(named: "spaceship_planet06")
            }
        }
        
        var frame: CGRect {
            let size: CGSize = [118.px, 118.px]
            let origin: CGPoint
            switch self {
            case .mercury:
                origin = [55.px, 22.5.px]
            case .venus:
                origin = [PortraitScreenWidth - 55.px - size.width, 22.5.px]
            case .mars:
                origin = [PortraitScreenWidth - size.width, 132.5.px]
            case .jupiter:
                origin = [PortraitScreenWidth - 55.px - size.width, 242.5.px]
            case .saturn:
                origin = [55.px, 242.5.px]
            case .uranus:
                origin = [0, 132.5.px]
            }
            return CGRect(origin: origin, size: size)
        }
    }
    
}
