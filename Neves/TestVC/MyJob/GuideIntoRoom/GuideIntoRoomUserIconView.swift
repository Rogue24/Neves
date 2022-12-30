//
//  GuideIntoRoomUserIconView.swift
//  Neves
//
//  Created by aa on 2022/12/30.
//

class GuideIntoRoomUserIconView: UIView, GuideIntoRoomContentViewCompatible {
    var viewSize: CGSize = .zero
    
    
    init() {
        self.viewSize = [GuideIntoRoomPopView.baseSize.width, CGFloat(83 + 10 + 24)]
        super.init(frame: .zero)
        backgroundColor = .randomColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
