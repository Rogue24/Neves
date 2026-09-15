//
//  Int+Extension.swift
//  Neves
//
//  Created by aa on 2025/5/8.
//

import Foundation

extension Int {
    func friendlyString(withDecimals decimals: Int = 1) -> String {
        switch self {
        case ..<1000:
            return "\(self)"
        case ..<1000000:
            return "\(Double(self) / 1000.0)".jp.truncatingFractionDigits(decimals) + "K"
        case ..<1000000000:
            return "\(Double(self) / 1000000.0)".jp.truncatingFractionDigits(decimals) + "M"
        default:
            return "\(Double(self) / 1000000000.0)".jp.truncatingFractionDigits(decimals) + "B"
        }
    }
    
    func friendlyStringMaxM(withDecimals decimals: Int = 1) -> String {
        switch self {
        case ..<1000:
            return "\(self)"
        case ..<1000000:
            return "\(Double(self) / 1000.0)".jp.truncatingFractionDigits(decimals) + "K"
        default:
            return "\(Double(self) / 1000000.0)".jp.truncatingFractionDigits(decimals) + "M"
        }
    }
    
    /// 将整数格式化为带千分位的字符串，例如`100000000 -> "100,000,000"`
    var formattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US") // 目标是西方数字，防止出现阿拉伯象形数字
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}
