//
//  CosmicExplorationStarView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import CoreGraphics
import UIKit

protocol CosmicExplorationStarViewDelegate {
    func starView(_ starView: CosmicExplorationStarView, betFrom giftType: Int, to frame: CGRect)
}

class CosmicExplorationStarView: UIView {
    
    static let wh: CGFloat = 118.px
    
    class MultipleView: UIView {
        
        let bgImgView = UIImageView()
        let multipleLabel = UILabel()
        
        init?(_ planet: CosmicExploration.Planet) {
            let multiple = planet.multiple
            guard multiple > 0 else { return nil }
            
            let size: CGSize = [38.px, 21.px]
            super.init(frame: CGRect(origin: [CosmicExplorationStarView.wh - size.width - 17.5.px, 28.px], size: size))
            
            bgImgView.image = planet.multipleImg
            bgImgView.frame = bounds
            addSubview(bgImgView)
            
            multipleLabel.font = .systemFont(ofSize: 10.px)
            multipleLabel.frame = [0, 4.5.px, bounds.width, 12.px]
            multipleLabel.textColor = .rgb(255, 241, 156)
            multipleLabel.textAlignment = .center
            multipleLabel.text = "x\(multiple)倍"
            addSubview(multipleLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class OtherBetView: UIView {
        let userIcon = UIImageView()
        let giftIcon = UIImageView()
        
        var willHide: ((OtherBetView) -> ())?
        var hideWorkItem: DispatchWorkItem? = nil
        
        init() {
            super.init(frame: CGRect(origin: [15.px, 33.px], size: [45.px, 14.px]))
            
            backgroundColor = .rgb(0, 0, 0, a: 0.4)
            layer.cornerRadius = 7.px
            layer.masksToBounds = true
            
            userIcon.image = UIImage(named: "jp_icon")
            userIcon.frame = [1.5.px, 1.5.px, 11.px, 11.px]
            userIcon.layer.cornerRadius = 5.5.px
            userIcon.layer.masksToBounds = true
            addSubview(userIcon)
            
            let label = UILabel()
            label.text = "补给"
            label.font = .systemFont(ofSize: 8.px)
            label.textColor = .white
            label.sizeToFit()
            label.frame.origin = [userIcon.maxX + 2.px, HalfDiffValue(14.px, label.frame.height)]
            addSubview(label)
            
            giftIcon.image = UIImage(named: "dragon_weideng")
            giftIcon.frame = [(45 - 10 - 2.5).px, 2.px, 10.px, 10.px]
            addSubview(giftIcon)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        static func show(on view: UIView, delay: TimeInterval, willHide: @escaping (OtherBetView) -> ()) -> OtherBetView {
            let otherBetView = OtherBetView()
            otherBetView.alpha = 0
            view.addSubview(otherBetView)
            otherBetView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 5.px)
            
            UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.88, initialSpringVelocity: 0, options: []) {
                otherBetView.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { _ in }
            
            UIView.animate(withDuration: 0.17, delay: delay, options: []) {
                otherBetView.alpha = 1
            } completion: { _ in }
            
            otherBetView.hideWorkItem = Asyncs.mainDelay(3 + delay) {
                otherBetView.hideAnim()
            }
            
            otherBetView.willHide = willHide
            return otherBetView
        }
        
        func topAnim() {
            var transform = self.transform.scaledBy(x: 0.8, y: 0.8)
//            let size = frame.applying(transform).size
            transform = transform.translatedBy(x: 0, y: -(frame.height + 3.px))
            
            var alpha = self.alpha - 0.6
            if alpha <= 0 {
                alpha = 0
                
                hideWorkItem?.cancel()
                willHide?(self)
                willHide = nil
            }
            
            UIView.animate(withDuration: 0.3) {
                self.alpha = alpha
                self.transform = transform
            } completion: { _ in
                if alpha == 0 {
                    self.removeFromSuperview()
                }
            }
        }
        
        func hideAnim() {
            hideWorkItem?.cancel()
            
            willHide?(self)
            willHide = nil
            
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
    
    let planet: CosmicExploration.Planet
    let bgImgView = UIImageView()
    
    var multiple: Int = 0
    let multipleView: MultipleView?
    let betGiftsView = BetGiftsView()
    
    weak var delegate: (AnyObject & CosmicExplorationStarViewDelegate)? = nil
    
    var otherBetViews: [OtherBetView] = []
    
    init(_ model: CosmicExploration.PlanetModel) {
        let planet = model.planet
        self.planet = planet
        self.multipleView = MultipleView(planet)
        
        super.init(frame: planet.frame)
        
        bgImgView.image = planet.bgImg
        bgImgView.frame = bounds
        addSubview(bgImgView)
        
        multipleView.map { addSubview($0) }
        
        addSubview(betGiftsView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClick)))
        
        updateSelected(model.isSelected, animated: false)
        updateBetGifts(model.betGifts, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("我心已死")
    }
    
}

extension CosmicExplorationStarView {
    @objc func didClick() {
        CosmicExplorationManager.shared.selectPlanet(planet)
    }
}

extension CosmicExplorationStarView {
    func updateSelected(_ isSelected: Bool, animated: Bool = true) {
        bgImgView.backgroundColor = isSelected ? .randomColor : .clear
        guard animated else { return }
        UIView.transition(with: bgImgView, duration: 0.2, options: .transitionCrossDissolve) {} completion: { _ in }
    }
    
    func updateBetGifts(_ betGifts: [CosmicExploration.BetGiftModel], giftType: Int? = nil, animated: Bool = true) {
        let itemModels = BetGiftItemModel.convert(withBetGiftModels: betGifts)
        guard animated else {
            betGiftsView.updateBetGifts(itemModels, animated: false)
            return
        }
        
        var delay: TimeInterval = 0
        if let delegate = self.delegate, let superView = self.superview,
           let giftType = giftType,
           let itemFrame = itemModels.first(where: { $0.giftType == giftType })?.itemFrame {
            delegate.starView(self, betFrom: giftType, to: betGiftsView.convert(itemFrame, to: superView))
            delay = 0.3
        }
        
        Asyncs.mainDelay(delay) {
            self.betGiftsView.updateBetGifts(itemModels, animated: animated)
        }
    }
}

extension CosmicExplorationStarView {
    func betFromOther() {
        JPrint("来了老弟")
        let delay: TimeInterval = otherBetViews.count == 0 ? 0 : 0.23
        
        otherBetViews.forEach { $0.topAnim() }
        
        let otherBetView = OtherBetView.show(on: self, delay: delay) { [weak self] obView in
            guard let self = self else { return }
            self.otherBetViews.removeAll { $0 == obView }
        }
        
        otherBetViews.insert(otherBetView, at: 0)
    }
}

// MARK: - 下注礼物列表
extension CosmicExplorationStarView {
    
    struct BetGiftItemModel {
        let giftType: Int
        let itemTitle: String
        var itemFrame: CGRect
        
        static func convert(withBetGiftModels betGifts: [CosmicExploration.BetGiftModel]) -> [BetGiftItemModel] {
            var itemModels: [BetGiftItemModel] = []
            
            let superW = CosmicExplorationStarView.wh
            let itemH: CGFloat = 14.px
            let minItemW = 20.5.px
            
            for model in betGifts {
                let itemTitle = "+\(model.betCount)"
                let itemW = minItemW + itemTitle.jp.textSize(withFont: .systemFont(ofSize: 10.px)).width
                itemModels.append(BetGiftItemModel(giftType: model.giftType, itemTitle: itemTitle, itemFrame: [0, 0, itemW, itemH]))
            }
            
            let total = itemModels.count
            let space: CGFloat = 2.px
            
            switch total {
            case 1:
                var itemModel1 = itemModels[0]
                itemModel1.itemFrame.origin.x = HalfDiffValue(superW, itemModel1.itemFrame.width)
                itemModels[0] = itemModel1
                
            case 2...:
                var itemModel1 = itemModels[0]
                var itemModel2 = itemModels[1]
                let firstLineW = itemModel1.itemFrame.width + space + itemModel2.itemFrame.width
                
                itemModel1.itemFrame.origin.x = HalfDiffValue(superW, firstLineW)
                itemModels[0] = itemModel1
                
                itemModel2.itemFrame.origin.x = itemModel1.itemFrame.maxX + space
                itemModels[1] = itemModel2
                
                if total > 2 {
                    let y = itemModel2.itemFrame.maxY + space
                    var itemModel3 = itemModels[2]
                    if total > 3 {
                        var itemModel4 = itemModels[3]
                        let secondLineW = itemModel3.itemFrame.width + space + itemModel4.itemFrame.width
                        
                        itemModel3.itemFrame.origin = [HalfDiffValue(superW, secondLineW), y]
                        itemModels[2] = itemModel3
                        
                        itemModel4.itemFrame.origin = [itemModel3.itemFrame.maxX + space, y]
                        itemModels[3] = itemModel4
                    } else {
                        itemModel3.itemFrame.origin = [HalfDiffValue(superW, itemModel3.itemFrame.width), y]
                        itemModels[2] = itemModel3
                    }
                }
            default:
                break
            }
            
            return itemModels
        }
    }
    
    class BetGiftItem: UIView {
        let icon = UIImageView()
        let label = UILabel()
        
        init() {
            super.init(frame: [0, 0, 0, 14.px])
            
            backgroundColor = .rgb(16, 20, 59, a: 0.7)
            layer.cornerRadius = 7.px
            layer.masksToBounds = true
            
            icon.image = UIImage(named: "dragon_weideng")
            icon.frame = [4.px, 2.px, 10.px, 10.px]
            addSubview(icon)
            
            label.frame = [icon.maxX + 2.px, 0, 100, 14.px]
            label.textColor = .white
            label.font = .systemFont(ofSize: 10.px)
            addSubview(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateUI(_ itemModel: BetGiftItemModel) {
            label.text = itemModel.itemTitle
            frame = itemModel.itemFrame
        }
    }
    
    
    class BetGiftsView: UIView {
        
        var items: [BetGiftItem] = []
        
        init() {
            super.init(frame: [0, CosmicExplorationStarView.wh - 38.px, CosmicExplorationStarView.wh, 38.px])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateBetGifts(_ itemModels: [BetGiftItemModel], animated: Bool = true) {
            if !animated {
                let items = self.items
                if items.count > itemModels.count {
                    for (i, item) in items.enumerated() {
                        if i >= itemModels.count {
                            item.removeFromSuperview()
                            if let index = self.items.firstIndex(where: { $0 == item }) {
                                self.items.remove(at: index)
                            }
                        } else {
                            let itemModel = itemModels[i]
                            item.updateUI(itemModel)
                        }
                    }
                } else {
                    for (i, itemModel) in itemModels.enumerated() {
                        if i >= items.count {
                            let item = BetGiftItem()
                            item.updateUI(itemModel)
                            self.addSubview(item)
                            self.items.append(item)
                        } else {
                            let item = items[i]
                            item.updateUI(itemModel)
                        }
                    }
                }
                return
            }
            
            let items = self.items
            if items.count > itemModels.count {
                for (i, item) in items.enumerated() {
                    if i >= itemModels.count {
                        if let index = self.items.firstIndex(where: { $0 == item }) {
                            self.items.remove(at: index)
                        }
                        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
                            item.alpha = 0
                            item.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        } completion: { _ in
                            item.removeFromSuperview()
                        }
                    } else {
                        let itemModel = itemModels[i]
                        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
                            item.updateUI(itemModel)
                        } completion: { _ in }
                    }
                }
            } else {
                for (i, itemModel) in itemModels.enumerated() {
                    if i >= items.count {
                        let item = BetGiftItem()
                        item.updateUI(itemModel)
                        item.alpha = 0
                        item.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        self.addSubview(item)
                        self.items.append(item)
                        
                        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
                            item.alpha = 1
                            item.transform = CGAffineTransform.identity
                        } completion: { _ in }
                    } else {
                        let item = items[i]
                        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
                            item.updateUI(itemModel)
                        } completion: { _ in }
                    }
                }
            }
        }
        
    }
    
    
}
