//
//  AsyncDecodeAnimationView.swift
//  Neves_Example
//
//  Created by aa on 2020/10/22.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftyJSON

@objcMembers class AsyncDecodeAnimationView: UIView {
    
    fileprivate struct DecodeImageProvider: AnimationImageProvider {
        let images: [String: CGImage]
        func imageForAsset(asset: ImageAsset) -> CGImage? {
            images[asset.name] ?? nil
        }
    }
    
    fileprivate struct AnimItem {
        let filePath: String
        let animTag: Int
        var playCount: Int = 1
        var subItems: [AnimSubItem] = []
    }
    
    fileprivate struct AnimSubItem {
        let viewTag: Int
        let viewFrame: CGRect
        let zPosition: CGFloat
        let anim: Animation?
        let provider: AnimationImageProvider?
    }
    
    fileprivate var animItems: [AnimItem] = []
    
    typealias AnimDone = () -> ()
    var animDone: AnimDone? = nil
    
    static func playAnimation(withFilePaths filePaths: [String], insertToSuperview superview: UIView, at index: Int = 0, animDone: AnimDone? = nil) {
        if filePaths.count == 0 { return }
        let animView = AsyncDecodeAnimationView(animDone: animDone)
        superview.insertSubview(animView, at: index)
        animView.prepareToPlay(filePaths)
    }
    
    private var isSync = false
    static func syncPlayAnimation(withFilePaths filePaths: [String], insertToSuperview superview: UIView, at index: Int = 0, animDone: AnimDone? = nil) {
        if filePaths.count == 0 { return }
        let animView = AsyncDecodeAnimationView(animDone: animDone)
        animView.isSync = true
        superview.insertSubview(animView, at: index)
        animView.prepareToPlay(filePaths)
    }
    
    private convenience init(animDone: AnimDone? = nil) {
        self.init(frame: UIScreen.main.bounds)
        self.animDone = animDone
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
    
    deinit {
        JPrint("老子死了")
    }
}

extension AsyncDecodeAnimationView {
    private func prepareToPlay(_ filePaths: [String]) {
        let superSize = self.bounds.size
        let ratio = UIScreen.main.bounds.size.width / 375.0
        
        let safeTop: CGFloat = NavTopMargin
        let safeBottom: CGFloat = DiffTabBarH
        
        DispatchQueue.global().async {
            // 除重
            var animItems = [String: AnimItem]()
            var animTag = 0
            for filePath in filePaths {
                if var animItem = animItems[filePath] {
                    animItem.playCount += 1
                    animItems[filePath] = animItem
                    self.animItems[animItem.animTag] = animItem
                } else {
                    let animItem = AnimItem(filePath: filePath, animTag: animTag)
                    animItems[filePath] = animItem
                    self.animItems.append(animItem)
                    animTag += 1
                }
            }
            
            for i in 0..<self.animItems.count {
                let animItem = self.animItems[i]
                JPrint("1", i, "---", animItem.filePath.components(separatedBy: "/").last!)
            }
            
            DispatchQueue.concurrentPerform(iterations: self.animItems.count) { [weak self] in
                guard let self = self else { return }
                var animItem = self.animItems[$0]
                
                let packageJson = URL(fileURLWithPath: animItem.filePath).appendingPathComponent("package.json")
                guard let config = try? JSON(data: Data(contentsOf: packageJson)),
                      let configList = config["list"].array else { return }
                
                for i in 0..<configList.count {
                    let subConfig = configList[i]
                    let packageName = subConfig["packageName"].stringValue
                    let animDirPath = packageJson.deletingLastPathComponent().appendingPathComponent(packageName).path
                    
                    guard let objs: (Animation?, AnimationImageProvider?) = Self.createAnimationAndImageProvider(animDirPath, isSync: self.isSync) else { break }
                    
                    let margin = UIEdgeInsets(top: subConfig["marginTop"].jp.cgFloatValue + safeTop,
                                              left: subConfig["marginLeft"].jp.cgFloatValue,
                                              bottom: subConfig["marginLeft"].jp.cgFloatValue + safeBottom,
                                              right: subConfig["marginLeft"].jp.cgFloatValue)
                    
                    let size = CGSize(width: subConfig["width"].jp.cgFloatValue * 0.5 * ratio,
                                      height: subConfig["height"].jp.cgFloatValue * 0.5 * ratio)
                    
                    let alignment = LottieAnimationUnitAlignment(rawValue: subConfig["gravity"].intValue) ?? .Top
                    let viewFrame = alignment.computeViewFrame(superSize, margin, size)
                    
                    /*
                     * viewTag ==> 1 01
                                   ↓ ↓↓
                                   ↓ →→→→→→→→→→→→→→→→→→→→→→→→→→→
                                   ↓                          ↓↓
                                   ↓                    当前Lottie的tag animTag
                            当前Lottie里面的第几个的tag
                     */
                    let subItem = AnimSubItem(viewTag: animItem.animTag + (i + 1) * 100,
                                              viewFrame: viewFrame,
                                              zPosition: subConfig["zIndex"].jp.cgFloatValue,
                                              anim: objs.0,
                                              provider: objs.1)
                    animItem.subItems.append(subItem)
                    
                    let lock = DispatchSemaphore(value: 0)
                    DispatchQueue.main.async {
                        let animView = AnimationView(animation: subItem.anim, imageProvider: subItem.provider)
                        animView.backgroundBehavior = .pauseAndRestore
                        animView.contentMode = .scaleToFill
                        animView.tag = subItem.viewTag
                        animView.frame = subItem.viewFrame
                        animView.layer.zPosition = subItem.zPosition
                        animView.isHidden = true
                        self.addSubview(animView)
                        lock.signal()
                    }
                    lock.wait()
                }
                JPrint("2", $0, "---", animItem.filePath.components(separatedBy: "/").last!)
                self.animItems[$0] = animItem
            }
            
            DispatchQueue.main.async { [weak self] in self?.playAll() }
        }
    }
    
