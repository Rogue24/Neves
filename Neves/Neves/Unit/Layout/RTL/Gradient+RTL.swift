//
//  Gradient+RTL.swift
//  Neves
//
//  Created by aa on 2023/11/22.
//

import UIKit

extension GradientView {
    func rtl_set(startPoint: CGPoint, endPoint: CGPoint) {
        guard isRTL else {
            self.startPoint = startPoint
            self.endPoint = endPoint
            return
        }
        self.startPoint = [endPoint.x, startPoint.y]
        self.endPoint = [startPoint.x, endPoint.y]
    }
}

extension CAGradientLayer {
    func rtl_set(startPoint: CGPoint, endPoint: CGPoint) {
        guard isRTL else {
            self.startPoint = startPoint
            self.endPoint = endPoint
            return
        }
        self.startPoint = [endPoint.x, startPoint.y]
        self.endPoint = [startPoint.x, endPoint.y]
    }
}
