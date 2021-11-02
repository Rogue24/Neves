//
//  Firework.TestData.swift
//  Neves_Example
//
//  Created by aa on 2020/10/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct UU_FireworkShowInfo {
    var uid: UInt32
    var fireworkId: UInt32
    var svrGotTime: UInt32
}

struct UU_FireworkGainInfo {
    var uid: UInt32
    var infoListArray: [UU_FireworkShowInfo]
    var infoListArray_Count: UInt
}

struct UU_FireworkLauncherInfo {
    var uid: UInt32
    var remainSeconds: UInt32
    var totalTime: UInt32
    var holdAmount: UInt32
    var targetAmount: UInt32
    var gotNum: UInt32
}
