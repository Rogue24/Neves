//
//  CosmicExploration.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

enum CosmicExploration {}

extension CosmicExploration {
    
    enum Planet: Equatable {
        /// 水星
        case mercury(_ multiple: Int)
        /// 金星
        case venus(_ multiple: Int)
        /// 火星
        case mars(_ multiple: Int)
        /// 木星
        case jupiter(_ multiple: Int)
        /// 土星
        case saturn(_ multiple: Int)
        /// 天王星
        case uranus(_ multiple: Int)
        
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
        
        var multipleImg: UIImage? {
            switch self {
            case .mercury:
                return UIImage(named: "spaceship_multiple_bg01")
            case .venus:
                return UIImage(named: "spaceship_multiple_bg05")
            case .mars:
                return UIImage(named: "spaceship_multiple_bg04")
            case .jupiter:
                return UIImage(named: "spaceship_multiple_bg02")
            case .saturn:
                return UIImage(named: "spaceship_multiple_bg03")
            case .uranus:
                return UIImage(named: "spaceship_multiple_bg06")
            }
        }
        
        var multiple: Int {
            switch self {
            case let .mercury(multiple): return multiple
            case let .venus(multiple): return multiple
            case let .mars(multiple): return multiple
            case let .jupiter(multiple): return multiple
            case let .saturn(multiple): return multiple
            case let .uranus(multiple): return multiple
            }
        }
        
        var size: CGSize { [118.px, 118.px] }
        
        var frame: CGRect {
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
    
    class PlanetModel {
        let planet: Planet
        
        weak var starView: CosmicExplorationStarView?
        
        init(_ planet: Planet) {
            self.planet = planet
        }
        
        var betGifts: [BetGiftModel] = []
        
        func bet(_ giftType: Int) {
            defer { starView?.updateBetGifts(betGifts) }
            guard let betGift = betGifts.first(where: { $0.giftType == giftType }) else {
                betGifts.append(BetGiftModel(giftType, 1))
                return
            }
            betGift.betCount += 1
        }
        
        var isSelected: Bool = false {
            didSet {
                guard isSelected != oldValue else { return }
                starView?.updateSelected(isSelected)
            }
        }
    }
    
    class BetGiftModel: Equatable {
        static func == (lhs: BetGiftModel, rhs: BetGiftModel) -> Bool { lhs.giftType == rhs.giftType }
        
        let giftType: Int
        var betCount: Int

        init(_ giftType: Int,  _ betCount: Int) {
            self.giftType = giftType
            self.betCount = betCount
        }
    }
    
}
 
extension CosmicExploration {
    
    enum GiftInfo: Equatable {
        static func == (lhs: GiftInfo, rhs: GiftInfo) -> Bool { lhs.type == rhs.type }
        
        case info1(_ singleVotes: Int, _ iconUrl: String)
        case info2(_ singleVotes: Int, _ iconUrl: String)
        case info3(_ singleVotes: Int, _ iconUrl: String)
        case info4(_ singleVotes: Int, _ iconUrl: String)
        
        var type: Int {
            switch self {
            case .info1: return 0
            case .info2: return 1
            case .info3: return 2
            case .info4: return 3
            }
        }
    }
    
}
