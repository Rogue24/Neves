//
//  AnimatedTypingTextView.swift
//  Neves
//
//  Created by aa on 2025/6/12.
//
//  学自：https://chatgpt.com/share/6849bf02-2228-800c-84c5-c987ae623725

import SwiftUI

struct AnimatedTypingTextView: View {
    let fullText: String =
    """
    你好，我是 ChatGPT，支持语义高亮、弹跳感动画、颜色渐变等高级动效。😎
    你好，我是 ChatGPT，支持语义高亮、弹跳感动画、颜色渐变等高级动效。😎
    你好，我是 ChatGPT，支持语义高亮、弹跳感动画、颜色渐变等高级动效。😎
    你好，我是 ChatGPT，支持语义高亮、弹跳感动画、颜色渐变等高级动效。😎
    你好，我是 ChatGPT，支持语义高亮、弹跳感动画、颜色渐变等高级动效。😎
    你好，我是 ChatGPT，支持语义高亮、弹跳感动画、颜色渐变等高级动效。😎
    """
    
    let typingInterval: TimeInterval = 0.05
    
    // 语义高亮关键词
    let highlightWords: [String] = ["ChatGPT", "高级动效", "语义"]

    @State private var revealedCount0: Int = 0
    @State private var revealedCount1: Int = 0
    
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
            
            FlowTextLayout0(text: fullText, revealedCount: revealedCount0)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            FlowTextLayout1(
                text: fullText,
                revealedCount: revealedCount1,
                highlightWords: highlightWords
            )
            .font(.system(size: 17))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .padding()
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTyping() {
        isAnimating = true
        timer?.invalidate()
        
        Task {
            for i in 0 ..< fullText.count {
                try? await Task.sleep(nanoseconds: UInt64(typingInterval * 1_000_000_000))
                revealedCount0 = i + 1
                revealedCount1 = i + 1
            }
        }
    }
    
    private func stopAnimationAndShowAll() {
        isAnimating = false
        timer?.invalidate()
        revealedCount0 = fullText.count
        revealedCount1 = fullText.count
    }
}



struct FlowTextLayout0: View {
    let text: String
    let revealedCount: Int

    // 控制字体、间距
    let spacing: CGFloat = 2
    let lineSpacing: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width

            var width: CGFloat = 0
            var height: CGFloat = 0

            ZStack(alignment: .topLeading) {
                ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                    Text(String(character))
                        .background(WidthReader())
                        .opacity(revealedCount > index ? 1 : 0)
                        .offset(y: revealedCount > index ? 0 : 10)
                        .animation(
                            .easeOut(duration: 0.25).delay(Double(index) * 0.02),
                            value: revealedCount
                        )
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > maxWidth {
                                width = 0
                                height -= d.height + lineSpacing
                            }
                            let result = width
                            if index == text.count - 1 {
                                width = 0 // 最后一个重置
                            } else {
                                width -= d.width + spacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if index == text.count - 1 {
                                height = 0 // 最后一个重置
                            }
                            return result
                        }
                }
            }
        }
        .frame(height: 300) // 高度你可以自适应处理
    }
}

struct WidthReader: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: WidthKey.self, value: geo.size.width)
        }
    }
}

struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        _ = nextValue()
    }
}




struct FlowTextLayout1: View {
    let text: String
    let revealedCount: Int
    let highlightWords: [String]

    let spacing: CGFloat = 2
    let lineSpacing: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width

            var width: CGFloat = 0
            var height: CGFloat = 0

            ZStack(alignment: .topLeading) {
                let characters = Array(text)
                let highlights = highlightIndices(in: text, words: highlightWords)

                ForEach(characters.indices, id: \.self) { index in
                    let char = characters[index]
                    let isHighlighted = highlights.contains(index)

                    Text(String(char))
                        .foregroundColor(
                            isHighlighted
                                ? .orange
                                : Color.black.opacity(revealedCount > index ? 1 : 0.4)
                        )
                        .scaleEffect(revealedCount > index ? 1 : 0.8)
                        .offset(y: revealedCount > index ? 0 : 6)
                        .opacity(revealedCount > index ? 1 : 0)
                        .animation(
                            .interpolatingSpring(stiffness: 200, damping: 15)
                            .delay(Double(index) * 0.02),
                            value: revealedCount
                        )
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > maxWidth {
                                width = 0
                                height -= d.height + lineSpacing
                            }
                            let result = width
                            if index == characters.count - 1 {
                                width = 0
                            } else {
                                width -= d.width + spacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if index == characters.count - 1 {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(height: 300)
    }

    // 高亮单词 → 返回字符 index 列表
    func highlightIndices(in text: String, words: [String]) -> Set<Int> {
        var indices = Set<Int>()
        let lowerText = text.lowercased()
        for word in words {
            let lw = word.lowercased()
            var searchStart = lowerText.startIndex
            while let range = lowerText.range(of: lw, range: searchStart..<lowerText.endIndex) {
                let start = lowerText.distance(from: lowerText.startIndex, to: range.lowerBound)
                for i in 0..<lw.count {
                    indices.insert(start + i)
                }
                searchStart = range.upperBound
            }
        }
        return indices
    }
}
