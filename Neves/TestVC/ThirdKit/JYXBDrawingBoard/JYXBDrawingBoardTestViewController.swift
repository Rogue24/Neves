//
//  JYXBDrawingBoardTestViewController.swift
//  Neves
//
//  Created by aa on 2023/12/6.
//

import UIKit

class JYXBDrawingBoardTestViewController: TestBaseViewController {

    let board = JYXBOTODrawingBoard(frame: [50, 120, PortraitScreenWidth - 100, PortraitScreenHeight - 200])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        board.backgroundColor = .white
        view.addSubview(board)
    }
}
