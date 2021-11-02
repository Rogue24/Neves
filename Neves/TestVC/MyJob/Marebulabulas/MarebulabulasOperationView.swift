//
//  MarebulabulasOperationView.swift
//  Neves_Example
//
//  Created by aa on 2020/10/27.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class MarebulabulasOperationView: UIView {
    
    let progressBgView = UIView()
    let progressLayer = CALayer()
    let progressLabel = UILabel()
    
    var recordControl: MarebulabulasRecordControl!
    
    var state: RecordState = .idle

    init(frame: CGRect, type: MarebulabulasType) {
        super.init(frame: frame)
        
        let scale: CGFloat = frame.height > 255.5 ? (frame.height / 255.5) : 1
        _setupProgressPart(type, scale)
        _setupRecordPart(scale)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MarebulabulasOperationView {
    func _setupProgressPart(_ type: MarebulabulasType, _ scale: CGFloat) {
        let w: CGFloat = 128.5
        let h: CGFloat = 29
        let y: CGFloat = 20 * scale
        let x: CGFloat = HalfDiffValue(frame.width, w)
        progressBgView.frame = [x, y, w, h]
        progressBgView.layer.cornerRadius = h * 0.5
        progressBgView.layer.masksToBounds = true
        addSubview(progressBgView)
        
        progressLayer.frame = [0, 0, progressBgView.bounds.width * 0.5, h]
        progressBgView.layer.addSublayer(progressLayer)
        
        if type.isDialogue {
            progressBgView.backgroundColor = .rgb(97, 130, 235)
            progressLayer.backgroundColor = UIColor.rgb(50, 90, 227).cgColor
        } else {
            progressBgView.backgroundColor = .rgb(232, 102, 131)
            progressLayer.backgroundColor = UIColor.rgb(255, 55, 125, a: 0.42).cgColor
        }
        
        progressLabel.frame = progressBgView.bounds
        progressLabel.textAlignment = .center
        progressLabel.textColor = .white
        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.text = "专辑已合成 2/4"
        progressBgView.addSubview(progressLabel)
    }
    
    func _setupRecordPart(_ scale: CGFloat) {
        recordControl = MarebulabulasRecordControl(totalTime: 5, minTime: 2)
        
        let y: CGFloat = progressBgView.maxY + 47 * scale
        let x: CGFloat = HalfDiffValue(frame.width, recordControl.width)
        recordControl.origin = [x, y]
        insertSubview(recordControl, belowSubview: progressBgView)
    }
}
