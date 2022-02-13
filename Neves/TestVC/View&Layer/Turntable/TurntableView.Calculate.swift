//
//  TurntableView.Calculate.swift
//  Neves
//
//  Created by aa on 2021/9/14.
//

extension TurntableView {
    
//    static func calculateCellLayouts(offset: CGFloat, totalOffset: CGFloat, cellLayouts: inout [TurntableViewCellLayout]) {
//        let circlePoint = QWRelationshipPlanet.planetCirclePoint
//        let radius = QWRelationshipPlanet.planetRadius
//        let radian90 = Self.radian90
//        let radian105 = Self.radian105
//        let radian360 = Self.radian360
//        let singleItemRadian = Self.singleItemRadian
//        let singleItemOffsetY = Self.singleItemOffsetY
//        let halfRoundOffsetY = Self.minContentH // 转半圈所需偏移量
//        
//        let offsetY = scrollView.contentOffset.y
//        let progress = offsetY / Self.totalOffsetY
//        
//        peopleViews.forEach { peopleView in
//            let index = peopleView.index
//            let minHideOffsetY = peopleView.minHideOffsetY
//            let minShowOffsetY = peopleView.minShowOffsetY
//            
//            // 弧度
//            var radian: CGFloat = singleItemRadian * CGFloat(index) - radian90
//            radian -= progress * radian360
//            
//            // 信息的透明度
//            var infoAlpha: CGFloat = 1
//            if offsetY > minHideOffsetY {
//                infoAlpha = 1 - (offsetY - minHideOffsetY) / singleItemOffsetY
//            } else {
//                let oy = offsetY + halfRoundOffsetY
//                if oy > minShowOffsetY {
//                    infoAlpha = (oy - minShowOffsetY) / singleItemOffsetY
//                } else {
//                    infoAlpha = 0
//                }
//            }
//            if infoAlpha < 0 {
//                infoAlpha = 0
//            } else if infoAlpha > 1 {
//                infoAlpha = 1
//            }
//            
//            // 中点
//            let centerX: CGFloat = circlePoint.x + radius * cos(radian)
//            let centerY: CGFloat = circlePoint.y + radius * sin(radian)
//            let center: CGPoint = [centerX, offsetY + centerY]
//            
//            // 是否隐藏
//            let isHidden = radian > radian105 || radian < -radian105
//            
//            peopleView.updateTurnLayout(radian: radian, infoAlpha: infoAlpha, center: center, isHidden: isHidden)
//        }
//    }
    
}
