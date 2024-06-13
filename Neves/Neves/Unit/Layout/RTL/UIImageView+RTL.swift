//
//  UIImageView+RTL.swift
//  Neves
//
//  Created by aa on 2024/5/8.
//
//  Absolute Layout for RTL.

import UIKit

extension UIImageView {
    var rtl_image: UIImage? {
        set { image = newValue?.rtl }
        get { image?.rtl }
    }
}

extension UIImage {
    var rtl: UIImage? {
        guard isRTL,
              imageOrientation != .upMirrored,
              let cgImage
        else { return self }
        return UIImage(cgImage: cgImage,
                       scale: scale,
                       orientation: .upMirrored)
    }
}
