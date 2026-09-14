//
//  Env.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

@objcMembers
final class Env: NSObject {
    /// window
    static var window: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            /// 在 App 启动早期（如`didFinishLaunching`）调用，
            /// 此时`scene`的`state`为`unattached`（刚创建但还没连接），
            /// 得在`scene(_:willConnectTo:)`或`sceneDidBecomeActive`之后才会变成`active`。
            /// 🙃说人话就是启动直至看到界面后才变状态
            ///
            /// 不过嘛🤔此项目确定只有一个`scene`，肯定从头到尾都是它，不用判断状态直接获取得了😏
//            guard scene.activationState == .foregroundActive else { continue }
            // 方式一：
            guard let windowScenes = scene as? UIWindowScene,
                  let window = windowScenes.windows.first else { continue }
            // 方式二：
//            guard let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
//                  let window = windowSceneDelegate.window else { continue }
            return window
        }
        return nil
    }
    
    /// windowScene
    static var windowScene: UIWindowScene? {
        window?.windowScene
    }
    
    /// 安全区域
    static var safeAreaInsets: UIEdgeInsets {
        if _safeAreaInsets == .zero, let window {
            _safeAreaInsets = window.safeAreaInsets
        }
        return _safeAreaInsets
    }
    private static var _safeAreaInsets: UIEdgeInsets = .zero
    
    /// 是否全面屏
    static var isAllScreen: Bool {
        safeAreaInsets.top > 20 && safeAreaInsets.bottom > 0
    }
    
    /// 屏幕尺寸
    static var screenSize: CGSize {
        if _screenSize == .zero, let windowScene {
            _screenSize = windowScene.screen.bounds.size
        }
        return _screenSize
    }
    private static var _screenSize: CGSize = .zero
    
    /// 屏幕宽度
    static var screenWidth: CGFloat { screenSize.width }
    /// 屏幕高度
    static var screenHeight: CGFloat { screenSize.height }
    /// 屏幕区域
    static var screenBounds: CGRect { .init(origin: .zero, size: screenSize) }
    
    /// 屏幕比例
    static var screenScale: CGFloat {
        if _screenScale == 0, let windowScene {
            _screenScale = windowScene.traitCollection.displayScale
        }
        return _screenScale
    }
    private static var _screenScale: CGFloat = 0
    
    /// 状态栏高度
    static var statusBarH: CGFloat {
        guard let window else { return 0 }
        if let sbMgr = window.windowScene?.statusBarManager {
            return sbMgr.statusBarFrame.height
        } else {
            return window.safeAreaInsets.top
        }
    }
    /// 导航栏基本高度
    static var navBarH: CGFloat { 44.0 }
    /// 状态栏+导航栏高度
    static var statusNavBarH: CGFloat { statusBarH + navBarH }
    
    /// tabBar基本高度
    static var tabBarBaseH: CGFloat { 49.0 }
    /// tabBar+底部安全间距
    static var tabBarFullH: CGFloat { tabBarBaseH + safeAreaInsets.bottom }
    
    /// 是否正在使用液态玻璃UI
    static var isUsingLiquidGlassUI: Bool {
        if let isUsing = _isUsingLiquidGlassUI {
            return isUsing
        }
        
        var isUsing = false
        if #available(iOS 26.0, *) {
            if let isEnabled = Bundle.main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool, isEnabled { // 已开启「禁用新UI」
                isUsing = false
            } else {
                isUsing = true
            }
        }
        
        _isUsingLiquidGlassUI = isUsing
        return isUsing
    }
    private static var _isUsingLiquidGlassUI: Bool? = nil
}

// MARK: - Layout Direction
extension Env {
    static var layoutDirection: UIUserInterfaceLayoutDirection {
        _layoutDirection ?? {
            guard let window else { return .leftToRight }
            let layoutDirection = UIView.userInterfaceLayoutDirection(for: window.semanticContentAttribute)
            let isRTL = layoutDirection == .rightToLeft
            _layoutDirection = layoutDirection
            _isRTL = isRTL
            return layoutDirection
        }()
    }
    private static var _layoutDirection: UIUserInterfaceLayoutDirection? = nil
    
    static var isRTL: Bool {
        _isRTL ?? {
            guard let window else { return false }
            let layoutDirection = UIView.userInterfaceLayoutDirection(for: window.semanticContentAttribute)
            let isRTL = layoutDirection == .rightToLeft
            _layoutDirection = layoutDirection
            _isRTL = isRTL
            return isRTL
        }()
    }
    private static var _isRTL: Bool? = nil
}
