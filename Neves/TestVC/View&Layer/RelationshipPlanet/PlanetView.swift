//
//  PlanetPeopleView.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

extension PlanetView {
    enum Style {
        /// 挚友
        case bosomFriend
        /// 闺蜜
        case confidante
        /// 死党
        case bestFriend
        /// 师徒
        case masterApprentice
        
        var title: String {
            switch self {
            case .bosomFriend: return "挚友"
            case .confidante: return "闺蜜"
            case .bestFriend: return "死党"
            case .masterApprentice: return "师徒"
            }
        }
        
        var planetImgName: String {
            switch self {
            case .bosomFriend: return "gxq_rk_zhiyou"
            case .confidante: return "gxq_rk_guimi"
            case .bestFriend: return "gxq_rk_sidang"
            case .masterApprentice: return "gxq_rk_shitu"
            }
        }
        
        var ringLottieName: String {
            switch self {
            case .bosomFriend: return "gxq_rk_shitu_zhiyou"
            case .confidante: return "gxq_rk_shitu_guimi"
            case .bestFriend: return "gxq_rk_shitu_sidang"
            case .masterApprentice: return "gxq_rk_shitu_shitu"
            }
        }
    }
    
    struct Layout {
        enum Location {
            case main
            case rightTop
            case rightMid
            case rightBottom
        }
        
        let location: Location
        let scale: CGFloat
        let center: CGPoint
        let imageAlpha: CGFloat
        let titleAlpha: CGFloat
        let titleScale: CGFloat
        
        func titleColors(style: Style) -> [UIColor] {
            switch location {
            case .main:
                switch style {
                case .bosomFriend: return [.rgb(62, 43, 93), .rgb(62, 43, 93)]
                case .confidante: return [.rgb(106, 49, 31), .rgb(106, 49, 31)]
                case .bestFriend: return [.rgb(51, 77, 52), .rgb(51, 77, 52)]
                case .masterApprentice: return [.rgb(36, 53, 79), .rgb(36, 53, 79)]
                }
                
            default:
                switch style {
                case .bosomFriend: return [.rgb(120, 152, 255), .rgb(211, 105, 255)]
                case .confidante: return [.rgb(255, 105, 150), .rgb(255, 184, 149)]
                case .bestFriend: return [.rgb(120, 255, 246), .rgb(255, 230, 105)]
                case .masterApprentice: return [.rgb(117, 138, 255), .rgb(116, 211, 255)]
                }
            }
        }
        
        static let main = Layout(location: .main,
                                 scale: 1,
                                 center: [0, 185.px + planetImgWH * 0.5],
                                 imageAlpha: 1,
                                 titleAlpha: 1,
                                 titleScale: 1)
        
        static let rightTop = Layout(location: .rightTop,
                                     scale: 70.px / planetImgWH,
                                     center: [universeSize.width - 95.px - 70.px * 0.5,
                                              CGFloat(85.px + 70.px * 0.5)],
                                     imageAlpha: 0.3,
                                     titleAlpha: 0.3,
                                     titleScale: 12.px / 23.px)
        
        static let rightMid = Layout(location: .rightMid,
                                     scale: 140.px / planetImgWH,
                                     center: [universeSize.width - (140.px * 0.5 - 45.px),
                                              CGFloat(185.px + 140.px * 0.5)],
                                     imageAlpha: 0.5,
                                     titleAlpha: 0.7,
                                     titleScale: 18.px / 23.px)
        
        static let rightBottom = Layout(location: .rightBottom,
                                        scale: 100.px / planetImgWH,
                                        center: [universeSize.width - 30.px - 100.px * 0.5,
                                                 CGFloat(464.px + 100.px * 0.5)],
                                        imageAlpha: 0.4,
                                        titleAlpha: 0.3,
                                        titleScale: 15.px / 23.px)
    }
}

extension PlanetView {
    class TitleView: UIView {
        
        let nameLabel = UILabel()
        let countLabel = UILabel()
        
