//
//  MarebulabulasViewController.swift
//  Neves_Example
//
//  Created by aa on 2020/10/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

enum MarebulabulasType: Equatable {
    case dialogue
    case sing(_ isAccompaniment: Bool)
    
    var isDialogue: Bool { self == .dialogue }
    var isAccompaniment: Bool { self == .sing(true) }
}

enum RecordState {
    case idle
    case readyRecord
    case recording
    case recordDone
    case recordSuccess
}

class MarebulabulasViewController: TestBaseViewController {
    
    let type: MarebulabulasType
    
    var state: RecordState { operationView.recordControl.state }
    
    init(type: MarebulabulasType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var gView: GradientView { view as! GradientView }
    let titleLabel = UILabel()
    var lrcView: MarebulabulasLrcView!
    var operationView: MarebulabulasOperationView!
    
    var manager: MarebulabulasManager!
    
    override func loadView() {
        let colors: [UIColor]
        
        switch type {
        case .dialogue:
            colors = [.rgb(72, 88, 228),
                      .rgb(80, 100, 234),
                      .rgb(84, 105, 237),
                      .rgb(108, 138, 255),
                      .rgb(117, 155, 255),
                      .rgb(117, 155, 255)]
        case .sing:
            colors = [.rgb(238, 80, 147),
                      .rgb(242, 89, 149),
                      .rgb(244, 91, 150),
                      .rgb(255, 113, 155),
                      .rgb(252, 121, 154),
                      .rgb(252, 121, 154)]
        }
        
        view = GradientView().startPoint(0.5, 0).endPoint(0.5, 1).colors(colors)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        manager = MarebulabulasManager(type: type, lrcView: lrcView, operationView: operationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
}

extension MarebulabulasViewController {
    fileprivate func setupUI() {
        _setupLrcView()
        _setupOperationView()
        _setupTopAnimView()
        _setupNavBar()
    }
    
    private func _setupTopAnimView() {
        let dirName = type.isDialogue ? "album_dialog_bg_lottie" : "album_sing_bg_lottie"
        let topAnimView = LottieAnimationView.jp.build(dirName)
        topAnimView.isUserInteractionEnabled = false
        view.addSubview(topAnimView)
        topAnimView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(view.snp.width).multipliedBy(250.0 / 375.0)
        }
        topAnimView.play(toProgress: 1, loopMode: .loop, completion: nil)
    }
    
    private func _setupNavBar() {
        let navBar = UIView()
        view.addSubview(navBar)
        navBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(NavBarH)
            $0.top.equalTo(StatusBarH)
        }
        
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.setTitle("关闭", for: .normal)
        closeBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        navBar.addSubview(closeBtn)
        closeBtn.snp.makeConstraints {
            $0.width.equalTo(NavBarH)
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(14)
        }
        
        let replayBtn = UIButton(type: .custom)
        let replayImgName = type.isDialogue ? "album_lz_replay_db" : "album_lz_replay_cyd"
        replayBtn.setImage(UIImage(named: replayImgName), for: .normal)
        replayBtn.setImage(UIImage(named: replayImgName), for: .highlighted)
        replayBtn.addTarget(self, action: #selector(replayAction), for: .touchUpInside)
        navBar.addSubview(replayBtn)
        replayBtn.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(23)
            $0.right.equalTo(-15)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "《晴天》"
        navBar.addSubview(titleLabel)
        if type.isAccompaniment {
            titleLabel.snp.makeConstraints {
                $0.left.equalTo(closeBtn)
                $0.right.equalTo(replayBtn)
                $0.top.equalToSuperview().offset(5.5)
                $0.height.equalTo(25)
            }
            
            let accLabel = UILabel()
            accLabel.font = .systemFont(ofSize: 12)
            accLabel.textColor = .white
            accLabel.textAlignment = .center
            accLabel.text = "伴奏版"
            navBar.addSubview(accLabel)
            accLabel.snp.makeConstraints {
                $0.height.equalTo(16.5)
                $0.width.equalTo(40)
                $0.centerX.equalToSuperview()
                $0.top.equalTo(self.titleLabel.snp.bottom).offset(1)
            }
        } else {
            titleLabel.snp.makeConstraints {
                $0.left.equalTo(closeBtn)
                $0.right.equalTo(replayBtn)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
    
    private func _setupLrcView() {
        let y = StatusBarH + 59
        let h: CGFloat = (PortraitScreenHeight - DiffStatusBarH - DiffTabBarH) * ((667 - 255.5 - 79) / 667)
        lrcView = MarebulabulasLrcView(frame: [0, y, PortraitScreenWidth, h])
        view.addSubview(lrcView)
    }
    
    private func _setupOperationView() {
        let y = lrcView.maxY
        let h: CGFloat = PortraitScreenHeight - y - DiffTabBarH
        operationView = MarebulabulasOperationView(frame: [0, y, PortraitScreenWidth, h], type: type)
        view.addSubview(operationView)
    }
}

extension MarebulabulasViewController {
    @objc fileprivate func closeAction() {
        if let navCtr = navigationController, navCtr.viewControllers.count > 1 {
            navCtr.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func replayAction() {
        JPrint("从头播放？")
    }
}
