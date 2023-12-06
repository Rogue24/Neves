//
//  UILabel+RTL.swift
//  Neves
//
//  Created by aa on 2023/10/23.
//
//  Absolute Layout for RTL.

import UIKit

extension UILabel {
    var rtl_alignment: NSTextAlignment {
        set {
            switch newValue {
            case .left:
                textAlignment = isRTL ? .right : .left
            case .right:
                textAlignment = isRTL ? .left : .right
            default:
                textAlignment = newValue
            }
        }
        get {
            switch textAlignment {
            case .left:
                return isRTL ? .right : textAlignment
            case .right:
                return isRTL ? .left : textAlignment
            default:
                return textAlignment
            }
        }
    }
}
