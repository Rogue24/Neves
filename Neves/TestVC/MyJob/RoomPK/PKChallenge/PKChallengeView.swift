//
//  PKChallengeView.swift
//  Neves
//
//  Created by aa on 2022/5/7.
//

class PKChallengeView: UIView {
    static let openSize: CGSize = [PortraitScreenWidth, 195]
    static let foldSize: CGSize = [105, 45]
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var leftUserIcon: UIImageView!
    @IBOutlet weak var leftUserNameLabel: UILabel!
    @IBOutlet weak var leftUserLabelContainer: UIView!
    @IBOutlet weak var leftSociatyLabel: UILabel!
    
    @IBOutlet weak var rightUserIcon: UIImageView!
    @IBOutlet weak var rightUserNameLabel: UILabel!
    @IBOutlet weak var rightUserLabelContainer: UIView!
    @IBOutlet weak var rightSociatyLabel: UILabel!
    
    @IBOutlet weak var pkAnimContainer: UIView!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var cancelBtn: NoHighlightButton!
    @IBOutlet weak var foldBtn: NoHighlightButton!
    
    @IBOutlet weak var unFoldView: UIView!
    
    
    @IBOutlet weak var bgViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgImgViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftUserIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftUserViewCenterXConstraints: NSLayoutConstraint!
    @IBOutlet weak var leftUserViewCenterYConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var rightUserIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightUserViewCenterXConstraints: NSLayoutConstraint!
    @IBOutlet weak var rightUserViewCenterYConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var pkAnimContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pkAnimContainerCenterYConstraints: NSLayoutConstraint!
    @IBOutlet weak var connectingLabelTopConstraint: NSLayoutConstraint!
    
    
    var foldStateDidChangeHandler: ((Bool) -> ())?
    var closeHandler: (() -> ())?
    var isFolded = false {
        didSet {
            guard isFolded != oldValue else { return }
            foldStateDidChanged()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        
        leftUserIcon.layer.cornerRadius = 32.5
        leftUserIcon.layer.masksToBounds = true
        
        rightUserIcon.layer.cornerRadius = 32.5
        rightUserIcon.layer.masksToBounds = true
        
        cancelBtn.layer.borderColor = UIColor.white.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.cornerRadius = 14
        cancelBtn.layer.masksToBounds = true
        
        foldBtn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        foldBtn.layer.cornerRadius = 8
        foldBtn.layer.masksToBounds = true
        foldBtn.layoutSubviewsHandler = { btn in
            guard let imageView = btn.imageView,
                  let titleLabel = btn.titleLabel else { return }
            var imageFrame = imageView.frame
            var titleFrame = titleLabel.frame
            let space: CGFloat = 0
            let totalW: CGFloat = imageFrame.width + space + titleFrame.width
            let totalMaxX: CGFloat = HalfDiffValue(btn.frame.width, totalW) + totalW
            imageFrame.origin.x = totalMaxX - imageFrame.width
            titleFrame.origin.x = imageFrame.origin.x - titleFrame.width - space
            imageView.frame = imageFrame
            titleLabel.frame = titleFrame
        }
        
        if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/pk_tag_lottie"),
           let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
            let pkLogoAnimView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
            pkLogoAnimView.backgroundBehavior = .pauseAndRestore
            pkLogoAnimView.contentMode = .scaleAspectFit
            pkLogoAnimView.loopMode = .loop
            pkAnimContainer.addSubview(pkLogoAnimView)
            pkLogoAnimView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            pkAnimContainer.layoutIfNeeded()
            pkLogoAnimView.play()
        }
        
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClick), for: .touchUpInside)
        foldBtn.addTarget(self, action: #selector(foldBtnDidClick), for: .touchUpInside)
        unFoldView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unFoldViewDidClick)))
    }
    
    deinit {
        JPrint("PKChallengeView 死无全尸")
    }
    
    func setupLayout() {
        snp.makeConstraints { make in
            make.size.equalTo(Self.openSize)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(Self.openSize.height)
        }
    }
}

extension PKChallengeView {
    func show() {
        snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in }
    }
    
    func close() {
        snp.updateConstraints { make in
            if isFolded {
                make.right.equalToSuperview().offset(Self.foldSize.width + 5)
            } else {
                make.bottom.equalToSuperview().offset(Self.openSize.height)
            }
        }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.closeHandler?()
        }
    }
}

extension PKChallengeView {
    @objc func cancelBtnDidClick() {
        close()
    }
    
    @objc func foldBtnDidClick() {
        isFolded = true
    }
    
    @objc func unFoldViewDidClick() {
        isFolded = false
    }
}

private extension PKChallengeView {
    func foldStateDidChanged() {
        updateLayout()
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.updateUI()
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        } completion: { _ in }
        foldStateDidChangeHandler?(isFolded)
    }
    
    func updateLayout() {
        bgViewBottomConstraint.constant = isFolded ? 0 : -10
        bgImgViewBottomConstraint.constant = isFolded ? -10 : 0
        
        let userIconWidth: CGFloat = isFolded ? 28 : 65
        let userViewCenterXDiff: CGFloat = isFolded ? 8 : 0
        let userViewCenterYDiff: CGFloat = isFolded ? 30 : 0
        
        leftUserIconWidthConstraint.constant = userIconWidth
        leftUserViewCenterXConstraints.constant = -userViewCenterXDiff
        leftUserViewCenterYConstraints.constant = userViewCenterYDiff
        
        rightUserIconWidthConstraint.constant = userIconWidth
        rightUserViewCenterXConstraints.constant = userViewCenterXDiff
        rightUserViewCenterYConstraints.constant = userViewCenterYDiff
        
        pkAnimContainerWidthConstraint.constant = isFolded ? 30 : 70
        pkAnimContainerCenterYConstraints.constant = isFolded ? 20 : 0
        
        connectingLabelTopConstraint.constant = isFolded ? -4 : 0
        connectingLabel.font = .systemFont(ofSize: isFolded ? 8 : 11)
        
        snp.updateConstraints { make in
            make.size.equalTo(isFolded ? Self.foldSize : Self.openSize)
            make.right.equalToSuperview().offset(isFolded ? -5 : 0)
            make.bottom.equalToSuperview().offset(isFolded ? -(50 + DiffTabBarH) : 0)
        }
    }
    
    func updateUI() {
        bgView.layer.cornerRadius = isFolded ? 7 : 10
        
        let userIconRadius: CGFloat = isFolded ? 14 : 32.5
        leftUserIcon.layer.cornerRadius = userIconRadius
        rightUserIcon.layer.cornerRadius = userIconRadius
        
        let alpha: CGFloat = isFolded ? 0 : 1
        
        leftUserNameLabel.alpha = alpha
        leftUserLabelContainer.alpha = alpha
        leftSociatyLabel.alpha = alpha
        
        rightUserNameLabel.alpha = alpha
        rightUserLabelContainer.alpha = alpha
        rightSociatyLabel.alpha = alpha
        
        cancelBtn.alpha = alpha
        foldBtn.alpha = alpha
        
        unFoldView.isUserInteractionEnabled = isFolded
    }
}
