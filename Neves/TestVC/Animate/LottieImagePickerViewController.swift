//
//  LottieImagePickerViewController.swift
//  Neves
//
//  Created by aa on 2021/10/14.
//

class LottieImagePickerViewController: TestBaseViewController {
    static var videoPath: String? = nil
    
    let lottieName = "fire_lottie2"
//            let lottieName = "album_videobg_jielong_lottie"
//            let lottieName = "album_sing_bg_lottie"
//            let lottieName = "cube_s_lottie"
//            let lottieName = "video_tx_jielong_lottie"
//            let lottieName = "album_videobg_jielong_lottie"
    
    var animView: AnimationView!
    
    var picker: LottieImagePicker?
    
    var isPicking = false
    
    var s1: LottieImageStore?
    var s2: LottieImageStore?
    var s3: LottieImageStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lottieName = self.lottieName
        Asyncs.async {
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
                
                let btn4 = UIButton(type: .system)
                btn4.titleLabel?.font = .systemFont(ofSize: 15)
                btn4.setTitle("播放视频", for: .normal)
                btn4.setTitleColor(.randomColor, for: .normal)
                btn4.backgroundColor = .randomColor
                btn4.frame = [x, y + h + s, w, h]
                btn4.addTarget(self, action: #selector(LottieImagePickerViewController.playVideo), for: .touchUpInside)
                self.view.addSubview(btn4)
                
                let btn5 = UIButton(type: .system)
                btn5.titleLabel?.font = .systemFont(ofSize: 15)
                btn5.setTitle("Store存储", for: .normal)
                btn5.setTitleColor(.randomColor, for: .normal)
                btn5.backgroundColor = .randomColor
                btn5.frame = [x + s + w, y + h + s, w, h]
                btn5.addTarget(self, action: #selector(LottieImagePickerViewController.pickImagesToStore), for: .touchUpInside)
                self.view.addSubview(btn5)
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
//        File.manager.deleteFile("/Users/aa/Desktop/LottieTest/Images/")
        
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
                
                File.manager.deleteFile(Self.videoPath)
                Self.videoPath = path
                JPrint("成功！视频路径", path)
                
            case .failure:
                JPProgressHUD.showError(withStatus: "失败！", userInteractionEnabled: true)
            }
            self.isPicking = false
        }
    }
    
    @objc func playVideo() {
        guard !isPicking else {
            JPrint("已经在制作！别动！")
            return
        }

        guard let videoPath = Self.videoPath else {
            JPProgressHUD.showError(withStatus: "木有视频！", userInteractionEnabled: true)
            return
        }

        Play(videoPath)
    }
    
    @objc func pickImagesToStore() {
        JPProgressHUD.show()
        Asyncs.async {
            let directoryPath = "/Users/aa/Desktop/LottieTest/Images/"
            
            let c1 = LottieImageStore.Configure(lottieName: "album_videobg_jielong_lottie",
                                                imageSize: [720, 720])
            if let s1 = LottieImageStore.createStore(configure: c1) {
                for (currentFrame, image) in s1.imageMap {
                    var url = URL(fileURLWithPath: directoryPath)
                    url.appendPathComponent("videobg_\(currentFrame).png")

                    guard let imgData = image.pngData() else {
                        JPrint("数据错误 ---", url.path)
                        continue
                    }

                    do {
                        try imgData.write(to: url)
                    } catch {
                        JPrint("写入错误 ---", url.path)
                    }
                }
                self.s1 = s1
            }

            let c2 = LottieImageStore.Configure(lottieName: "video_tx_jielong_lottie", imageSize: [720, 720], lottieSize: [220, 220]) { [374, 250, $1.width, $1.height] }
            if let s2 = LottieImageStore.createStore(configure: c2) {
                for (currentFrame, image) in s2.imageMap {
                    var url = URL(fileURLWithPath: directoryPath)
                    url.appendPathComponent("videotx_\(currentFrame).png")

                    guard let imgData = image.pngData() else {
                        JPrint("数据错误 ---", url.path)
                        continue
                    }

                    do {
                        try imgData.write(to: url)
                    } catch {
                        JPrint("写入错误 ---", url.path)
                    }
                }
                self.s2 = s2
            }
            
//            let c3 = LottieImageStore.Configure(lottieName: self.lottieName)
//            if let s3 = LottieImageStore.createStore(configure: c3) {
//                for (currentFrame, image) in s3.imageMap {
//                    var url = URL(fileURLWithPath: directoryPath)
//                    url.appendPathComponent("\(self.lottieName)_\(currentFrame).png")
//
//                    guard let imgData = image.pngData() else {
//                        JPrint("数据错误 ---", url.path)
//                        continue
//                    }
//
//                    do {
//                        try imgData.write(to: url)
//                    } catch {
//                        JPrint("写入错误 ---", url.path)
//                    }
//                }
//                self.s3 = s3
//            }
            
            Asyncs.main { JPProgressHUD.dismiss() }
        }
    }
}
