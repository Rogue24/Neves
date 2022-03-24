//
//  DrawRectTestViewController.swift
//  Neves
//
//  Created by aa on 2022/3/24.
//
//  参考：https://blog.csdn.net/xiaoxiaobukuang/article/details/51594157

class DrawRectTestViewController: TestBaseViewController {
    
    let slider = UISlider()
    let testView = TestView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.frame = [30, UIScreen.mainHeight - 100 - 40, UIScreen.mainWidth - 60, 20]
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        testView.frame = [100, 400, 100, 100]
        testView.backgroundColor = .randomColor
        view.addSubview(testView)
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let diff = CGFloat(slider.value)
        
        testView.frame.origin = [100 + diff, 400 + diff]
        testView.setNeedsLayout()
    }
    
    
    class TestView: UIView {
        
        let angle1: CGFloat = 240
        let clockwise = true
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            JPrint("调用了【drawRect】")
            
            // 画布
//            guard let ctx = UIGraphicsGetCurrentContext() else { return }
//
//            for i in 0 ..< Int(angle1) {
//
//            }
            
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
}
