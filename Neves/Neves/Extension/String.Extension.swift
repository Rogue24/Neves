//
//  String.Extension.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension String: JPCompatible {}
extension NSString: JPCompatible {}

func hasPrefix(_ prefix: String) -> ((String) -> Bool) { { $0.hasPrefix(prefix) } }
func hasSuffix(_ suffix: String) -> ((String) -> Bool) { { $0.hasSuffix(suffix) } }

extension String {
    static func ~= (pattern: (String) -> Bool, value: String) -> Bool {
        pattern(value)
    }
}

extension String {
    subscript(r: Range<Int>) -> String {
        let lower: Range<Int>.Bound = max(0, min(count, r.lowerBound))
        let upper: Range<Int>.Bound = min(count, max(0, r.upperBound))
        let range = Range(uncheckedBounds: (lower, upper))
        
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    subscript(i: Int) -> String {
        self[i ..< (i + 1)]
    }
    
    func substring(from i: Int) -> String {
        self[min(i, count) ..< count]
    }
    
    func substring(to i: Int) -> String {
        self[0 ..< max(0, i)]
    }
    
    func substring(at i: Int) -> String {
        self[i]
    }
}

extension JP where Base: ExpressibleByStringLiteral {
    var isContainsChinese: Bool {
        if let str = base as? NSString {
            for i in 0..<str.length {
                let a = str.character(at: i)
                if a > 0x4e00, a < 0x9fff {
                    return true
                }
            }
        }
        return false
    }
    
    func textSize(withFont font: UIFont,
                  lineSpace: CGFloat = 0,
                  isOneLine: inout Bool,
                  maxSize: CGSize) -> CGSize {
        
        guard let str = base as? NSString else { return .zero }
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = font
        
        if lineSpace > 0 {
            let parag = NSMutableParagraphStyle()
            parag.lineSpacing = lineSpace
            attributes[.paragraphStyle] = parag
        }
        
        var rect = str.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        // 文本的高度 - 字体高度 > 行间距 -----> 判断为当前超过1行
        let isMoreThanOneLine = (rect.size.height - font.lineHeight) > lineSpace
        if !isMoreThanOneLine, self.isContainsChinese {
            rect.size.height -= lineSpace
        }
        
        if rect.size.height > 0, rect.size.height < font.lineHeight {
            rect.size.height = font.lineHeight
        }
        
        isOneLine = !isMoreThanOneLine
        return rect.size
    }
    
    func textSize(withFont font: UIFont,
                  lineSpace: CGFloat = 0,
                  maxSize: CGSize = [9999, 9999]) -> CGSize {
        
        guard let str = base as? NSString else { return .zero }
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = font
        
        if lineSpace > 0 {
            let parag = NSMutableParagraphStyle()
            parag.lineSpacing = lineSpace
            attributes[.paragraphStyle] = parag
        }
        
        var rect = str.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        // 文本的高度 - 字体高度 > 行间距 -----> 判断为当前超过1行
        let isMoreThanOneLine = (rect.size.height - font.lineHeight) > lineSpace
        if !isMoreThanOneLine, self.isContainsChinese {
            rect.size.height -= lineSpace
        }
        
        if rect.size.height > 0, rect.size.height < font.lineHeight {
            rect.size.height = font.lineHeight
        }
        
        return rect.size
    }
    
    var isEmpty: Bool {
        guard let str = base as? NSString else { return false }
        let set = NSCharacterSet.whitespacesAndNewlines
        return str.trimmingCharacters(in: set).count == 0
    }
    
    func urlParams() -> [String: Any]? {
        guard let str = base as? String else { return nil }
        
        let arr1 = str.components(separatedBy: "?")
        guard arr1.count > 1, let allParmStr = arr1.last else { return nil }
        
        let arr2 = allParmStr.components(separatedBy: "&")
        guard arr2.count > 0 else { return nil }
        
        var params = [String: Any]()
        for parmStr in arr2 {
            let arr3 = parmStr.components(separatedBy: "=")
            if arr3.count == 2, let key = arr3.first, let value = arr3.last {
                params[key] = value
            } else {
                continue
            }
        }
        return params
    }
}

extension JP where Base == String {
    /// 从「前缀」开始获取`x`长度的子字符串
    /// 🌰🌰🌰 `Zhoujianpingisshuaige` --- 6 ---> `Zhouji`
    func prefix(_ maxLength: Int) -> String {
        String(base.prefix(maxLength))
    }
    
    /// 从「后缀」开始获取`x`长度的子字符串
    /// 🌰🌰🌰 `Zhoujianpingisshuaige` --- 6 ---> `huaige`
    func suffix(_ maxLength: Int) -> String {
        String(base.suffix(maxLength))
    }
    
    /// 仅首字母大写
    var capitalizeFirstLetter: String {
        guard let firstLetter = base.first else {
            return base
        }
        return String(firstLetter).uppercased() + base.dropFirst()
    }
    
