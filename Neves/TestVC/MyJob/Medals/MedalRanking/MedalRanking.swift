//
//  MedalRanking.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//

import UIKit
import Kingfisher

enum MedalRanking {
    enum ShowType {
        case fullScreen
        case pop
    }
    
    enum ListType: Int, CaseIterable {
        case quarterly
        case overall
        
        var title: String {
            switch self {
            case .quarterly: return "季度榜"
            case .overall: return "历史总榜"
            }
        }
        
        var cycle: Int {
            switch self {
            case .quarterly: return 4
            case .overall: return 5
            }
        }
    }
    
    enum RegionRange: Int, CaseIterable {
        case country = 1
        case global = 2
    }
    
    enum Ranking: Equatable {
        case top1
        case top2
        case top3
        case other(_ num: Int)
        
        var num: Int {
            switch self {
            case .top1: return 1
            case .top2: return 2
            case .top3: return 3
            case let .other(num): return num
            }
        }
        
        init(_ num: Int) {
            switch num {
            case 1:
                self = .top1
            case 2:
                self = .top2
            case 3:
                self = .top3
            default:
                self = .other(num)
            }
        }
    }
    
    enum IconSource {
        case image(_ img: UIImage)
        case asset(_ name: String)
        case remote(_ url: String)
        case label(_ text: String, _ mask: UIImage?)
        
        @MainActor
        static func setup(_ iconSource: IconSource?, for view: UIView) {
            switch view {
            case let imgView as UIImageView:
                guard let iconSource else {
                    imgView.kf.cancelDownloadTask()
                    imgView.image = nil
                    return
                }
                
                switch iconSource {
                case let .image(img):
                    imgView.kf.cancelDownloadTask()
                    imgView.image = img
                    
                case let .asset(name):
                    imgView.kf.cancelDownloadTask()
                    imgView.image = UIImage(named: name)
                    
                case let .remote(url):
                    imgView.kf.setImage(
                        with: URL(string: url),
                        options: [.transition(.fade(0.2))]
                    )
                case .label:
                    imgView.kf.cancelDownloadTask()
                    imgView.image = nil
                }
                
            case let label as UILabel:
                guard let iconSource else {
                    label.text = nil
                    (label as? JKRShimmeringLabel)?.shimmerMask = nil
                    return
                }
                
                switch iconSource {
                case .image, .asset, .remote:
                    label.text = nil
                    (label as? JKRShimmeringLabel)?.shimmerMask = nil
                    
                case let .label(str, mask):
                    label.text = str
                    (label as? JKRShimmeringLabel)?.shimmerMask = mask
                }
                
            default:
                break
            }
        }
    }
    
    enum Error: Swift.Error, LocalizedError {
        case networkFailed(_ type: ListType, _ range: RegionRange, _ error: Swift.Error?)
        case nullData(_ type: ListType, _ range: RegionRange)
        case userCancel(_ type: ListType, _ range: RegionRange)
        
        var listType: ListType {
            switch self {
            case let .networkFailed(type, _, _):
                return type
            case let .nullData(type, _):
                return type
            case let .userCancel(type, _):
                return type
            }
        }
        
        var range: RegionRange {
            switch self {
            case let .networkFailed(_, range, _):
                return range
            case let .nullData(_, range):
                return range
            case let .userCancel(_, range):
                return range
            }
        }
        
        var isUserCancel: Bool {
            switch self {
            case .userCancel:
                return true
            default:
                return false
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .networkFailed:
                return "网络连接异常，请检查您的网络"
            case .nullData:
                return "暂无数据"
            case .userCancel:
                return nil
            }
        }
    }
}
