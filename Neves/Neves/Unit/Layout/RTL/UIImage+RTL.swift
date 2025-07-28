//
//  UIImage+RTL.swift
//  Neves
//
//  Created by aa on 2024/5/8.
//
//  Absolute Layout for RTL.

import UIKit

extension UIImage {
    var rtl: UIImage {
        guard isRTL, !flipsForRightToLeftLayoutDirection else {
            return self
        }
        return imageFlippedForRightToLeftLayoutDirection()
    }
}
