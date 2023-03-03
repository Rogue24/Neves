//
//  extension.swift
//  TeacherDetailModule
//
//  Created by fulang on 2017/11/22.
//

import Foundation

// import RxSwift

import AVFoundation
import CoreGraphics

// import Toast

import SnapKit

private var key: Void?

extension UILabel {

    public var lineHeight: CGFloat {
        get {
            (objc_getAssociatedObject(self, &key) as? CGFloat) ?? 20
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

extension UIView {

    public enum ShadowType: Int {
        case all = 0 /// 四周
        case top = 1 /// 上方
        case left = 2/// 左边
        case right = 3/// 右边
        case bottom = 4/// 下方
    }

    public func makeShadow(color: UIColor, offset: CGSize = CGSize.zero, opacity: Float = 0.6, shadowRadius: CGFloat? = nil) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        if let radius = shadowRadius {
            layer.shadowRadius = radius
        }
    }

    /// 默认设置：黑色阴影, 阴影所占视图的比例
    /// 默认设置：黑色阴影
    public func shadow(_ type: ShadowType) {
        shadow(type: type, color: .black, opactiy: 0.4, shadowSize: 4)
    }

    /// 配置阴影
    /// - Parameters:
    ///   - type: 阴影方向
    ///   - color: 阴影颜色
    ///   - opactiy:  阴影透明度，默认0
    ///   - shadowSize: 阴影宽度
    ///   - shadowRadius: 阴影圆角半径
    ///   - shadowOffset: 偏移量
    public func shadow(type: ShadowType, color: UIColor, opactiy: Float, shadowSize: CGFloat, shadowRadius: CGFloat = 3, shadowOffset: CGSize = .zero) {
        layer.masksToBounds = false       // 必须要等于NO否则会把阴影切割隐藏掉
        layer.shadowColor = color.cgColor // 阴影颜色
        layer.shadowOpacity = opactiy     // 阴影透明度，默认0
        layer.shadowOffset = shadowOffset // shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
        layer.shadowRadius = shadowRadius // 阴影半径，默认3

        var shadowRect: CGRect?
        switch type {
        case .all:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .top:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .bottom:
            shadowRect = CGRect.init(x: -shadowSize, y: bounds.size.height - shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .left:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .right:
            shadowRect = CGRect.init(x: bounds.size.width - shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        }
        layer.shadowPath = UIBezierPath.init(rect: shadowRect!).cgPath
    }

    public func drawSeperateLineInContext(_ context: CGContext?, fromView: UIView, toView: UIView, offset: CGFloat = 3, color: UIColor = UIColor.jp_color(withHexString: "ECECEC"), width: CGFloat = 1) {
        guard let context = context else {
            return
        }
        let x1 = fromView.frame.origin.x + fromView.frame.size.width
        let y1 = fromView.frame.origin.y

        let x2 = toView.frame.origin.x
        let y2 = toView.frame.origin.y + toView.frame.size.height

        let x = (x1 + x2) / 2
        let yStart = y1 + offset
        let yEnd = y2 - offset

        let a = CGPoint(x: x, y: yStart)
        let b = CGPoint(x: x, y: yEnd)
        context.move(to: a)
        context.addLine(to: b)
        context.setLineWidth(width)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
    }
}

public extension String {

    func qrCodeImg(width: CGFloat) -> UIImage? {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        let outputImg = filter?.outputImage

        if let rect = outputImg?.extent.integral {
            let scale = min(width / rect.width, width / rect.height)

            let bitmapWidth: size_t = Int(rect.width * scale)
            let bitmapHeight: size_t = Int(rect.height * scale)

            let colorSpace = CGColorSpaceCreateDeviceGray()
            if let bitmapRef = CGContext(data: nil,
                    width: bitmapWidth,
                    height: bitmapHeight,
                    bitsPerComponent: 8,
                    bytesPerRow: 0,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.none.rawValue) {
                let context = CIContext(options: nil)

                if let image = outputImg {
                    if let bitmapImage = context.createCGImage(image, from: rect) {
                        bitmapRef.interpolationQuality = .none
                        bitmapRef.scaleBy(x: scale, y: scale)
                        bitmapRef.draw(bitmapImage, in: rect)

                        // 2.保存bitmap图片
                        if let scaledImage = bitmapRef.makeImage() {
                            return UIImage(cgImage: scaledImage)
                        }
                    }
                }
            }
        }
        return nil
    }

    var toOCStr: NSString {
        NSString(string: self)
    }

    func xb_stringToDict() -> [String: Any] {
        let jsonData: Data = data(using: .utf8)!

        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {

            if dict is [String: Any] {
                return dict as! [String: Any]
            }
        }
        return [:]
    }

    func xb_stringToArray() -> [Any] {
        let jsonData: Data = data(using: .utf8)!

        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {

            if dict is [Any] {
                return dict as! [Any]
            }
        }
        return []
    }

    func xb_stringWidth(font: UIFont, maxHeight: CGFloat) -> CGFloat {
        let str: NSString = self as NSString
        let size = CGSize.init(width: 10000, height: maxHeight)
        let dic = [NSAttributedString.Key.font: font]
        let strSize = str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        return strSize.width
    }
    
    func stringHeight(font: UIFont, maxWidth: CGFloat = 375, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let size = calculateSize(font: font, maxWidth: maxWidth, maxHeight: maxHeight)
        return size.height
    }
    
    private func calculateSize(font: UIFont, maxWidth: CGFloat = 375, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        let str: NSString = self as NSString
        let size = CGSize.init(width: maxWidth, height: maxHeight)
        let dic = [NSAttributedString.Key.font: font]
        let strSize = str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        return strSize
    }
}

public extension Array {
    func toJsonString() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let strJson = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return strJson ?? ""
    }
}

public extension Dictionary {
    func xb_dictToString() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let strJson = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return strJson ?? ""
    }
}

public extension Dictionary where Key == String, Value == Any {
    func xb_dictToString() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let strJson = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return strJson ?? ""
    }
}

extension TimeInterval {

