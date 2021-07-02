//
//  LottieTestViewController.swift
//  Neves
//
//  Created by aa on 2020/11/3.
//

class LottieTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func syncAction(_ sender: Any) {
        
        let filepath = Bundle.main.path(forResource: "appgift_fire", ofType: nil, inDirectory: "lottie")!
        let animView = AnimationView.jp.build(filepath)
        animView.frame = PortraitScreenBounds
        animView.contentMode = .scaleToFill
        view.addSubview(animView)
        
        animView.play { _ in
            animView.removeFromSuperview()
        }
        
    }
    
    @IBAction func asyncAction(_ sender: Any) {
        
    }
}
