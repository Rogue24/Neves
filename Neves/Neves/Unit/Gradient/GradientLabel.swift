//
//  GradientLabel.swift
//  Falla
//
//  Created by aa on 2024/9/5.
//

import UIKit

class GradientLabel: GradientView {
    private(set) lazy var label = {
        let label = UILabel(frame: bounds)
        label.textColor = .black
        addSubview(label)
        mask = label
        return label
    }()
    
    private var layoutLabel: UILabel? = nil
    
    var isAutotLayout: Bool = false {
        didSet {
            guard isAutotLayout != oldValue else { return }
            
            guard isAutotLayout else {
                layoutLabel?.removeFromSuperview()
                layoutLabel = nil
                return
            }
            
            /// 📢 为什么不直接使用`self.label`？
            /// 因为`self.mask`就是`self.label`，这样会使`self.label`的约束直接失效。
            /// 所以还是新建一个看不见的`layoutLabel`用来做自动布局，让`self`可以随着`layoutLabel`的变化进行自适应。
            
            let layoutLabel = UILabel()
            layoutLabel.font = label.font
            layoutLabel.numberOfLines = label.numberOfLines
            layoutLabel.text = label.text
            layoutLabel.attributedText = label.attributedText
            addSubview(layoutLabel)
            self.layoutLabel = layoutLabel
            
            // 不需要显示，只用来做布局
            layoutLabel.isHidden = true
            
            // 添加约束
            layoutLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                layoutLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                layoutLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                layoutLabel.topAnchor.constraint(equalTo: topAnchor),
                layoutLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        label.sizeThatFits(size)
    }

    override func sizeToFit() {
        if isAutotLayout {
            super.sizeToFit()
        } else {
            frame.size = label.sizeThatFits(.zero)
        }
    }
    
    var font: UIFont? {
        get { label.font }
        set {
            label.font = newValue
            layoutLabel?.font = newValue
        }
    }
    
    var numberOfLines: Int {
        get { label.numberOfLines }
        set {
            label.numberOfLines = newValue
            layoutLabel?.numberOfLines = newValue
        }
    }
    
    var textAlignment: NSTextAlignment {
        get { label.textAlignment }
        set {
            label.textAlignment = newValue
            layoutLabel?.textAlignment = newValue
        }
    }
    
    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            layoutLabel?.text = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get { label.attributedText }
        set {
            label.attributedText = newValue
            layoutLabel?.attributedText = newValue
        }
    }
}
