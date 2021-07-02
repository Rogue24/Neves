//
//  FireworkCell.swift
//  Neves_Example
//
//  Created by aa on 2020/10/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

struct FireworkCellModel {
    static func cellModels(_ models: [FireworkModel]) -> [FireworkCellModel] {
        return models.map { FireworkCellModel(base: $0) }
    }
    
    let base: FireworkModel
    
    let rightTopText: String?
    let progressText: String
    let countDownText: String
    let numberText: String
    let progress: CGFloat
    let countDownColor: UIColor
    let progressColors: [CGColor]
    
    init(base: FireworkModel) {
        self.base = base
        
        rightTopText = base.launcherInfo.gotNum > 0 ? "已集满 x \(base.launcherInfo.gotNum)" : nil
        progressText = "距再次触发焰火还差 \(base.launcherInfo.targetAmount - base.launcherInfo.holdAmount)"
        numberText = "\(base.launcherInfo.holdAmount) / \(base.launcherInfo.targetAmount)"
        countDownText = base.secondsText
        
        progress = CGFloat(base.launcherInfo.holdAmount) / CGFloat(base.launcherInfo.targetAmount)
        countDownColor = base.seconds <= 30 ? .rgb(255, 229, 75) : .white
        progressColors = base.seconds <= 30 ? [UIColor.rgb(255, 174, 89).cgColor, UIColor.rgb(251, 67, 137).cgColor] : [UIColor.rgb(144, 89, 255).cgColor, UIColor.rgb(245, 72, 220).cgColor]
    }
}

class FireworkCell: UITableViewCell, CellReusable {
    
    @IBOutlet weak var rightImgView: UIImageView!
    @IBOutlet weak var rightTopLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressBgView: UIView!
    @IBOutlet weak var progressLabe: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    let progressView: GradientView = {
        GradientView().startPoint(0, 0.5).endPoint(1, 0.5)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.layer.masksToBounds = true
        progressBgView.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.bottom.left.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0)
        }
    }
    
    deinit {
        JPrint("老子死了吗")
    }
    
    func setupUI(_ cm: FireworkCellModel) {
        nameLabel.text = cm.base.nickName
        iconView.image = cm.base.icon ?? FireworkModel.defaultIcon
        rightTopLabel.text = cm.rightTopText
        rightTopLabel.isHidden = cm.rightTopText == nil
        rightImgView.isHidden = rightTopLabel.isHidden
        progressLabe.text = cm.progressText
        numberLabel.text = cm.numberText
        countDownLabel.text = cm.countDownText
        countDownLabel.textColor = cm.countDownColor
        progressView.gLayer.colors = cm.progressColors
        progressView.snp.remakeConstraints {
            $0.top.bottom.left.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(cm.progress)
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        progressView.layer.cornerRadius = progressView.frame.height * 0.5
    }
}
