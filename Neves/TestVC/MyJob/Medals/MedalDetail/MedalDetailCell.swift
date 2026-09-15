//
//  MedalDetailCell.swift
//  Falla
//
//  Created by aa on 2023/7/7.
//

import UIKit
import SnapKit
import SVGAPlayer_Optimized
import Kingfisher

class MedalDetailCell: UICollectionViewCell, VBindable {
    static var size: CGSize { Env.screenSize }
    
    static var diffY: CGFloat { 20.px }
    
    static let loadingFrame: CGRect = {
        let w: CGFloat = 60.px
        let h: CGFloat = w * (67.0 / 100.0)
        let cellSize = MedalDetailCell.size
        return [HalfDiffValue(cellSize.width, w), HalfDiffValue(cellSize.height, h), w, h]
    }()
    
    static let medalIconFrame: CGRect = {
        let wh: CGFloat = 227.px
        let cellSize = MedalDetailCell.size
        return [HalfDiffValue(cellSize.width, wh), HalfDiffValue(cellSize.height, wh) - MedalDetailCell.diffY, wh, wh]
    }()
    
    var getLoadingEntity: (() -> SVGAVideoEntity?)? = nil
    
    /// =========`VBindable`=========
    private weak var _bindModel: MedalDetailCellModel?
    var bindModel: MedalDetailCellModel? {
        set {
            _bindModel = newValue
            updateUI()
        }
        get { _bindModel }
    }
    
    let bgView = UIView()
    
    private let imgView = UIImageView()
    private let player = SVGAExPlayer() //SVGARePlayer()
    private let titleLabel = UILabel()
    
    private var dateLabel: UILabel? = nil
    private var containerView: UIView? = nil
    private var scoreLabel: UILabel? = nil
    private var levelIconView: UIImageView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.size.equalTo(Self.size)
            make.center.equalToSuperview()
        }
        
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.size.equalTo(Self.medalIconFrame.size)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-Self.diffY)
        }
        imgView.contentMode = .scaleAspectFit
        imgView.alpha = 0
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(17.px)
            make.width.lessThanOrEqualTo(Self.size.width - 56.px)
            make.centerX.equalToSuperview()
        }
        
        if MedalDetailListViewController.isShowTitleOnly {
            titleLabel.font = .systemFont(ofSize: 16.px, weight: .medium)
        } else {
            titleLabel.font = .systemFont(ofSize: 14.5.px, weight: .medium)
            
            let dateLabel = UILabel()
            dateLabel.font = .systemFont(ofSize: 12.px)
            dateLabel.textColor = .rgb(220, 220, 220)
            bgView.addSubview(dateLabel)
            dateLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.px)
                make.centerX.equalToSuperview()
            }
            self.dateLabel = dateLabel
            
            let containerView = UIView()
            containerView.layer.cornerRadius = 18.px
            containerView.layer.masksToBounds = true
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = .rgb(255, 255, 255, a: 0.5)
            containerView.backgroundColor = .rgb(54, 41, 34, a: 0.5)
            containerView.alpha = 0
            bgView.addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.top.equalTo(dateLabel.snp.bottom).offset(8.px)
                make.width.equalTo(140.px)
                make.height.equalTo(36.px)
                make.centerX.equalToSuperview()
            }
            self.containerView = containerView
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 6.px
            stackView.alignment = .center
            containerView.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            let icon = UIImageView(image: UIImage(named: "medal_integral_logo_big"))
            stackView.addArrangedSubview(icon)
            icon.snp.makeConstraints { make in
                make.width.height.equalTo(28.px)
            }
            
            let scoreLabel = UILabel()
            scoreLabel.font = .systemFont(ofSize: 20.px, weight: .bold)
            scoreLabel.textColor = .rgb(248, 231, 28)
            stackView.addArrangedSubview(scoreLabel)
            self.scoreLabel = scoreLabel
            
            let levelIconView = UIImageView()
            levelIconView.contentMode = .scaleAspectFit
            contentView.addSubview(levelIconView)
            levelIconView.snp.makeConstraints { make in
                make.width.height.equalTo(50.px)
                make.leading.equalToSuperview().offset(16.px)
                make.top.equalToSuperview().offset(Env.safeAreaInsets.top + 110.px)
            }
            self.levelIconView = levelIconView
        }
        
        player.isAnimated = true
        player.isHideWhenStopped = true
        player.isHideWhenSwitchSourceWithoutAnimtion = true
        player.contentMode = .scaleAspectFit
        bgView.addSubview(player)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MedalDetailCell {
    func updateUI() {
        guard let model = _bindModel else { return }
        showLoading()
        
        switch model.iconSource {
        case let .svga(entity):
            guard let entity else { break }
            showSVGA(entity)
            
        case let .image(url):
            let identifier = model.identifier
            imgView.image = nil
            guard let URL = URL(string: url) else { return }
            KingfisherManager.shared.retrieveImage(with: URL) { [weak self] result in
                guard case let .success(value) = result else { return }
                Task { @MainActor [weak self] in
                    guard let self, let bindModel = self.bindModel,
                          identifier == bindModel.identifier else { return }
                    self.showImage(value.image)
                }
            }
        }
        
        titleLabel.text = model.title
        
        if MedalDetailListViewController.isShowTitleOnly {
            return
        }
        
        dateLabel?.text = model.subTitle
        
        if let score = model.score {
            scoreLabel?.text = score
            containerView?.alpha = 1
        } else {
            containerView?.alpha = 0
        }
        
        levelIconView?.image = model.levelIconName?.jp.image
    }
}

private extension MedalDetailCell {
    func showLoading() {
        showSVGA(getLoadingEntity?(), isLoading: true)
        imgView.alpha = 0
    }
    
    func showImage(_ image: UIImage) {
        hideSVGA()
        UIView.transition(with: imgView, duration: 0.2, options: .transitionCrossDissolve) {
            self.imgView.image = image
            self.imgView.alpha = 1
        }
    }
    
    func showSVGA(_ entity: SVGAVideoEntity?, isLoading: Bool) {
        guard let entity else {
            hideSVGA()
            return
        }
        
        player.frame = isLoading ? Self.loadingFrame : Self.medalIconFrame
//        player.videoItem = entity
//        player.startAnimation()
//        player.alpha = 1
        player.play(with: entity)
        
        guard !isLoading else { return }
        UIView.transition(with: player, duration: 0.2, options: .transitionCrossDissolve) {} completion: { _ in
//            if self.player.alpha == 0 {
//                self.player.stopAnimation()
//            }
        }
    }
    
    func hideSVGA() {
        player.stop()
//        player.alpha = 0
//        UIView.transition(with: player, duration: 0.2, options: .transitionCrossDissolve) {} completion: { Bool in
//            if self.player.alpha == 0 {
//                self.player.stopAnimation()
//            }
//        }
    }
}

extension MedalDetailCell {
    func showSVGA(_ entity: SVGAVideoEntity) {
        showSVGA(entity, isLoading: false)
        UIView.transition(with: imgView, duration: 0.2, options: .transitionCrossDissolve) {
            self.imgView.alpha = 0
        }
    }
}
