//
//  FuncTestViewController.swift
//  Neves
//
//  Created by 周健平 on 2020/12/12.
//

infix operator <*> : AdditionPrecedence
func <*><A, B>(fn: ((A) -> B)?, value: A?) -> B? {
    guard let f = fn, let v = value else { return nil }
    let result = f(v)
    return result // 返回的是B?，自动包装一层变回可选项返回
}

func ha(_ a: Int?, _ b: Int?) -> Int? {
    guard let aa = a, let bb = b else { return nil }
    let result = aa + bb
    return result // 返回的是Int?，自动包装一层变回可选项返回
}

class FuncTestViewController: TestBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value: Int? = 10
        let fn: ((Int) -> Int)? = { $0 * 2 }
        // Optional(20)
        JPrint(fn <*> value ?? 1)
        JPrint(ha(22, 11) as Any)
    }
}
