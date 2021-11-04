//
//  DragonSlayerInspireView.Bubble.swift
//  Neves
//
//  Created by aa on 2021/11/3.
//

import UIKit

extension DragonSlayerInspireView {
    
    class Bubble: UIView {
        init(name: String) {
            super.init(frame: .zero)
            
            let addIcon = UIImageView(frame: [6, 7, 6, 6])
            addIcon.image = UIImage(named: "album_xinqing_tc_add")
            addSubview(addIcon)
            
            let nameLabel = UILabel()
            nameLabel.font = .systemFont(ofSize: 10)
            nameLabel.textColor = UIColor(white: 1, alpha: 0.8)
            nameLabel.text = name
            nameLabel.sizeToFit()
            nameLabel.frame = [addIcon.frame.maxX + 3.5, 0, nameLabel.frame.width, 20]
            addSubview(nameLabel)
            
            frame = [0, 0, nameLabel.frame.maxX + 6, 20]
            layer.cornerRadius = 10
            layer.masksToBounds = true
            backgroundColor = .rgb(129, 80, 128)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
