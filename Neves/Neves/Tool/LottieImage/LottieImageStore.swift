//
//  LottieImageStore.swift
//  Neves
//
//  Created by aa on 2021/10/22.
//

import UIKit

class LottieImageStore {
    
    struct Configure {
        let lottieName: String
        let imageSize: CGSize?
        let lottieSize: CGSize?
        let lottieFrame: ((_ imageSize: CGSize, _ lottieSize: CGSize) -> CGRect?)?
        let framerate: Int?
        
        init(lottieName: String,
             imageSize: CGSize? = nil,
             lottieSize: CGSize? = nil,
             lottieFrame: ((_ imageSize: CGSize, _ lottieSize: CGSize) -> CGRect?)? = nil,
             framerate: Int? = nil) {
            self.lottieName = lottieName
            self.imageSize = imageSize
            self.lottieSize = lottieSize
            self.lottieFrame = lottieFrame
            self.framerate = framerate
        }
    }
    
    let framerate: Int
    let startFrame: Int
    let endFrame: Int
    let totalFrame: Int
    let duration: TimeInterval
    
    private(set) var imageSize: CGSize = .zero
    private(set) var lottieFrame: CGRect = .zero
    private(set) var imageMap: [Int: UIImage] = [:]
    
    init(framerate: Int,
         startFrame: Int,
         endFrame: Int,
         duration: TimeInterval) {
        self.framerate = framerate
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.totalFrame = endFrame - startFrame
        self.duration = duration
    }
    
}

extension LottieImageStore {
    static func createStore(configure: Configure) -> LottieImageStore? {
        guard let lottie = createAnimationAndImageProvider(configure.lottieName) else {
            return nil
        }
        
        let animation = lottie.0
        let provider = lottie.1
        
        let animLayer = createAnimationContainer(animation,
                                                 provider,
                                                 configure.lottieSize)
        
        let store = LottieImageStore(framerate: Int(animation.framerate),
                                     startFrame: Int(animation.startFrame),
                                     endFrame: Int(animation.endFrame),
                                     duration: animation.duration)
        
        store.getImages(configure: configure,
                        animLayer: animLayer)
        
        return store
    }
}

private extension LottieImageStore {
    static func createAnimationAndImageProvider(_ lottieName: String) -> (Animation, DecodeImageProvider)? {
        guard let directoryPath = Bundle.main.path(forResource: "lottie/\(lottieName)", ofType: nil) else {
            JPrint("路径错误！")
            return nil
        }
        
        let jsonPath = directoryPath + "/" + "data.json"
        guard File.manager.fileExists(jsonPath) else {
            JPrint("不存在JSON文件！")
            return nil
        }
        guard let animation = Animation.filepath(jsonPath, animationCache: LRUAnimationCache.sharedCache) else {
            JPrint("animation错误！")
            return nil
        }
        
        let imageDirPath = directoryPath + "/" + "images"
        guard let provider = DecodeImageProvider(imageDirPath: imageDirPath) else {
            JPrint("provider错误！")
            return nil
        }
        
        return (animation, provider)
    }
    
    static func createAnimationContainer(_ animation: Animation,
                                         _ imageProvider: AnimationImageProvider,
                                         _ size: CGSize?) -> AnimationContainer {
        
        let animLayer = AnimationContainer(animation: animation,
                                           imageProvider: imageProvider,
                                           textProvider: DefaultTextProvider(),
                                           fontProvider: DefaultFontProvider())
        animLayer.renderScale = 1
        animLayer.frame = CGRect(origin: .zero, size: size ?? animation.bounds.size)
        
        let scale: CGFloat
        if animation.bounds.size.width < animation.bounds.size.height {
            scale = animLayer.bounds.height / animation.bounds.size.height
        } else {
            scale = animLayer.bounds.width / animation.bounds.size.width
        }
        
        Syncs.main {
            animLayer.animationLayers.forEach {
                $0.transform = CATransform3DMakeScale(scale, scale, 1)
                // $0.anchorPoint 是 [0, 0]
                $0.position = [HalfDiffValue(animLayer.bounds.width, $0.frame.width),
                               HalfDiffValue(animLayer.bounds.height, $0.frame.height)]
            }
            
            animLayer.reloadImages()
            animLayer.setNeedsDisplay()
        }
        
        return animLayer
    }
    
    func getImages(configure: Configure, animLayer: AnimationContainer) {
        
        let imageSize = configure.imageSize ?? animLayer.bounds.size
        self.imageSize = imageSize
        self.lottieFrame = CGRect(origin: .zero, size: imageSize)
        
        let lottieSize = configure.lottieSize ?? imageSize
        UIGraphicsBeginImageContextWithOptions(lottieSize, false, 1)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        var imageMap: [Int: UIImage] = [:]
        defer { self.imageMap = imageMap }
        
        let startFrame = CGFloat(self.startFrame)
        let framerateScale = CGFloat(configure.framerate ?? self.framerate) / CGFloat(self.framerate)
        let totalFrame = CGFloat(self.totalFrame) * framerateScale
        let totalCount = Int(totalFrame)
        
        var lastFrame: Int = -1
        for i in 0 ... totalCount {
            let progress = CGFloat(i) / totalFrame
            let currentFrame = Int(startFrame + totalFrame * progress)
            
            guard lastFrame != currentFrame else { continue }
            lastFrame = currentFrame
            
            Syncs.main {
                animLayer.currentFrame = CGFloat(currentFrame)
                animLayer.display()
            }
            
            autoreleasepool {
//                ctx.saveGState()
                
                animLayer.render(in: ctx)
                imageMap[currentFrame] = UIGraphicsGetImageFromCurrentImageContext()
                
                ctx.clear(CGRect(origin: .zero, size: lottieSize))
//                ctx.restoreGState()
            }
        }
        UIGraphicsEndImageContext()
        
        guard let lottieFrame = configure.lottieFrame?(imageSize, lottieSize) else {
            return
        }
        self.lottieFrame = lottieFrame
        
        fitImages()
    }
    
    func fitImages() {
        guard lottieFrame != CGRect(origin: .zero, size: imageSize) else { return }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        for (currentFrame, image) in imageMap {
            autoreleasepool {
//                ctx.saveGState()
                
                image.draw(in: lottieFrame)
                imageMap[currentFrame] = UIGraphicsGetImageFromCurrentImageContext()
                
                ctx.clear(CGRect(origin: .zero, size: imageSize))
//                ctx.restoreGState()
            }
        }
        UIGraphicsEndImageContext()
    }
}

extension LottieImageStore {
    func getImage(_ currentFrame: Int) -> UIImage? {
        imageMap[startFrame + currentFrame]
    }
    
    func getImage(_ currentTime: TimeInterval) -> UIImage? {
        var fixTime = currentTime
        if currentTime > duration {
            let pe = Int(currentTime / duration)
            fixTime -= duration * TimeInterval(pe)
        }
        let progress: CGFloat = fixTime / duration
        let currentFrame = Int(CGFloat(totalFrame) * progress)
        return getImage(currentFrame)
    }
}
