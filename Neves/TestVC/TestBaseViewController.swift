//
//  TestBaseViewController.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TestBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        view.backgroundColor = .randomColor
    }
    
    private func setupTitle() {
        var title = "\(Self.self)" as NSString
        
        if let last = title.components(separatedBy: ".").last {
            title = last as NSString
        }
        
        if let first = title.components(separatedBy: "ViewController").first {
            title = first as NSString
        }
        
        self.title = title as String
    }
    
}
