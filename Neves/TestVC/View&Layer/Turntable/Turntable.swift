//
//  Turntable.swift
//  Neves
//
//  Created by aa on 2022/2/7.
//

import UIKit

typealias TurntableCell = UIView & TurntableCellCompatible

protocol TurntableCellCompatible: UIView {
    
}

protocol TurntableViewDataSource {
    
    func numberOfOneRound(in turntableView: TurntableView) -> Int
    
    func numberOfDisplays(in turntableView: TurntableView) -> Int
    
    func numberOfCells(in turntableView: TurntableView) -> Int
    
    func turntableView(_ turntableView: TurntableView, cellAtIndex index: Int) -> TurntableCell
    
}

protocol TurntableViewDelegate {
    
    func turntableView(_ turntableView: TurntableView, willDisplay cell: TurntableCell, atIndex index: Int)

    func turntableView(_ turntableView: TurntableView, didEndDisplaying cell: TurntableCell, atIndex index: Int)
    
    func turntableView(_ turntableView: TurntableView, sizeAtIndex index: Int) -> CGSize
    
    func turntableView(_ turntableView: TurntableView, didSelectCellAt index: Int)

}


enum Turntable {
    
    enum ScrollDirection {
        case vertical
        case horizontal
    }
    
    static let radian180 = CGFloat.pi
    static let radian360 = CGFloat.pi * 2
    static let radian90 = CGFloat.pi / 2.0
    static let radian30 = CGFloat.pi / 6.0
    static let radian105 = radian30 * 3.5
    
//    static let minContentH = RelationshipPlanet.planetH // 一屏显示半圈，也就是6个
//    static let totalOffsetY = minContentH * 2 // 用于计算转动进度的偏移量（一圈12个，一屏6个，滚一屏高度就是50%进度，所以两屏高度就是刚好能滚一圈的最佳偏移量）
//    static let oneRoundItemCount: Int = 12 // 一圈12个，一屏显示半圈，也就是6个
//    static let halfRoundItemCount: Int = oneRoundItemCount / 2 // 半圈6个
//    static let singleItemRadian: CGFloat = radian360 / CGFloat(oneRoundItemCount) // 360 / 12 = 30
//    static let singleItemOffsetY: CGFloat = minContentH / CGFloat(halfRoundItemCount) // 一屏显示6个
    
}
