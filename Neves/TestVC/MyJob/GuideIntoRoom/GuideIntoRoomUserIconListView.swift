//
//  GuideIntoRoomUserIconListView.swift
//  Neves
//
//  Created by aa on 2022/12/30.
//

import Lottie

class GuideIntoRoomUserIconListView: UIView, GuideIntoRoomContentViewCompatible {
    var viewSize: CGSize = .zero
    
    let isBlindDate: Bool
    
    var animView: LottieAnimationView!
    
    init(isBlindDate: Bool) {
        self.isBlindDate = isBlindDate
        self.viewSize = [GuideIntoRoomPopView.baseSize.width, CGFloat(53 + 26 + 24)]
        super.init(frame: .zero)
        backgroundColor = .randomColor
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/roomguide_tx_lottie"),
              let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            JPrint("路径错误！")
            return
        }
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        animView = LottieAnimationView(animation: animation, imageProvider: provider)
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop
        animView.backgroundBehavior = .pauseAndRestore
        addSubview(animView)
        animView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(53)
            make.top.equalToSuperview()
        }
        animView.play()
        
        if isBlindDate {
            setupBlindDateUI()
        } else {
            setupTagList()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupBlindDateUI() {
        
    }
    
    func setupTagList() {
        
    }
}
