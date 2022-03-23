//
//  TestView.swift
//  Neves
//
//  Created by 周健平 on 2022/2/13.
//
//  https://blog.csdn.net/xiaoxiaobukuang/article/details/51594157

import CoreGraphics

class TestView: UIView {
    
    let angle1: CGFloat = 240
    let clockwise = true
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        JPrint("调用了【drawRect】")
        
        // 画布
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        for i in 0 ..< Int(angle1) {
            
        }
        
//        // 渐变色
//        const CGFloat *startColorComponents = CGColorGetComponents(_startColor.CGColor);
//        const CGFloat *endColorComponents = CGColorGetComponents(_endColor.CGColor);
        
//        for (int i=0; i<_angle; i++) {
//            CGFloat ratio = (_clockwise?(_angle-i):i)/_angle;
//            CGFloat r = startColorComponents[0] - (startColorComponents[0]-endColorComponents[0])*ratio;
//            CGFloat g = startColorComponents[1] - (startColorComponents[1]-endColorComponents[1])*ratio;
//            CGFloat b = startColorComponents[2] - (startColorComponents[2]-endColorComponents[2])*ratio;
//            CGFloat a = startColorComponents[3] - (startColorComponents[3]-endColorComponents[3])*ratio;
//
//            // 画扇形
//            CGContextSetFillColorWithColor(context, DDYColor(r, g, b, a).CGColor);
//            CGContextSetLineWidth(context, 0);
//            CGContextMoveToPoint(context, self.center.x, self.center.y);
//            CGContextAddArc(context, self.center.x, self.center.y, _radius,  i*M_PI/180, (i + (_clockwise?-1:1))*M_PI/180, _clockwise);
//            CGContextDrawPath(context, kCGPathFillStroke);
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        JPrint("调用了【layoutSubviews】")
    }
    
}
