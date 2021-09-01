//
//  PeopleView.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

class PeopleView: UIView {
    
    let line = UIView()
    
    let userIcon = UIImageView(image: UIImage(named: "jp_icon"))
    
    let infoView = UIView()
    let nameLabel = UILabel()
    let levelIcon = UIImageView(image: UIImage(named: "gxq_lv5"))
    let relBgView = GradientView()
    let relLabel = UILabel()
    let relNumIcon = UIImageView(image: UIImage(named: "gxq_icon_qmz"))
    let relNumLabel = UILabel()
    
    init(tag: Int) {
        super.init(frame: [0, 0, peopleW, peopleH])
        self.tag = tag
//        backgroundColor = .randomColor
        layer.anchorPoint = [CGFloat(15.px / peopleW), 0.5]
        
        line.layer.anchorPoint = [1, 0.5]
        line.frame = [CGFloat(-20 - 5).px, HalfDiffValue(peopleH, 1.px), CGFloat(20 + 5 + 15).px, 1.px]
        addSubview(line)
        
        let gLayer = CAGradientLayer()
        gLayer.frame = [0, 0, 20.px, 1.px]
        gLayer.startPoint = [0, 0]
        gLayer.endPoint = [1, 0]
        gLayer.colors = [UIColor.clear.cgColor, UIColor(white: 1, alpha: 1).cgColor, UIColor.clear.cgColor]
        gLayer.opacity = 0.5
        line.layer.addSublayer(gLayer)
        
        userIcon.frame = [0, 0, peopleH, peopleH]
        userIcon.contentMode = .scaleAspectFill
        addSubview(userIcon)
        
        infoView.frame = [CGFloat(30 + 10).px, -3.5.px, 100.px, 37.px]
        addSubview(infoView)
        
        nameLabel.frame = [0, 0, 100.px, 16.5.px]
        nameLabel.font = .systemFont(ofSize: 12.px)
        nameLabel.textColor = .init(white: 1, alpha: 0.8)
        nameLabel.text = "健了个平 - \(tag)"
        infoView.addSubview(nameLabel)
        
        let y: CGFloat = nameLabel.maxY + 4.px
        levelIcon.frame = [1.px, y + HalfDiffValue(16.5.px, 11.3.px), 11.3.px, 11.3.px]
        infoView.addSubview(levelIcon)
        
        relLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
        relLabel.text = "宝贝"
        relLabel.sizeToFit()
        relLabel.height = 16.5.px
        
        relBgView
            .startPoint(0, 0)
            .endPoint(1, 0)
            .colors(.rgb(117, 138, 255), .rgb(116, 211, 255))
        relBgView.addSubview(relLabel)
        relBgView.mask = relLabel
        relBgView.frame = [levelIcon.maxX + 5.px, y, relLabel.width, relLabel.height]
        infoView.addSubview(relBgView)
        
        relNumIcon.frame = [relBgView.maxX + 10.px, y + HalfDiffValue(16.5.px, 13.px), 13.px, 13.px]
        infoView.addSubview(relNumIcon)
        
        relNumLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
        relNumLabel.text = "9999"
        relNumLabel.textColor = .init(white: 1, alpha: 0.5)
        relNumLabel.sizeToFit()
        relNumLabel.frame = [relNumIcon.maxX + 4.px, y, relNumLabel.width, 16.5.px]
        infoView.addSubview(relNumLabel)
        
        minShowOffsetY = CGFloat(tag) * onePeopleOffsetY - topInset
        maxShowOffsetY = CGFloat(tag) * onePeopleOffsetY
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var minShowOffsetY: CGFloat = 0
    var maxShowOffsetY: CGFloat = 0
    
    func updateAlpha(_ offsetY: CGFloat) {
        var alpha: CGFloat = 1
        
        if offsetY > minShowOffsetY {
            alpha = 1 - (offsetY - minShowOffsetY) / onePeopleOffsetY
        } else {
            let oy = offsetY + 5 * onePeopleOffsetY + topInset
            if oy > maxShowOffsetY {
                alpha = (oy - maxShowOffsetY) / onePeopleOffsetY
            } else {
                alpha = 0
            }
        }
        
        if alpha < 0 {
            alpha = 0
        } else if alpha > 1 {
            alpha = 1
        }
        infoView.alpha = alpha
    }
    
    private var _radian: CGFloat = 0
    var currentRradian: CGFloat {
        set {
            guard _radian != newValue else { return }
            _radian = newValue
            
            line.transform = .init(rotationAngle: newValue)
            
//            if tag == 6 {
//                JPrint("多少度！！", JPRadian2Angle(newValue))
//            }
            
            // 30 * 3.5 = 105
            if newValue > radian30 * 3.5 || newValue < -(radian30 * 3.5) {
                line.isHidden = true
                userIcon.isHidden = true
            } else {
                line.isHidden = false
                userIcon.isHidden = false
            }
        }
        get { _radian }
    }
}
