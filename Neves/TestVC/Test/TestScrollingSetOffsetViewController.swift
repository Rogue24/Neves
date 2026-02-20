//
//  TestScrollingSetOffsetViewController.swift
//  Neves
//
//  Created by aa on 2026/1/21.
//

import UIKit
import FunnyButton

class TestScrollingSetOffsetViewController: TestBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = [0, 200, PortraitScreenWidth, 200]
        scrollView.backgroundColor = .randomColor
        scrollView.jp_contentInsetAdjustmentNever()
        
        let vvv = UIView(frame: [0, 0, PortraitScreenWidth, 400])
        vvv.backgroundColor = .randomColor
        scrollView.addSubview(vvv)
        scrollView.contentSize = vvv.size
        
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction { [weak self] in
            guard let self else { return }
            self.myTest()
        }
    }
    
    private let scrollView = UIScrollView()
    private var tag = 0
    
    private func myTest() {
        scrollView.contentOffset = [0, -100]
        // 设置一样的contentOffset是不会触发scrollViewDidScroll的
//        scrollView.contentOffset = scrollView.contentOffset
//        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
}

extension TestScrollingSetOffsetViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tag = self.tag
        self.tag += 1
        
        JPrint("111 offsetY: \(scrollView.contentOffset.y), tag: \(tag)") // 1
        
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero // 2
            JPrint("222 offsetY: \(scrollView.contentOffset.y), tag: \(tag)") // 3
        }
    }
    
    // jpjpjp [12:58:47:90]: 111 offsetY: -100.0, tag: 0
    // jpjpjp [12:58:47:90]: 111 offsetY: 0.0, tag: 1
    // jpjpjp [12:58:47:90]: 222 offsetY: 0.0, tag: 1
    // jpjpjp [12:58:47:90]: 222 offsetY: 0.0, tag: 0
    
    // 执行顺序：tag0_1 ~> tag0_2 ~> tag1_1 ~> tag1_2 ~> tag1_3 ~> tag0_3
}

