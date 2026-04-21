//
//  UIImage.Extension.swift
//  Neves
//
//  Created by aa on 2021/5/20.
//

extension UIImage: JPCompatible {}
extension JP where Base: UIImage {
    /// 添加水印：按照图片像素（字体根据比例相应缩放）
    var watermark: UIImage? {
        let scale = base.size.width / PortraitScreenWidth
        
        let str: NSString = "帅哥平哇哈哈哈哦"
        let font = UIFont.systemFont(ofSize: 20.px * scale)
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = .zero
        shadow.shadowColor = UIColor.rgb(0, 0, 0, a: 0.3)
//        let attDic: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor(white: 1, alpha: 0.5), .shadow: shadow]
        let attDic: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.red, .shadow: shadow]
        
        let size = str.jp.textSize(withFont: font)
        let x = base.size.width - size.width - 7.5.px * scale
        let y = base.size.height - size.height - 7.5.px * scale
        let rect = CGRect(origin: [x, y], size: size)
        
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        base.draw(at: .zero)
        str.draw(in: rect, withAttributes: attDic)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// 添加水印：按照屏幕像素（图片像素不够就扩大）
    var watermarkOnScreenWidth: UIImage? {
        let str: NSString = "帅哥平哇哈哈哈哦"
        let font = UIFont.systemFont(ofSize: 20.px)
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = .zero
        shadow.shadowColor = UIColor.rgb(0, 0, 0, a: 0.3)
//        let attDic: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor(white: 1, alpha: 0.5), .shadow: shadow]
        let attDic: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.red, .shadow: shadow]
        
        let size = str.jp.textSize(withFont: font)
        let x = PortraitScreenWidth - size.width - 7.5.px
        let y = PortraitScreenWidth - size.height - 7.5.px
        let rect = CGRect(origin: [x, y], size: size)
        
        let imgRect: CGRect
        if base.size.width > base.size.height {
            let imgY = HalfDiffValue(PortraitScreenWidth,  PortraitScreenWidth * (base.size.height / base.size.width))
            imgRect = [0, imgY, PortraitScreenWidth, PortraitScreenWidth - 2 * imgY]
        } else {
            let imgX = HalfDiffValue(PortraitScreenWidth,  PortraitScreenWidth * (base.size.width / base.size.height))
            imgRect = [imgX, 0, PortraitScreenWidth - 2 * imgX, PortraitScreenWidth]
        }
        
        UIGraphicsBeginImageContextWithOptions([PortraitScreenWidth, PortraitScreenWidth], false, ScreenScale)
//        base.draw(at: [imgX, imgY])
        base.draw(in: imgRect)
        str.draw(in: rect, withAttributes: attDic)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func fromBundle(_ name: String, type: String? = nil) -> UIImage? {
        Base(contentsOfFile: Bundle.jp.resourcePath(withName: name, type: type))
    }
    
    var isContainsAlpha: Bool {
        base.cgImage?.jp.isContainsAlpha ?? false
    }
    
    /// 应用灰度滤镜
    func applyGrayscale() -> UIImage {
        // 创建Core Image滤镜
        guard let filter = CIFilter(name: "CIColorControls") else { return base }
        
        // 创建灰度颜色空间
        guard let _ = CGColorSpace(name: CGColorSpace.linearGray) else { return base }

        // 创建Core Image上下文
        let context = CIContext(options: nil)

        // 将UIImage转换为CIImage
        guard let ciImage = CIImage(image: base) else { return base }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputBrightnessKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)

        // 将CIImage渲染到CGImage
        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return base }

        // 将CGImage转换为UIImage并设置到UIImageView中
        return UIImage(cgImage: outputCGImage)
    }
    
    /// 水平翻转
    func horizontalFlip() -> UIImage {
        let size = base.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale // 保持原图缩放因子
        
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            let context = ctx.cgContext
            // 左右翻转变换
            context.translateBy(x: size.width, y: 0) // 原点移动到右侧
            context.scaleBy(x: -1.0, y: 1.0) // X轴反向
            // 📢：要用`image.draw(in:)`进行绘制，不能使用`context.draw(cgImage, in:)`，否则会变成上下翻转！
            base.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// 绘制UIImage（提供上下文给外界视图进行render）
    static func makeUIImage(withSize size: CGSize, isPNG: Bool, render: (_ ctx: UIGraphicsImageRendererContext) -> Void) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        var result = renderer.image { ctx in
            if Thread.isMainThread {
                render(ctx)
            } else {
                DispatchQueue.main.sync { render(ctx) }
            }
        }
        
        // 代码绘制的图片默认为jpeg格式（没有透明通道），需要手动转成png格式
        if isPNG, let pngData = result.pngData() {
           result = UIImage(data: pngData) ?? result
        }
        
        return result
    }
    
    /// 绘制UIImage后转Data（提供上下文给外界视图进行render）
    static func makeImageData(withSize size: CGSize, isPNG: Bool, render: (_ ctx: UIGraphicsImageRendererContext) -> Void) -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        let actions: (UIGraphicsImageRendererContext) -> Void = { ctx in
            if Thread.isMainThread {
                render(ctx)
            } else {
                DispatchQueue.main.sync { render(ctx) }
            }
        }
        
        if isPNG {
            return renderer.pngData(actions: actions)
        } else {
            return renderer.jpegData(withCompressionQuality: 0.9, actions: actions)
        }
    }
}

extension CGImage: JPCompatible {}
extension JP where Base: CGImage {
    var isContainsAlpha: Bool {
        let alphaInfo = base.alphaInfo
        if alphaInfo == .premultipliedLast ||
            alphaInfo == .premultipliedFirst ||
            alphaInfo == .last ||
            alphaInfo == .first {
            return true
        }
        return false
    }
}
