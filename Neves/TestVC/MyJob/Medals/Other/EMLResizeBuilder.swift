//
//  EMLResizeBuilder.swift
//  Neves
//
//  Created by aa on 2025/8/15.
//

import UIKit

struct EMLResizeBuilder {
    private let url: String
    private var size: CGSize
    private var scale: Int = Int(UIScreen.main.scale)
    private var mode: EMLResizeMode = EMLResizeMode_fill

    init(url: String, size: CGSize = .zero) {
        self.url = url
        self.size = size
    }

    func size(_ w: CGFloat, _ h: CGFloat) -> Self {
        var copy = self
        copy.size = CGSizeMake(w, h)
        return copy
    }
    
    func size(_ s: CGSize) -> Self {
        var copy = self
        copy.size = s
        return copy
    }
    
    func scale(_ s: Int) -> Self {
        var copy = self
        copy.scale = s
        return copy
    }
    
    func scale(_ s: CGFloat) -> Self {
        var copy = self
        copy.scale = Int(s)
        return copy
    }
    
    func mode(_ m: EMLResizeMode) -> Self {
        var copy = self
        copy.mode = m
        return copy
    }
    
    func mode(_ m: UInt) -> Self {
        var copy = self
        copy.mode = EMLResizeMode(rawValue: m)
        return copy
    }

    func build() -> String {
        (url as NSString).resizeQuality(
            withCustomSize: size,
            scale: scale,
            mode: mode
        )
    }
}

extension String {
    var rq: EMLResizeBuilder { .init(url: self) }
    
    var rq_20x20: String {
        EMLResizeBuilder(
            url: self,
            size: CGSizeMake(20, 20)
        ).build()
    }

    var rq_40x40: String {
        EMLResizeBuilder(
            url: self,
            size: CGSizeMake(40, 40)
        ).build()
    }

    var rq_80x80: String {
        EMLResizeBuilder(
            url: self,
            size: CGSizeMake(80, 80)
        ).build()
    }
    
    var rq_100x100: String {
        EMLResizeBuilder(
            url: self,
            size: CGSizeMake(100, 100)
        ).build()
    }
}
