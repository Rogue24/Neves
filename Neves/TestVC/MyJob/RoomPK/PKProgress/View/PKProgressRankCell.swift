//
//  PKProgressRankCell.swift
//  Neves
//
//  Created by aa on 2022/4/28.
//

class PKProgressRankCell<T: PKRankModelCompatible>: UICollectionViewCell {
    let userIcon = UIImageView()
    let rankingIcon = UIImageView()
    
    var model: T? = nil {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        userIcon.contentMode = .scaleAspectFill
        userIcon.layer.cornerRadius = 10.5
        userIcon.layer.masksToBounds = true
        contentView.addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rankingIcon.contentMode = .scaleToFill
        contentView.addSubview(rankingIcon)
        rankingIcon.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 19, height: 9))
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI() {
        guard let model = self.model else {
            userIcon.image = UIImage(named: "pk_blank_seat")
            rankingIcon.isHidden = true
            return
        }
        
        userIcon.image = UIImage(named: "jp_icon")
        rankingIcon.isHidden = false
        
        let ranking = model.getRanking()
        switch ranking {
        case 1:
            rankingIcon.image = UIImage(named: "pk_no1")
        case 2:
            rankingIcon.image = UIImage(named: "pk_no2")
        case 3:
            rankingIcon.image = UIImage(named: "pk_no3")
        default:
            break
        }
    }
}
