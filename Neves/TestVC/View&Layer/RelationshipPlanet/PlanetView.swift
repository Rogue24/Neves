//
//  PlanetPeopleView.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

class PlanetView: UIView {
    
    let style: RelationshipPlanet.Style
    var layout: RelationshipPlanet.Layout
    
    weak var universe: UniverseView?
    
    lazy var planetImgView: UIImageView = { UIImageView(image: UIImage(named: style.planetImgName)) }()
    lazy var planetRingImgView: AnimationView = { AnimationView.jp.build(style.ringLottieName) }()
    weak var turntableView: PeopleTurntableView?
    lazy var titleView: PlanetTitleView = { PlanetTitleView(style: style, layout: layout, count: 13) }()
    
    init(style: RelationshipPlanet.Style, layout: RelationshipPlanet.Layout) {
        self.style = style
        self.layout = layout
        super.init(frame: [0, 0, RelationshipPlanet.planetW, RelationshipPlanet.planetH])
        clipsToBounds = false
//        backgroundColor = .randomColor
        
        let planetImgWH = RelationshipPlanet.planetImgWH
        planetImgView.image = UIImage(named: style.planetImgName)
        planetImgView.frame = [HalfDiffValue(frame.width, planetImgWH),
                               HalfDiffValue(frame.height, planetImgWH),
                               planetImgWH, planetImgWH]
        planetImgView.alpha = layout.imageAlpha
        addSubview(planetImgView)
        
        let planetRingImgView = AnimationView.jp.build(style.ringLottieName)
        planetRingImgView.loopMode = .loop
        planetRingImgView.frame = planetImgView.bounds
        planetRingImgView.isUserInteractionEnabled = false
        planetImgView.addSubview(planetRingImgView)
        self.planetRingImgView = planetRingImgView
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchMainPlanet)))
        addSubview(titleView)
        
        if layout.location != .main {
            planetRingImgView.stop()
            planetRingImgView.alpha = 0
        } else {
            planetRingImgView.play()
            planetRingImgView.alpha = 1
        }
        
        transform = .init(scaleX: layout.scale, y: layout.scale)
        center = layout.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlanetView {
    @objc func switchMainPlanet() {
        guard layout.location != .main, let universe = universe else { return }
        universe.switchMainPlanet(self)
    }
}

extension PlanetView {
    
    func insertTurntableView(_ turntableView: PeopleTurntableView) {
        insertSubview(turntableView, belowSubview: titleView)
        self.turntableView = turntableView
    }
    
    func changeActivity(_ isActivity: Bool, completion: (() -> ())? = nil) {
        let scale: CGFloat = isActivity ? 1 : (300 / (330 + 60))
        let alpha: CGFloat = isActivity ? 1 : 0
        let ringScale: CGFloat = isActivity ? 1 : 0.95
        
        if isActivity { planetRingImgView.play() }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: []) {
            self.turntableView?.update(scale: scale, alpha: alpha)
            self.planetRingImgView.transform = .init(scaleX: ringScale, y: ringScale)
            self.planetRingImgView.alpha = alpha
        } completion: { _ in
            if !isActivity { self.planetRingImgView.stop() }
            completion?()
        }
    }
    
}










































//        let v1 = universe.viewWithTag(10086) ?? {
//            let view = UIView(frame: [0, 0, 30, 30])
//            view.tag = 10086
//            universe.addSubview(view)
//            return view
//        }()
//
//        v1.center = aaaaaaaaaaaaaaa(mainLayout.center, myLayout.center, length: 200)
//        v1.backgroundColor = .yellow
//
//        let v2 = universe.viewWithTag(10087) ?? {
//            let view = UIView(frame: [0, 0, 30, 30])
//            view.tag = 10087
//            universe.addSubview(view)
//            return view
//        }()
//
//        v2.center = aaaaaaaaaaaaaaa(myLayout.center, mainLayout.center, length: 200)
//        v2.backgroundColor = .green

//extension PlanetView {
//    func aaaaaaaaaaaaaaa(_ p1: CGPoint, _ p2: CGPoint, length: CGFloat) -> CGPoint {
//
//        let diffW = CGFloat(fabs(Double(p2.x - p1.x)))
//        let diffH = CGFloat(fabs(Double(p2.y - p1.y)))
//
//        let diffD = sqrt(pow(diffW, 2) + pow(diffH, 2))
//        let halfD = diffD * 0.5
//
//        let distance = sqrt(pow(halfD, 2) + pow(length, 2))
//
//        let diffR = atan(diffH / diffW)
//        let radian = atan(length / halfD)
//        let radian2 = radian - diffR
//        let radian3 = radian90 - radian2
//
//        let w = distance * sin(radian3)
//        let h = distance * cos(radian3)
//
//        JPrint("p1:", p1)
//        JPrint("p2:", p2)
//
//        JPrint("始角:", JPRadian2Angle(diffR))
//        JPrint("总角:", JPRadian2Angle(radian))
//        JPrint("差角:", JPRadian2Angle(radian2))
//        JPrint("终角:", JPRadian2Angle(radian3))
//
//        return [p2.x > p1.x ? (p1.x + w) : (p1.x - w), p2.y > p1.y ? (p1.y - h) : (p1.y + h)]
//
//    }
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