        let nameView = GradientView()
        let countView = GradientView()
        
        let style: Style
        
        init(style: Style, layout: Layout, count: Int) {
            self.style = style
            super.init(frame: [0, 0, 46.px, (32.5 + 3 + 25.5).px])
            
            nameLabel.font = .systemFont(ofSize: 23.px, weight: .bold)
            nameLabel.text = style.title
            nameLabel.sizeToFit()
            nameLabel.height = 32.5.px
            
            nameView.startPoint(0, 0.5).endPoint(1, 0.5)
            nameView.frame = [HalfDiffValue(width, nameLabel.width), 0, nameLabel.width, nameLabel.height]
            nameView.addSubview(nameLabel)
            nameView.mask = nameLabel
            addSubview(nameView)
            
            countView.startPoint(0, 0.5).endPoint(1, 0.5)
            countView.addSubview(countLabel)
            countView.mask = countLabel
            addSubview(countView)
            
            updateLayout(layout, count: count, isInAnimated: false)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateLayout(_ layout: Layout, count: Int? = nil, isInAnimated: Bool) {
            var scale = layout.location == .main ? 1 : (1 / layout.scale)
            scale *= layout.titleScale
            
            let colors = layout.titleColors(style: style).map { $0.cgColor }
            
            defer {
                
                if isInAnimated {
                    let colorAnim1 = CABasicAnimation(keyPath: "colors")
                    colorAnim1.toValue = colors
                    colorAnim1.fillMode = .forwards
                    colorAnim1.isRemovedOnCompletion = false
                    colorAnim1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    colorAnim1.duration = planetSwitchDuration
                    
                    let colorAnim2 = CABasicAnimation(keyPath: "colors")
                    colorAnim2.toValue = colors
                    colorAnim2.fillMode = .forwards
                    colorAnim2.isRemovedOnCompletion = false
                    colorAnim2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    colorAnim2.duration = planetSwitchDuration
                    
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        self.nameView.gLayer.colors = colors
                        self.countView.gLayer.colors = colors
                    }
                    nameView.gLayer.add(colorAnim1, forKey: "colors")
                    countView.gLayer.add(colorAnim2, forKey: "colors")
                    CATransaction.commit()
                } else {
                    nameView.gLayer.colors = colors
                    countView.gLayer.colors = colors
                }
                
                alpha = layout.titleAlpha
                transform = .init(scaleX: scale, y: scale)
                center = [planetW * 0.5 + (layout.location == .main ? (20.px + 46.px * 0.5) : 0), planetH * 0.5]
            }
            
            var countX: CGFloat = layout.location == .main ? nameView.x : HalfDiffValue(width, countView.width)
            guard let count = count else {
                countView.x = countX
                return
            }
            
            guard count > 0 else {
                nameView.y = HalfDiffValue(height, nameView.height)
                
                countView.x = countX
                countView.alpha = 0
                return
            }
            
            let countStr = "\(count) 人"
            let countAttStr = NSMutableAttributedString(string: countStr, attributes: [.font: UIFont(name: "DINAlternate-Bold", size: 22.px)!])
            countAttStr.addAttributes([.font: UIFont.systemFont(ofSize: 11.px, weight: .bold), .baselineOffset: 1.px], range: NSMakeRange(countStr.count - 1, 1))
            
            countLabel.attributedText = countAttStr
            countLabel.sizeToFit()
            countLabel.height = 25.5.px
            
            nameView.y = 0
            if layout.location != .main { countX = HalfDiffValue(width, countLabel.width) }
            countView.frame = [countX, nameView.maxY + 3.px, countLabel.width, countLabel.height]
            countView.alpha = 1
        }
    }
}

class PlanetView: UIView {
    
    let style: Style
    var layout: Layout
    
