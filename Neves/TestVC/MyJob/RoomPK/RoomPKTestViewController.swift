//
//  RoomPKTestViewController.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

class RoomPKTestViewController: TestBaseViewController {
    
    let fmPkProgressVM = PKProgressViewModel<PKRankModel>()
    let phPkProgressVM = PlayhousePKProgressViewModel<PKRankModel>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fmPkProgressVM.addProgressView(on: self.view, top: 150)
        phPkProgressVM.addProgressView(on: self.view, top: 300)
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: #selector(sliderValueDidChanged(_:)), for: .valueChanged)
        slider.frame = [20.px, PortraitScreenHeight - 260, PortraitScreenWidth - 40.px, slider.height]
        view.addSubview(slider)
        
        makeBtn("胜利", [20.px, 420.px], #selector(shengli))
        makeBtn("失败", [100.px, 420.px], #selector(shibai))
        makeBtn("打平", [180.px, 420.px], #selector(daping))
        
        makeBtn("开始PK", [20.px, 460.px], #selector(kaishipk))
        makeBtn("开始巅峰", [100.px, 460.px], #selector(kaishidianfeng))
        makeBtn("结束PK", [180.px, 460.px], #selector(jiesupk))
        
        makeBtn("收起邀请", [20.px, 500.px], #selector(shouqiyaoqing))
        makeBtn("弹起邀请", [100.px, 500.px], #selector(tanqiyaoqing))
        makeBtn("收到邀请", [180.px, 500.px], #selector(shoudaoyaoqing))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            
            self.fmPkProgressVM.updateRankData(
                leftRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }), rightRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }))
            
            self.fmPkProgressVM.updateProgress(leftValue: Int.random(in: 0...100),
                                               rightValue: Int.random(in: 0...100),
                                               animated: true)
            
            self.phPkProgressVM.updateRankData(
                leftRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }), rightRankModels: Array(0...Int.random(in: 0...2)).map({
                PKRankModel(userIconUrl: "", ranking: $0 + 1)
            }))
            
            self.phPkProgressVM.updateProgress(leftValue: Int.random(in: 0...100),
                                               rightValue: Int.random(in: 0...100),
                                               animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
    func makeBtn(_ title: String, _ origin: CGPoint, _ action: Selector) {
        let btn: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.yellow, for: .normal)
            btn.backgroundColor = .purple
            btn.frame = CGRect(origin: origin, size: [70.px, 30.px])
            btn.addTarget(self, action: action, for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn)
    }
}

extension RoomPKTestViewController {
    @objc func sliderValueDidChanged(_ slider: UISlider) {
//        let value = CGFloat(slider.value)
//        fmPkProgressVM?.contentView.updateProgress(value)
//        phPkProgressVM?.contentView.updateProgress(value)
    }
}

extension RoomPKTestViewController {
    @objc func shengli() {
        
    }
    
    @objc func shibai() {
        
    }
    
    @objc func daping() {
        
    }
}

extension RoomPKTestViewController {
    @objc func kaishipk() {
        fmPkProgressVM.startPK()
        phPkProgressVM.startPK()
    }
    
    @objc func kaishidianfeng() {
        fmPkProgressVM.startPeakPK()
        phPkProgressVM.startPeakPK()
    }
    
    @objc func jiesupk() {
        fmPkProgressVM.endPk()
        phPkProgressVM.endPk()
    }
}

extension RoomPKTestViewController {
    @objc func shouqiyaoqing() {
        
    }
    
    @objc func tanqiyaoqing() {
        
    }
    
    @objc func shoudaoyaoqing() {
        
    }
}
