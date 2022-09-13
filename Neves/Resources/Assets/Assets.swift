// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "NevesColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = NevesColorAsset.Color
@available(*, deprecated, renamed: "NevesImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = NevesImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = NevesColorAsset(name: "AccentColor")
  internal static let albumVideobgJielong = NevesImageAsset(name: "album_videobg_jielong")
  internal static let coin = NevesImageAsset(name: "coin")
  internal static let roomCubeEntranceIcon = NevesImageAsset(name: "room_cube_entrance_icon")
  internal static let spaceFailTitle = NevesImageAsset(name: "space_fail_title")
  internal static let spaceVictoryTitle = NevesImageAsset(name: "space_victory_title")
  internal static let spaceshipStartTxt = NevesImageAsset(name: "spaceship_ start_txt")
  internal static let spaceshipSupplyTxt = NevesImageAsset(name: "spaceship_ supply_txt")
  internal static let spaceshipActiveBtn1 = NevesImageAsset(name: "spaceship_active_btn1")
  internal static let spaceshipActiveBtn2 = NevesImageAsset(name: "spaceship_active_btn2")
  internal static let spaceshipActiveBtn3 = NevesImageAsset(name: "spaceship_active_btn3")
  internal static let spaceshipActiveBtn4 = NevesImageAsset(name: "spaceship_active_btn4")
  internal static let spaceshipAddticket = NevesImageAsset(name: "spaceship_addticket")
  internal static let spaceshipAwardTitle = NevesImageAsset(name: "spaceship_award_title")
  internal static let spaceshipBag = NevesImageAsset(name: "spaceship_bag")
  internal static let spaceshipBg = NevesImageAsset(name: "spaceship_bg")
  internal static let spaceshipBlank = NevesImageAsset(name: "spaceship_blank")
  internal static let spaceshipClose = NevesImageAsset(name: "spaceship_close")
  internal static let spaceshipClose2 = NevesImageAsset(name: "spaceship_close2")
  internal static let spaceshipCoinBg = NevesImageAsset(name: "spaceship_coin_bg")
  internal static let spaceshipConfirmBtn = NevesImageAsset(name: "spaceship_confirm_btn")
  internal static let spaceshipFailTxt = NevesImageAsset(name: "spaceship_fail_txt")
  internal static let spaceshipFunctionBg = NevesImageAsset(name: "spaceship_function_bg")
  internal static let spaceshipGetticketBg = NevesImageAsset(name: "spaceship_getticket_bg")
  internal static let spaceshipGetticketTitle = NevesImageAsset(name: "spaceship_getticket_title")
  internal static let spaceshipGiveIcon = NevesImageAsset(name: "spaceship_give_icon")
  internal static let spaceshipMore = NevesImageAsset(name: "spaceship_more")
  internal static let spaceshipMoreBg = NevesImageAsset(name: "spaceship_more_bg")
  internal static let spaceshipMultipleBg01 = NevesImageAsset(name: "spaceship_multiple_bg01")
  internal static let spaceshipMultipleBg02 = NevesImageAsset(name: "spaceship_multiple_bg02")
  internal static let spaceshipMultipleBg03 = NevesImageAsset(name: "spaceship_multiple_bg03")
  internal static let spaceshipMultipleBg04 = NevesImageAsset(name: "spaceship_multiple_bg04")
  internal static let spaceshipMultipleBg05 = NevesImageAsset(name: "spaceship_multiple_bg05")
  internal static let spaceshipMultipleBg06 = NevesImageAsset(name: "spaceship_multiple_bg06")
  internal static let spaceshipMyresultTitle = NevesImageAsset(name: "spaceship_myresult_title")
  internal static let spaceshipNormalBtn1 = NevesImageAsset(name: "spaceship_normal_btn1")
  internal static let spaceshipNormalBtn2 = NevesImageAsset(name: "spaceship_normal_btn2")
  internal static let spaceshipNormalBtn3 = NevesImageAsset(name: "spaceship_normal_btn3")
  internal static let spaceshipNormalBtn4 = NevesImageAsset(name: "spaceship_normal_btn4")
  internal static let spaceshipNoticeIcon = NevesImageAsset(name: "spaceship_notice_icon")
  internal static let spaceshipNoticePattern = NevesImageAsset(name: "spaceship_notice_pattern")
  internal static let spaceshipNum0 = NevesImageAsset(name: "spaceship_num_0")
  internal static let spaceshipNum1 = NevesImageAsset(name: "spaceship_num_1")
  internal static let spaceshipNum2 = NevesImageAsset(name: "spaceship_num_2")
  internal static let spaceshipNum3 = NevesImageAsset(name: "spaceship_num_3")
  internal static let spaceshipNum4 = NevesImageAsset(name: "spaceship_num_4")
  internal static let spaceshipNum5 = NevesImageAsset(name: "spaceship_num_5")
  internal static let spaceshipNum6 = NevesImageAsset(name: "spaceship_num_6")
  internal static let spaceshipNum7 = NevesImageAsset(name: "spaceship_num_7")
  internal static let spaceshipNum8 = NevesImageAsset(name: "spaceship_num_8")
  internal static let spaceshipNum9 = NevesImageAsset(name: "spaceship_num_9")
  internal static let spaceshipNumS = NevesImageAsset(name: "spaceship_num_s")
  internal static let spaceshipOptionSelectedbg = NevesImageAsset(name: "spaceship_option_selectedbg")
  internal static let spaceshipPlanet01 = NevesImageAsset(name: "spaceship_planet01")
  internal static let spaceshipPlanet02 = NevesImageAsset(name: "spaceship_planet02")
  internal static let spaceshipPlanet03 = NevesImageAsset(name: "spaceship_planet03")
  internal static let spaceshipPlanet04 = NevesImageAsset(name: "spaceship_planet04")
  internal static let spaceshipPlanet05 = NevesImageAsset(name: "spaceship_planet05")
  internal static let spaceshipPlanet06 = NevesImageAsset(name: "spaceship_planet06")
  internal static let spaceshipPlanetS01 = NevesImageAsset(name: "spaceship_planet_s01")
  internal static let spaceshipPlanetS02 = NevesImageAsset(name: "spaceship_planet_s02")
  internal static let spaceshipPlanetS03 = NevesImageAsset(name: "spaceship_planet_s03")
  internal static let spaceshipPlanetS04 = NevesImageAsset(name: "spaceship_planet_s04")
  internal static let spaceshipPlanetS05 = NevesImageAsset(name: "spaceship_planet_s05")
  internal static let spaceshipPlanetS06 = NevesImageAsset(name: "spaceship_planet_s06")
  internal static let spaceshipPlus = NevesImageAsset(name: "spaceship_plus")
  internal static let spaceshipPopupBg = NevesImageAsset(name: "spaceship_popup_bg")
  internal static let spaceshipPopupBg2 = NevesImageAsset(name: "spaceship_popup_bg2")
  internal static let spaceshipResultTitle = NevesImageAsset(name: "spaceship_result_title")
  internal static let spaceshipResultTxt2 = NevesImageAsset(name: "spaceship_result_txt 2")
  internal static let spaceshipResultTxt = NevesImageAsset(name: "spaceship_result_txt")
  internal static let spaceshipResultTxt01 = NevesImageAsset(name: "spaceship_result_txt01")
  internal static let spaceshipResultTxt02 = NevesImageAsset(name: "spaceship_result_txt02")
  internal static let spaceshipResultTxt03 = NevesImageAsset(name: "spaceship_result_txt03")
  internal static let spaceshipResultTxt04 = NevesImageAsset(name: "spaceship_result_txt04")
  internal static let spaceshipResultTxt05 = NevesImageAsset(name: "spaceship_result_txt05")
  internal static let spaceshipRuleTitle = NevesImageAsset(name: "spaceship_rule_title")
  internal static let spaceshipTicket = NevesImageAsset(name: "spaceship_ticket")
  internal static let spaceshipTips = NevesImageAsset(name: "spaceship_tips")
  internal static let spaceshipTitle = NevesImageAsset(name: "spaceship_title")
  internal static let spaceshipVictoryBg = NevesImageAsset(name: "spaceship_victory_bg")
  internal static let spacesihpContinueBtn = NevesImageAsset(name: "spacesihp_continue_btn")
  internal static let spacesihpMoreBtn = NevesImageAsset(name: "spacesihp_more_btn")
  internal static let supercubeSIcon = NevesImageAsset(name: "supercube_s_icon")
  internal static let albumXinqingTcAdd = NevesImageAsset(name: "album_xinqing_tc_add")
  internal static let dragonBattleBg = NevesImageAsset(name: "dragon_battle_bg")
  internal static let dragonBattleBtn0attack = NevesImageAsset(name: "dragon_battle_btn_0attack")
  internal static let dragonBattleBtnAttack = NevesImageAsset(name: "dragon_battle_btn_attack")
  internal static let dragonBattleBtnEnd = NevesImageAsset(name: "dragon_battle_btn_end")
  internal static let dragonBattleBtnEnd2 = NevesImageAsset(name: "dragon_battle_btn_end2")
  internal static let dragonBattleBtnWait = NevesImageAsset(name: "dragon_battle_btn_wait")
  internal static let dragonBattleIconClose = NevesImageAsset(name: "dragon_battle_icon_close")
  internal static let dragonBattleIconMission = NevesImageAsset(name: "dragon_battle_icon_mission")
  internal static let dragonBattleMesBg = NevesImageAsset(name: "dragon_battle_mes_bg")
  internal static let dragonCommonTcBg = NevesImageAsset(name: "dragon_common_tc_bg")
  internal static let dragonCommonTcBtn1 = NevesImageAsset(name: "dragon_common_tc_btn1")
  internal static let dragonCommonTcBtn2 = NevesImageAsset(name: "dragon_common_tc_btn2")
  internal static let dragonCommonTcBtn3 = NevesImageAsset(name: "dragon_common_tc_btn3")
  internal static let dragonGuwuBanner = NevesImageAsset(name: "dragon_guwu_banner")
  internal static let dragonGuwuBtn = NevesImageAsset(name: "dragon_guwu_btn")
  internal static let dragonIconGuwu1 = NevesImageAsset(name: "dragon_icon_guwu1")
  internal static let dragonIconGuwu2 = NevesImageAsset(name: "dragon_icon_guwu2")
  internal static let dragonKnife = NevesImageAsset(name: "dragon_knife")
  internal static let dragonLifeFull = NevesImageAsset(name: "dragon_life_full")
  internal static let dragonLifeHalf = NevesImageAsset(name: "dragon_life_half")
  internal static let dragonLifeOnefourth = NevesImageAsset(name: "dragon_life_onefourth")
  internal static let dragonLoseTcbg1 = NevesImageAsset(name: "dragon_lose_tcbg_1")
  internal static let dragonLoseTcbg2 = NevesImageAsset(name: "dragon_lose_tcbg_2")
  internal static let dragonLoseTcbg3 = NevesImageAsset(name: "dragon_lose_tcbg_3")
  internal static let dragonMissionTcRule = NevesImageAsset(name: "dragon_mission_tc_rule")
  internal static let dragonMissonIconDragon = NevesImageAsset(name: "dragon_misson_icon_dragon")
  internal static let dragonMissonIconEnterroom = NevesImageAsset(name: "dragon_misson_icon_enterroom")
  internal static let dragonMissonIconGift = NevesImageAsset(name: "dragon_misson_icon_gift")
  internal static let dragonMissonIconTime = NevesImageAsset(name: "dragon_misson_icon_time")
  internal static let dragonMissonTcBanner = NevesImageAsset(name: "dragon_misson_tc_banner")
  internal static let dragonMissonTcClose = NevesImageAsset(name: "dragon_misson_tc_close")
  internal static let dragonMissonTcTitle1 = NevesImageAsset(name: "dragon_misson_tc_title1")
  internal static let dragonMissonTcTitle2 = NevesImageAsset(name: "dragon_misson_tc_title2")
  internal static let dragonMissonTcTitle3 = NevesImageAsset(name: "dragon_misson_tc_title3")
  internal static let dragonMissonTcTitle4 = NevesImageAsset(name: "dragon_misson_tc_title4")
  internal static let dragonMultipleLifeBg = NevesImageAsset(name: "dragon_multiple_life_bg")
  internal static let dragonRankBg = NevesImageAsset(name: "dragon_rank_bg")
  internal static let dragonRankIconMyattack = NevesImageAsset(name: "dragon_rank_icon_myattack")
  internal static let dragonSingleLifeBg = NevesImageAsset(name: "dragon_single_life_bg")
  internal static let dragonTcBtnLong = NevesImageAsset(name: "dragon_tc_btn_long")
  internal static let dragonTcBtnShort = NevesImageAsset(name: "dragon_tc_btn_short")
  internal static let dragonTcGiftBg = NevesImageAsset(name: "dragon_tc_gift_bg")
  internal static let dragonTcRoomfull = NevesImageAsset(name: "dragon_tc_roomfull")
  internal static let dragonWeideng = NevesImageAsset(name: "dragon_weideng")
  internal static let dragonWinTcbg1 = NevesImageAsset(name: "dragon_win_tcbg_1")
  internal static let dragonWinTcbg2 = NevesImageAsset(name: "dragon_win_tcbg_2")
  internal static let dragonWinTcbg3 = NevesImageAsset(name: "dragon_win_tcbg_3")
  internal static let gxqIconQmz = NevesImageAsset(name: "gxq_icon_qmz")
  internal static let gxqLv1 = NevesImageAsset(name: "gxq_lv1")
  internal static let gxqLv2 = NevesImageAsset(name: "gxq_lv2")
  internal static let gxqLv3 = NevesImageAsset(name: "gxq_lv3")
  internal static let gxqLv4 = NevesImageAsset(name: "gxq_lv4")
  internal static let gxqLv5 = NevesImageAsset(name: "gxq_lv5")
  internal static let gxqLv6 = NevesImageAsset(name: "gxq_lv6")
  internal static let gxqLv7 = NevesImageAsset(name: "gxq_lv7")
  internal static let gxqRkGuimi = NevesImageAsset(name: "gxq_rk_guimi")
  internal static let gxqRkShitu = NevesImageAsset(name: "gxq_rk_shitu")
  internal static let gxqRkSidang = NevesImageAsset(name: "gxq_rk_sidang")
  internal static let gxqRkZhiyou = NevesImageAsset(name: "gxq_rk_zhiyou")
  internal static let popBlock = NevesImageAsset(name: "pop_block")
  internal static let popCancelblock = NevesImageAsset(name: "pop_cancelblock")
  internal static let popSetnotes = NevesImageAsset(name: "pop_setnotes")
  internal static let popSlogBlock = NevesImageAsset(name: "pop_slog_block")
  internal static let popSlogBlockCancel = NevesImageAsset(name: "pop_slog_block_cancel")
  internal static let popSlogDelete = NevesImageAsset(name: "pop_slog_delete")
  internal static let popSlogRecommend = NevesImageAsset(name: "pop_slog_recommend")
  internal static let popSlogRecommendCancel = NevesImageAsset(name: "pop_slog_recommend_cancel")
  internal static let popSlogRedesign = NevesImageAsset(name: "pop_slog_redesign")
  internal static let popSlogReport = NevesImageAsset(name: "pop_slog_report")
  internal static let popSlogTop = NevesImageAsset(name: "pop_slog_top")
  internal static let popSlogTopCancel = NevesImageAsset(name: "pop_slog_top_cancel")
  internal static let popSlogUninterst = NevesImageAsset(name: "pop_slog_uninterst")
  internal static let icAllForward = NevesImageAsset(name: "ic_all_forward")
  internal static let jpIcon = NevesImageAsset(name: "jp_icon")
  internal static let albumBzLyAutomatic = NevesImageAsset(name: "album_bz_ly_automatic")
  internal static let albumBzPlayDefault = NevesImageAsset(name: "album_bz_play_default")
  internal static let albumBzPlaySelected = NevesImageAsset(name: "album_bz_play_selected")
  internal static let albumEfOff = NevesImageAsset(name: "album_ef_off")
  internal static let albumEfOpen = NevesImageAsset(name: "album_ef_open")
  internal static let albumLzCountdown1 = NevesImageAsset(name: "album_lz_countdown_1")
  internal static let albumLzCountdown2 = NevesImageAsset(name: "album_lz_countdown_2")
  internal static let albumLzCountdown3 = NevesImageAsset(name: "album_lz_countdown_3")
  internal static let albumLzDown = NevesImageAsset(name: "album_lz_down")
  internal static let albumLzLinebg1 = NevesImageAsset(name: "album_lz_linebg1")
  internal static let albumLzLinebg2 = NevesImageAsset(name: "album_lz_linebg2")
  internal static let albumLzReplayCyd = NevesImageAsset(name: "album_lz_replay_cyd")
  internal static let albumLzReplayDb = NevesImageAsset(name: "album_lz_replay_db")
  internal static let albumLzUp = NevesImageAsset(name: "album_lz_up")
  internal static let albumRecordSinging = NevesImageAsset(name: "album_record_singing")
  internal static let recordBtnBack = NevesImageAsset(name: "record_btn_back")
  internal static let recordBtnIng = NevesImageAsset(name: "record_btn_ing")
  internal static let recordBtnSend1 = NevesImageAsset(name: "record_btn_send1")
  internal static let recordBtnStop = NevesImageAsset(name: "record_btn_stop")
  internal static let promptBubbleTriangle = NevesImageAsset(name: "prompt_bubble_triangle")
  internal static let quanziLevel1 = NevesImageAsset(name: "quanzi_level_1")
  internal static let quanziLevel10 = NevesImageAsset(name: "quanzi_level_10")
  internal static let quanziLevel11 = NevesImageAsset(name: "quanzi_level_11")
  internal static let quanziLevel12 = NevesImageAsset(name: "quanzi_level_12")
  internal static let quanziLevel13 = NevesImageAsset(name: "quanzi_level_13")
  internal static let quanziLevel14 = NevesImageAsset(name: "quanzi_level_14")
  internal static let quanziLevel15 = NevesImageAsset(name: "quanzi_level_15")
  internal static let quanziLevel16 = NevesImageAsset(name: "quanzi_level_16")
  internal static let quanziLevel17 = NevesImageAsset(name: "quanzi_level_17")
  internal static let quanziLevel18 = NevesImageAsset(name: "quanzi_level_18")
  internal static let quanziLevel2 = NevesImageAsset(name: "quanzi_level_2")
  internal static let quanziLevel3 = NevesImageAsset(name: "quanzi_level_3")
  internal static let quanziLevel4 = NevesImageAsset(name: "quanzi_level_4")
  internal static let quanziLevel5 = NevesImageAsset(name: "quanzi_level_5")
  internal static let quanziLevel6 = NevesImageAsset(name: "quanzi_level_6")
  internal static let quanziLevel7 = NevesImageAsset(name: "quanzi_level_7")
  internal static let quanziLevel8 = NevesImageAsset(name: "quanzi_level_8")
  internal static let quanziLevel9 = NevesImageAsset(name: "quanzi_level_9")
  internal static let quanziMingpaiHyd = NevesImageAsset(name: "quanzi_mingpai_hyd")
  internal static let fireBg = NevesImageAsset(name: "fire_bg")
  internal static let rocketListBanner1 = NevesImageAsset(name: "rocket_list_banner1")
  internal static let rocketListBanner2 = NevesImageAsset(name: "rocket_list_banner2")
  internal static let rocketListBg = NevesImageAsset(name: "rocket_list_bg")
  internal static let rocketListLabel = NevesImageAsset(name: "rocket_list_label")
  internal static let rocketListTips = NevesImageAsset(name: "rocket_list_tips")
  internal static let rocketRule = NevesImageAsset(name: "rocket_rule")
  internal static let rocketTcBg = NevesImageAsset(name: "rocket_tc_bg")
  internal static let rocketTcIconClose = NevesImageAsset(name: "rocket_tc_icon_close")
  internal static let pkBlankSeat = NevesImageAsset(name: "pk_blank_seat")
  internal static let pkConnectArrow = NevesImageAsset(name: "pk_connect_arrow")
  internal static let pkConnectBg = NevesImageAsset(name: "pk_connect_bg")
  internal static let pkDuelLogo = NevesImageAsset(name: "pk_duel_logo")
  internal static let pkEmptybottle = NevesImageAsset(name: "pk_emptybottle")
  internal static let pkFlyingstar = NevesImageAsset(name: "pk_flyingstar")
  internal static let pkFmStar = NevesImageAsset(name: "pk_fm_star")
  internal static let pkFollowIcon = NevesImageAsset(name: "pk_follow_icon")
  internal static let pkFullbottle = NevesImageAsset(name: "pk_fullbottle")
  internal static let pkIcon = NevesImageAsset(name: "pk_icon")
  internal static let pkInviteBg = NevesImageAsset(name: "pk_invite_bg")
  internal static let pkJoinBtnbg = NevesImageAsset(name: "pk_join_btnbg")
  internal static let pkListBlank = NevesImageAsset(name: "pk_list_blank")
  internal static let pkListNo1 = NevesImageAsset(name: "pk_list_no1")
  internal static let pkListNo2 = NevesImageAsset(name: "pk_list_no2")
  internal static let pkListNo3 = NevesImageAsset(name: "pk_list_no3")
  internal static let pkMicLeave = NevesImageAsset(name: "pk_mic_leave")
  internal static let pkNo1 = NevesImageAsset(name: "pk_no1")
  internal static let pkNo2 = NevesImageAsset(name: "pk_no2")
  internal static let pkNo3 = NevesImageAsset(name: "pk_no3")
  internal static let pkProgressBule = NevesImageAsset(name: "pk_progress_bule")
  internal static let pkProgressRed = NevesImageAsset(name: "pk_progress_red")
  internal static let pkResultDraw = NevesImageAsset(name: "pk_result_draw")
  internal static let pkResultFail = NevesImageAsset(name: "pk_result_fail")
  internal static let pkResultVictory = NevesImageAsset(name: "pk_result_victory")
  internal static let pkRoomBg = NevesImageAsset(name: "pk_room_bg")
  internal static let pkStarActive1 = NevesImageAsset(name: "pk_star_active1")
  internal static let pkStarActive2 = NevesImageAsset(name: "pk_star_active2")
  internal static let pkStarActive3 = NevesImageAsset(name: "pk_star_active3")
  internal static let pkStarActive4 = NevesImageAsset(name: "pk_star_active4")
  internal static let pkStarActive5 = NevesImageAsset(name: "pk_star_active5")
  internal static let pkStarActive6 = NevesImageAsset(name: "pk_star_active6")
  internal static let pkStarEmptybottleActive = NevesImageAsset(name: "pk_star_emptybottle_active")
  internal static let pkStarEmptybottleGrey = NevesImageAsset(name: "pk_star_emptybottle_grey")
  internal static let pkStarGrey1 = NevesImageAsset(name: "pk_star_grey1")
  internal static let pkStarGrey2 = NevesImageAsset(name: "pk_star_grey2")
  internal static let pkStarGrey3 = NevesImageAsset(name: "pk_star_grey3")
  internal static let pkStarGrey4 = NevesImageAsset(name: "pk_star_grey4")
  internal static let pkStarGrey5 = NevesImageAsset(name: "pk_star_grey5")
  internal static let pkStarGrey6 = NevesImageAsset(name: "pk_star_grey6")
  internal static let pkStartBtnbg = NevesImageAsset(name: "pk_start_btnbg")
  internal static let pkYuleBgLong = NevesImageAsset(name: "pk_yule_bg_long")
  internal static let pkYuleBgShort = NevesImageAsset(name: "pk_yule_bg_short")
  internal static let roomMoreAdminPk = NevesImageAsset(name: "room_more_admin_pk")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class NevesColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension NevesColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: NevesColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct NevesImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension NevesImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the NevesImageAsset.image property")
  convenience init?(asset: NevesImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
