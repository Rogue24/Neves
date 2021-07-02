//
//  FileEffectViewController.swift
//  Neves_Example
//
//  Created by aa on 2020/10/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class FileEffectViewController: TestBaseViewController {

    var animView1: AnimationView!
    var animView2: AnimationView!
    var animView3: AnimationView!
    
    var fwCtr: FireworkController!
    
    @IBOutlet weak var box: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = PortraitScreenBounds
        
//        let w: CGFloat = 65
//        let h: CGFloat = w * (200.0 / 65.0)
//
//        let dic = ["img_0.png": UIImage(named: "jp_icon")!]
//
//        let filepath1 = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/fire_lottie2")!
//        let path1 = URL(fileURLWithPath: filepath1).deletingLastPathComponent().path
//        let imageProvider1 = ExtendedFilepathImageProvider(filepath: path1, imageReplacement: dic)
//        animView1 = AnimationView(filePath: filepath1, imageProvider: imageProvider1)
//        animView1.backgroundColor = .randomColor()
//        animView1.size = .init(width: w, height: h)
//        view.addSubview(animView1)
//        animView1.right = 10
//        animView1.bottom = 80
//
//        let filepath2 = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/fire_lottie3")!
//        let path2 = URL(fileURLWithPath: filepath2).deletingLastPathComponent().path
//        let imageProvider2 = ExtendedFilepathImageProvider(filepath: path2, imageReplacement: dic)
//        animView2 = AnimationView(filePath: filepath2, imageProvider: imageProvider2)
//        animView2.backgroundColor = .randomColor()
//        animView2.size = .init(width: w, height: h)
//        view.addSubview(animView2)
//        animView2.x = 10
//        animView2.bottom = 80
        
        let operationView = UIView()
        operationView.backgroundColor = .randomColor
        view.addSubview(operationView)
        operationView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 100, height: 100))
            $0.right.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview().offset(-50)
        }
        
        fwCtr = FireworkController()
        fwCtr.setupFireworkView(onView: view, operationView: operationView, isMinigameMode: true)
//        fwCtr.fwView.backgroundColor = .randomColor()
//        view.addSubview(fwCtr.fwView)
//        fwCtr.fwView.snp.makeConstraints {
//            $0.width.equalTo(w)
//            $0.height.equalTo(h)
//            $0.top.equalTo(animView1)
//            $0.centerX.equalTo(view)
//        }
        
        box.backgroundColor = .randomColor
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat]) {
            self.box.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        } completion: { _ in
            
        }
    }
    
    deinit {
        JPrint("死了！")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        fwCtr.addModels([FireworkModel(Double(JPRandomNumber(10, 40)))])
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        fwCtr.stopAll()
        fwCtr.stopAll()
    }
    
    @IBAction func start1(_ sender: Any) {
//        animView1.play()
        
//        fwView.launch()
        
        fwCtr.updateModels([UU_FireworkLauncherInfo(uid: 123, remainSeconds: 600, totalTime: 600, holdAmount: 1000, targetAmount: 2000, gotNum: 1),
                            UU_FireworkLauncherInfo(uid: 456, remainSeconds: 600, totalTime: 600, holdAmount: 1000, targetAmount: 2000, gotNum: 1),
                            UU_FireworkLauncherInfo(uid: 789, remainSeconds: 600, totalTime: 600, holdAmount: 1000, targetAmount: 2000, gotNum: 1),
                            UU_FireworkLauncherInfo(uid: 101, remainSeconds: 600, totalTime: 600, holdAmount: 1000, targetAmount: 2000, gotNum: 1)])
    }

    @IBAction func start2(_ sender: Any) {
//        animView2.play()
        
//        fwView.quit()
    }
    
    var isMinigameMode = false
    
    @IBAction func start3(_ sender: Any) {
//        animView3.play()
        
//        fwView.switchItem()
        
    }
    
    @IBAction func openList(_ sender: Any) {
//        FireworkPopView.show()
        
        isMinigameMode = !isMinigameMode
        fwCtr.updateLayout(isMinigameMode)
    }
    
    @IBAction func startFire(_ sender: Any) {
//        fwCtr.addModels([FireworkModel(Double(JPRandomNumber(10, 40)))])
        
//        animView3.play()
        
        let filepath1 = Bundle.main.path(forResource: "appgift_30128", ofType: nil, inDirectory: "lottie")!
        let filepath2 = Bundle.main.path(forResource: "appgift_fire", ofType: nil, inDirectory: "lottie")!
        let filepath3 = Bundle.main.path(forResource: "album_dialog_bg_lottie", ofType: nil, inDirectory: "lottie")!
        let filepath4 = Bundle.main.path(forResource: "album_sing_bg_lottie", ofType: nil, inDirectory: "lottie")!
        AsyncDecodeAnimationView.playAnimation(withFilePaths: [filepath1, filepath2, filepath3, filepath4], insertToSuperview: view, at: 0) {
            JPrint("搞完")
        }
    }
    
    @IBAction func startFire2(_ sender: Any) {
        let filepath1 = Bundle.main.path(forResource: "appgift_30128", ofType: nil, inDirectory: "lottie")!
        let filepath2 = Bundle.main.path(forResource: "appgift_fire", ofType: nil, inDirectory: "lottie")!
        let filepath3 = Bundle.main.path(forResource: "album_dialog_bg_lottie", ofType: nil, inDirectory: "lottie")!
        let filepath4 = Bundle.main.path(forResource: "album_sing_bg_lottie", ofType: nil, inDirectory: "lottie")!
        AsyncDecodeAnimationView.syncPlayAnimation(withFilePaths: [filepath1, filepath2, filepath3, filepath4], insertToSuperview: view, at: 0) {
            JPrint("搞完")
        }
    }
}
