//
//  PopViewTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2021/4/16.
//

import UIKit

class PopViewTestViewController: TestBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        OptionPopView.show(title: "娃哈哈", actions: [
            .action(.remarks) { _, _, _ in },
            .action(.blacklist(true)) { _, _, _ in },
            .action(.report) { _, _, _ in },
            .action(.secondCreation) { _, _, _ in },
            .action(.theTop(true)) { _, _, _ in },
            .action(.recommend(true)) { _, _, _ in },
            .action(.uninterested) { _, _, _ in },
            .action(.shield(true)) { _, _, _ in },
            .action(.delete) { _, _, _ in },
        ])
    }

}
