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
        layer.anchorPoint = [CGFloat(15 / peopleW), 0.5]
        
        line.layer.anchorPoint = [1, 0.5]
        line.frame = [CGFloat(-20 - 5), HalfDiffValue(peopleH, 1), CGFloat(20 + 5 + 15), 1]
        addSubview(line)
        
        let gLayer = CAGradientLayer()
        gLayer.frame = [0, 0, 20, 1]
        gLayer.startPoint = [0, 0]
        gLayer.endPoint = [1, 0]
        gLayer.colors = [UIColor.clear.cgColor, UIColor(white: 1, alpha: 1).cgColor, UIColor.clear.cgColor]
        gLayer.opacity = 0.5
        line.layer.addSublayer(gLayer)
        
        userIcon.frame = [0, 0, peopleH, peopleH]
        userIcon.contentMode = .scaleAspectFill
        userIcon.layer.cornerRadius = peopleH * 0.5
        userIcon.layer.masksToBounds = true
        addSubview(userIcon)
        
        infoView.frame = [CGFloat(30 + 10), -3.5, 100, 37]
        addSubview(infoView)
        
        nameLabel.frame = [0, 0, 100, 16.5]
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.textColor = .init(white: 1, alpha: 0.8)
        nameLabel.text = "健了个平 - \(tag)"
        infoView.addSubview(nameLabel)
        
        let y: CGFloat = nameLabel.maxY + 4
        levelIcon.frame = [1, y + HalfDiffValue(16.5, 11.3), 11.3, 11.3]
        infoView.addSubview(levelIcon)
        
        relLabel.font = .systemFont(ofSize: 12, weight: .medium)
        relLabel.text = "你爹"
        relLabel.sizeToFit()
        relLabel.height = 16.5
        
        relBgView
            .startPoint(0, 0)
            .endPoint(1, 0)
            .colors(.rgb(117, 138, 255), .rgb(116, 211, 255))
        relBgView.addSubview(relLabel)
        relBgView.mask = relLabel
        relBgView.frame = [levelIcon.maxX + 5, y, relLabel.width, relLabel.height]
        infoView.addSubview(relBgView)
        
        relNumIcon.frame = [relBgView.maxX + 10, y + HalfDiffValue(16.5, 13), 13, 13]
        infoView.addSubview(relNumIcon)
        
        relNumLabel.font = .systemFont(ofSize: 12, weight: .medium)
        relNumLabel.text = "9999"
        relNumLabel.textColor = .init(white: 1, alpha: 0.5)
        relNumLabel.sizeToFit()
        relNumLabel.frame = [relNumIcon.maxX + 4, y, relNumLabel.width, 16.5]
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
            
            if tag == 0 {
                JPrint("多少度！！", JPRadian2Angle(newValue))
            }
            
            if newValue > radian180 || newValue < -radian180 {
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
