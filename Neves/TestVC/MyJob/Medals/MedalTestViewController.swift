//
//  MedalTestViewController.swift
//  Neves
//
//  Created by aa on 2026/9/15.
//

import UIKit

class MedalTestViewController: TestBaseViewController {
    private var user: JKRCurrentUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JPHUD.show(isUserInteractionEnabled: true)
        var user: JKRCurrentUser? = nil
        Asyncs.asyncDelay(0.3) {
            guard let url = Bundle.main.url(forResource: "account_data", withExtension: "txt"),
                  let data = try? Data(contentsOf: url),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }
            user = JKRCurrentUser.mj_object(withKeyValues: dict)
        } mainTask: { [weak self] in
            guard let self else { return }
            guard let user else {
                JPHUD.showError(withStatus: "user 创建失败")
                return
            }
            JPHUD.dismiss()
            self.user = user
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.delegate = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction(name: "MedalWallPopViewController") { [weak self] in
            guard let self, let user = self.user else { return }
            MedalWallPopViewController.show(from: self, model: user)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunnyActions()
        JPHUD.dismiss()
    }
}
