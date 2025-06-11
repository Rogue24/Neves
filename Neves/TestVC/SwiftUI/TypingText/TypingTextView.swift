//
//  TypingTextView.swift
//  Neves
//
//  Created by aa on 2025/6/12.
//

import SwiftUI

struct TypingTextView: View {
    let fullText: String =
    """
    你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
    你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
    你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
    你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
    你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
    """
    let typingInterval: TimeInterval = 0.03

    @State private var displayText: String = ""
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    @State private var isAnimating = false

    var body: some View {
        ScrollView {
            Button("点我\(isAnimating ? "暂停" : "开始")") {
                if isAnimating {
                    stopAnimationAndShowAll()
                } else {
                    startTyping()
                }
            }
            Text(displayText)
                .font(.system(size: 17))
                .foregroundColor(.primary)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        }
        .padding()
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTyping() {
        displayText = ""
        currentIndex = 0
        isAnimating = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { t in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayText.append(fullText[index])
                currentIndex += 1
            } else {
                t.invalidate()
                isAnimating = false
            }
        }
    }

    private func stopAnimationAndShowAll() {
        timer?.invalidate()
        displayText = fullText
        isAnimating = false
    }
}
