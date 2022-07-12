//
//  ResultBuilderView.swift
//  Neves_SwiftUI
//
//  Created by aa on 2022/7/6.
//
//  学自：https://cloud.tencent.com/developer/article/1906860

import SwiftUI

@resultBuilder
struct StringBuilder {
    // 整个函数体【每一行】返回的结果都会作为`components`的参数在这里集中处理最终返回
    static func buildBlock(_ components: String...) -> String {
        components.joined(separator: "🐶")
    }
    
    // 使用了`if {}`但没有`else {}`时，`else {}`的部分在这里补全
    static func buildOptional(_ component: String?) -> String {
        component ?? "(🐷what)"
    }
    
    // 使用了`if {} else {}`时，`if {}`的部分在这里返回
    static func buildEither(first component: String) -> String {
        component + "(🐦first)"
    }
    // 使用了`if {} else {}`时，`else {}`的部分在这里返回
    static func buildEither(second component: String) -> String {
        component + "(🐔second)"
    }
    
    // 使用了`for in`时，循环返回的全部结果会组成一个数组在这里返回处理
    static func buildArray(_ components: [String]) -> String {
        components.joined(separator: "🐻")
    }
    
    // 可以对原有的返回结果上进行加工（`component`就是`func buildBlock(_)`返回的结果）
    // PS：由于此处返回了相同的类型，所以后续重载的`func buildFinalResult(_)`中的`component`都是这里返回的结果。
    static func buildFinalResult(_ component: String) -> String {
        component //+ "!!!"
    }
    
    // 可以使用重载支持返回不同类型
    // 如果已经通过`func buildFinalResult(_)`返回了相同类型的结果，
    // 那么此处的`component`就是`func buildFinalResult(_)`返回的结果。
    static func buildFinalResult(_ component: String) -> Int {
        component.count
    }
}

@available(iOS 14.0.0, *)
struct ResultBuilderView: View {
    @State var isOpen = false
    @State var funcText = ""
    @State var x = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $isOpen) {
                Text("\(isOpen ? "is open": "no open")")
            }
            
            Divider()
            Group {
                Text("myString: \n\(myString)")
                Text("myStringWithoutElse: \n\(myStringWithoutElse)")
                Text("myStringWithElse: \n\(myStringWithElse)")
                Text("myStringWithLoop: \n\(myStringWithLoop)")
                Text("myStringCount: \n\(myStringCount)")
            }
            .multilineTextAlignment(.center)
            
            Divider()
            Button {
                x = (x + 1) % 5
            } label: {
                Text("x = \(x)")
            }
            Text("myStringWithSwitch: \n\(myStringWithSwitch)")
                .multilineTextAlignment(.center)
            
            Divider()
            Text("funcText: \n\(funcText)")
                .multilineTextAlignment(.center)
        }
        .onAppear() {
            funcText = isOpen ? myString2() : myStringWithLoop2()
        }
        .onChange(of: isOpen) { newValue in
            // 需要跑模拟器才能监听到确切的变化，Previews只会监听到前两次变化。
            funcText = newValue ? myString2() : myStringWithLoop2()
        }
        .padding(20)
    }
}

// MARK: - 基本使用
@available(iOS 14.0.0, *)
extension ResultBuilderView {
    @StringBuilder var myString: String {
        /// `@StringBuilder`标记的函数，其`{}`包裹的函数体称作【组件区域】，
        ///【组件区域】内的【每一行】返回的就是`buildBlock(_ component: T...)`的可变参数的【每一个组件】，所以每一行最终返回的结果必须是`T`类型。
        "wo"
        "shuai"
        
        /// 每一行都相当于一个小型函数（必须要返回`T`类型），
        /// 因此下面这种计算代码是不能写入到【组件区域】内。
//        x += 1
        
        /// 只要每一行最终返回的结果是`T`类型即可。
        isOpen ? "ojbk" : "ok"
    }
    
    
    @StringBuilder var myStringWithoutElse: String {
        "wo"
        "shuai"
        
        if isOpen {
            "[if {}]"
        }
        
        "(withoutElse)"
    }
    
    @StringBuilder var myStringWithElse: String {
        "wo"
        "shuai"
        
        if isOpen {
            "[if {}]"
        } else {
            "[else {}]"
        }
        
        "(withElse)"
    }
    
    @StringBuilder var myStringWithLoop: String {
        "wo"
        "shuai"
        
        if isOpen {
            for i in 0..<5 {
                "\(i)"
            }
        } else {
            for i in (0..<5).reversed() {
                "\(i)"
            }
        }
        
        "(loop)"
    }
    
    @StringBuilder var myStringCount: Int {
        myString
    }
    
    // `switch`的情况有点特殊，有待考量。
    // 不过只要`buildEither(first)`和`buildEither(second)`返回的是原值就没问题!
    @StringBuilder var myStringWithSwitch: String {
        switch x {
        case 0:
            myString
        case 1:
            myStringWithoutElse
        case 2:
            myStringWithElse
        case 3:
            myStringWithLoop
        default:
            "\(myStringCount)"
        }
        "(switch)"
    }
}

// MARK: - 等同写法
/// `@StringBuilder`标记的函数的执行效果说白了就是把【组件区域】内的全部组件（每一行的结果）作为其静态函数`buildBlock(_ component: T...)`的可变参数去调用。
@available(iOS 14.0.0, *)
extension ResultBuilderView {
    /// `@StringBuilder var myString: String {}`等价于以下写法：
    func myString2() -> String {
        StringBuilder.buildFinalResult(
            StringBuilder.buildBlock(
                "wo",
                "shuai",
                (isOpen ? "ojbk" : "ok")
            )
        )
    }
    
    /// `@StringBuilder var myStringWithLoop: String {}`等价于以下写法：
    func myStringWithLoop2() -> String {
        StringBuilder.buildFinalResult(
            StringBuilder.buildBlock(
                "wo",
                "shuai",
                {
                    if isOpen {
                        return StringBuilder.buildEither(first:
                            StringBuilder.buildArray(
                                Array(0..<5).map({ "\($0)" })
                            )
                        )
                    } else {
                        return StringBuilder.buildEither(second:
                            StringBuilder.buildArray(
                                Array(0..<5).reversed().map({ "\($0)" })
                            )
                        )
                    }
                }(),
                "(loop)"
            )
        )
    }
}

@available(iOS 14.0.0, *)
struct ResultBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        ResultBuilderView()
    }
}
