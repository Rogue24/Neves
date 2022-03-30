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
        case mercury(_ multiple: Int = 0)
        /// 金星
        case venus(_ multiple: Int = 0)
        /// 火星
        case mars(_ multiple: Int = 0)
        /// 木星
        case jupiter(_ multiple: Int = 0)
        /// 土星
        case saturn(_ multiple: Int = 0)
        /// 天王星
        case uranus(_ multiple: Int = 0)
        
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
        
        var frame: CGRect {
            let wh = CosmicExplorationPlanetView.wh
            let origin: CGPoint
            switch self {
            case .mercury:
                origin = [55.px, 22.5.px]
            case .venus:
                origin = [PortraitScreenWidth - 55.px - wh, 22.5.px]
            case .mars:
                origin = [PortraitScreenWidth - wh, 132.5.px]
            case .jupiter:
                origin = [PortraitScreenWidth - 55.px - wh, 242.5.px]
            case .saturn:
                origin = [55.px, 242.5.px]
            case .uranus:
                origin = [0, 132.5.px]
            }
            return CGRect(origin: origin, size: [wh, wh])
        }
    }
    
}
 
extension CosmicExploration {
    
    enum SupplyType: Int, CaseIterable {
        case supply1
        case supply2
        case supply3
        case supply4
    }
    
    struct SupplyInfoModel {
        let type: SupplyType
        let singleVotes: Int
        let iconUrl: String
    }
    
}


extension CosmicExploration {
    
    class SupplyModel: Equatable {
        static func == (lhs: SupplyModel, rhs: SupplyModel) -> Bool { lhs.type == rhs.type }
        
        let type: SupplyType
        var count: Int

        init(_ type: SupplyType,  _ count: Int) {
            self.type = type
            self.count = count
        }
    }
    
    class PlanetModel {
        weak var planetView: CosmicExplorationPlanetView?
        
        let planet: Planet
        init(_ planet: Planet) {
            self.planet = planet
        }
        
        // MARK: - 补给
        var supplyModels: [SupplyModel] = []
        
        func findSupply(_ type: SupplyType) -> SupplyModel? {
            supplyModels.first { $0.type == type }
        }
        
        func addSupply(_ type: SupplyType) {
            if let supplyModel = findSupply(type) {
                supplyModel.count += 1
            } else {
                supplyModels.append(SupplyModel(type, 1))
            }
            
            planetView?.updateSupplies(supplyModels, supplyType: type)
        }
        
        // MARK: - 选中状态
        var isSelected: Bool = false {
            didSet {
                guard isSelected != oldValue else { return }
                planetView?.updateSelected(isSelected)
            }
        }
    }
    
    
}
