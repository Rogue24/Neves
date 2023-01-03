//
//  GuideIntoRoomPopView.swift
//  Neves
//
//  Created by aa on 2022/12/28.
//

class GuideIntoRoomPopView: UIView {
    
    static let viewWidth = PortraitScreenWidth - 30
    static let contentInsets = UIEdgeInsets(top: 8, left: 15, bottom: 15, right: 15)
    static let contentWidth = viewWidth - contentInsets.left - contentInsets.right
    
    var viewSize: CGSize = [GuideIntoRoomPopView.viewWidth, 0]
    
    let type: GuideIntoRoomType
    
    let titleH: CGFloat = 28
    let subtitleH: CGFloat = 18
    let titleSpace: CGFloat = 5
    let bottomBtnH: CGFloat = 43
    
    let bgImgView = UIImageView()
    let titleLabel = UILabel()
    let subtitleBgView = UIView()
    let subtitleLabel = UILabel()
    let closeBtn = NoHighlightButton()
    var contentView: GuideIntoRoomContentViewCompatible!
    let bottomBtn = NoHighlightButton()
    
    init(type: GuideIntoRoomType) {
        self.type = type
        super.init(frame: .zero)
        
        setupBase()
        setupBgImgView()
        setupTopBar()
        setupContentView()
        setupBottomBtn()
        
        let contentInsets = Self.contentInsets
        viewSize.height = contentInsets.top + titleH + titleSpace + subtitleH + type.contentTopInset + contentView.viewSize.height + type.contentBottomInset + bottomBtnH + contentInsets.bottom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GuideIntoRoomPopView {
    func setupBase() {
        backgroundColor = .randomColor
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    func setupBgImgView() {
        let bgImage = type.bgImage
        let bgImageViewH = Self.viewWidth * (bgImage.size.height / bgImage.size.width)
        bgImgView.image = bgImage
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bgImageViewH)
        }
    }
    
    func setupTopBar() {
        titleLabel.font = UIFont(name: "PingFangSC-Semibold", size: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = type.title
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(Self.contentInsets.top)
            make.height.equalTo(titleH)
        }
        
        closeBtn.setImage(UIImage(named: "roomguide_tc_icon_close"), for: .normal)
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        let onlineImageView = UIImageView()
        onlineImageView.image = UIImage(named: "paly_animation01")
        onlineImageView.animationImages = (1...9).map { UIImage(named: "paly_animation0\($0)")! }
        onlineImageView.animationDuration = 0.9
        onlineImageView.startAnimating()
        subtitleBgView.addSubview(onlineImageView)
        onlineImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: subtitleH, height: subtitleH))
            make.top.left.bottom.equalToSuperview()
        }
        
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.8)
        subtitleLabel.text = type.subtitle(1000)
        subtitleBgView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(onlineImageView.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        addSubview(subtitleBgView)
        subtitleBgView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(titleSpace)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupContentView() {
        switch type {
        case .blindDate:
            contentView = GuideIntoRoomUserIconListView(isBlindDate: true)
        case .joyParty:
            contentView = GuideIntoRoomUserIconListView(isBlindDate: false)
        case .fm:
            contentView = GuideIntoRoomFmView()
        case let .gameTeam(id):
            contentView = GuideIntoRoomGameTeamCardListView(gameId: id)
        }
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.size.equalTo(contentView.viewSize)
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleBgView.snp.bottom).offset(type.contentTopInset)
        }
    }
    
    func setupBottomBtn() {
        bottomBtn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17)
        bottomBtn.setTitle(type.btnTitle, for: .normal)
        bottomBtn.setTitleColor(.rgb(30, 27, 43), for: .normal)
        bottomBtn.backgroundColor = .white
        bottomBtn.layer.cornerRadius = 21.5
        bottomBtn.layer.masksToBounds = true
        addSubview(bottomBtn)
        bottomBtn.snp.makeConstraints { make in
            make.width.equalTo(Self.contentWidth)
            make.height.equalTo(bottomBtnH)
            make.bottom.equalTo(-Self.contentInsets.bottom)
            make.centerX.equalToSuperview()
        }
    }
}