    /// 将倒计时转换成字符串 XX天
    public func xb_convertTimeIntervalToString() -> String? {

        guard self >= 0 else {
            return nil
        }
        let timeInterval = Int(self)
        let d = (timeInterval / 3600) / 24
        let h = (timeInterval / 3600) % 24
        let m = (timeInterval % 3600) / 60
        let s = (timeInterval % 3600) % 60

        var time = ""

        if d >= 1 {
            if h > 0 {
                time = String(format: "%d天%d小时", d, h)
            } else {
                time = String(format: "%d天", d)
            }
        } else if h >= 1 {
            time = String(format: "%d小时%d分", h, m)
        } else if m > 0 {
            time = String(format: "%d分钟%d秒", m, s)
        } else {
            time = String(format: "%d秒", s)
        }
        return time
    }

    public func xb_strFromFormat(_ formatStr: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return date.xb_strFromFormat(formatStr)
    }

    public func xb_strToOtherTime(_ other: TimeInterval) -> String {

        let thisDate = Date(timeIntervalSince1970: self)
        let otherDate = Date(timeIntervalSince1970: other)

        if other == 0 {
            let thisStr = thisDate.xb_strFromFormat("MM月dd日 EEE HH:mm")
            return thisStr
        }

        let thisStr1 = thisDate.xb_strFromFormat("yyyy年MM月")
        let otherStr1 = otherDate.xb_strFromFormat("yyyy年MM月")

        if thisStr1 != otherStr1 {
            /// 不同月
            let thisStr3 = thisDate.xb_strFromFormat("MM月dd日 EEE HH:mm")
            let otherStr3 = otherDate.xb_strFromFormat("MM月dd日 EEE HH:mm")

            return thisStr3 + "-" + otherStr3
        } else {
            /// 同月
            let thisStr2 = thisDate.xb_strFromFormat("MM月dd日")
            let otherStr2 = otherDate.xb_strFromFormat("MM月dd日")

            if thisStr2 != otherStr2 {
                /// 不同日
                let thisStr3 = thisDate.xb_strFromFormat("MM月dd日 EEE HH:mm")
                let otherStr3 = otherDate.xb_strFromFormat("dd日 EEE HH:mm")

                return thisStr3 + "-" + otherStr3
            } else {
                /// 同日
                let thisStr3 = thisDate.xb_strFromFormat("MM月dd日 EEE HH:mm")
                let otherStr3 = otherDate.xb_strFromFormat("HH:mm")

                return thisStr3 + "-" + otherStr3
            }
        }
    }

    /// 临时班课的时间
    public func xb_temp_class_course_timeTo(_ other: TimeInterval) -> String {

        let thisDate = Date(timeIntervalSince1970: self)
        let otherDate = Date(timeIntervalSince1970: other)

        if other == 0 {
            let thisStr = thisDate.xb_strFromFormat("MM月dd日 EEE HH:mm")
            return thisStr
        }

        /// 同日
        let thisStr3 = thisDate.xb_strFromFormat("MM月dd日 EEE HH:mm")
        let otherStr3 = otherDate.xb_strFromFormat("HH:mm")

        return thisStr3 + "-" + otherStr3
    }

