//
//  KFImageTestView.swift
//  Neves
//
//  Created by aa on 2022/7/14.
//

import SwiftUI
import Kingfisher

@available(iOS 15.0.0, *)
struct TestView: View {
    var url: URL?
    var text: String
    
    @Binding var count: Int
    
    var body: some View {
        ZStack {
            AsyncImage(url: url) { phase in
                switch phase {
                // 请求中
                case .empty:
                    ProgressView()
                // 请求成功
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                // 请求失败
                case .failure:
                    Text("Failure")
                @unknown default:
                    ProgressView()
                }
            }
            
            VStack {
                Text(text)
                    .background(.blue)
                
                Button {
                    count += 1
                } label: {
                    Text("count \(count)")
                }
                .background(.red)
            }
        }
    }
}

@available(iOS 15.0.0, *)
struct KFImageTestView: View {
    
    @State var isLocal = false
    @State var url: URL? = nil
    @State var text: String = ""
    @State var count: Int = 0
    
    var body: some View {
        
        VStack {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .background(.red)
                .clipped()
            
            AsyncImage(url: url) { phase in
                switch phase {
                // 请求中
                case .empty:
                    ProgressView()
                // 请求成功
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                // 请求失败
                case .failure:
                    Text("Failure")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
            .background(.green)
            .clipped()
            
            HStack {
                TestView(url: url, text: text, count: $count)
                    .frame(width: 200, height: 200)
                    .background(.blue)
                    .clipped()
                
                Text("count \(count)")
            }
            
            HStack {
                Button {
                    isLocal.toggle()
                    if isLocal {
                        print("isReLoad 猫！")
                        url = URL(fileURLWithPath: Bundle.main.path(forResource: "Cat", ofType: "gif")!)
                        text = "法克鱿"
                        count = 100
                    } else {
                        print("isReLoad DesignCode！")
                        url = URL(string: "https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff6f34b91b5046c292092205bfc0aaea~tplv-k3u1fbpfcp-watermark.image?")
                        text = "曹尼玛"
                        count = 888
                    }
                } label: {
                    Image(systemName: "goforward")
                        .frame(width: 50, height: 50)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .accentColor(.white)
                }
                
            }
        }
    }
}
