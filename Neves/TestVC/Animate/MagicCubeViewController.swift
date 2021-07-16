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
        guard suspendView == nil else { return }
        suspendView = MagicCubeSuspendView.show(on: view, contentInset: .init(top: NavTopMargin, left: 0, bottom: DiffTabBarH, right: 0))
    }
}

