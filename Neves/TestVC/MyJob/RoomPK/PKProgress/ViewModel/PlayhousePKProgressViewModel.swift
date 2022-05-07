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
        
        contentView.progressBgViewTopConstraint.constant = 41
        contentView.collectionViewTopConstraint.constant = 5
        
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func startPK() {
        super.startPK()
        infoView.leftResultImgView.image = nil
        infoView.rightResultImgView.image = nil
    }
    
    override func startPeakPK() {
        super.startPeakPK()
        infoView.leftResultImgView.image = nil
        infoView.rightResultImgView.image = nil
    }
    
    override func endPk() {
        super.endPk()
        
        var leftResultImgName = ""
        var rightResultImgName = ""
        
        let leftResult = Int.random(in: 0..<3)
        switch leftResult {
        case 0:
            leftResultImgName = "pk_result_victory"
            rightResultImgName = "pk_result_fail"
        case 1:
            leftResultImgName = "pk_result_fail"
            rightResultImgName = "pk_result_victory"
        case 2:
            leftResultImgName = "pk_result_draw"
            rightResultImgName = "pk_result_draw"
        default:
            return
        }
        
        infoView.leftResultImgView.image = UIImage(named: leftResultImgName)
        infoView.rightResultImgView.image = UIImage(named: rightResultImgName)
    }
    
}
