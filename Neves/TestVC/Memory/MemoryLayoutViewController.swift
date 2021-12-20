//
//  MemoryLayoutViewController.swift
//  Neves
//
//  Created by aa on 2021/12/20.
//

/*
 * 内存分布：
    低地址
        - 代码段（函数）
        - 数据段（常量、全局变量、类/元类对象）
            - 常量区
            - 静态区/全局区
        - 堆空间（对象）
        - 栈空间（局部变量）栈空间先进后出，内存地址分配是从最高开始，往低排
        - 动态库
    高地址
 */

class MemoryLayoutViewController: TestBaseViewController {
    
    func show()  {
        print("jp show")
    }
    
    private class JPPoint {
        var x = 11
        var y = 22
        func jpShow()  {
            var a = 10
            print(x, y, a)
            print("局部变量a所在的地址（栈空间）", Mems.ptr(ofVal: &a))
        }
    }
    
    static private var point = JPPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        show()
        
        let imp = method_getImplementation(class_getInstanceMethod(MemoryLayoutViewController.self, #selector(viewDidLoad))!)
        print(imp)
        
        Self.point.jpShow() // 0x100002340
        
        print("全局变量p所在的地址（数据段）", Mems.ptr(ofVal: &Self.point))
        print("指针p指向的对象地址（堆空间）", Mems.ptr(ofRef: Self.point))
    }
}
 
//p.jpShow() --- 0x0000000100002340     函数（代码段）    函数地址定死在代码段的
//show() ------- 0x0000000100001ed0     函数（代码段）    函数地址定死在代码段的
//p ------------ 0x0000000100007540     全局变量（数据段）
//*p ----------- 0x0000000102055e60     对象（堆空间）
//a ------------ 0x00007ffeefbff398     局部变量（栈空间） 数字很大的地址一般都是栈空间的


