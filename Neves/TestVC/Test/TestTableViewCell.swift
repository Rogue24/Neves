//
//  TestTableViewCell.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/31.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {
    
    var tapMeAction: (() -> ())?
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("我死了")
    }
    
    @objc func tapMe() {
        tapMeAction?()
        JPrint("点我干嘛")
    }
}
