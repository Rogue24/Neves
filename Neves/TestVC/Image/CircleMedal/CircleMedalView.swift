//
//  CircleMedalView.swift
//  Neves
//
//  Created by aa on 2021/4/30.
//

class CircleMedalView: UIView {
    
    let layout: CircleLevelView.Layout
    let space: CGFloat = 4
    
    var levelView: CircleLevelView? = nil
    var activeView: UIImageView? = nil
    var signinView: UIImageView? = nil
    
    init(layout: CircleLevelView.Layout) {
        self.layout = layout
        super.init(frame: [0, 0, 0, layout.rawValue])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(layout: CircleLevelView.Layout,
                     levelInfo: (level: Int, text: String)? = nil,
                     activeImage: UIImage? = nil,
                     signinImage: UIImage? = nil) {
        self.init(layout: layout)
        update(levelInfo: levelInfo, activeImage: activeImage, signinImage: signinImage)
    }
    
    func update(levelInfo: (level: Int, text: String)? = nil,
                activeImage: UIImage? = nil,
                signinImage: UIImage? = nil) {
        
        var frame = self.frame
        
        if let levelInfo = levelInfo {
            if let levelView = self.levelView {
                levelView.isHidden = false
                levelView.update(level: levelInfo.level, text: levelInfo.text)
            } else if let levelView = CircleLevelView(layout: layout, level: levelInfo.level, text: levelInfo.text) {
                addSubview(levelView)
                self.levelView = levelView
            }
        } else {
            levelView?.isHidden = true
        }
        
        frame.size.width = levelView?.frame.maxX ?? 0
        
        if let activeImage = activeImage {
            if let activeView = self.activeView {
                activeView.isHidden = false
                activeView.image = activeImage
            } else {
                let activeView = UIImageView(image: activeImage)
                addSubview(activeView)
                self.activeView = activeView
            }
            let x = frame.width == 0 ? 0 : (frame.width + space)
            activeView?.frame = [x, 0, layout.rawValue, layout.rawValue]
            frame.size.width = activeView?.frame.maxX ?? 0
        } else {
            activeView?.isHidden = true
        }
        
        if let signinImage = signinImage {
            if let signinView = self.signinView {
                signinView.isHidden = false
                signinView.image = signinImage
            } else {
                let signinView = UIImageView(image: signinImage)
                addSubview(signinView)
                self.signinView = signinView
            }
            let x = frame.width == 0 ? 0 : (frame.width + space)
            signinView?.frame = [x, 0, layout.rawValue, layout.rawValue]
            frame.size.width = signinView?.frame.maxX ?? 0
        } else {
            signinView?.isHidden = true
        }
        
        self.frame = frame
    }
}
