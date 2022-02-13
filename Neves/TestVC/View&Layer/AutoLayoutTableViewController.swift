//
//  AutoLayoutTableViewController.swift
//  Neves
//
//  Created by aa on 2022/2/7.
//

import UIKit

class AutoLayoutTableViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: [0, NavTopMargin, PortraitScreenWidth, PortraitScreenHeight - NavTopMargin], style: .plain)
        tableView.jp.contentInsetAdjustmentNever()
        tableView.register(AutoLayoutTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.rowHeight = 80
        view.addSubview(tableView)
    }
    
}

extension AutoLayoutTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AutoLayoutTableViewCell
        
        cell.index = indexPath.row
        
        return cell
        
    }
    
}

class AutoLayoutTableViewCell: UITableViewCell {
    
    var index = 0 {
        didSet {
            box.text = "\(index)"
            
            // 只需要update即可，不用layoutIfNeed
            box.snp.updateConstraints { make in
                make.left.equalTo(50 + 10 * (index % 5))
            }
        }
    }
    
    let box = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(box)
        
        box.textColor = .randomColor
        box.font = .boldSystemFont(ofSize: 30)
        box.textAlignment = .center
        
        box.backgroundColor = .randomColor
        box.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.top.equalTo(10)
            make.width.height.equalTo(50)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