    /// 系列班课的时间
    public func xb_series_class_course_timeTo(_ other: TimeInterval) -> String {

        let thisDate = Date(timeIntervalSince1970: self)
        let otherDate = Date(timeIntervalSince1970: other)

        if other == 0 {
            let thisStr = thisDate.xb_strFromFormat("yyyy年MM月dd日 EEE HH:mm")
            return thisStr
        }

        /// 不同日
        let thisStr3 = thisDate.xb_strFromFormat("yyyy年MM月dd日")
        let otherStr3 = otherDate.xb_strFromFormat("yyyy年MM月dd日")

        return thisStr3 + "-" + otherStr3
    }
}

extension Date {
    public func xb_strFromFormat(_ formatStr: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formatStr
        let str = dateFormatter.string(from: self)
        return str
    }
}

@objc extension UIResponder {
    open func onTapCellChild(with key: String, and data: Any?) {
        next?.onTapCellChild(with: key, and: data)
    }
}

public extension CGFloat {
    var w: CGFloat {
        if UIScreen.mainWidth > UIScreen.mainHeight {
            return self / 667.0 * UIScreen.mainWidth
        }
        return self / 375.0 * UIScreen.mainWidth
    }

    var h: CGFloat {
        if UIScreen.mainWidth < UIScreen.mainHeight {
            return self / 375.0 * UIScreen.mainWidth
        }
        return self / 667.0 * UIScreen.mainHeight
    }
}

public extension UIImage {

    func rotate(orientation: Orientation) -> UIImage? {
        if let cg = cgImage {
            let flipImg = UIImage(cgImage: cg, scale: scale, orientation: orientation)
            return flipImg
        }

        return self
    }

    func decodeCompletion(completion: ((String?, NSError?) -> Void)?) {
        guard let imageData = pngData(),
              let ciImage = CIImage.init(data: imageData) else {
            return
        }
        // 从选中的图片中读取二维码数据
        // 创建一个探测器
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])

        // 利用探测器探测数据
        guard let feature = detector?.features(in: ciImage),
              feature.count != 0 else {
            completion?(nil, NSError(domain: "error.qr.com", code: -1, userInfo: nil))
            return
        }

        // 取出探测到的数据
        for result in feature {
            if let res = result as? CIQRCodeFeature {
                let urlStr = res.messageString
                completion?(urlStr, nil)
            }
        }
    }
}

@objc extension UIViewController {
    open func shouldShutDownChilds() {

        /// 当前控制器释放
        doShutDown()
        /// 当前 View 释放
        if view != nil {
            view.shouldShutDownChilds()
        }
        /// 让子控制器也释放
        for child in children {
            child.shouldShutDownChilds()
        }
    }

    open func doShutDown() {
    }
}

@objc extension UIView {
    open func shouldShutDownChilds() {
        /// 当前 View 释放
        doShutDown()

        /// 让子控制器也释放
        for child in subviews {
            child.shouldShutDownChilds()
        }
    }

    open func doShutDown() {
    }
}

@objc extension UIResponder {
    open func shouldDoSomething(key: String, data: Any?) {
        next?.shouldDoSomething(key: key, data: data)
    }
}

public func debugDo(schedue: (() -> Void)?) {
    #if DEBUG
    schedue?()
    #endif
}

public extension Int {
    var int32: Int32 {
        Int32(self)
    }

    var int64: Int64 {
        Int64(self)
    }
}

public extension URL {
    var duration: Double {
        let urlAsset = AVURLAsset(url: self, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(booleanLiteral: true)])
        let duration = urlAsset.duration.seconds
        return duration
    }
}

private var kIndicator: Void?

extension UIView {

    private var indicator: UIActivityIndicatorView {
        get {
            guard let view = objc_getAssociatedObject(self, &kIndicator) as? UIActivityIndicatorView else {
                let v = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                v.hidesWhenStopped = true

                objc_setAssociatedObject(self, &kIndicator, v, .OBJC_ASSOCIATION_RETAIN)

                if let superView = superview {
                    superView.addSubview(v)
                    v.snp.makeConstraints {
                        $0.center.equalTo(self)
                    }
                } else {
                    addSubview(v)
                    v.snp.makeConstraints {
                        $0.center.equalToSuperview()
                    }
                }

                return v
            }

            return view
        }
    }

    public func startLoading() {
        indicator.startAnimating()
    }

    public func endLoading() {
        indicator.stopAnimating()
    }
}
