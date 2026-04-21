//
//  Date.Extension.swift
//  Neves
//
//  Created by aa on 2021/9/25.
//

extension Date: JPCompatible {}
extension JP where Base == Date {
    typealias DateInfo = (year: String, month: String, day: String, weekday: String)
    var info: DateInfo {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: base)
    
        let year = "\(components.year!)"
        let month = Months[components.month! - 1]
        let day = "\(components.day!)"
        let weekday = ShotWeekdays[components.weekday! - 1] // 星期几（注意，周日是“1”，周一是“2”。。。。）
        return (year, month, day, weekday)
    }
    
    var mmssString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: base)
    }
    
    var ssString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: base)
    }
}

extension Date {
    static let zeroTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// 获取那天0点时间戳
    static func getThatDayZeroTime(_ thatDayTime: TimeInterval) -> TimeInterval {
        let thatDayDate = Date(timeIntervalSince1970: thatDayTime)
        let thatDayZeroDateStr = zeroTimeFormatter.string(from: thatDayDate)
        let thatDayZeroDate = zeroTimeFormatter.date(from: thatDayZeroDateStr)
        return thatDayZeroDate?.timeIntervalSince1970 ?? 0
    }
    
    /// 获取今天0点时间戳
    static func getTodayZeroTime() -> TimeInterval {
        let todayTime = Date().timeIntervalSince1970
        return getThatDayZeroTime(todayTime)
    }
}
