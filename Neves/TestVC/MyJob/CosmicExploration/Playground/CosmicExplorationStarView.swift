//
//  CosmicExplorationStarView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import CoreGraphics

class CosmicExplorationStarView: UIView {
    
    let planet: CosmicExploration.Planet
    let bgImgView = UIImageView()
    
    init(_ planet: CosmicExploration.Planet) {
        self.planet = planet
        super.init(frame: planet.frame)
        bgImgView.image = planet.bgImg
        bgImgView.frame = bounds
        addSubview(bgImgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
