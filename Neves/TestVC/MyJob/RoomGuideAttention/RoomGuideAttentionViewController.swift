//
//  RoomGuideAttentionViewController.swift
//  Neves
//
//  Created by aa on 2021/11/23.
//

import UIKit

class RoomGuideAttentionViewController: TestBaseViewController {
    
    var bsTag = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            self.bsTag += 1
            self.launchBubble(AttentionBothSides.Model(name1: "美男", name2: "帅哥", tag: self.bsTag))
            JPrint("点了第\(self.bsTag)下")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunnyActions()
    }
    
    var models: [AttentionBothSides.Model] = []
    var bsViews: [AttentionBothSides.View] = []
}

extension RoomGuideAttentionViewController {
    
    func launchBubble(_ model: AttentionBothSides.Model) {
        models.append(model)
        tryLaunchBubble()
    }
    
    func tryLaunchBubble() {
        guard let model = models.first, bsViews.count < 2 else { return }
        models.remove(at: 0)
        
        let isFirst = bsViews.count == 0
        
        let bsView = AttentionBothSides.View.create(model, isFirst: isFirst, on: view)
        bsViews.append(bsView)
        bsView.show()
        
        if isFirst {
            tryNextTopBubble()
        }
    }
    
    func tryNextTopBubble() {
        Asyncs.mainDelay(2) { [weak self] in
            guard let self = self else { return }
            defer { self.tryLaunchBubble() }
            
            guard let topBsView = self.bsViews.first else { return }
            topBsView.hide()
            self.bsViews.remove(at: 0)
            
            guard let botBsView = self.bsViews.first else { return }
            botBsView.toTop()
            self.tryNextTopBubble()
        }
    }
    
}


extension RoomGuideAttentionViewController {
    
}
