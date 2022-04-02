//
//  CosmicExplorationBannerView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit

class CosmicExplorationBannerView: UIView {
    
    var tableView: UITableView?
    
    @IBOutlet weak var leftIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftIconLeftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 11.px
        layer.masksToBounds = true
        
        leftIconWidthConstraint.constant = 15.px
        leftIconLeftConstraint.constant = 5.px
        
        // TODO: 临时做法
        Asyncs.main {
            let x: CGFloat = (5 + 15 + 5).px
            let w: CGFloat = PortraitScreenWidth - 20.px - x - 5.px
            let tableView = UITableView(frame: [x, 0, w, 22.px], style: .plain)
            tableView.isUserInteractionEnabled = false
            tableView.backgroundColor = .clear
            tableView.jp.contentInsetAdjustmentNever()
            tableView.rowHeight = 22.px
            tableView.showsVerticalScrollIndicator = false
            tableView.register(CosmicExplorationBannerView.Cell.self, forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            self.addSubview(tableView)
            self.tableView = tableView
        }
    }
    
}

extension CosmicExplorationBannerView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
}

extension CosmicExplorationBannerView {
    
    class Cell: UITableViewCell {
        let titleLabel = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            backgroundColor = .clear
            
            titleLabel.font = .systemFont(ofSize: 11.px)
            titleLabel.textColor = .white
            titleLabel.textAlignment = .left
            titleLabel.text = "别玩了，浪费钱。"
            titleLabel.frame = [0, 0, PortraitScreenWidth, 22.px]
            contentView.addSubview(titleLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
