//
//  TypingLabelViewController.swift
//  Neves
//
//  Created by aa on 2025/6/12.
//

import UIKit
import FunnyButton

class TypingLabelViewController: TestBaseViewController {
    private let textView = UITextView()
    private var fullText: String = ""
    private var currentIndex = 0
    private var timer: Timer?
    private var isAnimating = false
    private let typingInterval: TimeInterval = 0.03
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            self?.handling()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
    private func setupTextView() {
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            textView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func startTyping(text: String) {
        fullText = text
        textView.text = ""
        currentIndex = 0
        isAnimating = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: typingInterval, target: self, selector: #selector(updateText), userInfo: nil, repeats: true)
    }
    
    @objc private func updateText() {
        guard currentIndex < fullText.count else {
            timer?.invalidate()
            isAnimating = false
            return
        }
        
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        let char = fullText[index]
        textView.text.append(char)
        currentIndex += 1
    }
    
    private func handling() {
        if isAnimating {
            timer?.invalidate()
            textView.text = fullText
            isAnimating = false
        } else {
            startTyping(text:
                """
                你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
                你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
                你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
                你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
                你好！我是 ChatGPT，我会逐字逐句地把回答展示给你。如果你点击文本，我会立刻显示完整内容哦。😊
                """
            )
        }
    }
}
