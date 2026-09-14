//
//  EMLRankingRegionToggleButton.swift
//  Neves
//
//  Created by aa on 2026/9/14.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - 区域切换按钮
class EMLRankingRegionToggleButton: UIView {
    static var size: CGSize { [CGFloat(23 + 4 + 12), 22] }
    
    private let globalView = UIImageView()
    private let countryView = UIImageView()
    private let arrImgView = UIImageView()
    
    private(set) var isCountry = false
    private var regionDidChange: ((_ isCountry: Bool) -> Void)? = nil
    
    var isDark: Bool = false {
        didSet {
            guard isDark != oldValue else { return }
            let imageName = isDark ? "icon_ranking_toggle_dark" : "icon_ranking_toggle_light"
            UIView.transition(with: arrImgView, duration: 0.15, options: .transitionCrossDissolve) {
                self.arrImgView.image = UIImage(named: imageName)
            }
        }
    }
    
    init(isDark: Bool) {
        self.isDark = isDark
        super.init(frame: .zero)
        
        let iconContainer = UIView()
        iconContainer.layer.cornerRadius = 4
        iconContainer.layer.masksToBounds = true
        addSubview(iconContainer)
        iconContainer.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(22)
            make.leading.top.bottom.equalToSuperview()
        }
        
        globalView.image = UIImage(named: "icon_ranking_global")
        globalView.contentMode = .scaleAspectFill
        globalView.clipsToBounds = true
        iconContainer.addSubview(globalView)
        globalView.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.top.equalTo(isCountry ? -(22.0 + 4) : 0)
        }
        
        countryView.contentMode = .scaleAspectFill
        countryView.clipsToBounds = true
        iconContainer.addSubview(countryView)
        countryView.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.top.equalTo(globalView.snp.bottom).offset(4)
        }
        
        let imageName = isDark ? "icon_ranking_toggle_dark" : "icon_ranking_toggle_light"
        arrImgView.image = UIImage(named: imageName)
        addSubview(arrImgView)
        arrImgView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.leading.equalTo(iconContainer.snp.trailing).offset(4)
            make.trailing.centerY.equalToSuperview()
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe)))
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var countryUrl: String? = nil {
        didSet {
//            countryView.jkr_setImage(with: URL(string: countryUrl ?? ""))
        }
    }
    
    @objc private func tapMe() {
        guard let regionDidChange else { return }
        
        isCountry.toggle()
        regionDidChange(isCountry)
        
        globalView.snp.updateConstraints { make in
            make.top.equalTo(isCountry ? -(22.0 + 4) : 0)
        }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            self.globalView.superview?.layoutIfNeeded()
        }
        
        let msg = isCountry ? "已切换为国家榜单" : "已切换为全服榜单"
        JPHUD.showInfo(withStatus: msg)
    }
    
    func setupRegion(_ isCountry: Bool, nationalFlag: String, regionDidChange: ((_ isCountry: Bool) -> Void)?) {
        self.isCountry = isCountry
        self.regionDidChange = regionDidChange
        
        countryView.kf.setImage(with: URL(string: nationalFlag))
        // JP_Test
//        countryView.jkr_cancelCurrentImageRequest()
//        countryView.image = "account_info_header_google".fa.image
        
        globalView.snp.updateConstraints { make in
            make.top.equalTo(isCountry ? -(22.0 + 4) : 0)
        }
        
        globalView.superview?.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
    }
}
