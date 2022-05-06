//
//  PKResult.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

enum PKResult {
    case victory(_ isFm: Bool)
    case lose(_ isFm: Bool)
    case draw(_ isFm: Bool)
    
    enum Info {
        case title(_ size: CGSize, _ replaceKey: String)
        case star(_ size: CGSize, _ replaceKey: String)
        case icon(_ size: CGSize, _ replaceKey: String)
        case name(_ size: CGSize, _ replaceKey: String)
        case boosters(_ size: CGSize, _ replaceKey: String)
        
        var size: CGSize {
            switch self {
            case let .title(size, _): return size
            case let .star(size, _): return size
            case let .icon(size, _): return size
            case let .name(size, _): return size
            case let .boosters(size, _): return size
            }
        }
        
        var replaceKey: String {
            switch self {
            case let .title(_, replaceKey): return replaceKey
            case let .star(_, replaceKey): return replaceKey
            case let .icon(_, replaceKey): return replaceKey
            case let .name(_, replaceKey): return replaceKey
            case let .boosters(_, replaceKey): return replaceKey
            }
        }
    }
    
    var isFm: Bool {
        switch self {
        case let .victory(isFm): return isFm
        case let .lose(isFm): return isFm
        case let .draw(isFm): return isFm
        }
    }
    
    var lottieName: String {
        switch self {
        case let .victory(isFm): return isFm ? "pk_fm_win_lottie" : "pk_yule_win_lottie"
        case let .lose(isFm): return isFm ? "pk_fm_lose_lottie" : "pk_yule_lose_lottie"
        case let .draw(isFm): return isFm ? "pk_fm_draw_lottie" : "pk_yule_draw_lottie"
        }
    }
    
    var infos: [Info] {
        var infos: [Info] = []
        if isFm {
            infos.append(.title([220, 18], "img_3.png"))
            infos.append(.star([220, 16], "img_4.png"))
            infos.append(.icon([60, 60], "img_0.png"))
        } else {
            infos.append(.icon([65, 65], "img_0.png"))
        }
        infos.append(.name([120, 16], "img_1.png"))
        infos.append(.boosters([220, 44], "img_2.png"))
        return infos
    }
}
