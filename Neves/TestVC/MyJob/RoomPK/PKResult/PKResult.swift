//
//  PKResult.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

enum PKResult {
    case victory
    case lose
    case draw
    
    var bgImage: UIImage? {
        switch self {
        case .victory: return UIImage(named: "")
        case .lose: return UIImage(named: "")
        case .draw: return UIImage(named: "")
        }
    }
}
