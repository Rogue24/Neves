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
        /// `/api/chat/completions`：多轮对话接口，可以保持上下文，实现连续对话
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
        /// `/api/chat/completions`：多轮对话接口，可以保持上下文，实现连续对话
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

// MARK: - 常见的本地大模型 API 接口对比
///
/// ### 1. `POST /api/generate`
/// **功能**：最基础的文本生成接口，直接给模型一个 prompt，模型返回生成的文本。
/// **特点**：
///   * 类似早期 GPT-2/3 风格的生成接口。
///   * 输入一般是纯文本。
///   * 输出一般是生成文本。
/// **使用场景**：
///   * 单次生成任务。
///   * 不需要上下文管理或多轮对话。
///
/// ### 2. `POST /api/chat/completions`
/// **功能**：多轮对话接口，专门设计用于 chat 场景。
/// **特点**：
///   * 输入是一个数组，每条消息都有 `role`（`user`、`assistant`、`system`）和 `content`。
///   * 可以保持上下文，实现连续对话。
///   * 支持 system 指令（设定模型行为）和 user 指令（用户输入）。
/// **使用场景**：
///   * 聊天机器人、问答助手。
///   * 需要保持对话状态的场景。
///
/// ### 3. `POST /api/chat`（有些本地部署或老版本使用）
/// **功能**：和 `/api/chat/completions` 类似，也是对话接口。
/// **区别**：
///   * 一般是更老的接口或更轻量的接口，可能不支持像 OpenAI 那样的标准 `chat/completions` JSON 格式。
///   * 有些实现只接受一次性历史对话的完整文本。
///
/// ### 4. 其他可能的接口
/// 不同本地大模型服务或厂商可能还提供：
/// - `/api/embed` 或 `/api/embeddings`：文本向量化，用于语义搜索、相似度计算。
/// - `/api/edits`：文本编辑接口，比如给定原文 + 指令生成修改后的文本。
/// - `/api/stream`：流式输出接口，边生成边返回结果。
/// - `/api/files` 或 `/api/models`：模型管理或上传文件接口。
///
/// 💡 **总结**：
/// - **/generate** → 一次性文本生成，简单快速。
/// - **/chat/completions** → 多轮对话，支持上下文和 system 指令。
/// - **/chat** → 老版或轻量 chat 接口，可能功能不全。
/// - 其他接口更多是扩展功能，比如 embedding、编辑、流式输出等。
///
