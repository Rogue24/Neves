//
//  AttentionBothSides.swift
//  Neves
//
//  Created by aa on 2021/11/23.
//

enum AttentionBothSides {
    
    struct Model {
        let name1: String
        let name2: String
        let tag: Int
    }
    
    static let viewSize: CGSize = [89, 26]
    static let viewX = PortraitScreenWidth - 10
    static let viewTopY = PortraitScreenHeight * 0.5
    static let viewBottomY = viewTopY + viewSize.height + 6
    
    class View: UIView  {
        let model: Model
        
        var isShowing = false
        var isHiding = false
        
        init(_ model: Model, isFirst: Bool) {
            self.model = model
            super.init(frame: CGRect(origin: .zero, size: AttentionBothSides.viewSize))
            
            backgroundColor = .randomColor
            
            layer.anchorPoint = [1, 0]
            layer.position.x = PortraitScreenWidth + AttentionBothSides.viewSize.width
            layer.position.y = isFirst ? AttentionBothSides.viewTopY : AttentionBothSides.viewBottomY
            
            
            let label: UILabel = {
                let lab = UILabel()
                lab.font = .systemFont(ofSize: 20)
                lab.textColor = .randomColor
                lab.text = "\(model.tag)"
                lab.textAlignment = .center
                lab.frame = bounds
                return lab
            }()
            addSubview(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var isTop: Bool {
            frame.origin.y >= AttentionBothSides.viewTopY
        }
        
        var isBottom: Bool {
            frame.origin.y <= AttentionBothSides.viewBottomY
        }
        
        static func create(_ model: Model, isFirst: Bool, on view: UIView) -> View {
            let bsView = View(model, isFirst: isFirst)
            view.addSubview(bsView)
            return bsView
        }
        
        func show() {
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: []) {
                self.layer.position.x = AttentionBothSides.viewX
            } completion: { _ in }
        }
        
        func toTop() {
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: []) {
                self.layer.position.y = AttentionBothSides.viewTopY
            } completion: { _ in }
        }
        
        func hide() {
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: []) {
                self.layer.position.y = AttentionBothSides.viewTopY - AttentionBothSides.viewSize.height
                self.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1)
                self.layer.opacity = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
    
}
