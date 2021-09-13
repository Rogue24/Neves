//
//  PeopleView.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

class PeopleView: UIView {
    let minHideOffsetY: CGFloat
    let minShowOffsetY: CGFloat
    
    let nameH: CGFloat = 16.5.px
    let relH: CGFloat = 16.5.px
    let relLevelIconWH: CGFloat = 11.3.px
    let relNumIconWH: CGFloat = 13.px
    lazy var infoSize: CGSize = [100.px, nameH + 4.px + relH]
    
    let lineBgView = UIView()
    let userIcon = UIImageView(image: UIImage(named: "jp_icon"))
    let infoView = UIView()
    
    let nameLabel = UILabel()
    let relLevelIcon = UIImageView(image: UIImage(named: "gxq_lv5"))
    let relBgView = GradientView()
    let relLabel = UILabel()
    let relNumIcon = UIImageView(image: UIImage(named: "gxq_icon_qmz"))
    let relNumLabel = UILabel()
    
    init(tag: Int) {
        let singleItemOffsetY = PeopleTurntableView.singleItemOffsetY
        self.minHideOffsetY = CGFloat(tag) * singleItemOffsetY - singleItemOffsetY
        self.minShowOffsetY = CGFloat(tag) * singleItemOffsetY
        
        super.init(frame: [0, 0, RelationshipPlanet.peopleW, RelationshipPlanet.peopleH])
        self.tag = tag
        
        let peopleIconWH = RelationshipPlanet.peopleIconWH
        layer.anchorPoint = [peopleIconWH * 0.5 / frame.width, 0.5]
        
        let lineSize: CGSize = [20.px, 1.px]
        let lineSpace: CGFloat = 5.px
        lineBgView.layer.anchorPoint = [1, 0.5]
        lineBgView.frame = [-lineSize.width - lineSpace, HalfDiffValue(frame.height, lineSize.height), lineSize.width + lineSpace + peopleIconWH * 0.5, lineSize.height]
        addSubview(lineBgView)
        
        let line = CAGradientLayer()
        line.frame = .init(origin: .zero, size: lineSize)
        line.startPoint = [0, 0.5]
        line.endPoint = [1, 0.5]
        line.colors = [UIColor.clear.cgColor, UIColor(white: 1, alpha: 1).cgColor, UIColor.clear.cgColor]
        line.opacity = 0.5
        lineBgView.layer.addSublayer(line)
        
        userIcon.frame = [0, 0, peopleIconWH, peopleIconWH]
        userIcon.contentMode = .scaleAspectFill
        addSubview(userIcon)
        
        infoView.frame = [userIcon.frame.maxX + 10.px,HalfDiffValue(frame.height, infoSize.height), infoSize.width, infoSize.height]
        infoView.clipsToBounds = false
        addSubview(infoView)
        
        nameLabel.frame = [0, 0, infoSize.width * 2, nameH]
        nameLabel.font = .systemFont(ofSize: 12.px)
        nameLabel.textColor = .init(white: 1, alpha: 0.8)
        nameLabel.text = "健了个平 - \(tag)"
        infoView.addSubview(nameLabel)
        
        let y: CGFloat = infoSize.height - relH
        relLevelIcon.frame = [1.px, y + HalfDiffValue(relH, relLevelIconWH), relLevelIconWH, relLevelIconWH]
        infoView.addSubview(relLevelIcon)
        
        relLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
        relLabel.text = "宝贝"
        relLabel.sizeToFit()
        relLabel.frame.size.height = relH
        
        relBgView
            .startPoint(0, 0.5)
            .endPoint(1, 0.5)
            .colors(.rgb(117, 138, 255), .rgb(116, 211, 255))
        relBgView.addSubview(relLabel)
        relBgView.mask = relLabel
        relBgView.frame = [relLevelIcon.frame.maxX + 5.px, y, relLabel.frame.width, relLabel.frame.height]
        infoView.addSubview(relBgView)
        
        relNumIcon.frame = [relBgView.maxX + 10.px, y + HalfDiffValue(relH, relNumIconWH), relNumIconWH, relNumIconWH]
        infoView.addSubview(relNumIcon)
        
        relNumLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
        relNumLabel.text = "9999"
        relNumLabel.textColor = .init(white: 1, alpha: 0.5)
        relNumLabel.sizeToFit()
        relNumLabel.frame = [relNumIcon.maxX + 4.px, y, relNumLabel.frame.width, relH]
        infoView.addSubview(relNumLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(offsetY: CGFloat, progress: CGFloat) {
        let circlePoint = RelationshipPlanet.planetCirclePoint
        let radius = RelationshipPlanet.planetRadius
        let radian90 = PeopleTurntableView.radian90
        let radian105 = PeopleTurntableView.radian105
        let radian360 = PeopleTurntableView.radian360
        let singleItemRadian = PeopleTurntableView.singleItemRadian
        let singleItemOffsetY = PeopleTurntableView.singleItemOffsetY
        let halfRoundOffsetY = PeopleTurntableView.minContentH // 转半圈所需偏移量
        
        // 弧度
        var radian: CGFloat = singleItemRadian * CGFloat(tag) - radian90
        radian -= progress * radian360
        
        let centerX: CGFloat = circlePoint.x + radius * cos(radian)
        let centerY: CGFloat = circlePoint.y + radius * sin(radian)
        center = [centerX, offsetY + centerY]
        
        // 线的角度和显示、头像的显示
        lineBgView.transform = .init(rotationAngle: radian)
        // 30 * 3.5 = 105
        if radian > radian105 || radian < -radian105 {
            lineBgView.isHidden = true
            userIcon.isHidden = true
        } else {
            lineBgView.isHidden = false
            userIcon.isHidden = false
        }

        // 信息的透明度
        var infoAlpha: CGFloat = 1
        if offsetY > minHideOffsetY {
            infoAlpha = 1 - (offsetY - minHideOffsetY) / singleItemOffsetY
        } else {
            let oy = offsetY + halfRoundOffsetY
            if oy > minShowOffsetY {
                infoAlpha = (oy - minShowOffsetY) / singleItemOffsetY
            } else {
                infoAlpha = 0
            }
        }
        if infoAlpha < 0 {
            infoAlpha = 0
        } else if infoAlpha > 1 {
            infoAlpha = 1
        }
        infoView.alpha = infoAlpha
    }
}
