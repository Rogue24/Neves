//
//  GuideIntoRoomPopView.swift
//  Neves
//
//  Created by aa on 2022/12/28.
//

class GuideIntoRoomPopView: UIView {
    
    static let baseSize: CGSize = [PortraitScreenWidth - 30, 300]
    
    var viewSize: CGSize = GuideIntoRoomPopView.baseSize
    
    let type: GuideIntoRoomType
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let closeBtn = NoHighlightButton()
    var contentView: GuideIntoRoomContentViewCompatible!
    let bottomBtn = NoHighlightButton()
    
    init(type: GuideIntoRoomType) {
        self.type = type
        super.init(frame: .zero)
        
        backgroundColor = .randomColor
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        titleLabel.font = UIFont(name: "PingFangSC-Semibold", size: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = type.title
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(8)
            make.height.equalTo(28)
        }
        
        closeBtn.setImage(UIImage(named: "roomguide_tc_icon_close"), for: .normal)
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        let subView = UIView()
        
        let onlineImageView = UIImageView()
        onlineImageView.image = UIImage(named: "paly_animation01")
        onlineImageView.animationImages = (1...9).map { UIImage(named: "paly_animation0\($0)")! }
        onlineImageView.animationDuration = 0.9
        onlineImageView.startAnimating()
        subView.addSubview(onlineImageView)
        onlineImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.top.left.bottom.equalToSuperview()
        }
        
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.8)
        subtitleLabel.text = type.subtitle(1000)
        subView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(onlineImageView.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        addSubview(subView)
        subView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        switch type {
        case .blindDate:
            contentView = GuideIntoRoomUserIconListView(isBlindDate: true)
        case .joyParty:
            contentView = GuideIntoRoomUserIconListView(isBlindDate: false)
        case .fm:
            contentView = GuideIntoRoomUserIconView()
        case let .gameTeam(id):
            contentView = GuideIntoRoomGameTeamCardListView(gameId: id)
        }
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.size.equalTo(contentView.viewSize)
            make.centerX.equalToSuperview()
            make.top.equalTo(subView.snp.bottom).offset(type.topInset)
        }
        
        bottomBtn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17)
        bottomBtn.setTitle(type.btnTitle, for: .normal)
        bottomBtn.setTitleColor(.rgb(30, 27, 43), for: .normal)
        bottomBtn.backgroundColor = .white
        bottomBtn.layer.cornerRadius = 21.5
        bottomBtn.layer.masksToBounds = true
        addSubview(bottomBtn)
        bottomBtn.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(43)
        }
        
        viewSize.height = 8 + 28 + 5 + 18 + type.topInset + contentView.viewSize.height + type.bottomInset + 43 + 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
}

extension GuideIntoRoomPopView {
    
}


