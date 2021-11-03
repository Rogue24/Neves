//
//  FunFloatButton.DragonSlayerBanner.swift
//  Neves
//
//  Created by aa on 2021/11/2.
//

extension FunFloatButton {
    
    static var num = 1
    static var top = true
    
    func addDragonSlayerBannerAction() {
        guard FunFloatButton.shared.tapMeAction == nil else { return }
        
        FunFloatButton.shared.tapMeAction = {
            
            if Self.num % 3 == 0 {
                DragonSlayerBanner.bannerY = Self.top ? 0 : 50
                Self.top.toggle()
                
                JPrint("换位置 ---", Self.num)
                Self.num += 1
                return
            }
            
            let duration = TimeInterval(1 + arc4random_uniform(2))
            let info = DragonSlayerBanner.Info(title: "\(Self.num)", duration: duration)
            DragonSlayerBanner.show(info)
            
            JPrint("放横幅 ---", Self.num)
            Self.num += 1
            
        }
    }
    
}
