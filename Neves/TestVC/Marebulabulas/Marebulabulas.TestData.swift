//
//  Marebulabulas.TestData.swift
//  Neves
//
//  Created by aa on 2020/11/2.
//

import Foundation

struct UU_VoiceInfo {
    var voiceId: UInt64

    /** use UU_VoiceType */
    var voiceType: UInt32

    /** 声音动态不记录用户位置信息，因为位置信息随时会变，客户端拿到声音动态(名片)后，再去批量获取用户信息拿位置信息 */
    var pubUid: UInt32

    /** 引导资源类型 use UU_GuideResType */
    var guideResType: UInt32

    /** 引导资源id，不直接保存内容，以便通过模板id进行控制内容传播 */
    var guideResId: UInt32

    /** 引导资源内的 组id */
    var guideGroupId: UInt32

    /** 引导资源块 id */
    var guideBlockId: UInt32

    /** 背景音乐url地址，可以通过替换、删除CDN资源来控制 */
    var bgmURL: String

    /** 背景图片url地址，如果是用户通过相册选择的，需要客户端先上传 */
    var bgpURL: String

    /** 背景图片是否使用的官方提供的图片 */
    var bgpIsGuide: Bool

    /** 用户录音文件url地址 */
    var userVoiceURL: String

    /** 展示的文字，json 格式 */
    var textContent: String

    /** 声音动态总时长 （单位毫秒） */
    var totalTime: UInt32

    /** 心情主题id */
    var themeId: UInt32

    /** 背景音乐开始的偏移值 （单位毫秒） */
    var bgmOffset: UInt32

    /** 合成视频 的下载地址，为空时需要本地合成并上传 cdn，并将视频url地址上报给服务器 */
    var videoURL: String

    /** 发布时间 */
    var pubTime: UInt32

    /** 是否为声音名片 */
    var isCard: Bool

    /** 是否曾经被设置过为名片 */
    var isHistoryCard: Bool

    /** 被收听总次数 */
    var listenNum: UInt32

    /** 被推荐次数 */
    var recommendNum: UInt32

    /** 被喜欢次数 */
    var likedNum: UInt32

    /** 被say hi 次数 */
    var hiNum: UInt32

    /** 是否被删除 */
    var isDeleted: Bool

    /** 用户原始录音文件url地址 */
    var userRawVoiceURL: String

    /** use UU_VoiceStatus */
    var status: UInt32

    /** use UU_VoiceSubStatus */
    var subStatus: UInt32

    /** 首次被设置为声音名片的时间 */
    var firstSetCardTime: UInt32

    /** 心情主题名称 */
    var themeName: String

    /** 纬度 */
    var latitude: Double

    /** 经度 */
    var longitude: Double

    /** 名片录制类型 use UU_VoiceCreateType */
    var voiceCreateType: UInt32

    /** 音色 */
    var voiceTone: String

    /** 背景音乐音量 */
    var bgmVolume: UInt32

    /** 人声原声音量 */
    var rawVolume: UInt32

    /** 声音消息下一段block */
    var guideNextBlockId: UInt32
}
