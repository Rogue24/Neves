//
//  CosmicExplorationStarView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import CoreGraphics
import UIKit

class CosmicExplorationStarView: UIView {
    
    class MultipleView: UIView {
        
        let bgImgView = UIImageView()
        let multipleLabel = UILabel()
        
        init?(_ planet: CosmicExploration.Planet) {
            let multiple = planet.multiple
            guard multiple > 0 else { return nil }
            
            let size: CGSize = [38.px, 21.px]
            super.init(frame: CGRect(origin: [planet.size.width - size.width - 17.5.px, 28.px], size: size))
            
            bgImgView.image = planet.multipleImg
            bgImgView.frame = bounds
            addSubview(bgImgView)
            
            multipleLabel.font = .systemFont(ofSize: 10.px)
            multipleLabel.frame = [0, 4.5.px, bounds.width, 12.px]
            multipleLabel.textColor = .rgb(255, 241, 156)
            multipleLabel.textAlignment = .center
            multipleLabel.text = "x\(multiple)倍"
            addSubview(multipleLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    let planet: CosmicExploration.Planet
    let bgImgView = UIImageView()
    
    var multiple: Int = 0
    let multipleView: MultipleView?
    
    init(_ model: CosmicExploration.PlanetModel) {
        let planet = model.planet
        self.planet = planet
        self.multipleView = MultipleView(planet)
        
        super.init(frame: planet.frame)
        
        bgImgView.image = planet.bgImg
        bgImgView.frame = bounds
        addSubview(bgImgView)
        
        multipleView.map { addSubview($0) }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClick)))
        
        updateSelected(model.isSelected, animated: false)
        updateBetGifts(model.betGifts, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("我心已死")
    }
    
}

extension CosmicExplorationStarView {
    @objc func didClick() {
        CosmicExplorationManager.shared.selectPlanet(planet)
    }
}

extension CosmicExplorationStarView {
    func updateSelected(_ isSelected: Bool, animated: Bool = true) {
        bgImgView.backgroundColor = isSelected ? .randomColor : .clear
        guard animated else { return }
        UIView.transition(with: bgImgView, duration: 0.2, options: .transitionCrossDissolve) {} completion: { _ in }
    }
    
    func updateBetGifts(_ betGifts: [CosmicExploration.BetGiftModel], animated: Bool = true) {
        JPrint("刷新礼物了喂")
    }
}


