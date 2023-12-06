//
//  Function.swift
//  Neves_Example
//
//  Created by aa on 2020/10/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import AVKit

// MARK: - 自定义日志
private let JPrintQueue = DispatchQueue(label: "JPrintQueue")
/// 自定义日志
func JPrint(_ msg: Any..., file: NSString = #file, line: Int = #line, fn: String = #function) {
#if DEBUG
    guard msg.count != 0, let lastItem = msg.last else { return }
    
    // 时间+文件位置+行数
    let date = hhmmssSSFormatter.string(from: Date()).utf8
//    let fileName = (file.lastPathComponent as NSString).deletingPathExtension
//    let prefix = "[\(date)] [\(fileName) \(fn)] [第\(line)行]:"
    let prefix = "jpjpjp [\(date)]:"
    
    // 获取【除最后一个】的其他部分
    let items = msg.count > 1 ? msg[..<(msg.count - 1)] : []
    
    JPrintQueue.sync {
        print(prefix, terminator: " ")
        items.forEach { print($0, terminator: " ") }
        print(lastItem)
    }
#endif
}

/// 互换两个值
func swapValues<T>(_ a: inout T, _ b: inout T) {
    (a, b) = (b, a)
}

/// 一半的差值
func HalfDiffValue(_ superValue: CGFloat, _ subValue: CGFloat) -> CGFloat {
    (superValue - subValue) * 0.5
}

/// 获取当前页码
func CurrentPageNumber(_ offsetValue: CGFloat, _ pageSizeValue: CGFloat) -> Int {
    Int((offsetValue + pageSizeValue * 0.5) / pageSizeValue)
}

/// 按页拖动的比例
func PageScrollProgress(WithPageSizeValue pageSizeValue: CGFloat,
                        pageCount: Int,
                        offsetValue: CGFloat,
                        maxOffsetValue: CGFloat,
                        startOffsetValue: inout CGFloat,
                        currentPage: inout Int,
                        sourcePage: inout Int,
                        targetPage: inout Int,
                        progress: inout CGFloat) -> Bool {
    var ov: CGFloat = offsetValue
    if ov < 0 {
        ov = 0
    } else if ov > maxOffsetValue {
        ov = maxOffsetValue
    }
    
    var kStartOffsetValue = startOffsetValue
    
    if ov == kStartOffsetValue {
        return false
    }
    
    var kSourcePage: Int = 0
    var kTargetPage: Int = 0
    var kProgress: CGFloat = 0
    
    // 滑动位置与初始位置的距离
    let offsetDistance = CGFloat(fabs(Double(ov - kStartOffsetValue)))
    
    if ov > kStartOffsetValue {
        // 左/上滑动
        kSourcePage = Int(ov / pageSizeValue)
        kTargetPage = kSourcePage + 1
        kProgress = offsetDistance / pageSizeValue
        if kProgress >= 1 {
            if kTargetPage == pageCount {
                kProgress = 1
                kTargetPage -= 1
                kSourcePage -= 1
            } else {
                kProgress = 0
            }
        }
    } else {
        // 右/下滑动
        kTargetPage = Int(ov / pageSizeValue)
        kSourcePage = kTargetPage + 1
        kProgress = offsetDistance / pageSizeValue
        if kProgress > 1 {
            if kSourcePage == pageCount {
                kProgress = 1
                kTargetPage -= 1
                kSourcePage -= 1
            } else {
                kProgress = 0
            }
        }
    }
    
    if offsetDistance >= pageSizeValue {
        let kCurrentPage = Int((offsetValue + pageSizeValue * 0.5) / pageSizeValue)
        kStartOffsetValue = pageSizeValue * CGFloat(kCurrentPage)
        currentPage = kCurrentPage
        startOffsetValue = kStartOffsetValue
    }
    
    sourcePage = kSourcePage
    targetPage = kTargetPage
    progress = kProgress
    
    return true
}

// MARK: - 获取【KeyWindow】
/// 获取`KeyWindow`
func GetKeyWindow() -> UIWindow? {
    if #available(iOS 13.0, *) {
        for connectedScene in UIApplication.shared.connectedScenes {
            guard connectedScene.activationState == .foregroundActive else { continue }
            guard let windowScene = connectedScene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window
            }
        }
    }
    
    for window in UIApplication.shared.windows where window.isKeyWindow {
        return window
    }
    
    return nil
}

