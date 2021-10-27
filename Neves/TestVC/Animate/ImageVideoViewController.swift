//
//  ImageVideoViewController.swift
//  Neves
//
//  Created by aa on 2021/10/19.
//

import UIKit
import AVKit

class ImageVideoViewController: TestBaseViewController {
    
    static var videoPath: String? = nil
    
    let frameInterval: Int = 24
    let size: CGSize = [720, 720]
    
    let duration: TimeInterval = 0.6
    let anim1Duration: TimeInterval = 6
    let anim2Duration: TimeInterval = 8
    let anim3Duration: TimeInterval = 5//17
    lazy var totalDuration: TimeInterval = anim1Duration + anim2Duration + anim3Duration
    
    let bgView = UIView()
    
    lazy var solitaireView = SolitaireCalculationView(frameInterval: frameInterval)
    lazy var solitaireLayer = SolitaireAnimationLayer()
    
    var isMaking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgImageView = UIImageView(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "girl", ofType: "jpg")!))
        bgImageView.frame.size = size
        bgImageView.contentMode = .scaleAspectFill
        
        let lottieBgImgView = UIImageView(image: UIImage(named: "album_videobg_jielong"))
        lottieBgImgView.frame.size = size
        lottieBgImgView.contentMode = .scaleAspectFill
        
        bgView.clipsToBounds = true
        bgView.frame.size = size
        bgView.addSubview(bgImageView)
        bgView.addSubview(lottieBgImgView)
        
        let btn3 = UIButton(type: .system)
        btn3.titleLabel?.font = .systemFont(ofSize: 15)
        btn3.setTitle("制作视频", for: .normal)
        btn3.setTitleColor(.randomColor, for: .normal)
        btn3.backgroundColor = .randomColor
        btn3.frame = [100, 120, 80, 40]
        btn3.addTarget(self, action: #selector(makeVideo), for: .touchUpInside)
        view.addSubview(btn3)
        
        let btn4 = UIButton(type: .system)
        btn4.titleLabel?.font = .systemFont(ofSize: 15)
        btn4.setTitle("播放视频", for: .normal)
        btn4.setTitleColor(.randomColor, for: .normal)
        btn4.backgroundColor = .randomColor
        btn4.frame = [100, 180, 80, 40]
        btn4.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        view.addSubview(btn4)
        
        let textView = UITextView(frame: [70, 300, 270, 170])
        textView.backgroundColor = .randomColor
        textView.textColor = .randomColor
        textView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        view.addSubview(textView)
        
    }
    
    
    @objc func makeVideo() {
        guard !isMaking else {
            JPrint("已经在制作！别动！")
            return
        }
        
        JPrint("开始制作！")
        isMaking = true
        
        let audioPath = Bundle.main.path(forResource: "Matteo-Panama", ofType: "mp3")
        let animLayer = solitaireLayer
        
        JPProgressHUD.show(true)
        Asyncs.async {
            guard let store1 = LottieImageStore.createStore(configure: LottieImageStore.Configure(lottieName: "album_videobg_jielong_lottie", imageSize: self.size)) else {
                Asyncs.main {
                    JPrint("失败！")
                    JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
                    self.isMaking = false
                }
                return
            }
            
            guard let store2 = LottieImageStore.createStore(configure: LottieImageStore.Configure(lottieName: "video_tx_jielong_lottie", imageSize: self.size, lottieSize: [220, 220]) { [374, 250, $1.width, $1.height] }) else {
                Asyncs.main {
                    JPrint("失败！")
                    JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
                    self.isMaking = false
                }
                return
            }
            
//            VideoMaker.makeVideoTest(framerate: self.frameInterval,
            VideoMaker.makeVideo(framerate: self.frameInterval,
                                 frameInterval: self.frameInterval,
                                 duration: self.totalDuration,
                                 size: self.size,
                                 audioPath: audioPath,
                                 animLayer: animLayer,
                                 imageStores: [store1, store2]) { result in
                switch result {
                case let .success(path):
                    JPProgressHUD.showSuccess(withStatus: "成功！", userInteractionEnabled: true)
                    
                    File.manager.deleteFile(Self.videoPath)
                    Self.videoPath = path
                    JPrint("成功！视频路径", path)
                    
                case .failure:
                    JPrint("失败！")
                    JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
                }
                
                self.isMaking = false
            }
        }
    }
    
    @objc func playVideo() {
        guard !isMaking else {
            JPrint("已经在制作！别动！")
            return
        }
        
        guard let videoPath = Self.videoPath else {
            JPProgressHUD.showError(withStatus: "木有视频！", userInteractionEnabled: true)
            return
        }
        
        Play(videoPath)
    }
}

