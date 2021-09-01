//
//  RelationshipUniverse.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

let universeSize: CGSize = [PortraitScreenWidth, 604.px]

let radian360 = CGFloat.pi * 2
let radian180 = CGFloat.pi
let radian90 = CGFloat.pi / 2.0
let radian30 = CGFloat.pi / 6.0

let peopleW: CGFloat = (30 + 10 + 100).px
let peopleH: CGFloat = 30.px

let planetRadius: CGFloat = 165.px // 330
let planetW: CGFloat = (planetRadius + peopleW - 15.px) * 2
let planetH: CGFloat = (planetRadius + peopleH - 15.px) * 2
let planetCirclePoint: CGPoint = [planetW * 0.5, planetH * 0.5]
let planetImgWH: CGFloat = 300.px


let minContentH = planetH
let maxContentH = planetH * 3 // 数值越大 滚动速度越慢
let maxOffsetY = maxContentH - minContentH

let onePeopleRadian: CGFloat = radian30
let onePeopleOffsetY: CGFloat = minContentH * (radian30 / radian180)
let topInset = onePeopleOffsetY

let planetSwitchDuration: TimeInterval = 1

enum RelationshipUniverse {
    
    
}
