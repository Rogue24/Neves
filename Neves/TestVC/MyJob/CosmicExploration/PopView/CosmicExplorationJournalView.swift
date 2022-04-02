//
//  CosmicExplorationJournalView.swift
//  Neves
//
//  Created by aa on 2022/4/1.
//

import UIKit

class CosmicExplorationJournalView: UIView, CosmicExplorationPopViewCompatible {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var titleImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    static let cellH: CGFloat = 50.px
    static let subCellH: CGFloat = 40.px
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleImgViewWidthConstraint.constant = 228.px
        closeBtnWidthConstraint.constant = 30.px
        tableViewTopConstraint.constant = 13.px
        
        emptyView.isHidden = true
        
        tableView.jp.contentInsetAdjustmentNever()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: DiffTabBarH, right: 0)
        tableView.register(CosmicExplorationJournalView.Cell.self, forCellReuseIdentifier: "cell")
        tableView.register(CosmicExplorationJournalView.SubCell.self, forCellReuseIdentifier: "subCell")
        tableView.dataSource = self
        tableView.delegate = self
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

extension CosmicExplorationJournalView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? Self.cellH : Self.subCellH
    }
    
}
    
extension CosmicExplorationJournalView {
    class Cell: UITableViewCell {
        let planetIcon = UIImageView()
        let titleLabel = UILabel()
        let resultLabel = UILabel()
        let dateLabel = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .rgb(45, 54, 100)
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
            
            resultLabel.font = .systemFont(ofSize: 13.px)
            resultLabel.textColor = .rgb(255, 241, 156)
            resultLabel.textAlignment = .right
            resultLabel.frame = [PortraitScreenWidth - 200.px - 15.px, 8.5.px, 200.px, 16.px]
            resultLabel.text = "探险成功"
            contentView.addSubview(resultLabel)
            
            dateLabel.font = .systemFont(ofSize: 11.px)
            dateLabel.textColor = .rgb(182, 216, 249)
            dateLabel.textAlignment = .right
            dateLabel.frame = [PortraitScreenWidth - 200.px - 15.px, resultLabel.frame.maxY + 3.px, 200.px, 14.px]
            dateLabel.text = "2020/07/07 12:30:00"
            contentView.addSubview(dateLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class SubCell: UITableViewCell {
        
        let titleLabel = UILabel()
        var giftItems: [GiftItem] = []
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .rgb(32, 42, 89)
            selectionStyle = .none
            
            titleLabel.font = .systemFont(ofSize: 12.px)
            titleLabel.textAlignment = .left
            titleLabel.frame = [15.px, 0, 200.px, CosmicExplorationJournalView.subCellH]
            titleLabel.textColor = .rgb(255, 241, 156)
            titleLabel.text = "获得x15"
            contentView.addSubview(titleLabel)
            
            var lastGiftItem: GiftItem? = nil
            for _ in 0 ..< 4 {
                let giftItem = GiftItem()
                contentView.addSubview(giftItem)
                giftItems.append(giftItem)
                
                giftItem.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    if let lastGiftItem = lastGiftItem {
                        make.right.equalTo(lastGiftItem.snp.left).offset(-5.px)
                    } else {
                        make.right.equalToSuperview().offset(-15.px)
                    }
                }
                
                lastGiftItem = giftItem
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class GiftItem: UIView {
        let giftIcon = UIImageView()
        let countLabel = UILabel()
        
        init() {
            super.init(frame: .zero)
            
            backgroundColor = .rgb(16, 20, 59, a: 0.3)
            layer.cornerRadius = 10.px
            layer.masksToBounds = true
            
            giftIcon.contentMode = .scaleAspectFit
            addSubview(giftIcon)
            giftIcon.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.top.equalToSuperview().offset(2.5.px)
                make.bottom.equalToSuperview().offset(-2.5.px)
                make.left.equalToSuperview().offset(5.px)
                make.size.equalTo(CGSize(width: 15.px, height: 15.px))
            }
            
            countLabel.font = .systemFont(ofSize: 12.px)
            countLabel.textColor = .rgb(255, 241, 156)
            addSubview(countLabel)
            countLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(giftIcon.snp.right).offset(3.px)
                make.right.equalToSuperview().offset(-6.5.px)
            }
            
            giftIcon.image = UIImage(named: "dragon_weideng")
            countLabel.text = "x150"
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
