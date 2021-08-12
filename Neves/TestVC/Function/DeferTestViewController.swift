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
        abc1()
        abc2()
    }
    
    /**
     * 1. 一个函数中可以有多个`defer`，同一层的`defer`都是以栈的形式添加的（先进后出）
     *
     * 2. `defer`可以被阻拦添加（例如添加新`defer`前就 return 了）
     *
     * 3. `defer`可以嵌套
     *  - 如果其中一层`defer`里面有多个子`defer`，执行这一层时同样也是以先进后出的顺序去执行里面的子`defer`
     *
     * 🌰 func abc1() { }
     * Self.sss == true：
     *  [03:30:20:40] [DeferTestViewController abc()] [第20行]: aaaa
        [03:30:20:41] [DeferTestViewController abc()] [第32行]: bbbbb
        [03:30:20:41] [DeferTestViewController abc()] [第29行]: cccccc
        [03:30:20:41] [DeferTestViewController abc()] [第23行]: dddddd
     * Self.sss == false：
     *  [03:32:19:66] [DeferTestViewController abc()] [第20行]: aaaa
        [03:32:19:66] [DeferTestViewController abc()] [第23行]: dddddd
     *
     * 4. `defer`可以访问【当前层】以及【所有外层`defer`】的任意变量（最外层是函数体）
     *  - 并且这些变量不是copy过来的，而是类似引用类型，是真的把变量传过来的，有关联的；
     *  - 而【所有内层`defer`】中的变量都无法访问。
     *
     * 🌰 func abc2() { }
     *  [01:37:55:89] [DeferTestViewController abc2()] [第95行]: a: 5, b: 5, c: 5, d: 5, e: 5
     */
    func abc1() {
        JPrint("---------- abc1 ----------")
        
        JPrint("aaaaaa 1") // 1
        
        defer {
            JPrint("gggggg 7") // 7
        }
        
        defer {
            // defer可以嵌套
            // 执行这一层时同样也是以先进后出的顺序去执行里面的子defer
            
            defer {
                JPrint("ffffff 6") // 6
            }
            
            defer {
                JPrint("eeeeee 5")  // 5
            }
            
            JPrint("dddddd 4") // 4
        }
        
        guard Self.sss else { return }
        
        // defer可以被阻拦添加
        
        defer {
            JPrint("cccccc 3") // 3
        }
        
        JPrint("bbbbbb 2") // 2
    }
    
    func abc2() {
        JPrint("---------- abc2 ----------")
        defer {
            defer {
                defer {
                    defer {
                        let e = 5
                        d += 1
                        c += 1
                        b += 1
                        a += 1
                        JPrint("a: \(a),", "b: \(b),", "c: \(c),", "d: \(d),", "e: \(e)")
                    }
                    var d = 4
                    c += 1
                    b += 1
                    a += 1
                }
                var c = 3
                b += 1
                a += 1
            }
            var b = 2
            a += 1
        }
        var a = 1
        
        // 无法访问内层defer的变量
//        b += 1
    }
}

