//
//  CG.swift
//  XBBaseModule
//
//  Created by xy_yanfa_imac_sumsung on 2021/4/2.
//

import Foundation

/// 计算两个点的 frame
public extension CGPoint {
    func getRect(to other: CGPoint) -> CGRect {
        let originX = min(x, other.x)
        let originY = min(y, other.y)

        let width = abs(x - other.x)
        let height = abs(y - other.y)

        let rect = CGRect(x: originX, y: originY, width: width, height: height)
        debugPrint("rect-", rect)
        return rect
    }
}
