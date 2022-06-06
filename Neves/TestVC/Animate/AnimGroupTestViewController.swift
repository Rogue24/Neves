//
//  AnimGroupTestViewController.swift
//  Neves
//
//  Created by aa on 2022/6/6.
//

class AnimGroupTestViewController: TestBaseViewController {
    
    let box = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        box.backgroundColor = UIColor.randomColor.cgColor
        box.frame = [20, 150, 100, 100]
        view.layer.addSublayer(box)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addFunAction { [weak self] in
            guard let self = self else { return }
            
            let anim1 = CABasicAnimation(keyPath: "transform.scale")
            anim1.toValue = CGPoint(x: 1.5, y: 1.5)
            
            let anim2 = CABasicAnimation(keyPath: "transform.rotation.z")
            anim2.toValue = CGFloat.pi * 0.25
            
            let anim3 = CABasicAnimation(keyPath: "transform.translation")
            anim3.toValue = CGPoint(x: 150, y: 150)
            
            anim1.beginTime = 0
            anim1.duration = 3
            anim1.isRemovedOnCompletion = false
            anim1.fillMode = .forwards
            
            anim2.beginTime = 0
            anim2.duration = 3
            anim2.isRemovedOnCompletion = false
            anim2.fillMode = .forwards
            
            anim3.beginTime = 2
            anim3.duration = 3
            anim3.isRemovedOnCompletion = false
            anim3.fillMode = .forwards
            
            // 不管子anim怎么设置，动画的时长（beginTime、duration）都由CAAnimationGroup来决定，时间一到就停止，即便子anim还没执行完
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2, anim3]
            animGroup.beginTime = CACurrentMediaTime() + 1
            animGroup.duration = 1
            animGroup.isRemovedOnCompletion = false
            animGroup.fillMode = .forwards
            
            self.box.add(animGroup, forKey: "animGroup")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }

}
