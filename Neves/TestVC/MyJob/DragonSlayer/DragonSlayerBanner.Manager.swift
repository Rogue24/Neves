//
//  DragonSlayerBanner.Manager.swift
//  Neves
//
//  Created by aa on 2021/11/2.
//

import UIKit

enum DragonSlayerBanner {
    
    private static var container: Container?
    private static var window: UIWindow? {
        GetKeyWindow() ?? UIApplication.shared.keyWindow
    }
    
    private static var isShowing = false
    private static var bannerQueue: [Info] = []
    
    static var bannerY: CGFloat = 0 {
        didSet {
            container?.bannerY = bannerY
        }
    }
    
    static func show(_ info: Info) {
        bannerQueue.append(info)
        showIfNeed()
    }
    
    private static func showIfNeed() {
        guard !isShowing else { return }
        
        guard let window = window, let info = bannerQueue.first else {
            isShowing = false
            container?.removeFromSuperview()
            container = nil
            return
        }
        bannerQueue.remove(at: 0)
        
        let container = self.container.map {
            return $0
        } ?? {
            let c = Container.create(on: window)
            self.container = c
            return c
        }()
        container.bannerY = bannerY
        
        isShowing = true
        container.showBanner(withInfo: info) {
            isShowing = false
            showIfNeed()
        }
    }
}


