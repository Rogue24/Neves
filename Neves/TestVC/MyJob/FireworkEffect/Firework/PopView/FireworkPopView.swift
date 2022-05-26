//
//  FireworkPopView.swift
//  Neves_Example
//
//  Created by aa on 2020/10/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class FireworkPopView: UIView {
    // MARK: - 公开属性
    @IBOutlet weak var contentViewBottom: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: FireworkListView!
    @IBOutlet weak var topBgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - 初始化&反初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let image = topBgView.image?.resizableImage(withCapInsets: .init(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
        topBgView.image = image
        
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.rgb(72, 22, 126).cgColor
        bgLayer.lineWidth = 0
        bgLayer.path = UIBezierPath(roundedRect: UIScreen.main.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: .init(width: 10, height: 10)).cgPath
        contentView.layer.insertSublayer(bgLayer, at: 0)
        
        contentViewBottom.constant = -(contentViewHeight.constant + 20)
    }
    
    deinit {
        JPrint("老子死了吗")
    }
    
    // MARK: - 弹出动画
    class func show(onView view: UIView? = nil, _ models: [FireworkModel]) {
        guard let superview = view ?? UIApplication.shared.keyWindow else { return }
        
        let popView = Self.loadFromNib()
        superview.addSubview(popView)
        
        popView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        superview.layoutIfNeeded()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        popView.dateLabel.text = "数据最后更新于\(formatter.string(from: Date()))"
        popView.tableView.cellModels = FireworkCellModel.cellModels(models)
        
        popView.show()
    }
    
    func show() {
        contentViewBottom.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
            self.layoutIfNeeded()
            self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.5).cgColor
        }, completion: nil)
    }
    
    // MARK: - 关闭动画
    func close() {
        isUserInteractionEnabled = false
        contentViewBottom.constant = -(contentViewHeight.constant + 20)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.layoutIfNeeded()
            self.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: 点击空白关闭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        if contentView.frame.contains(point) == false { close() }
    }
    
    // MARK: - 弹出规则视图
    @IBAction func showRule() {
        FireworkRulePopView.show { [weak self] in
            self?.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        } closeHandle: { [weak self] in
            self?.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.5).cgColor
        }
    }
}

class FireworkListView: UITableView {
    // MARK: - 公开属性
    var cellModels: [FireworkCellModel] = [] {
        didSet { reloadData() }
    }
    
    // MARK: - 初始化&反初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 11.0, *) { contentInsetAdjustmentBehavior = .never }
        alwaysBounceVertical = false
        tableFooterView = UIView.loadFromNib("FireworkFooter")
        registerCell(FireworkCell.self)
        dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(getUserInfo), name: FireworkModel.UserInfoGetedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        JPrint("老子死了吗")
    }
    
    // MARK: - 监听获取到用户信息的通知
    @objc func getUserInfo(_ notification: Notification) {
        guard let userInfo = notification.object as? FireworkModel.UserInfo,
              visibleCells.count > 0 else { return }
        for i in 0..<cellModels.count {
            let cellModel = cellModels[i]
            if cellModel.base.uid == userInfo.uid {
                if let cell = cellForRow(at: IndexPath(row: i, section: 0)) as? FireworkCell {
                    cell.setupUI(cellModel)
                }
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension FireworkListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as FireworkCell
        cell.setupUI(cellModels[indexPath.row])
        return cell
    }
}
