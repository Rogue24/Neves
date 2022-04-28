//
//  PlayhousePKProgressViewModel.swift
//  Neves
//
//  Created by aa on 2022/4/27.
//

class PlayhousePKProgressViewModel<T: PKRankModelCompatible>: PKProgressViewModel<T> {
    
    let infoView = PKProgressPlayhouseInfoView.loadFromNib()
    
    override init() {
        super.init()
        contentView.posAnimView.frame.origin.y = 32
        contentView.progressBgViewTopConstraint.constant = 41
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
