//
//  MemorySizeViewController.swift
//  Neves
//
//  Created by aa on 2021/12/20.
//

class MemorySizeViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lookRefSize()
        
        JPrint("------- 我是分隔线 -------")
        
        lookValSize()
    }
    
    class JPPersonRef {
        var age: Int = 18 // 8
        var isMan: Bool = true // 1
        var isRich: Bool = false // 1
        var games: [String] = ["lolm", "yuanshen"] // 8
        // 每个实例对象最少都有16个字节，开头第一个8字节用来存放【指向类型信息】，开头第二个8字节用来存放【引用计数】
        // (8 + 8) + 8 + 1 + 1 + 8 = 34
        // ==> 8 * 5 = 40 ---- `class_getInstanceSize`获取实例对象至少需要占用多少内存，这个函数算出来的一般是按【8】对齐
        // ==> 16 * 3 = 48 --- `Malloc`函数分配的内存大小总是【16】的倍数
    }
    
    func lookRefSize() {
        // MemoryLayout只能用于查看【值类型】的大小，不能查看【引用类型】
        JPrint(MemoryLayout<JPPersonRef>.size)
        JPrint(MemoryLayout<JPPersonRef>.stride) // 8 这里是返回JPPerson所生成的<指针变量>的大小，而指针变量只占8个字节
        JPrint(MemoryLayout<JPPersonRef>.alignment)
        
        // class_getInstanceSize 获取实例对象至少需要占用多少内存，这个函数算出来的一般是按【8】对齐
        JPrint(class_getInstanceSize(JPPersonRef.self)) // 40
        // 这里只是告诉我们这个实例对象至少要40个字节（以8对齐算出来的），而实际上是占用48个字节（以16对齐）
        
        let per = JPPersonRef()
        
        // 方式1：MJ工具
        JPrint(Mems.size(ofRef: per)) // 48
        
        // 方式2：Foundation + MJ工具
        let ptr = Mems.ptr(ofRef: per) // 获得指针per所指向内存的地址（实例对象在堆空间的地址）
        JPrint(malloc_size(ptr)) // 48 传入对象在堆空间的地址，返回分配给这个对象的内存大小，按16对齐；只要不是堆空间的就返回0
        
        // `Mems.size(ofRef: per)`内部是调用了`malloc_size(Mems.ptr(ofRef: per))`
    }
    
    
    struct JPPersonVal {
        var name: String = "meinanping" // 16
        var age: Int = 18 // 8
        var isMan: Bool = true // 1
        var isRich: Bool = true // 1
        // MemoryLayout<JPPersonVal>.size ==> 16 + 8 + 1 + 1 = 26
        // MemoryLayout<JPPersonVal>.stride ==> 8 * 4 = 32 ---- 因为按【8】对齐，并且26大于24，所以要分配32（`24` < 26 <= `32`）
        // MemoryLayout<JPPersonVal>.alignment ==> 8 ---- 按【8】对齐
    }
    
    func lookValSize() {
        // MemoryLayout只能用于查看【值类型】的大小
        JPrint(MemoryLayout<JPPersonVal>.size) // 26 -------- 至少要多少个字节
        JPrint(MemoryLayout<JPPersonVal>.stride) // 32 ------ 实际占用了多少个字节
        JPrint(MemoryLayout<JPPersonVal>.alignment) // 8 ---- 以多少个字节来对齐
        
        var per = JPPersonVal()
        
        // MJ工具：查看内存的字节分布（默认8个字节为一组）
        JPrint(Mems.memStr(ofVal: &per))
        
        // MJ工具：查看分配内存大小
        JPrint(Mems.size(ofVal: &per)) // 32
        
        // `malloc_size`只能查看【引用类型】，只要不是堆空间的就返回0
        JPrint(malloc_size(Mems.ptr(ofRef: per))) // 0
    }

}
