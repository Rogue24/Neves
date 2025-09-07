//
//  ChatClient.swift
//  Neves
//
//  Created by aa on 2025/9/7.
//

import Foundation

/// 通用 Chat API 客户端（兼容 OpenAI & Ollama）
///
/// Ollama 本地
/// let client = ChatClient(baseURL: "http://127.0.0.1:11434/v1")
///
/// OpenAI 云端
/// let client = ChatClient(baseURL: "https://api.openai.com/v1", apiKey: `你的OPENAI_KEY`)
///
class ChatClient {
    private let baseURL: String
    private let apiKey: String
    
    init(baseURL: String, apiKey: String = "") {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    // MARK: - 一次性返回完整结果
    func sendMessage(model: String, messages: [[String: String]]) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        } else {
            throw NSError(domain: "ChatClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "解析失败"])
        }
    }
    
    // MARK: - 流式输出
    func sendMessageStream(
        model: String,
        messages: [[String: String]],
        onToken: @escaping (String) -> Void
    ) async throws {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "stream": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (result, response) = try await URLSession.shared.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "ChatClient", code: -2, userInfo: [NSLocalizedDescriptionKey: "请求失败"])
        }
        
        for try await line in result.lines {
            guard line.hasPrefix("data: ") else { continue }
            let jsonString = String(line.dropFirst(6)) // 去掉 "data: "
            if jsonString == "[DONE]" { break }
            
            if let data = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let delta = choices.first?["delta"] as? [String: Any],
               let token = delta["content"] as? String {
                DispatchQueue.main.async {
                    onToken(token)
                }
            }
        }
    }
}

