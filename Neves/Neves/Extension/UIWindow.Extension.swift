//
//  UIWindow.Extension.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension JP where Base: UIWindow {
    
    static var mainWindowTopVC: UIViewController? {
        return GetTopMostViewController()
    }
    
    static var keyWindowTopVC: UIViewController? {
        return GetKeyWindow()?.jp.topVC
    }
    
    static var delegateWindowTopVC: UIViewController? {
        return UIApplication.shared.delegate?.window??.jp.topVC
    }
    
    /**
     * 获取顶层控制器
     */
    var topVC: UIViewController? {
        guard let rootVC = base.rootViewController else { return nil }
        return GetTopMostViewController(from: rootVC)
    }
    
}
