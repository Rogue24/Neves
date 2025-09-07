//
//  LocalLLMViewController.swift
//  Neves
//
//  Created by aa on 2025/9/6.
//

import UIKit

class LocalLLMViewController: TestBaseViewController {
    private let inputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入问题"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送到 Ollama", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let outputView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.alwaysBounceVertical = true
        tv.keyboardDismissMode = .onDrag
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutUI()
        
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    private func layoutUI() {
        view.addSubview(inputField)
        view.addSubview(sendButton)
        view.addSubview(outputView)
        
        NSLayoutConstraint.activate([
            inputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 12),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            sendButton.widthAnchor.constraint(equalToConstant: 150),
            
            outputView.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            outputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            outputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            outputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func sendTapped() {
        guard let text = inputField.text, !text.isEmpty else { return }
        inputField.resignFirstResponder()
        outputView.text = ""
        Task {
            await sendStreamRequest(prompt: text)
        }
    }
    
    // 🔹 调用 Ollama API (流式)
    func sendStreamRequest(prompt: String) async {
        guard let url = URL(string: "http://127.0.0.1:11434/api/generate") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "deepseek-r1:8b",   // 改成你在 Ollama 本地加载的模型
            "prompt": prompt,
            "stream": true       // 开启流式输出
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            let (result, response) = try await URLSession.shared.bytes(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                await appendText("请求失败")
                return
            }
            
            for try await line in result.lines {
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["response"] as? String {
                    await appendText(token)
                }
            }
            
        } catch {
            await appendText("错误: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func appendText(_ text: String) async {
        outputView.text += text
        // 自动滚动到底部
        let range = NSRange(location: outputView.text.count, length: 1)
        outputView.scrollRangeToVisible(range)
    }
}