    /// 将字符串缩至指定的最大宽度内
    /// 🌰🌰🌰 `Zhoujianpingisshuaige` --> `Zhouji...`
    func resize(within maxWidth: CGFloat, font: UIFont, omitStr: String = "...") -> String {
        guard maxWidth > 0 else { return "" }
        guard textSize(withFont: font).width > maxWidth else {
            return base
        }
        
        var omitCount = omitStr.count
        if omitCount >= base.count {
            return omitStr[0 ..< base.count]
        }
        
        var str = base[0 ..< (base.count - omitCount)] + omitStr
        var strWidth = str.jp.textSize(withFont: font).width
        while strWidth > maxWidth {
            omitCount += 1
            if omitCount >= base.count {
                str = omitStr // 全都省略了
                break
            }
            str = base[0 ..< (base.count - omitCount)] + omitStr
            strWidth = str.jp.textSize(withFont: font).width
        }
        
        return str
    }
    
    /// 只缩短指定字符串，将整体文本缩至给定的最大范围内
    /// 🌰🌰🌰
    /// ```
    /// Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to
    /// catch this in the debugger. The methods in <UIKitCore/UIView.h> may
    /// also be helpful.
    /// ```
    /// ↓↓ 只缩短`UIViewAlertForUnsatisfiableConstraints`，使其最多`2`行 ↓↓
    /// ```
    /// Make a symbolic breakpoint at UIViewAlertForUnsatis... to catch this in
    /// the debugger. The methods in <UIKitCore/UIView.h> may also be helpful.
    /// ```
    static func resize(_ str: String, inFullStr fullStr: (String) -> String,
                       maxWidth: CGFloat, maxLine: Int,
                       font: UIFont, omitStr: String = "...") -> (str: String, fullStr: String) {
        guard maxWidth > 0, maxLine > 0 else { return ("", "") }
        let maxSize: CGSize = [maxWidth, 9999]
        let fStrMaxSize: CGSize = [maxWidth, font.lineHeight * CGFloat(maxLine)] // 最多x行
        
        var kStr = str
        var fStr = fullStr(kStr)
        var fStrSize = fStr.jp.textSize(withFont: font, maxSize: maxSize)
        guard fStrSize.height > fStrMaxSize.height else {
            return (kStr, fStr)
        }
        
        var omitCount = omitStr.count
        if omitCount >= str.count {
            kStr = omitStr[0 ..< str.count]
            fStr = fullStr(kStr)
            return (kStr, fStr)
        }
        
        kStr = str[0 ..< (str.count - omitCount)] + omitStr
        fStr = fullStr(kStr)
        fStrSize = fStr.jp.textSize(withFont: font, maxSize: maxSize)
        while fStrSize.height > fStrMaxSize.height {
            omitCount += 1
            if omitCount >= str.count {
                kStr = omitStr // 全都省略了
                fStr = fullStr(kStr)
                break
            }
            kStr = str[0 ..< (str.count - omitCount)] + omitStr
            fStr = fullStr(kStr)
            fStrSize = fStr.jp.textSize(withFont: font, maxSize: maxSize)
        }
        
        return (kStr, fStr)
    }
    
    /// 获取Assets中的图片
    var image: UIImage? {
        UIImage(named: base)
    }
    
    /// 获取Assets中的图片并生成UIImageView
    var imageView: UIImageView {
        UIImageView(image: UIImage(named: base))
    }
    
    /// 转成「分:秒」格式字符串 🌰 2600 ~> 43:20
    static func formatAsMMSS(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 转成「时:分:秒」格式字符串 🌰 8000 ~> 02:13:20
    static func formatAsHHMMSS(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds) // HH:MM:SS
        } else {
            return String(format: "%02d:%02d", minutes, seconds) // MM:SS
        }
    }
    
    /// 是否MP4路径
    var isMp4Url: Bool {
        base.hasSuffix(".mp4")
    }
    
    /// 是否SVGA路径
    var isSvgaUrl: Bool {
        base.hasSuffix(".svga")
    }
    
    /// 是否远程路径
    var isRemoteUrl: Bool {
        base.hasPrefix("http://") || base.hasPrefix("https://")
    }
    
    /// 移除所有URL参数（包括 fragment）
    var removingAllURLParams: String {
        guard var components = URLComponents(string: base) else { return base }
        components.query = nil
        components.fragment = nil
        return components.string ?? base
    }
    
    /// 移除单个参数
    func removingURLParam(_ name: String) -> String {
        removingURLParams([name])
    }

    /// 移除多个参数
    func removingURLParams(_ names: [String]) -> String {
        guard names.count > 0,
              var components = URLComponents(string: base),
              let items = components.queryItems
        else {
            return base
        }
        
        components.queryItems = items.filter { !names.contains($0.name) }
        return components.string ?? base
    }
    
