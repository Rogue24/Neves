//
//  AnimationView.Extension.swift
//  Neves_Example
//
//  Created by aa on 2020/10/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIImage {
    // MARK:- 图片切圆&压缩
    func clipRound(_ scale: CGFloat? = nil) -> UIImage {
        guard let cgImg = self.cgImage else { return self }
        
        let scale = scale ?? 1
        let w = self.size.width * scale
        let h = self.size.height * scale
        let imgSize = CGSize(width: w, height: h)
        
        let minSide = min(w, h)
        let roundSize = CGSize(width: minSide, height: minSide)
        
        UIGraphicsBeginImageContextWithOptions(roundSize, false, self.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -roundSize.height)
        
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: roundSize),
                                byRoundingCorners: .allCorners,
                                cornerRadii: .init(width: minSide * 0.5, height: 0))
        path.close()
        path.addClip()
        
        let rect = CGRect(origin: .init(x: (roundSize.width - w) * 0.5, y: (roundSize.height - h) * 0.5),
                          size: imgSize)
        ctx.draw(cgImg, in: rect)
        
        let finalImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImg ?? self
    }
    
//    // MARK:- 图片解码&压缩
//    func decode(_ scale: CGFloat? = nil) -> UIImage {
//        guard let cgImg = self.cgImage else { return self }
//        
//        let maxWidth = size.width * self.scale
//        let width = maxWidth * (scale == nil ? 1 : (scale! > 1 ? 1 : scale!))
//        let height = width * (size.height / size.width)
//        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        var bitmapRawValue = CGBitmapInfo.byteOrder32Little.rawValue
//        let alphaInfo = cgImg.alphaInfo
//        if alphaInfo == .premultipliedLast ||
//            alphaInfo == .premultipliedFirst ||
//            alphaInfo == .last ||
//            alphaInfo == .first {
//            bitmapRawValue += CGImageAlphaInfo.premultipliedFirst.rawValue
//        } else {
//            bitmapRawValue += CGImageAlphaInfo.noneSkipFirst.rawValue
//        }
//        
//        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapRawValue) else { return self }
//        
//        context.setShouldAntialias(true)
//        context.setAllowsAntialiasing(true)
//        context.interpolationQuality = .high
//        context.draw(cgImg, in: CGRect(x: 0, y: 0, width: width, height: height))
//        
//        guard let finalImgRef = context.makeImage() else { return self }
//        return UIImage(cgImage: finalImgRef, scale: self.scale, orientation: imageOrientation)
//    }
}

enum LottieAnimationUnitAlignment: Int {
    case Full_Screen
    case Top
    case Aline_Bottom
    case Below_ActionBar
    case AreaView_Top_Left
    case AreaView_Top_Right
    case AreaView_Bottom_Left
    case AreaView_Bottom_Right
    case AreaView_Center_Horizen
    case AreaView_Center_Vertical
    case AreaView_Center_Horizen_Below_ActionBar
    
    func computeViewFrame(_ superSize: CGSize, _ margin: UIEdgeInsets, _ size: CGSize) -> CGRect {
        let origin: CGPoint
        let viewSize: CGSize
        
        switch self {
        case .Full_Screen:
            origin = .zero
            viewSize = superSize
             
        case .Aline_Bottom:
            origin = .init(x: (superSize.width - size.width) * 0.5,
                           y: superSize.height - size.height)
            viewSize = size
            
        case .Below_ActionBar:
            fallthrough
        case .AreaView_Center_Horizen_Below_ActionBar:
            origin = .init(x: (superSize.width - size.width) * 0.5,
                           y: margin.top)
            viewSize = size
            
        case .Top:
            fallthrough
        default:
            origin = .init(x: (superSize.width - size.width) * 0.5, y: 0)
            viewSize = size
        }
        
        return .init(origin: origin, size: viewSize)
    }
}
