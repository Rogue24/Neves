//
//  CircleLevelView.swift
//  Neves
//
//  Created by aa on 2021/4/30.
//


class CircleLevelView: UIView {
    
    enum Layout: CGFloat {
        case height27 = 27
        case height18 = 18
        case height14 = 14
    }
    
    static let levelImgOriginSize: CGSize = [148.0, 81.0]
    
    let layout: Layout
    
    let levelImgScale: CGFloat

    let textFont: UIFont
    let textInset: UIEdgeInsets
    let textHeight: CGFloat

    let levelImgView: UIImageView = UIImageView()
    let textLabel: UILabel = UILabel()
    
    private(set) var level: Int

    init?(layout: Layout, level: Int, text: String) {
        guard text.count > 0, 1...18 ~= level else { return nil }
        
        self.level = level
        self.layout = layout
        self.levelImgScale = layout.rawValue / Self.levelImgOriginSize.height
        switch layout {
        case .height27:
            self.textFont = .systemFont(ofSize: 15, weight: .semibold)
            self.textInset = .init(top: 3, left: 36, bottom: 2, right: 7)
        case .height18:
            self.textFont = .systemFont(ofSize: 10, weight: .semibold)
            self.textInset = .init(top: 2, left: 25, bottom: 1, right: 6)
        case .height14:
            self.textFont = .systemFont(ofSize: 8, weight: .semibold)
            self.textInset = .init(top: 2, left: 20, bottom: 1, right: 4.5)
        }
        self.textHeight = layout.rawValue - self.textInset.top - self.textInset.bottom

        let textWidth = text.jp.textSize(withFont: textFont).width
        let textFrame = CGRect(origin: [textInset.left, textInset.top], size: [textWidth, textHeight])
        var viewFrame = CGRect(origin: .zero, size: [textFrame.maxX + textInset.right, layout.rawValue])
        
        var levelImgWidth = viewFrame.width / levelImgScale
        if levelImgWidth < Self.levelImgOriginSize.width {
            levelImgWidth = Self.levelImgOriginSize.width
            viewFrame.size.width = levelImgWidth * levelImgScale
        }

        super.init(frame: viewFrame)
        
        levelImgView.image = levelImage
        levelImgView.bounds = [0, 0, levelImgWidth, Self.levelImgOriginSize.height]
        levelImgView.transform = CGAffineTransform(scaleX: levelImgScale, y: levelImgScale)
        levelImgView.frame = [0, 0, viewFrame.width, viewFrame.height] 
        addSubview(levelImgView)

        textLabel.font = textFont
        textLabel.textColor = .white
        textLabel.text = text
        textLabel.frame = textFrame
        addSubview(textLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var levelImage: UIImage? {
        UIImage(named: "quanzi_level_\(level)")?
            .resizableImage(withCapInsets:
                                .init(top: 0,
                                      left: Self.levelImgOriginSize.width * 0.80,
                                      bottom: 0,
                                      right: Self.levelImgOriginSize.width * 0.17),
                            resizingMode: .stretch)
    }

    func update(level: Int? = nil, text: String? = nil) {
        if level == nil, text == nil { return }
        if level == self.level, text == textLabel.text { return }
        
        if let level = level, 1...18 ~= level, level != self.level {
            self.level = level
            levelImgView.image = levelImage
        }
        
        if let text = text, text.count > 0 {
            textLabel.text = text
        }
        
        let textWidth = textLabel.text?.jp.textSize(withFont: textFont).width ?? 0
        let textFrame: CGRect = [textInset.left, textInset.top, textWidth, textHeight]
        var viewFrame: CGRect = [frame.origin.x, frame.origin.y, textFrame.maxX + textInset.right, layout.rawValue]
        
        var levelImgWidth = viewFrame.width / levelImgScale
        if levelImgWidth < Self.levelImgOriginSize.width {
            levelImgWidth = Self.levelImgOriginSize.width
            viewFrame.size.width = levelImgWidth * levelImgScale
        }
        
        levelImgView.bounds = [0, 0, levelImgWidth, Self.levelImgOriginSize.height]
        levelImgView.frame = [0, 0, viewFrame.width, viewFrame.height]
        textLabel.frame = textFrame
        frame = viewFrame
    }
}
