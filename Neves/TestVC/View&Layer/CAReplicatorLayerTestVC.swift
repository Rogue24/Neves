//
//  CAReplicatorLayerTestVC.swift
//  Neves
//
//  Created by aa on 2022/5/6.
//

class CAReplicatorLayerTestVC: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicAnimation()
        dotLoading()
    }
    
    func musicAnimation() {
        // 创建replicatorLayer
        let replicatorLayer = CAReplicatorLayer()
        let height: CGFloat = 230
        replicatorLayer.frame = CGRect(x: HalfDiffValue(PortraitScreenWidth, height), y: NavTopMargin + 20, width: height, height: height)
        replicatorLayer.backgroundColor = UIColor.gray.cgColor
        view.layer.addSublayer(replicatorLayer)

        // 创建音量条
        let volumeLayer = CALayer()
        volumeLayer.backgroundColor = UIColor.cyan.cgColor
        let volumeWidth: CGFloat = 30
        volumeLayer.bounds = CGRect(x: 0, y: 0, width: volumeWidth, height: 100);
        volumeLayer.anchorPoint = CGPoint(x: 0, y: 1)
        volumeLayer.position = CGPoint(x: 0, y: height)
//        view.layer.addSublayer(volumeLayer)

        // 对音量条添加动画
        let animation = CABasicAnimation(keyPath: "transform.scale.y")
        animation.toValue = 0
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        volumeLayer.add(animation, forKey: nil)

        replicatorLayer.addSublayer(volumeLayer)

        // 设置音量条个数
        replicatorLayer.instanceCount = 6
        // 设置延时
        replicatorLayer.instanceDelay = 0.35
        // 设置透明度递减
        replicatorLayer.instanceAlphaOffset = -0.15
        // 对每个音量震动条移动40
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(volumeWidth + 10, 0, 0)
    }
    
    func dotLoading() {
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        replicatorLayer.position = [view.center.x, view.center.y + 100]
        view.layer.addSublayer(replicatorLayer)

        // 添加小圆点
        let dotLayer = CALayer()
        dotLayer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        dotLayer.position = CGPoint(x: 50, y: 20)
        dotLayer.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.6).cgColor
        dotLayer.cornerRadius = 5;
        dotLayer.masksToBounds = true
        replicatorLayer.addSublayer(dotLayer)
        // 解决最开始旋转衔接效果
        dotLayer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
        
        // 添加缩放动画
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 1
        animation.fromValue = 1
        animation.toValue = 0.1
        animation.repeatCount = Float.infinity
        dotLayer.add(animation, forKey: nil)

        // 设置个数
        let count = 12
        replicatorLayer.instanceCount = count
        // 每次旋转的角度等于 2π / 12
        replicatorLayer.instanceTransform = CATransform3DMakeRotation((2 * CGFloat.pi) / CGFloat(count) , 0, 0, 1)
        // 添加延迟
        replicatorLayer.instanceDelay = CFTimeInterval(1.0 / CGFloat(count))
    }
}
