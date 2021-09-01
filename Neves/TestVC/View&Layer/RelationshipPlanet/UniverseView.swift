//
//  UniverseView.swift
//  Neves
//
//  Created by aa on 2021/9/1.
//

class UniverseView: UIView {
    
    let bgAnimView = AnimationView.jp.build("gxq_bg_lottie")
    let bosomFriendPlanet = PlanetView(style: .bosomFriend, layout: .main)
    let confidantePlanet = PlanetView(style: .confidante, layout: .rightTop)
    let bestFriendPlanet = PlanetView(style: .bestFriend, layout: .rightMid)
    let masterApprenticePlanet = PlanetView(style: .masterApprentice, layout: .rightBottom)
    
    lazy var mainPlanet: PlanetView = bosomFriendPlanet
    
    init() {
        super.init(frame: .init(origin: .zero, size: universeSize))
        backgroundColor = .rgb(30, 27, 43)
        
        let bgH: CGFloat = width * (513.0 / 375.0)
        bgAnimView.loopMode = .loop
        bgAnimView.frame = [0, HalfDiffValue(height, bgH), width, bgH]
        bgAnimView.isUserInteractionEnabled = false
        
        bosomFriendPlanet.layer.zPosition = 1
        bosomFriendPlanet.universe = self
        confidantePlanet.universe = self
        bestFriendPlanet.universe = self
        masterApprenticePlanet.universe = self
        
        addSubview(bgAnimView)
        addSubview(bosomFriendPlanet)
        addSubview(confidantePlanet)
        addSubview(bestFriendPlanet)
        addSubview(masterApprenticePlanet)
        
        bgAnimView.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
