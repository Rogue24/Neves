//
//  FireLottieTestViewController.swift
//  Neves
//
//  Created by aa on 2020/11/3.
//

class FireLottieTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func syncAction(_ sender: Any) {
        
//        let filepath = Bundle.main.path(forResource: "appgift_fire", ofType: nil, inDirectory: "lottie")!
        let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/appgift_fire/appgift_fire_animation")!
        
        let animView = LottieAnimationView.jp.build(at: filepath)
        animView.frame = PortraitScreenBounds
        animView.contentMode = .scaleToFill
        view.addSubview(animView)
        
        animView.play { [weak animView] _ in
            animView?.removeFromSuperview()
        }
        
    }
    
    @IBAction func asyncAction(_ sender: Any) {
        
    }
}
