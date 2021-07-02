//
//  MarebulabulasLrcView.swift
//  Neves_Example
//
//  Created by aa on 2020/10/27.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class MarebulabulasLrcView: UIView {
    let tableView: UITableView
    
    override init(frame: CGRect) {
        self.tableView = UITableView(frame: CGRect(origin: .zero, size: frame.size), style: .plain)
        super.init(frame: frame)
        
        _setupMaskView()
        _setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MarebulabulasLrcView {
    func _setupMaskView() {
        let maskView = UIView(frame: bounds)
        
        let topMaskView = UIImageView(image: UIImage(named: "album_lz_up"))
        topMaskView.contentMode = .scaleToFill
        topMaskView.frame = [0, 0, frame.width, 20]
        maskView.addSubview(topMaskView)
        
        let midMaskView = UIView(frame: [0, 20, frame.width, frame.height - 40])
        midMaskView.backgroundColor = .black
        maskView.addSubview(midMaskView)
        
        let bottomMaskView = UIImageView(image: UIImage(named: "album_lz_down"))
        bottomMaskView.contentMode = .scaleToFill
        bottomMaskView.frame = [0, frame.height - 20, frame.width, 20]
        maskView.addSubview(bottomMaskView)
        
        mask = maskView
    }
    
    func _setupTableView() {
        tableView.registerCell(MarebulabulasLrcCell.self)
        if #available(iOS 11.0, *) { tableView.contentInsetAdjustmentBehavior = .never }
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.contentInset = .init(top: 20, left: 0, bottom: 20, right: 0)
        tableView.backgroundColor = .clear
        addSubview(tableView)
    }
}