    private func playAll() {
        guard let animItem = self.animItems.first else {
            animDone?()
            self.removeFromSuperview()
            return
        }
        
        self.animItems.remove(at: 0)
        
        let playCount = Float(animItem.playCount)
        
        let total = animItem.subItems.count
        let allDone = { [weak self] (count: Int) in
            if count == total { self?.playAll() }
        }
        
        var currCount = 0
        for i in 0..<animItem.subItems.count {
            let subItem = animItem.subItems[i]
            
            guard let animView = viewWithTag(subItem.viewTag) as? AnimationView else {
                currCount += 1
                allDone(currCount)
                return
            }
            
            animView.isHidden = false
            animView.play(toProgress: 1, loopMode: .repeat(playCount)) { [weak animView] _ in
                animView?.removeFromSuperview()
                currCount += 1
                allDone(currCount)
            }
        }
    }
}

extension AsyncDecodeAnimationView {
    
//    private static let decodeQueue = DispatchQueue(label: "AsyncDecode.SerialQueue")
//
//    static func decodeImageOfFile(_ imgPath: String) -> CGImage? {
    
    static func createAnimationAndImageProvider(_ animDirPath: String, isSync: Bool = false) -> (Animation?, AnimationImageProvider?)? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: animDirPath) else { return nil }
        
        let animJsonPath = animDirPath + "/data.json"
        let imageDirPath = animDirPath + "/images"
        
        guard fileManager.fileExists(atPath: animJsonPath) else { return nil }
        
        let anim = Animation.filepath(animJsonPath)
        
        guard fileManager.fileExists(atPath: imageDirPath) else { return (anim, nil) }
        
        // TODO: 可以考虑用NSCache缓存在内存，具有时效性的缓存
        let provider: AnimationImageProvider
        if let fileNames = try? fileManager.subpathsOfDirectory(atPath: imageDirPath) {
            var images: [String: CGImage] = [:]
            for fileName in fileNames {
                let imagePath = imageDirPath + "/\(fileName)"
                guard let image = decodeImageOfFile(imagePath) else { break }
                images[fileName] = image
            }
            provider = images.count == fileNames.count ? DecodeImageProvider(images: images) : FilepathImageProvider(filepath: animDirPath)
        } else {
            provider = FilepathImageProvider(filepath: animDirPath)
        }
        
        return (anim, provider)
    }
    
    static func decodeImageOfFile(_ imgPath: String) -> CGImage? {
        guard let image = UIImage(contentsOfFile: imgPath), let cgImg = image.cgImage else { return nil }
        
        let width = cgImg.width
        let height = cgImg.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapRawValue = CGBitmapInfo.byteOrder32Little.rawValue
        let alphaInfo = cgImg.alphaInfo
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
                                      space: colorSpace,
                                      bitmapInfo: bitmapRawValue) else { return nil }
        context.draw(cgImg, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let decodeImg = context.makeImage()
        return decodeImg
    }
}
