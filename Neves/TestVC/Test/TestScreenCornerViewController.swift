//
//  TestScreenCornerViewController.swift
//  Neves
//
//  Created by aa on 2021/12/10.
//

class TestScreenCornerViewController: TestBaseViewController {
    
    let slider = UISlider()
    let v = UIView(frame: [0, UIScreen.mainHeight - 100, UIScreen.mainWidth, 100])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        slider.frame = [30, UIScreen.mainHeight - 100 - 40, UIScreen.mainWidth - 60, 20]
        slider.minimumValue = 34
        slider.maximumValue = 50
        slider.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        v.backgroundColor = .black
        v.layer.cornerRadius = 34
        v.layer.masksToBounds = true
        view.addSubview(v)
        
        /// 感觉是`47`
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let cornerRadius = CGFloat(slider.value)
        JPrint("cornerRadius", cornerRadius)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(nil)
        v.layer.cornerRadius = cornerRadius
        CATransaction.commit()
    }
    
}
