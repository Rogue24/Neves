//
//  LocalLLMView.swift
//  Neves
//
//  Created by aa on 2025/9/7.
//

import SwiftUI

struct LocalLLMView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var isLoading = false
    // 绑定焦点状态
    @FocusState private var isTextFieldFocused: Bool
    
    // ✅ 使用 ChatClient（此处默认用 Ollama，本地 API）
    private let client = ChatClient(baseURL: "http://127.0.0.1:11434/v1")
    // 改成你在 Ollama 本地加载的模型
    private let model = "deepseek-r1:8b"
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("请输入问题", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isTextFieldFocused) // 关联焦点状态
            
            Button(action: {
                isTextFieldFocused = false // 点击后收起键盘
                Task {
//                    await sendStreamRequest_mySelf()
                    await sendStreamRequest_client()
                }
            }) {
                Text(isLoading ? "生成中..." : "发送到模型")
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isLoading || inputText.isEmpty)
            
            ScrollView {
                Text(outputText)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.black)
//            .scrollDismissesKeyboard(.immediately) // 滚动时收起键盘
        }
        .padding()
    }
}

// MARK: - 自己实现流式请求
private extension LocalLLMView {
    // 🔹 调用 Ollama API (流式)
    func sendStreamRequest_mySelf() async {
        guard let url = URL(string: "http://127.0.0.1:11434/api/generate") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "prompt": inputText,
            "stream": true // 开启流式输出
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            isLoading = true
            outputText = ""
            
            // 使用 URLSession.bytes 流式读取
            let (result, response) = try await URLSession.shared.bytes(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                outputText = "请求失败"
                isLoading = false
                return
            }
            
            for try await line in result.lines {
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["response"] as? String {
                    // 🔹 每次拼接一个 token
                    DispatchQueue.main.async {
                        self.outputText += token
                    }
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.outputText = "错误: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}

// MARK: - 使用 ChatClient（推荐）
private extension LocalLLMView {
    func sendStreamRequest_client() async {
        isLoading = true
        outputText = ""
        
        do {
            try await client.sendMessageStream(
                model: model,
                messages: [["role": "user", "content": inputText]]
            ) { token in
                Task { @MainActor in
                    self.outputText += token
                }
            }
        } catch {
            Task { @MainActor in
                self.outputText = "错误：\(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}
