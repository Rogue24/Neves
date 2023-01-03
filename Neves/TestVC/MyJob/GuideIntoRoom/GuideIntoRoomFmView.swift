//
//  GuideIntoRoomFmView.swift
//  Neves
//
//  Created by aa on 2022/12/30.
//

class GuideIntoRoomFmView: UIView, GuideIntoRoomContentViewCompatible {
    var viewSize: CGSize = .zero
    
    let userIcon = UIImageView()
    let topicView = TopicView()
    
    
    
    init() {
        self.viewSize = [GuideIntoRoomPopView.viewWidth, CGFloat(82 + 10)]
        super.init(frame: .zero)
        
        userIcon.image = UIImage(named: "jp_icon")
        userIcon.contentMode = .scaleAspectFill
        userIcon.layer.cornerRadius = 41
        userIcon.layer.borderWidth = 1
        userIcon.layer.borderColor = UIColor.white.cgColor
        userIcon.layer.masksToBounds = true
        addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.width.height.equalTo(82)
            make.centerX.top.equalToSuperview()
        }
        
        setupTopic()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTopic() {
        let text = "如果两个人同时喜欢你，你说说该咋办呢"
        
        let font = TopicView.font
        let lineSpacing = TopicView.lineSpacing
        let maxContentW = TopicView.maxContentW
        let contentInsets = TopicView.contentInsets
        
        let iconAttStr = NSAttributedString.yy_attachmentString(withContent: UIImage(named: "tingjian_icon_topic"), contentMode: .scaleAspectFit, attachmentSize: [42, 15], alignTo: font, alignment: .center)
        let sapceAttStr = NSAttributedString.yy_attachmentString(withContent: nil, contentMode: .scaleAspectFit, attachmentSize: [3, 15], alignTo: font, alignment: .center)
        let textAttStr = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: UIColor(white: 1, alpha: 0.8)])
        
        let contentAttStr = NSMutableAttributedString()
        contentAttStr.append(iconAttStr)
        contentAttStr.append(sapceAttStr)
        contentAttStr.append(textAttStr)
        contentAttStr.yy_lineSpacing = lineSpacing
        
        let contentSize = YYTextLayout(containerSize: [maxContentW, 999], text: contentAttStr)?.textBoundingSize ?? .zero
        let topicViewW = contentInsets.left + contentSize.width + contentInsets.right
        let topicViewH = contentInsets.top + contentSize.height + contentInsets.bottom
        
        topicView.label.attributedText = contentAttStr
        addSubview(topicView)
        topicView.snp.makeConstraints { make in
            make.width.equalTo(topicViewW)
            make.height.equalTo(topicViewH)
            make.centerX.bottom.equalToSuperview()
        }
        
        viewSize.height += topicViewH
    }
}

extension GuideIntoRoomFmView {
    class TopicView: UIView {
        static var font: UIFont {
            UIFont.systemFont(ofSize: 13)
        }
        static var lineSpacing: CGFloat { 4 }
        static var minContentH: CGFloat { ceil(font.lineHeight) }
        static var maxContentW: CGFloat {
            let contentInsets = TopicView.contentInsets
            return GuideIntoRoomPopView.contentWidth - contentInsets.left - contentInsets.right
        }
        static var contentInsets: UIEdgeInsets {
            let verInset = (24 - TopicView.minContentH) * 0.5
            return UIEdgeInsets(top: verInset, left: 6, bottom: verInset, right: 6)
        }
        
        let label = YYLabel()
        
        init() {
            super.init(frame: .zero)
            
            layer.cornerRadius = 12
            layer.borderColor = UIColor(white: 1, alpha: 0.3).cgColor
            layer.borderWidth = 1
            layer.masksToBounds = true
            
            label.isUserInteractionEnabled = false
            label.numberOfLines = 0
            addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(Self.contentInsets.left)
                make.right.equalTo(-Self.contentInsets.right)
                make.top.equalTo(Self.contentInsets.top)
                make.bottom.equalTo(-Self.contentInsets.bottom)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