    /// 只保留指定参数（移除其他所有参数）
    func keepingURLParams(_ names: [String]) -> String {
        guard names.count > 0,
              var components = URLComponents(string: base),
              let items = components.queryItems
        else {
            return base
        }

        components.queryItems = items.filter { names.contains($0.name) }
        return components.string ?? base
    }
    
    /// 添加/覆盖参数；value 为空内容或 nil 时删除参数
    func addOrUpdateParam(_ key: String, _ value: String?) -> String {
        // 拆分 fragment
        let parts = base.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let urlWithoutFragment = String(parts.first ?? "")
        let fragment = parts.count > 1 ? "#" + parts[1] : ""

        // 如果没有 query
        guard let queryStart = urlWithoutFragment.firstIndex(of: "?") else {
            // value 为空内容或 nil：啥也不用加，直接返回原 url
            guard let value, !value.isEmpty else { return urlWithoutFragment + fragment }

            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return urlWithoutFragment + "?\(encodedKey)=\(encodedValue)" + fragment
        }

        // 拆分 base 与 query
        let base = String(urlWithoutFragment[..<queryStart])
        let query = String(urlWithoutFragment[urlWithoutFragment.index(after: queryStart)...])

        // 拆分所有参数
        var pairs = query.split(separator: "&").map(String.init)
        var updated = false

        for i in 0..<pairs.count {
            let kv = pairs[i].split(separator: "=", maxSplits: 1).map(String.init)
            if kv.first == key {
                updated = true
                if let value, !value.isEmpty {
                    // 覆盖
                    let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                    let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                    pairs[i] = "\(encodedKey)=\(encodedValue)"
                } else {
                    // 删除此参数
                    pairs.remove(at: i)
                }
                break
            }
        }

        // 原来没有该参数 → 需要新增
        if !updated, let value, !value.isEmpty {
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            pairs.append("\(encodedKey)=\(encodedValue)")
        }

        // 若 query 全被移除，连 ? 都不要保留
        if pairs.isEmpty {
            return base + fragment
        }

        return base + "?" + pairs.joined(separator: "&") + fragment
    }
    
    /// 获取目标参数值
    func getParam(_ key: String) -> String? {
        let parts = base.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let urlWithoutFragment = String(parts.first ?? "")
        
        // 如果没有 query
        guard let queryStart = urlWithoutFragment.firstIndex(of: "?") else {
            return nil
        }

        // 拆分 query
        let query = String(urlWithoutFragment[urlWithoutFragment.index(after: queryStart)...])

        // 拆分所有参数
        let pairs = query.split(separator: "&").map(String.init)
        
        for i in 0..<pairs.count {
            let kv = pairs[i].split(separator: "=", maxSplits: 1).map(String.init)
            if kv.first == key {
                return kv.last
            }
        }
        
        return nil
    }
}




/**
 🌰🌰🌰 removingAllURLParam 🌰🌰🌰
 let url = "https://ssr-test.zzzzjp.live/app-level/wealth400?__debug__=true&__refresh__=1760612005961&fuck=xiaotao"
  
 // 移除所有参数
 EML_DebugLog(url.jp.removingAllURLParams)
 // 👉 https://ssr-test.zzzzjp.live/app-level/wealth400
 
 // 移除单个参数
 JPrint(url.jp.removingURLParam("__debug__"))
 // 👉 https://ssr-test.zzzzjp.live/app-level/wealth400?__refresh__=1760612005961&fuck=xiaotao
 
 // 移除多个参数
 JPrint(url.jp.removingURLParams(["__refresh__", "__debug__"]))
 // 👉 https://ssr-test.zzzzjp.live/app-level/wealth400?fuck=xiaotiao
 
 // 只保留指定参数
 JPrint(url.jp.keepingURLParams(["__refresh__"]))
 // 👉 https://ssr-test.zzzzjp.live/app-level/wealth400?__refresh__=1760612005961
 
 🌰🌰🌰 addOrUpdateParam 🌰🌰🌰
 Asyncs.async {
     let url = "https://ssr-test.zzzzjp.live/app-level/wealth400?__debug__=true&__refresh__=1760612005961&fuck=xiaotao"
     let url1 = url.jp.addOrUpdateParam("__debug__", "fuck")
     let url2 = url.jp.addOrUpdateParam("__debug__", nil)
     let url3 = url.jp.addOrUpdateParam("caonima", "fuck")
     let url4 = url.jp.addOrUpdateParam("__refresh__", "")
     let url5 = url.jp.addOrUpdateParam("__debug__", nil).jp.addOrUpdateParam("__refresh__", nil).jp.addOrUpdateParam("fuck", "")
      
     JPrint("url1", url1)
     JPrint("url2", url2)
     JPrint("url3", url3)
     JPrint("url4", url4)
     JPrint("url5", url5)
     JPrint("··································")
 }
 */
