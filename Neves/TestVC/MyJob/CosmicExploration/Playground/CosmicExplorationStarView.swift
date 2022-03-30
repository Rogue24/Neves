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
    
    let planet: CosmicExploration.Planet
    let bgImgView = UIImageView()
    
    var multiple: Int = 0
    let multipleView: MultipleView?
    let betGiftsView = BetGiftsView()
    
    weak var delegate: (AnyObject & CosmicExplorationStarViewDelegate)? = nil
    
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
