//
//  MarebulabulasLrcCell.swift
//  Neves_Example
//
//  Created by aa on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

struct MarebulabulasLrcCellModel {
    let iconURL: String
    let content: String
    let index: Int
    
    let lrcAttStr: NSAttributedString
    let lrcFrame: CGRect
    let cellHeight: CGFloat
    
    var isPlaying: Bool = false
    
    init(iconURL: String, content: String, index: Int) {
        self.iconURL = iconURL
        self.content = content
        self.index = index
        
        let lineSpace: CGFloat = 6
        let font = UIFont.boldSystemFont(ofSize: 17)
        let textColor = UIColor.white
        let maxSize = CGSize(width: MarebulabulasLrcCell.LrcMaxWidth, height: 999)
        
        var isOneLine: Bool = false
        
        lrcFrame = [MarebulabulasLrcCell.LrcX,
                    0,
                    maxSize.width,
                    content.textSize(withFont: font, lineSpace: lineSpace, isOneLine: &isOneLine, maxSize: maxSize).height]
        cellHeight = lrcFrame.height + 16
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.foregroundColor] = textColor
        if isOneLine == false {
            let parag = NSMutableParagraphStyle()
            parag.lineSpacing = lineSpace
            attributes[NSAttributedString.Key.paragraphStyle] = parag
        }
        lrcAttStr = NSAttributedString(string: content, attributes: attributes)
    }
}

class MarebulabulasLrcCell: UITableViewCell, CellReusable {
    
    static let LrcX: CGFloat = 38 + 30 + 33
    static let LrcMaxWidth = UIScreen.main.bounds.width - (LrcX + 44)
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var playingView: UIImageView!
    
    let lrcLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.layer.cornerRadius = 15
        iconView.layer.masksToBounds = true
        
        playingView.alpha = 0
        
        lrcLabel.numberOfLines = 0
        addSubview(lrcLabel)
    }

    func setupUI(_ cm: MarebulabulasLrcCellModel) {
        iconView.kf.setImage(with: URL(string: cm.iconURL), placeholder: UIImage(named: "jp_icon"))
        
        lrcLabel.attributedText = cm.lrcAttStr
        lrcLabel.frame = cm.lrcFrame
        lrcLabel.alpha = cm.isPlaying ? 1 : 0.5
        
        let isPlaying = playingView.alpha == 1
        if isPlaying != cm.isPlaying  {
            if cm.isPlaying {
                addPlayingAnim()
            } else {
                removePlayingAnim()
            }
        }
    }
    
    func addPlayingAnim() {
        if playingView.layer.animation(forKey: "transform.rotation.z") == nil {
            let anim = CABasicAnimation(keyPath: "transform.rotation.z")
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.duration = 5
            anim.toValue = CGFloat.pi * 2
            anim.repeatCount = 999
            playingView.layer.add(anim, forKey: "transform.rotation.z")
        }
        
        if playingView.alpha < 1 {
            UIView.animate(withDuration: 0.15) {
                self.playingView.alpha = 1
            }
        }
    }
    
    func removePlayingAnim() {
        if playingView.alpha > 0 {
            UIView.animate(withDuration: 0.15) {
                self.playingView.alpha = 0
            } completion: { _ in
                self.playingView.layer.removeAllAnimations()
            }
        }
    }
}
