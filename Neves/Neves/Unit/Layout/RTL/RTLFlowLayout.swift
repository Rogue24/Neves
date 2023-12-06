//
//  RTLFlowLayout.swift
//  Neves
//
//  Created by aa on 2023/7/25.
//

import UIKit

class RTLFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        isRTL
    }
}
