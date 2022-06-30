//
//  JPUserInfo.swift
//  Neves
//
//  Created by aa on 2021/6/22.
//

class JPUserInfo: NSObject {
    /// 0：互相都没关注；1：只是自己关注了对方；2：只是对方关注了自己；3：互相关注；其他：未知，还没获取
    static let likeStatusRange: ClosedRange<Int> = 0 ... 3
    
    /** uid */
    var uid: Int = 0

    /** 昵称 */
    var nickName: String = ""

    /** 手机 */
    var phone: String = ""

    /** 用户性别 */
    var sex: Int = 0

    /** 头像 */
    var imgURL: String = ""

    /** 签名 */
    var sign: String = ""
    
    /** IM的id */
    var imId: Int = 0
    /** IM的id字符串，用于模糊搜索 */
    var imIdStr: String = ""

    var shortImId: Int = 0

    var ageTime: String = ""

    /** 跟随状态(1跟随) */
    var followStatus: Int = 0

    var cityName: String = ""

    var registerTime: Int = 0
    
    /** 0：互相都没关注；1：只是自己关注了对方；2：只是对方关注了自己；3：互相关注；其他：未知，还没获取 */
    var likeStatus: Int = 99
    
    /** 备注名 */
    var remarkName: String = ""
    
    /** 是否设置位置隐藏 */
    var isCityHide: Bool = false
    
    deinit {
        print("goto dead id: \(uid), nickName: \(nickName)")
    }
}

extension JPUserInfo: JPCacheObject {
    var jp_key: Int { uid }
}
