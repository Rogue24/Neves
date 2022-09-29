//
//  AppDelegate.swift
//  Neves
//
//  Created by 周健平 on 2020/11/1.
//

import UIKit
import FunnyButton

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // iOS13及以上用这个
    @objc var window: UIWindow? {
        set {}
        get {
            if #available(iOS 13.0, *) {
                guard let scene = UIApplication.shared.connectedScenes.first,
                      let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
                      let window = windowSceneDelegate.window
                else {
                    return nil
                }
                return window
            } else {
                return UIApplication.shared.keyWindow
            }
        }
    }
    
    // iOS13以下用这个
//    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FunnyButton.orientationMask = JPScreenRotationTool.sharedInstance().orientationMask
        JPScreenRotationTool.sharedInstance().orientationMaskDidChange = { orientationMask in
            FunnyButton.orientationMask = orientationMask
        }
        
        JPProgressHUD.setMaxSupportedWindowLevel(.alert)
        JPProgressHUD.setMinimumDismissTimeInterval(1.3)
        
        JPrint(File.documentDirPath)
        JPrint(File.documentFilePath("123"))
        JPrint(File.cacheDirPath)
        JPrint(File.cacheFilePath("456"))
        JPrint(File.tmpDirPath)
        JPrint(File.tmpFilePath("789"))
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            let navigationBar = UINavigationBar.appearance()
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
        }
        
        // 初始化MMKV
        KVM.register(520)
        
        JPrint("000 StatusBar", StatusBarH, DiffStatusBarH)
        JPrint("000 TabBar", TabBarH, DiffTabBarH)
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return JPScreenRotationTool.sharedInstance().orientationMask
    }
}

