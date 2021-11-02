//
//  MagicCubeViewController.swift
//  Neves
//
//  Created by aa on 2021/7/15.
//

class MagicCubeViewController: TestBaseViewController {
    
//    var suspendView: MagicCubeSuspendView?
    weak var suspendView: JPMagicCubeSuspendView? = nil
    weak var bubbleView: JPMagicCubeBubbleView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let suspendView = self.suspendView else {
//            suspendView = MagicCubeSuspendView.show(on: view, contentInset: .init(top: NavTopMargin, left: 0, bottom: DiffTabBarH, right: 0))
            suspendView = JPMagicCubeSuspendView.show(on: view, contentInset: .init(top: NavTopMargin, left: 0, bottom: DiffTabBarH, right: 0))
            return
        }
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)
        
        guard !suspendView.frame.contains(point) else { return }
//        MagicCubeBubbleView.launch(on: view, site: suspendView.site, launchPoint: point)
        launchMagicCubeBubble(point)
    }
    
    func launchMagicCubeBubble(_ point: CGPoint) {
        let isToLeft = point.x <= view.width * 0.5
        let isToTop = (point.y - JPMagicCubeBubbleView.bubbleH) >= NavTopMargin
        
        let site: JPMagicCubeBubbleView.Site
        switch (isToLeft, isToTop) {
        case (true, true): site = .topLeft
        case (false, true): site = .topRight
        case (false, false): site = .bottomRight
        case (true, false): site = .bottomLeft
        }
        
        bubbleView?.stop(andRemove: true)
        bubbleView = JPMagicCubeBubbleView.launch(on: view, awardInfo: JPMagicGiftInfo(name: "美少男帅哥平", iconURL: ""), site: site, launchPoint: point) { bubble in
            bubble.removeFromSuperview()
        }
    }
}
