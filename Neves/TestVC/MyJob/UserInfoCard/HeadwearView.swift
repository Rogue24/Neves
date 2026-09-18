//
//  HeadwearView2.swift
//  Falla
//
//  Created by aa on 2023/8/10.
//

import UIKit
import Kingfisher

@objcMembers
class HeadwearView: SVGAExImageView {
    
    /// 自定义头像布局
    var avatarViewFrameBuilder: (_ viewSize: CGSize) -> CGRect = {
        let w = $0.width * (25.0 / 85.0)
        let h = $0.height * (25.0 / 85.0)
        let x = $0.width - w - $0.width * (4.5 / 85.0)
        let y = $0.height - h - $0.height * (11.5 / 85.0)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private(set) var avatarUrl: String?
    
    private var avatarView: AnimatedImageView?
    
    deinit {
//        avatarView?.kf.cancelDownloadTask()
//        print("jpjpjp HeadwearView 死！！！")
    }
    
    // MARK: - Override
    
    override func viewBoundsDidChange() {
        super.viewBoundsDidChange()
        _resetAvatarViewFrame()
    }
    
    override func updateUI(source: SVGAExImageView.Source, animated: Bool) {
        super.updateUI(source: source, animated: animated)
        showAvatarIfNeeded(nil, animated: animated)
    }
    
    override func clean(animated: Bool) {
        super.clean(animated: animated)
        hideAvatar(animated: animated)
    }
    
    override func reset(animated: Bool) {
        super.reset(animated: animated)
        hideAvatar(isRemove: true, animated: animated)
    }
    
    // MARK: - API
    
    func updateUI(source: Source, avatarUrl: String? = nil, animated: Bool) {
        super.updateUI(source: source, animated: animated)
        showAvatarIfNeeded(avatarUrl, animated: animated)
    }
}

// MARK: - 亲密关系用户头像 加载&移除
private extension HeadwearView {
    func showAvatarIfNeeded(_ avatarUrl: String?, animated: Bool) {
        guard let avatarUrl, avatarUrl.count > 0 else {
            hideAvatar(animated: isHideWhenSwitchSourceWithoutAnimtion ? false : animated)
            return
        }
        self.avatarUrl = avatarUrl
        
        let avatarView = _getAvatarView()
        
        var options: KingfisherOptionsInfo?
        if animated { options = [.transition(.fade(0.2))] }
        avatarView.kf.setImage(with: URL(string: avatarUrl.rq_40x40),
                               placeholder: UIImage(named: "header_no"),
                               options: options)
        
        guard animated else {
            avatarView.alpha = 1
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            avatarView.alpha = 1
        }
    }
    
    func hideAvatar(isRemove: Bool = false, animated: Bool) {
        avatarUrl = nil
        
        guard animated else {
            _removeAvatar(isRemove: isRemove)
            return
        }
        
        guard let avatarView = self.avatarView else { return }
        UIView.animate(withDuration: 0.2) {
            avatarView.alpha = 0
        } completion: { _ in
            guard self.avatarUrl == nil else { return }
            self._removeAvatar(isRemove: isRemove)
        }
    }
    
    func _getAvatarView() -> AnimatedImageView {
        let avatarView = self.avatarView ?? {
            let avatarView = AnimatedImageView()
            avatarView.image = UIImage(named: "header_no")
            avatarView.isUserInteractionEnabled = false
            avatarView.contentMode = .scaleAspectFill
            avatarView.layer.masksToBounds = true
            avatarView.alpha = 0
            insertSubview(avatarView, at: 0)
            self.avatarView = avatarView
            self._resetAvatarViewFrame()
            return avatarView
        }()
        avatarView.runLoopMode = imageRunloopMode
        return avatarView
    }
    
    func _resetAvatarViewFrame() {
        guard let avatarView else { return }
        avatarView.frame = avatarViewFrameBuilder(viewBounds.size)
        avatarView.layer.cornerRadius = avatarView.frame.height * 0.5
    }
    
    func _removeAvatar(isRemove: Bool) {
        guard let avatarView = self.avatarView else { return }
        avatarView.alpha = 0
        avatarView.kf.cancelDownloadTask()
        avatarView.image = nil
        if isRemove || !isMultiplex {
            avatarView.removeFromSuperview()
            self.avatarView = nil
        }
    }
}

// MARK: - API for OC
extension HeadwearView {
    @objc func updateUI(image: UIImage?, avatarUrl: String?, animated: Bool) {
        guard let image else {
            clean(animated: animated)
            return
        }
        updateUI(source: .image(image), avatarUrl: avatarUrl, animated: animated)
    }
    
    @objc func updateUI(imageName: String?, avatarUrl: String?, animated: Bool) {
        guard let imageName else {
            clean(animated: animated)
            return
        }
        updateUI(source: .asset(imageName), avatarUrl: avatarUrl, animated: animated)
    }
    
    @objc func updateUI(imageUrl: String?, placeholder: UIImage?, avatarUrl: String?, animated: Bool) {
        guard let imageUrl else {
            clean(animated: animated)
            return
        }
        updateUI(source: .remote(imageUrl, false, false, placeholder), avatarUrl: avatarUrl, animated: animated)
    }
    
    @objc func updateUI(svgaUrl: String?, placeholder: UIImage?, avatarUrl: String?, animated: Bool) {
        guard let svgaUrl else {
            clean(animated: animated)
            return
        }
        updateUI(source: .svga(svgaUrl, false, placeholder), avatarUrl: avatarUrl, animated: animated)
    }
    
    @objc func updateUI(svgaUrl: String?, avatarUrl: String?, animated: Bool) {
        guard let svgaUrl else {
            clean(animated: animated)
            return
        }
        updateUI(source: .svga(svgaUrl, false, nil), avatarUrl: avatarUrl, animated: animated)
    }
    
    @objc func updateUI(image: UIImage?, avatarUrl: String?) {
        updateUI(image: image, avatarUrl: avatarUrl, animated: false)
    }
    
    @objc func updateUI(imageName: String?, avatarUrl: String?) {
        updateUI(imageName: imageName, avatarUrl: avatarUrl, animated: false)
    }
    
    @objc func updateUI(imageUrl: String?, placeholder: UIImage?, avatarUrl: String?) {
        updateUI(imageUrl: imageUrl, placeholder: placeholder, avatarUrl: avatarUrl, animated: false)
    }
    
    @objc func updateUI(svgaUrl: String?, avatarUrl: String?) {
        updateUI(svgaUrl: svgaUrl, avatarUrl: avatarUrl, animated: false)
    }
    
    // MARK: ------------ 通用API ------------
    
    @objc func updateUI(url: String?, placeholder: UIImage?, avatarUrl: String?, animated: Bool) {
        if let url, url.hasSuffix(".svga") {
            updateUI(svgaUrl: url, placeholder: placeholder, avatarUrl: avatarUrl, animated: animated)
        } else {
            updateUI(imageUrl: url, placeholder: placeholder, avatarUrl: avatarUrl, animated: animated)
        }
    }
}

