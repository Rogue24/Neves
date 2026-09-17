//
//  EMLUserTitleCellModel.swift
//  Falla
//
//  Created by aa on 2025/6/10.
//

import UIKit

protocol EMLUserTitleCellModel {
    var aspectRatio: CGFloat { get }
    var source: SVGAExImageView.Source { get }
    var jumpUrl: String { get }
}

extension EMLUserTitleFlowView {
    struct CellModel: EMLUserTitleCellModel {
        var frame: CGRect
        let source: SVGAExImageView.Source
        let jumpUrl: String
        
        var aspectRatio: CGFloat {
            guard frame.width > 0, frame.height > 0 else { return 0 }
            return frame.width / frame.height
        }
    }
}

extension EMLProfileTitlesResourcesItemModel: EMLUserTitleCellModel {
    var aspectRatio: CGFloat {
        guard weight > 0, height > 0 else { return 0 }
        return CGFloat(weight) / CGFloat(height)
    }
    
    var source: SVGAExImageView.Source {
        if resourceUrl.hasSuffix(".svga") {
            return .svga(resourceUrl)
        } else {
            return .remote(resourceUrl, false, effectType == 1)
        }
    }
}
