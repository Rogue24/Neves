//
//  Buttons.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import UIKit
import SnapKit

@objcMembers
class ExpandButton: UIButton {
    var dx: CGFloat = 0
    var dy: CGFloat = 0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -dx, dy: -dy).contains(point)
    }
}

class CustomLayoutButton: ExpandButton {
    var layoutSubviewsHandler: ((_ btn: CustomLayoutButton) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler?(self)
    }
}

class NoHighlightButton: CustomLayoutButton {
    override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {}
    }
}

class HighlightUnchangedButton: CustomLayoutButton {
    private var normalImage: UIImage?
    private var selectedImage: UIImage?
    
    private var normalBgImage: UIImage?
    private var selectedBgImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isUnchanged {
            normalImage = super.image(for: .normal)
            selectedImage = super.image(for: .selected)
            
            normalBgImage = super.backgroundImage(for: .normal)
            selectedBgImage = super.backgroundImage(for: .selected)
        }
    }
    
    var isUnchanged = true {
        didSet {
            guard isUnchanged != oldValue else { return }
            if isUnchanged {
                normalImage = super.image(for: .normal)
                selectedImage = super.image(for: .selected)
                
                normalBgImage = super.backgroundImage(for: .normal)
                selectedBgImage = super.backgroundImage(for: .selected)
            } else {
                super.setImage(normalImage, for: .normal)
                super.setImage(selectedImage, for: .selected)
                normalImage = nil
                selectedImage = nil
                
                super.setBackgroundImage(normalBgImage, for: .normal)
                super.setBackgroundImage(selectedBgImage, for: .selected)
                normalBgImage = nil
                selectedBgImage = nil
            }
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        
        guard isUnchanged else { return }
        switch state {
        case .normal:
            normalImage = image
        case .selected:
            selectedImage = image
        default:
            break
        }
    }
    
    override func image(for state: UIControl.State) -> UIImage? {
        guard isUnchanged else {
            return super.image(for: state)
        }
        
        switch state {
        case .normal:
            return normalImage
        case .selected:
            return selectedImage
        default:
            return super.image(for: state)
        }
    }
    
    override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImage(image, for: state)
        
        guard isUnchanged else { return }
        switch state {
        case .normal:
            normalBgImage = image
        case .selected:
            selectedBgImage = image
        default:
            break
        }
    }
    
    override func backgroundImage(for state: UIControl.State) -> UIImage? {
        guard isUnchanged else {
            return super.backgroundImage(for: state)
        }
        
        switch state {
        case .normal:
            return normalBgImage
        case .selected:
            return selectedBgImage
        default:
            return super.backgroundImage(for: state)
        }
    }
    
    var isNoHighlight: Bool = false
    override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            if isNoHighlight { return }
            guard super.isHighlighted != newValue else { return }
            defer { super.isHighlighted = newValue }
            
            guard isUnchanged else { return }
            if newValue, isSelected {
                super.setImage(selectedImage, for: .normal)
                super.setBackgroundImage(selectedBgImage, for: .normal)
            } else {
                super.setImage(normalImage, for: .normal)
                super.setBackgroundImage(normalBgImage, for: .normal)
            }
        }
    }
}

class JvhuaButton: HighlightUnchangedButton {
    private weak var jvhua: JPJvhua?
    
    private func getJvhua() -> JPJvhua {
        if let jvhua {
            return jvhua
        }
        
        let jvhua = JPJvhua()
        addSubview(jvhua)
        jvhua.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        layoutIfNeeded()
        self.jvhua = jvhua
        return jvhua
    }
    
    override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            super.isEnabled = newValue
            guard !newValue else {
                jvhua?.stopAnimating()
                return
            }
            let jvhua = getJvhua()
            jvhua.startAnimating()
        }
    }
}

class UnreadTipButton: HighlightUnchangedButton {
    private weak var unreadTipView: UIImageView?
    
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    private func getUnreadTipView() -> UIImageView {
        if let unreadTipView {
            return unreadTipView
        }
        
        let unreadTipView = UIImageView(image: UIImage(named: "chatroom_quickmessage_input_unread_badge"))
        addSubview(unreadTipView)
        unreadTipView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-offsetX)
            make.top.equalToSuperview().offset(offsetY)
            make.width.height.equalTo(10)
        }
        layoutIfNeeded()
        self.unreadTipView = unreadTipView
        return unreadTipView
    }
    
    var isUnreadTip: Bool = false {
        didSet {
            guard isUnreadTip != oldValue else { return }
            if isUnreadTip {
                let unreadTipView = getUnreadTipView()
                unreadTipView.isHidden = false
            } else {
                unreadTipView?.isHidden = true
            }
        }
    }
}

class MaskImageButton: ExpandButton {
    var maskImage: UIImage? = nil {
        didSet {
            guard let maskImage else {
                layer.mask = nil
                return
            }
            if layer.mask == nil {
                let maskLayer = CALayer()
                maskLayer.contentsGravity = .center
                maskLayer.contentsScale = UIScreen.main.scale
                layer.mask = maskLayer
            }
            layer.mask?.contents = maskImage.cgImage
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.mask?.frame = bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView?.addObserver(self, forKeyPath: #keyPath(UIImageView.layer.opacity), options: .new, context: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        imageView?.addObserver(self, forKeyPath: #keyPath(UIImageView.layer.opacity), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIImageView.layer.opacity), let newOpacity = change?[.newKey] as? CGFloat {
            layer.mask?.opacity = Float(newOpacity)
        }
    }
    
    deinit {
        imageView?.removeObserver(self, forKeyPath: #keyPath(UIImageView.layer.opacity))
    }
}

class MaskImageView: UIView {
    var maskImage: UIImage? = nil {
        didSet {
            guard let maskImage else {
                layer.mask = nil
                return
            }
            if layer.mask == nil {
                let maskLayer = CALayer()
                maskLayer.contentsGravity = .center
                maskLayer.contentsScale = UIScreen.main.scale
                layer.mask = maskLayer
            }
            layer.mask?.contents = maskImage.cgImage
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.mask?.frame = bounds
    }
}
