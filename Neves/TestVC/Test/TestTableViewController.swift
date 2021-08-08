//
//  TestTableViewController.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/31.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TestTableViewController: TestBaseViewController, UITableViewDataSource {

    var tableView = TestTableView(frame: [0, 100, PortraitScreenWidth, PortraitScreenWidth], style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .randomColor
        tableView.register(TestTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        view.addSubview(tableView)
        
    }
    
    deinit {
        JPrint("我死了")
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TestTableViewCell
        cell.backgroundColor = .randomColor
        // Configure the cell...
        cell.textLabel?.text = "\(indexPath.row)"
        
        // MARK:- 循环引用问题
        cell.tapMeAction = {
            // controller、tableView、cell都不死
            // cell ← tableView ← self
            //  ↓                  ↑
            //  →→→→→→→→→→→→→→→→→→→→
            JPrint(self)
            
            // controller死，tableView、cell不死
            // cell ← tableView ← self
            //  ↓         ↑
            //  →→→→→→→→→→→
//            JPrint(tableView)
        }

        return cell
    }

}

// MARK:- TableView
class TestTableView: UITableView {

    deinit {
        JPrint("我死了")
    }

}

// MARK:- TableViewCell
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
