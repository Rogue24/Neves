//
//  CosmicExplorationRecordView.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

class CosmicExplorationRecordDetailView: UIView, CosmicExplorationPopViewCompatible {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var titleImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleImgViewWidthConstraint.constant = 228.px
        closeBtnWidthConstraint.constant = 30.px
        tableViewTopConstraint.constant = 13.px
        
        emptyView.isHidden = true
        
        tableView.jp.contentInsetAdjustmentNever()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: DiffTabBarH, right: 0)
        tableView.rowHeight = 50.px
        tableView.register(CosmicExplorationRecordDetailView.Cell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        
        let footerView = UILabel(frame: [0, 0, PortraitScreenWidth, 24.px])
        footerView.textColor = .rgb(182, 216, 249, a: 0.4)
        footerView.font = .systemFont(ofSize: 11.px)
        footerView.textAlignment = .center
        footerView.text = "—————— 仅展示最近24小时的探险日志 ——————"
        tableView.tableFooterView = footerView
    }
    
    @IBAction func closeAction() {
        close()
    }

    static var testTag = false
    
    func reloadData() {
        Self.testTag.toggle()
        
        UIView.transition(with: emptyView, duration: 0.15, options: .transitionCrossDissolve) {
            self.emptyView.isHidden = Self.testTag
        } completion: { _ in }
        
        UIView.transition(with: tableView, duration: 0.15, options: .transitionCrossDissolve) {
            self.tableView.isHidden = !Self.testTag
        } completion: { _ in }
    }
}

extension CosmicExplorationRecordDetailView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
}
    
extension CosmicExplorationRecordDetailView {
    class Cell: UITableViewCell {
        let planetIcon = UIImageView()
        let titleLabel = UILabel()
        let dateLabel = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .clear
            selectionStyle = .none
            
            planetIcon.frame = [15.px, HalfDiffValue(50.px, 25.px), 25.px, 25.px]
            planetIcon.contentMode = .scaleAspectFit
            planetIcon.image = UIImage(named: "spaceship_planet_s06")
            contentView.addSubview(planetIcon)
            
            titleLabel.font = .systemFont(ofSize: 13.px)
            titleLabel.textColor = .white
            titleLabel.textAlignment = .left
            titleLabel.frame = [planetIcon.frame.maxX + 15.px, 0, 200.px, 50.px]
            titleLabel.text = "土星（15倍）"
            contentView.addSubview(titleLabel)
            
            dateLabel.font = .systemFont(ofSize: 13.px)
            dateLabel.textColor = .rgb(182, 216, 249)
            dateLabel.textAlignment = .right
            dateLabel.frame = [PortraitScreenWidth - 200.px - 15.px, 0, 200.px, 50.px]
            dateLabel.text = "2020/07/07 12:30:00"
            contentView.addSubview(dateLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
