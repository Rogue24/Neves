//
//  HitokotoModel.swift
//  Neves
//
//  Created by aa on 2026/6/8.
//
//  接口文档：https://developer.hitokoto.cn/sentence
//  请求接口：https://v1.hitokoto.cn

import Foundation

/// 句子类型（`type`参数）
/// 参数  -  说明
/// a  -  动画
/// b  -  漫画
/// c  -  游戏
/// d  -  文学
/// e  -  原创
/// f  -  来自网络
/// g  -  其他
/// h  -  影视
/// i  -  诗词
/// j  -  网易云
/// k  -  哲学
/// l  -  抖机灵
/// 其他  -  作为 动画 类型处理
/// - 可选择多个分类，例如： ?c=a&c=c

struct HitokotoModel: Codable {
    /// 一言标识
    let id: Int
    /// 一言正文。编码方式 unicode。使用 utf-8。
    let hitokoto: String
    /// 类型。请参考句子类型
    let type: String
    /// 一言的出处
    let from: String
    /// 一言的作者
    let fromWho: String?
    /// 添加者
    let creator: String
    /// 添加者用户标识
    let creatorUid: Int
    /// 审核员标识
    let reviewer: Int
    /// 一言唯一标识；可以链接到 https://hitokoto.cn?uuid=[uuid] 查看这个一言的完整信息
    let uuid: String
    /// 提交方式
    let commitFrom: String
    /// 添加时间
    let createdAt: String
    /// 句子长度
    let length: Int

    enum CodingKeys: String, CodingKey {
        case id
        case hitokoto
        case type
        case from
        case fromWho = "from_who"
        case creator
        case creatorUid = "creator_uid"
        case reviewer
        case uuid
        case commitFrom = "commit_from"
        case createdAt = "created_at"
        case length
    }
}
