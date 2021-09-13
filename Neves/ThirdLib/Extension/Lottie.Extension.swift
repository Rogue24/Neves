//
//  Lottie.Extension.swift
//  Neves_Example
//
//  Created by aa on 2020/10/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

struct ImageReplacementProvider: AnimationImageProvider {
    let replacement: [String: CGImage?]?
    let fileProvider: FilepathImageProvider
    
    init(imageReplacement: [String: CGImage?]?, filePath: String) {
        replacement = imageReplacement
        fileProvider = FilepathImageProvider(filepath: filePath)
    }
    
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        if let cgImg = replacement?[asset.name] {
            return cgImg
        }
        return fileProvider.imageForAsset(asset: asset)
    }
}

//extension AnimationView: JPCompatible {}
extension JP where Base: AnimationView {
    static func build(_ dirName: String, _ imageReplacement: [String: CGImage?]? = nil) -> Base {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(dirName)") else { fatalError("路径错误！") }
        let animView: Base
        if let imageReplacement = imageReplacement {
            let path = URL(fileURLWithPath: filepath).deletingLastPathComponent().path
            let imageProvider = ImageReplacementProvider(imageReplacement: imageReplacement, filePath: path)
            animView = Base.init(filePath: filepath, imageProvider: imageProvider)
        } else {
            animView = Base.init(filePath: filepath)
        }
        animView.backgroundBehavior = .pauseAndRestore
        return animView
    }
    
    static func build(at filepath: String, _ imageReplacement: [String: CGImage?]? = nil) -> Base {
        let animView: Base
        if let imageReplacement = imageReplacement {
            let path = URL(fileURLWithPath: filepath).deletingLastPathComponent().path
            let imageProvider = ImageReplacementProvider(imageReplacement: imageReplacement, filePath: path)
            animView = Base.init(filePath: filepath, imageProvider: imageProvider)
        } else {
            animView = Base.init(filePath: filepath)
        }
        animView.backgroundBehavior = .pauseAndRestore
        return animView
    }
}
