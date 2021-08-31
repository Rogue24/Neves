//
//  RelationshipPlanetViewController.swift
//  Neves
//
//  Created by aa on 2021/8/30.
//

import UIKit

class RelationshipPlanetViewController: TestBaseViewController {

    let planetView = PlanetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(30, 27, 43)
        
        let h: CGFloat = PortraitScreenWidth * (410.0 / 375.0)
        let bgImgView = UIImageView(image: UIImage(named: "gxq_bg_lottie"))
        bgImgView.frame = [0, HalfDiffValue(PortraitScreenHeight, h), PortraitScreenWidth, h]
        view.addSubview(bgImgView)
        
        planetView.x = -planetView.width * 0.5
        planetView.y = bgImgView.y + HalfDiffValue(h, planetView.height)
        view.addSubview(planetView)
    }
    
    

}
