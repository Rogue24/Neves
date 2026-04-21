//
//  Comparable+Extension.swift
//  Neves
//
//  Created by aa on 2025/3/31.
//

import Foundation

extension Comparable {
    /// 获取限定范围内的值 `lower <= x <= upper`
    func clamped(in range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
    
    /// 获取单边限定的值 `x >= minValue`
    func clamped(min minValue: Self) -> Self {
        max(self, minValue)
    }
    
    /// 获取单边限定的值 `x <= maxValue`
    func clamped(max maxValue: Self) -> Self {
        min(self, maxValue)
    }
}
