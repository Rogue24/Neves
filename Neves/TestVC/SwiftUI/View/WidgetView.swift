//
//  WidgetView.swift
//  Neves
//
//  Created by aa on 2022/6/13.
//

import SwiftUI

struct WidgetView: View {
    let dateInfo = Date().jp.info
    
    var body: some View {
        NavigationLink(destination: Text("哈哈")) {
            oneDayView
                .frame(width: 250, height: 250)
        }
    }
    
    var oneDayView: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(dateInfo.day)
                        .font(.custom("DINAlternate-Bold", size: 28))
                        .foregroundColor(.white)
                    + Text(" / \(dateInfo.month)")
                        .font(.custom("DINAlternate-Bold", size: 14))
                        .foregroundColor(.white)

                    Text("\(dateInfo.year), \(dateInfo.weekday)")
                        .font(.custom("PingFangSC", size: 10))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .baseShadow()

            Spacer()

            Text("一切都会好起来的")
                .font(.custom("PingFangSC", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                .lineSpacing(4)
                .baseShadow()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.black.opacity(0.15))
        .background(
            Image(uiImage: UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: "girl.jpg"))!)
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView()
    }
}
