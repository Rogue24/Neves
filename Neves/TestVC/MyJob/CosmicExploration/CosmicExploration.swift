//
//  CosmicExploration.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

enum CosmicExploration {}

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
    
    class SupplyModel: Equatable {
        static func == (lhs: SupplyModel, rhs: SupplyModel) -> Bool { lhs.type == rhs.type }
        
        let type: SupplyType
        var count: Int

        init(_ type: SupplyType,  _ count: Int = 0) {
            self.type = type
            self.count = count
        }
    }
}

extension CosmicExploration {
    enum Planet: Hashable {
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
        
        var name: String {
            switch self {
            case .mercury:
                return "水星"
            case .venus:
                return "金星"
            case .mars:
                return "火星"
            case .jupiter:
                return "木星"
            case .saturn:
                return "土星"
            case .uranus:
                return "天王星"
            }
        }
        
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
        
        func addSupply(for type: SupplyType) {
            let supplyModel = findSupply(type) ?? {
                let model = SupplyModel(type)
                supplyModels.append(model)
                return model
            }()
            supplyModel.count += 1
            planetView?.updateSupplies(supplyModels, supplyType: type)
        }
        
        func removeSupplies() {
            guard supplyModels.count > 0 else { return }
            supplyModels.removeAll()
            planetView?.updateSupplies(supplyModels)
        }
        
        // MARK: - 选中状态
        var isSelected: Bool = false {
            didSet {
                guard isSelected != oldValue else { return }
                planetView?.updateIsSelected(isSelected)
            }
        }
        
        // MARK: - 目标状态
        var isTarget: Bool = false {
            didSet {
                guard isTarget != oldValue else { return }
                if isTarget {
                    planetView?.startExploringAnimtion()
                } else {
                    planetView?.stopExploringAnimtion()
                }
            }
        }
        
        // MARK: - 中奖状态
        var isWinning: Bool = false {
            didSet {
                guard isWinning != oldValue else { return }
                isTarget = isWinning
                planetView?.updateIsWinning(isWinning)
            }
        }
    }
}

extension CosmicExploration {
    enum Stage: Equatable {
        case idle
        case supplying(_ second: TimeInterval)
        case exploring(_ second: TimeInterval)
        case finish(_ isDiscover: Bool, _ second: TimeInterval)
    }
}
