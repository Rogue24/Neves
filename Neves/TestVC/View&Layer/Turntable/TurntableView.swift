//
//  TurntableView.swift
//  Neves
//
//  Created by aa on 2021/9/14.
//

import UIKit

class TurntableView: UIScrollView {
    
//    static let minContentH = RelationshipPlanet.planetH // 一屏显示半圈，也就是6个
//    static let totalOffsetY = minContentH * 2 // 用于计算转动进度的偏移量（一圈12个，一屏6个，滚一屏高度就是50%进度，所以两屏高度就是刚好能滚一圈的最佳偏移量）
//    static let oneRoundItemCount: Int = 12 // 一圈12个，一屏显示半圈，也就是6个
//    static let halfRoundItemCount: Int = oneRoundItemCount / 2 // 半圈6个
//    static let singleItemRadian: CGFloat = radian360 / CGFloat(oneRoundItemCount) // 360 / 12 = 30
//    static let singleItemOffsetY: CGFloat = minContentH / CGFloat(halfRoundItemCount) // 一屏显示6个
//
//    lazy var peoples: [PeopleView] = (0 ..< RelationshipPlanet.singlePlanetMaxPeopleCount).map { PeopleView(tag: $0) }
//    var maxOffsetY: CGFloat = 0
//
//    init() {
//        super.init(frame: [0, 0, RelationshipPlanet.planetW, RelationshipPlanet.planetH])
//        jp.contentInsetAdjustmentNever()
//        delegate = self
//        alwaysBounceVertical = true
//        showsVerticalScrollIndicator = false
//        clipsToBounds = false
//
//        peoples.forEach { addSubview($0) }
//
//        let singleItemOffsetY = Self.singleItemOffsetY
//
//        let minContentH = Self.minContentH
//        var contentH = singleItemOffsetY * CGFloat(peoples.count)
//        if contentH < minContentH { contentH = minContentH }
//        contentSize = [0, contentH]
//
//        let topInset = singleItemOffsetY // 需要空一格，否则第一个就在中心位置
//        contentInset = .init(top: topInset, left: 0, bottom: 0, right: 0)
//        contentOffset = [0, -topInset]
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TurntableView: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let progress = offsetY / Self.totalOffsetY
////        JPrint("offsetY:", offsetY)
////        JPrint("progress:", progress)
////        JPrint("----------------------")
//        peoples.forEach { $0.updateLayout(offsetY: offsetY, progress: progress) }
//    }
}

extension TurntableView {
    func update(scale: CGFloat, alpha: CGFloat) {
        self.transform = .init(scaleX: scale, y: scale)
        self.alpha = alpha
    }
}