    let planetImgView = UIImageView()
    var planetRingImgView: AnimationView!
    let scrollView = UIScrollView()
    lazy var peoples: [PeopleView] = {
        (0 ..< 15).map { PeopleView(tag: $0) }
    }()
    var peopleCount: Int { peoples.count }
    lazy var titleView: TitleView = { TitleView(style: style, layout: layout, count: peopleCount) }()
    
    weak var universe: UniverseView?
    
    init(style: Style, layout: Layout) {
        self.style = style
        self.layout = layout
        super.init(frame: [0, 0, planetW, planetH])
        clipsToBounds = false
//        backgroundColor = .randomColor
        
        planetImgView.image = UIImage(named: style.planetImgName)
        planetImgView.frame = [HalfDiffValue(planetW, planetImgWH),
                               HalfDiffValue(planetH, planetImgWH),
                               planetImgWH, planetImgWH]
        planetImgView.alpha = layout.imageAlpha
        addSubview(planetImgView)
        
        let planetRingImgView = AnimationView.jp.build(style.ringLottieName)
        planetRingImgView.loopMode = .loop
        planetRingImgView.frame = planetImgView.bounds
        planetRingImgView.isUserInteractionEnabled = false
        planetImgView.addSubview(planetRingImgView)
        self.planetRingImgView = planetRingImgView
        
        scrollView.jp.contentInsetAdjustmentNever()
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        addSubview(scrollView)
        
        peoples.forEach { scrollView.addSubview($0) }
        
        var contentH = onePeopleOffsetY * CGFloat(peopleCount)
        if contentH < minContentH { contentH = minContentH }
        scrollView.contentSize = [0, contentH]
        scrollView.contentInset = .init(top: topInset, left: 0, bottom: 0, right: 0)
        scrollView.contentOffset = [0, -topInset]
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchMainPlanet)))
        addSubview(titleView)
        
        var scale: CGFloat = 1
        var alpha: CGFloat = 1
        if layout.location != .main {
            scale = 300 / (330 + 60)
            alpha = 0
            planetRingImgView.stop()
            planetRingImgView.alpha = 0
        } else {
            planetRingImgView.play()
            planetRingImgView.alpha = 1
        }
        scrollView.transform = .init(scaleX: scale, y: scale)
        scrollView.alpha = alpha
        
        transform = .init(scaleX: layout.scale, y: layout.scale)
        center = layout.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlanetView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        let scale = offsetY / maxOffsetY
//        JPrint("offsetY:", offsetY)
//        JPrint("scale:", scale)
//        JPrint("onePeopleOffsetY:", onePeopleOffsetY)
//        JPrint("onePeopleRadian:", onePeopleRadian)
//        JPrint("----------------------")
        
        for i in 0 ..< peopleCount {
            let people = peoples[i]
            people.updateAlpha(offsetY)
            people.center = center
            
            // 弧度
            var radian: CGFloat = onePeopleRadian * CGFloat(i) - radian90
            radian -= scale * radian360
            
            let centerX: CGFloat = planetCirclePoint.x + planetRadius * cos(radian)
            let centerY: CGFloat = planetCirclePoint.y + planetRadius * sin(radian)
            people.center = [centerX, offsetY + centerY]
            people.currentRradian = radian
        }
    }
}

extension PlanetView {
    
    func showOrHidePeoples(_ isShow: Bool, completion: (() -> ())? = nil) {
        let scale: CGFloat = isShow ? 1 : (300 / (330 + 60))
        let alpha: CGFloat = isShow ? 1 : 0
        
        let ringScale: CGFloat = isShow ? 1 : 0.95
        
        if isShow {
            self.planetRingImgView.play()
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: []) {
            self.scrollView.transform = .init(scaleX: scale, y: scale)
            self.scrollView.alpha = alpha
            
            self.planetRingImgView.transform = .init(scaleX: ringScale, y: ringScale)
            self.planetRingImgView.alpha = alpha
        } completion: { _ in
            if !isShow {
                self.planetRingImgView.stop()
            }
            completion?()
        }
    }
    
