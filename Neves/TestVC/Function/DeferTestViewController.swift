//
//  DeferTestViewController.swift
//  Neves
//
//  Created by aa on 2021/8/10.
//

import UIKit

class DeferTestViewController: TestBaseViewController {
    
    static var sss = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Self.sss.toggle()
        abc()
    }
    
    /**
     * 一个函数中可以有多个defer，每个defer都是以栈的形式添加的（先进后出），也可以被阻拦添加（添加defer前return）。
     * 打印：
     * Self.sss == true：
     *  [03:30:20:40] [DeferTestViewController abc()] [第20行]: aaaa
        [03:30:20:41] [DeferTestViewController abc()] [第32行]: bbbbb
        [03:30:20:41] [DeferTestViewController abc()] [第29行]: cccccc
        [03:30:20:41] [DeferTestViewController abc()] [第23行]: dddddd
     * Self.sss == false：
     *  [03:32:19:66] [DeferTestViewController abc()] [第20行]: aaaa
        [03:32:19:66] [DeferTestViewController abc()] [第23行]: dddddd
     */
    func abc() {
        JPrint("aaaa") // 1
        
        defer {
            JPrint("dddddd") // 4
        }
        
        guard Self.sss else { return }
        
        defer {
            JPrint("cccccc") // 3
        }
        
        JPrint("bbbbb") // 2
    }
    
}

