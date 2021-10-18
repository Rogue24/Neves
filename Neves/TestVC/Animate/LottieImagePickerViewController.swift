//
//  LottieImagePickerViewController.swift
//  Neves
//
//  Created by aa on 2021/10/14.
//

class LottieImagePickerViewController: TestBaseViewController {
    
    var animView: AnimationView!
    
    var picker: LottieImagePicker?
    
    var isPicking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Asyncs.async {
            let lottieName = "fire_lottie2"
    //        let lottieName = "album_videobg_jielong_lottie"
//            let lottieName = "album_sing_bg_lottie"
//            let lottieName = "cube_s_lottie"
//            let lottieName = "video_tx_jielong_lottie"
//            let lottieName = "album_videobg_jielong_lottie"
            
            guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/\(lottieName)"),
                  let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
            else {
                JPrint("路径错误！")
                return
            }
            
            guard let picker = LottieImagePicker(lottieName: lottieName,
                                                 bgColor: .clear,
                                                 animSize: [720, 720])
            else {
                JPrint("创建失败")
                return
            }
            JPrint("创建成功")
            self.picker = picker
            
            let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
            
            Asyncs.main {
                
                let animView = AnimationView(animation: animation, imageProvider: provider)
                animView.backgroundColor = .black
                animView.frame = [HalfDiffValue(PortraitScreenWidth, 300), NavTopMargin + 20, 300, 300]
                animView.contentMode = .scaleAspectFit
                animView.loopMode = .loop
                self.view.addSubview(animView)
                animView.play()
                self.animView = animView
                
                
                let s: CGFloat = 5
                let x: CGFloat = 15
                let y = animView.maxY + 20
                let w = (PortraitScreenWidth - 2 * x - 3 * s) / 4
                let h: CGFloat = 50
                
                let btn1 = UIButton(type: .system)
                btn1.titleLabel?.font = .systemFont(ofSize: 20)
                btn1.setTitle("提取全部", for: .normal)
                btn1.setTitleColor(.randomColor, for: .normal)
                btn1.backgroundColor = .randomColor
                btn1.frame = [x, y, w, h]
                btn1.addTarget(self, action: #selector(LottieImagePickerViewController.pickImages), for: .touchUpInside)
                self.view.addSubview(btn1)
                
                let btn2 = UIButton(type: .system)
                btn2.titleLabel?.font = .systemFont(ofSize: 20)
                btn2.setTitle("清空图片", for: .normal)
                btn2.setTitleColor(.randomColor, for: .normal)
                btn2.backgroundColor = .randomColor
                btn2.frame = [x + s + w, y, w, h]
                btn2.addTarget(self, action: #selector(LottieImagePickerViewController.deleteImages), for: .touchUpInside)
                self.view.addSubview(btn2)
                
                let btn3 = UIButton(type: .system)
                btn3.titleLabel?.font = .systemFont(ofSize: 20)
                btn3.setTitle("创建视频", for: .normal)
                btn3.setTitleColor(.randomColor, for: .normal)
                btn3.backgroundColor = .randomColor
                btn3.frame = [x + 2 * (s + w), y, w, h]
                btn3.addTarget(self, action: #selector(LottieImagePickerViewController.createVideo), for: .touchUpInside)
                self.view.addSubview(btn3)
                
            }
        }
    }


    @objc func pickImages() {
        guard !isPicking, let picker = self.picker else {
            return
        }
        
        isPicking = true
        
        JPProgressHUD.show()
        picker.asyncPickAllImages(framerate: nil, directoryPath: "/Users/aa/Desktop/LottieTest/Images/") { isSuccess in
            if isSuccess {
                JPProgressHUD.showSuccess(withStatus: "成功！", userInteractionEnabled: true)
            } else {
                JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
            }
            self.isPicking = false
        }
        
        
    }
    
    @objc func deleteImages() {
        File.manager.deleteFile("/Users/aa/Desktop/LottieTest/Images/")
        
    }
    
    @objc func createVideo() {
        guard !isPicking, let picker = self.picker else {
            return
        }
        
        isPicking = true
        JPProgressHUD.show()
        
        let maker = VideoMaker()
        maker.makeVideo(with: picker) { result in
            switch result {
            case let .success(path):
                JPProgressHUD.showSuccess(withStatus: "成功！", userInteractionEnabled: true)
                JPrint("视频路径", path)
            case .failure:
                JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
            }
            self.isPicking = false
        }
        
    }
}