    @objc func switchMainPlanet() {
        guard layout.location != .main, let universe = universe else { return }
        universe.isUserInteractionEnabled = false
        
        let currentMainPlanet = universe.mainPlanet
        
        let myLayout = layout
        let mainLayout = currentMainPlanet.layout
        
        currentMainPlanet.layout = myLayout
        layout = mainLayout
        universe.mainPlanet = self
        
        currentMainPlanet.showOrHidePeoples(false)
        
        let duration: TimeInterval = planetSwitchDuration
        
        
        var myControlPoint: CGPoint = .zero
        myControlPoint.x = max(myLayout.center.x, mainLayout.center.x)
        myControlPoint.y = min(myLayout.center.y, mainLayout.center.y)
        
        let myPath = UIBezierPath()
        myPath.move(to: myLayout.center)
        myPath.addQuadCurve(to: mainLayout.center, controlPoint: myControlPoint)
        
        let myPathAnim = CAKeyframeAnimation(keyPath: "position")
        myPathAnim.path = myPath.cgPath
        myPathAnim.fillMode = .forwards
        myPathAnim.isRemovedOnCompletion = false
        myPathAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        myPathAnim.duration = duration
        
        
        var taControlPoint: CGPoint = .zero
        taControlPoint.x = min(myLayout.center.x, mainLayout.center.x)
        taControlPoint.y = max(myLayout.center.y, mainLayout.center.y)
        
        let taPath = UIBezierPath()
        taPath.move(to: mainLayout.center)
        taPath.addQuadCurve(to: myLayout.center, controlPoint: taControlPoint)
        
        let taPathAnim = CAKeyframeAnimation(keyPath: "position")
        taPathAnim.path = taPath.cgPath
        taPathAnim.fillMode = .forwards
        taPathAnim.isRemovedOnCompletion = false
        taPathAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        taPathAnim.duration = duration
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
//            [weak self, weak currentMainPlanet] in
//            guard let self = self else { return }
//            self.layer.removeAllAnimations()
//            self.center = mainLayoutInfo.center
//
//            currentMainPlanet?.layer.removeAllAnimations()
//            currentMainPlanet?.center = myLayoutInfo.center
        }
        self.layer.add(myPathAnim, forKey: "position")
        currentMainPlanet.layer.add(taPathAnim, forKey: "position")
        CATransaction.commit()
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.layer.zPosition = 1
            self.transform = .init(scaleX: mainLayout.scale, y: mainLayout.scale)
            self.planetImgView.alpha = mainLayout.imageAlpha
            self.titleView.updateLayout(mainLayout, isInAnimated: true)

            currentMainPlanet.layer.zPosition = 0
            currentMainPlanet.transform = .init(scaleX: myLayout.scale, y: myLayout.scale)
            currentMainPlanet.planetImgView.alpha = myLayout.imageAlpha
            currentMainPlanet.titleView.updateLayout(myLayout, isInAnimated: true)

        } completion: { _ in
            self.layer.removeAllAnimations()
            self.center = mainLayout.center
            self.showOrHidePeoples(true)
            
            currentMainPlanet.layer.removeAllAnimations()
            currentMainPlanet.center = myLayout.center
            
            universe.isUserInteractionEnabled = true
        }
    }
    
}












































//extension PlanetView {
//
//    func peopleCenteres(_ offsetY: CGFloat) -> [CGPoint] {
//        var centeres: [CGPoint] = []
//
//        let scale = offsetY / maxOffsetY
//
//        for i in 0 ..< peopleCount {
//            // 弧度
//            var radian: CGFloat = onePeopleRadian * CGFloat(i) - radian90
//            radian -= scale * radian360
//
//            let centerX: CGFloat = planetCirclePoint.x + planetRadius * cos(radian)
//            let centerY: CGFloat = planetCirclePoint.y + planetRadius * sin(radian)
//            centeres.append([centerX, offsetY + centerY])
//        }
//
//        return centeres
//    }
//
//}
