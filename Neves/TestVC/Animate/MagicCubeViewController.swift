//
//  MagicCubeViewController.swift
//  Neves
//
//  Created by aa on 2021/7/15.
//


class MagicCubeViewController: TestBaseViewController {
    
    var suspendView: MagicCubeSuspendView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let suspendView = self.suspendView else {
            suspendView = MagicCubeSuspendView.show(on: view, contentInset: .init(top: NavTopMargin, left: 0, bottom: DiffTabBarH, right: 0))
            return
        }
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)
        
        guard suspendView.frame.contains(point) else { return }
        MagicCubeBubbleView.launch(on: view, site: suspendView.site, launchPoint: point)
    }
}

