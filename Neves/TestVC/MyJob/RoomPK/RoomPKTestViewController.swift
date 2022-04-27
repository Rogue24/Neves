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
        slider.frame = [20.px, PortraitScreenHeight - 200, PortraitScreenWidth - 40.px, slider.height]
        view.addSubview(slider)
        
        let btn1: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("胜利", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [20.px, 420.px, 60.px, 30.px]
            btn.addTarget(self, action: #selector(btn1DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn1)
        
        let btn2: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("失败", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [90.px, 420.px, 60.px, 30.px]
            btn.addTarget(self, action: #selector(btn2DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn2)
        
        let btn3: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("打平", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [160.px, 420.px, 60.px, 30.px]
            btn.addTarget(self, action: #selector(btn3DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn3)
        
        
        let btn21: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("开始PK", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [20.px, 460.px, 60.px, 30.px]
            btn.addTarget(self, action: #selector(btn21DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn21)
        
        let btn22: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("开始巅峰", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [90.px, 460.px, 60.px, 30.px]
            btn.addTarget(self, action: #selector(btn22DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn22)
        
        let btn23: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("结束PK", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.frame = [160.px, 460.px, 60.px, 30.px]
            btn.addTarget(self, action: #selector(btn23DidClick), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn23)
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
    
    @objc func sliderValueDidChanged(_ slider: UISlider) {
//        let value = CGFloat(slider.value)
//
//        fmPkProgressVM?.contentView.updateProgress(value)
//        phPkProgressVM?.contentView.updateProgress(value)
    }
    
    @objc func btn1DidClick() {
        
    }
    
    @objc func btn2DidClick() {
        
    }
    
    @objc func btn3DidClick() {
        
    }
    
    @objc func btn21DidClick() {
        fmPkProgressVM.contentView.playStartAnim()
        phPkProgressVM.contentView.playStartAnim()
    }
    
    @objc func btn22DidClick() {
        fmPkProgressVM.contentView.playStartPeakAnim()
        fmPkProgressVM.contentView.playPeakingAnim()
        
        phPkProgressVM.contentView.playStartPeakAnim()
        phPkProgressVM.contentView.playPeakingAnim()
    }
    
    @objc func btn23DidClick() {
        fmPkProgressVM.contentView.stopAnim()
        phPkProgressVM.contentView.stopAnim()
    }
}
