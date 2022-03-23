//
//  PanScrollViewController.swift
//  Neves
//
//  Created by aa on 2022/3/8.
//

import UIKit

class TapView: UIView {
    
    init() {
        super.init(frame: [0, 0, 200, 200])
        backgroundColor = .randomColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        JPrint(tag, "--- 点哥干啥 touchesBegan")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        JPrint(tag, "--- 点哥干啥 touchesEnded")
    }
}

class PanScrollViewController: TestBaseViewController {
    
    var scrollView: UIScrollView!
    var scrollView2: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView(frame: [0, NavTopMargin + 20, PortraitScreenWidth, 30])
        scrollView.jp.contentInsetAdjustmentNever()
        scrollView.backgroundColor = .randomColor
        scrollView.tag = 1
        scrollView.delegate = self
        scrollView.contentSize = [PortraitScreenWidth * 2, 0]
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        let tv = TapView()
        tv.tag = 1
        tv.origin = [HalfDiffValue(PortraitScreenWidth, tv.width), HalfDiffValue(PortraitScreenHeight, tv.height)]
        view.addSubview(tv)
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        view.addGestureRecognizer(panGR)
        
        let scrollView2 = UIScrollView(frame: [0, NavTopMargin + 60, PortraitScreenWidth, 30])
        scrollView2.jp.contentInsetAdjustmentNever()
        scrollView2.backgroundColor = .randomColor
        scrollView2.tag = 2
        scrollView2.delegate = self
        let tv2 = TapView()
        tv2.tag = 2
        tv2.frame = [HalfDiffValue(PortraitScreenWidth, 100), 0, 100, 30]
        scrollView2.addSubview(tv2)
        scrollView2.contentSize = [PortraitScreenWidth * 2, 0]
        view.addSubview(scrollView2)
        self.scrollView2 = scrollView2
        
        // 转移手势
//        addToMyView()
        addToOtherScrollView()
    }
    
    // MARK: - 1.将scrollView的滚动手势转移到vc.view上
    /// 转移后`scrollView`自身【也能】滚动，不会影响到`vc.view`原来的点击手势，但会覆盖原有的滚动手势（方向一样的才会覆盖，不同方向不会覆盖）
    func addToMyView() {
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
    }
    
    // MARK: - 2.将scrollView的滚动手势转移到另一个scrollView2上
    /// 转移后`scrollView`自身【不能】滚动，不会影响到`scrollView2`原来的点击手势，但会覆盖原有的滚动手势（`scrollView2`无法滚动了）
    func addToOtherScrollView() {
        scrollView2.addGestureRecognizer(scrollView.panGestureRecognizer)
    }

}

extension PanScrollViewController {
    @objc func panHandler(_ panGR: UIPanGestureRecognizer) {
        JPrint("滚滚滚")
    }
}

extension PanScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        JPrint(scrollView.tag, "--- 滚了滚了", String(format: "%.2lf", scrollView.contentOffset.x))
    }
}
