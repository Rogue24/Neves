//
//  Setter.swift
//  Neves
//
//  Created by aa on 2022/6/22.
//
//  学自：https://zhuanlan.zhihu.com/p/415217937

/**
 * `@dynamicMemberLookup`：动态成员查询
 * 实现下标脚本函数`subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V?`，
 * 编译器会通过下标脚本函数，根据`KeyPath`就可以访问到对象不存在的属性。
 
 * 🌰🌰🌰🌰
 * `roomWidth`和`roomHeight`是属于`House.Room`的属性，创建`House`的对象，其中的`room`属性是私有不公开的，按照以往方式是无法访问的，
 * 使用`@dynamicMemberLookup`声明`House`，实现`subscript(dynamicMember keyPath: WritableKeyPath<House.Room, CGFloat>) -> CGFloat`，
 * 可以直接访问内部`room`属性的`roomWidth`和`roomHeight`属性。
 * PS：使用`WritableKeyPath`可以进行【读写】操作，而`KeyPath`只能只读。
     @dynamicMemberLookup
     struct House {
         struct Room {
             var roomWidth: CGFloat
             var roomHeight: CGFloat
         }
         
         private var room = Room(roomWidth: 100, roomHeight: 200)
         
         subscript(dynamicMember keyPath: WritableKeyPath<House.Room, CGFloat>) -> CGFloat {
             set { room[keyPath: keyPath] = newValue }
             get { room[keyPath: keyPath] }
         }
     }
 
     func test() {
         var house = House()
         
         JPrint("house.roomWidth:", house.roomWidth)
         JPrint("house.roomHeight:", house.roomHeight)
         
         house.roomWidth = 18
         house.roomHeight = 12
         
         JPrint("house.roomWidth:", house.roomWidth)
         JPrint("house.roomHeight:", house.roomHeight)
     }
 * 🌰🌰🌰🌰
 */

/**
 * `Setter`的使用：
 * 🌰🌰🌰🌰
     let myLabel = Setter(UILabel()) // -------------------------- 包装的`UILabel`对象
                .backgroundColor(.randomColor) // 设置背景色
                .font(.systemFont(ofSize: 25)) // 设置字体
                .textColor(.randomColor) // 设置文本颜色
                .text("zhoujianping") // 设置文本
                .frame([50, 120, 150, 50]) // 设置`frame`
                .subject // 最后返回`UILabel`对象（上面都是返回`Setter`本身，这里就是返回包装的对象本身了，中断链式）
     view.addSubview(myLabel)
 * 🌰🌰🌰🌰
 */
@dynamicMemberLookup
struct Setter<T> {
    let subject: T
    
    init(_ subject: T) {
        self.subject = subject
    }
    
    /// 返回的是一个函数，因此外部使用时将是：
    /// `Setter(UILabel()).text("abc")` 👉🏻👉🏻👉🏻 XXX.属性名(属性值)
    /// 首先是通过属性名调取下标脚本函数，然后返回的是函数，接着使用括号即是调用该函数，括号里面放的则是函数参数，即对应要修改的属性值。
    subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> ((V) -> Setter<T>) {
        var subject = self.subject
        return { value in
            subject[keyPath: keyPath] = value
            return Setter(subject)
        }
    }
}
