//
//  DragonSlayerBanner.View.swift
//  Neves
//
//  Created by aa on 2021/11/2.
//

import UIKit

extension DragonSlayerBanner {
    
    class Container: FloatContainer {
        weak var banner: Banner?
        
        static func create(on view: UIView) -> Container {
            let c = Container(frame: [0, NavTopMargin, PortraitScreenWidth, 150])
//            c.backgroundColor = .randomColor(0.3)
            view.addSubview(c)
            return c
        }
        
        func showBanner(withInfo info: Info, completion: @escaping () -> ()) {
            
            let banner = self.banner ?? {
                let b = Banner()
                addSubview(b)
                self.banner = b
                return b
            }()
            
            banner.alpha = 0
            banner.frame.origin.y = bannerY
            banner.label.text = info.title
            
            UIView.animate(withDuration: 0.25) {
                banner.alpha = 1
            } completion: { _ in
                
                JPrint("正在展示横幅 ---", info.title, ", 停留", info.duration)
                
                Asyncs.mainDelay(info.duration) {
                    UIView.animate(withDuration: 0.25) {
                        banner.alpha = 0
                    } completion: { _ in
                        completion()
                    }
                }
            }
        }
        
        var bannerY: CGFloat = 0 {
            didSet {
                guard bannerY != oldValue, let banner = self.banner else {
                    return
                }
                
                UIView.animate(withDuration: 0.25) {
                    banner.frame.origin.y = self.bannerY
                }
            }
        }
    }
    
    class Banner: UIView {
        let label = UILabel()
        
        init() {
            super.init(frame: [20, 0, PortraitScreenWidth - 40, 100])
            backgroundColor = .randomColor
            
            label.frame = bounds
            label.textColor = .randomColor
            label.font = .boldSystemFont(ofSize: 30)
            label.textAlignment = .center
            addSubview(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
