//
//  BaseNavigationController.swift
//  Neves
//
//  Created by aa on 2022/9/20.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // 🌰🌰🌰：竖屏 --> 横屏
        
        // 当屏幕发生旋转时，系统会自动触发该函数，`size`为【旋转之后】的屏幕尺寸
        JPrint("size", size) // --- (926.0, 428.0)
        
        // 或者通过`UIScreen`也能获取【旋转之后】的屏幕尺寸
        JPrint("mainScreen", UIScreen.mainSize) // --- (926.0, 428.0)
        
        // 📢 注意：如果想通过`self.xxx`去获取屏幕相关的信息（如`self.view.frame`），【此时】获取的尺寸还是【旋转之前】的尺寸
        JPrint("----------- 屏幕即将旋转 -----------")
        logViewInfo()
        logOrientationMask()
        
        // 📢 想要获取【旋转之后】的屏幕信息，需要到`Runloop`的下一个循环才能获取
        DispatchQueue.main.async {
            JPrint("----------- 屏幕已经旋转 -----------")
            self.logViewInfo()
            self.logOrientationMask()
            JPrint("==================================")
        }
    }
    
    private func logViewInfo() {
        // (428.0, 926.0) - (926.0, 428.0)
        JPrint("view.size", view.size)
        // (428.0, 926.0) - (926.0, 428.0)
        JPrint("window.size", view.window?.size ?? .zero)
        // UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0) - UIEdgeInsets(top: 0.0, left: 47.0, bottom: 21.0, right: 47.0)
        JPrint("window.safeAreaInsets", view.window?.safeAreaInsets ?? .zero)
    }
    
    private func logOrientationMask(_ orientationMask: UIInterfaceOrientationMask? = nil) {
        switch orientationMask ?? JPScreenRotator.sharedInstance().orientationMask {
        case .landscapeLeft:
            JPrint("landscapeLeft")
        case .landscapeRight:
            JPrint("landscapeRight")
        case .landscape:
            JPrint("landscape")
        default:
            JPrint("portrait")
        }
    }
}
