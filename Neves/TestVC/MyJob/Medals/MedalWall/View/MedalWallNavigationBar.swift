//
//  MedalWallNavigationBar.swift
//  Neves
//
//  Created by aa on 2023/7/6.
//

class MedalWallNavigationBar: UIView {
    static var size: CGSize { [Env.screenWidth, 52.px] }
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let closeBtn = NoHighlightButton(type: .custom)
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16.px
        layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16.px, weight: .bold)
        titleLabel.textColor = .rgb(51, 51, 51)
        titleLabel.text = "季度勋章"
        
        dateLabel.font = .systemFont(ofSize: 12.px)
        dateLabel.textColor = .rgb(51, 51, 51)
        dateLabel.isHidden = true
        
        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.distribution = .fill
        containerView.spacing = 4.px
        containerView.alignment = .center
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(5.px)
            make.bottom.equalTo(-3.px)
            make.centerX.equalToSuperview()
        }
        containerView.addArrangedSubview(titleLabel)
        containerView.addArrangedSubview(dateLabel)
        
        closeBtn.setImage(UIImage(named: "chatroom_member_close_icon"), for: .normal)
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalTo(5.px)
            make.width.height.equalTo(44.px)
            make.trailing.equalToSuperview()
        }
        
        let line = UIView()
        addSubview(line)
        line.backgroundColor = .rgb(233, 233, 233)
        line.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MedalWallNavigationBar {
    func updateData(_ mwVM: MedalWallViewModel) {
        if mwVM.quarter.count > 0 {
            dateLabel.text = mwVM.quarter
            dateLabel.isHidden = false
        } else {
            dateLabel.isHidden = true
        }
    }
}
