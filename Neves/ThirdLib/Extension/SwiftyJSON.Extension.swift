//
//  SwiftyJSON.Extension.swift
//  Neves_Example
//
//  Created by aa on 2020/10/26.
//  Copyright © 2020 Quwan. All rights reserved.
//

import SwiftyJSON

extension JSON: JPCompatible {}
extension JP where Base == JSON {
    var cgFloatValue: CGFloat { CGFloat(base.doubleValue) }
}