// MARK: - 获取【主Window】
/// 获取`主Window`
func GetMainWindow() -> UIWindow? {
    // 一般来说第一个window就是app主体的window。
    if #available(iOS 13.0, *) {
        for connectedScene in UIApplication.shared.connectedScenes {
            guard let windowScene = connectedScene as? UIWindowScene else { continue }
            return windowScene.windows.first
        }
    }
    return UIApplication.shared.windows.first
}

// MARK: - 获取【下巴】高度
/// 获取`下巴`高度
func GetDiffTabBarH() -> CGFloat {
    if #available(iOS 11.0, *) {
        return GetMainWindow()?.safeAreaInsets.bottom ?? 0
    }
    return 0
}

// MARK: - 获取【状态栏】高度
/// 获取`状态栏`高度
func GetStatusBarH() -> CGFloat {
    var h: CGFloat = 0
    if #available(iOS 11.0, *) {
        if let window = GetMainWindow() {
            if #available(iOS 13.0, *), let sbMgr = window.windowScene?.statusBarManager {
                h = sbMgr.statusBarFrame.height
            } else {
                h = window.safeAreaInsets.top
            }
        }
    } else {
        h = UIApplication.shared.statusBarFrame.height
    }
    return h
}

// MARK: - 获取最顶层的【ViewController】--- from main window
/// 获取最顶层的`ViewController` --- 从`主Window`开始查找
func GetTopMostViewController() -> UIViewController? {
    guard let rootVC = GetMainWindow()?.rootViewController else { return nil }
    return GetTopMostViewController(from: rootVC)
}

// MARK: - 获取最顶层的【ViewController】--- from some VC
/// 获取最顶层的`ViewController` --- 从指定VC开始查找
func GetTopMostViewController(from vc: UIViewController) -> UIViewController {
    if let presentedVC = vc.presentedViewController {
        return GetTopMostViewController(from: presentedVC)
    }
    
    switch vc {
    case let navCtr as UINavigationController:
        guard let topVC = navCtr.topViewController else { return navCtr }
        return GetTopMostViewController(from: topVC)
        
    case let tabBarCtr as UITabBarController:
        guard let selectedVC = tabBarCtr.selectedViewController else { return tabBarCtr }
        return GetTopMostViewController(from: selectedVC)
        
    case let alertCtr as UIAlertController:
        guard let presentedVC = alertCtr.presentedViewController else { return alertCtr }
        return GetTopMostViewController(from: presentedVC)
        
    default:
        return vc
    }
}

// MARK: - 解码图片
/// 解码图片
func DecodeImage(_ cgImage: CGImage) -> CGImage? {
    let width = cgImage.width
    let height = cgImage.height
    
    var bitmapRawValue = CGBitmapInfo.byteOrder32Little.rawValue
    let alphaInfo = cgImage.alphaInfo
    if alphaInfo == .premultipliedLast ||
        alphaInfo == .premultipliedFirst ||
        alphaInfo == .last ||
        alphaInfo == .first {
        bitmapRawValue |= CGImageAlphaInfo.premultipliedFirst.rawValue
    } else {
        bitmapRawValue |= CGImageAlphaInfo.noneSkipFirst.rawValue
    }
    
    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space: ColorSpace,
                                  bitmapInfo: bitmapRawValue) else { return nil }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    let decodeImg = context.makeImage()
    return decodeImg
}

// MARK: - 简易播放视频（系统播放器）
func Play(_ filePath: String, isAutoPlay: Bool = true) {
    guard File.manager.fileExists(filePath) else {
        JPProgressHUD.showError(withStatus: "文件不存在！", userInteractionEnabled: true)
        return
    }
    
    guard let topVC = GetTopMostViewController() else {
        JPProgressHUD.showError(withStatus: "木有控制器！", userInteractionEnabled: true)
        return
    }
    
    let playerVC = AVPlayerViewController()
    playerVC.player = AVPlayer(url: URL(fileURLWithPath: filePath))
    
    topVC.present(playerVC, animated: true) {
        if isAutoPlay { playerVC.player?.play() }
    }
}

// MARK: - 获取枚举名
/// 获取枚举名
func GetEnumName<T>(_ value: T) -> String {
    let mirror = Mirror(reflecting: value)
    guard let displayStyle = mirror.displayStyle, displayStyle == .enum,
          let enumName = mirror.children.first?.label
    else { return "" }
    return enumName
}
