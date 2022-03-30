//
//  CosmicExplorationHostView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

class CosmicExplorationHostView: UIView {
    
    init() {
        let size: CGSize = [200.px, 200.px]
        super.init(frame: [HalfDiffValue(PortraitScreenWidth, size.width), 100.px, size.width, size.height])
        
        backgroundColor = .randomColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
    
    func updateStage(_ stage: CosmicExploration.Stage, animated: Bool) {
        
        
    }
}
