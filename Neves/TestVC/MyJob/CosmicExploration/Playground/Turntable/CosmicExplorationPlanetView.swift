//
//  CosmicExplorationPlanetView.swift
//  Neves
//
//  Created by aa on 2022/3/28.
//

import CoreGraphics
import UIKit

protocol CosmicExplorationPlanetViewDelegate {
    func planetView(_ planetView: CosmicExplorationPlanetView,
                    updateSuppliesFromSupplyType supplyType: CosmicExploration.SupplyType,
                    toItemFrame itemFrame: CGRect)
}

class CosmicExplorationPlanetView: UIView {
    
    static let size: CGSize = [118.px, 118.px]
    
    class MultipleView: UIView {
        
        let bgImgView = UIImageView()
        let multipleLabel = UILabel()
        
        init?(_ planet: CosmicExploration.Planet) {
            let multiple = planet.multiple
            guard multiple > 0 else { return nil }
            
            let size: CGSize = [38.px, 21.px]
            super.init(frame: CGRect(origin: [CosmicExplorationPlanetView.size.width - size.width - 17.5.px, 28.px], size: size))
            
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
    
    weak var delegate: (AnyObject & CosmicExplorationPlanetViewDelegate)? = nil
    
    let planet: CosmicExploration.Planet
    let bgImgView = UIImageView()
    
    var multiple: Int = 0
    let multipleView: MultipleView?
    let supplyListView = SupplyListView()
    private var otherSupplyViews: [OtherSupplyView] = []
    
    let bgAnimView: AnimationView = AnimationView(animation: nil, imageProvider: nil)
    let selectedAnimView: AnimationView = AnimationView(animation: nil, imageProvider: nil)
    let exploringAnimView: AnimationView = AnimationView(animation: nil, imageProvider: nil)
    weak var winningAnimView: AnimationView?
    
    init(_ model: CosmicExploration.PlanetModel) {
        let planet = model.planet
        
        let size = CosmicExplorationPlanetView.size
        let origin: CGPoint
        switch planet {
        case .mercury:
            origin = [55.px, 22.5.px]
        case .venus:
            origin = [PortraitScreenWidth - 55.px - size.width, 22.5.px]
        case .mars:
            origin = [PortraitScreenWidth - size.width, 132.5.px]
        case .jupiter:
            origin = [PortraitScreenWidth - 55.px - size.width, 242.5.px]
        case .saturn:
            origin = [55.px, 242.5.px]
        case .uranus:
            origin = [0, 132.5.px]
        }
        
        self.planet = planet
        self.multipleView = MultipleView(planet)
        super.init(frame: CGRect(origin: origin, size: size))
        
        bgAnimView.backgroundBehavior = .pauseAndRestore
        bgAnimView.contentMode = .scaleAspectFill
        bgAnimView.frame = bounds
        bgAnimView.loopMode = .loop
        addSubview(bgAnimView)
        
        bgImgView.image = planet.bgImg
        bgImgView.frame = bounds
        addSubview(bgImgView)
        
        selectedAnimView.backgroundBehavior = .pauseAndRestore
        selectedAnimView.contentMode = .scaleAspectFill
        selectedAnimView.frame = bounds
        selectedAnimView.loopMode = .loop
        selectedAnimView.alpha = 0
        addSubview(selectedAnimView)
        
        exploringAnimView.backgroundBehavior = .pauseAndRestore
        exploringAnimView.contentMode = .scaleAspectFill
        exploringAnimView.frame = bounds
        exploringAnimView.loopMode = .loop
        exploringAnimView.alpha = 0
        addSubview(exploringAnimView)
        
        multipleView.map { addSubview($0) }
        
        addSubview(supplyListView)
        
        updateIsSelected(model.isSelected, animated: false)
        updateSupplies(model.supplyModels, animated: false)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClick)))
        
        // TODO: 临时做法
        DispatchQueue.main.async {
            if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/spaceship_default_lottie"), let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
                self.bgAnimView.animation = animation
                self.bgAnimView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
                self.bgAnimView.play()
            }

            if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/spaceship_target_lottie"), let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
                self.selectedAnimView.animation = animation
                self.selectedAnimView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
                self.selectedAnimView.stop()
            }
            
            if let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/spaceship_random_lottie"), let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache) {
                self.exploringAnimView.animation = animation
                self.exploringAnimView.imageProvider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
                self.exploringAnimView.stop()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("我心已死")
    }
    
}

extension CosmicExplorationPlanetView {
    @objc func didClick() {
        CosmicExplorationManager.shared.selectPlanet(planet)
    }
}

// MARK: - 选中状态
extension CosmicExplorationPlanetView {
    func updateIsSelected(_ isSelected: Bool, animated: Bool = true) {
        if isSelected {
            selectedAnimView.play()
            if animated {
                UIView.animate(withDuration: 0.15) {
                    self.selectedAnimView.alpha = 1
                }
            } else {
                selectedAnimView.alpha = 1
            }
        } else {
            if animated {
                UIView.animate(withDuration: 0.15) {
                    self.selectedAnimView.alpha = 0
                } completion: { finished in
                    guard finished else { return }
                    self.selectedAnimView.stop()
                }
            } else {
                selectedAnimView.stop()
                selectedAnimView.alpha = 0
            }
        }
    }
}

// MARK: - 我的补给
extension CosmicExplorationPlanetView {
    struct SupplyItemModel {
        let type: CosmicExploration.SupplyType
        let itemTitle: String
        var itemFrame: CGRect
        
        static func convert(fromSupplyModels supplyModels: [CosmicExploration.SupplyModel]) -> [SupplyItemModel] {
            var itemModels: [SupplyItemModel] = []
            
            let planetWidth = CosmicExplorationPlanetView.size.width
            let itemH: CGFloat = 14.px
            let minItemW = 20.5.px
            
            for model in supplyModels {
                let itemTitle = "+\(model.count)"
                let itemW = minItemW + itemTitle.jp.textSize(withFont: .systemFont(ofSize: 10.px)).width
                itemModels.append(SupplyItemModel(type: model.type, itemTitle: itemTitle, itemFrame: [0, 0, itemW, itemH]))
            }
            
            let total = itemModels.count
            let space: CGFloat = 2.px
            
            switch total {
            case 1:
                var itemModel1 = itemModels[0]
                itemModel1.itemFrame.origin.x = HalfDiffValue(planetWidth, itemModel1.itemFrame.width)
                itemModels[0] = itemModel1
                
            case 2...:
                var itemModel1 = itemModels[0]
                var itemModel2 = itemModels[1]
                let firstLineW = itemModel1.itemFrame.width + space + itemModel2.itemFrame.width
                
                itemModel1.itemFrame.origin.x = HalfDiffValue(planetWidth, firstLineW)
                itemModels[0] = itemModel1
                
                itemModel2.itemFrame.origin.x = itemModel1.itemFrame.maxX + space
                itemModels[1] = itemModel2
                
                if total > 2 {
                    let y = itemModel2.itemFrame.maxY + space
                    var itemModel3 = itemModels[2]
                    if total > 3 {
                        var itemModel4 = itemModels[3]
                        let secondLineW = itemModel3.itemFrame.width + space + itemModel4.itemFrame.width
                        
                        itemModel3.itemFrame.origin = [HalfDiffValue(planetWidth, secondLineW), y]
                        itemModels[2] = itemModel3
                        
                        itemModel4.itemFrame.origin = [itemModel3.itemFrame.maxX + space, y]
                        itemModels[3] = itemModel4
                    } else {
                        itemModel3.itemFrame.origin = [HalfDiffValue(planetWidth, itemModel3.itemFrame.width), y]
                        itemModels[2] = itemModel3
                    }
                }
            default:
                break
            }
            
            return itemModels
        }
    }
    
    class SupplyItem: UIView {
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
        
        func updateUI(_ itemModel: SupplyItemModel) {
            label.text = itemModel.itemTitle
            frame = itemModel.itemFrame
        }
    }
    
    
    class SupplyListView: UIView {
        
        var items: [SupplyItem] = []
        
        init() {
            super.init(frame: [0, CosmicExplorationPlanetView.size.height - 38.px, CosmicExplorationPlanetView.size.width, 38.px])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateSupplies(_ itemModels: [SupplyItemModel], animated: Bool = true) {
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
                            let item = SupplyItem()
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
                        let item = SupplyItem()
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
    
    func updateSupplies(_ supplyModels: [CosmicExploration.SupplyModel], supplyType: CosmicExploration.SupplyType? = nil, animated: Bool = true) {
        let itemModels = SupplyItemModel.convert(fromSupplyModels: supplyModels)
        
        guard animated else {
            supplyListView.updateSupplies(itemModels, animated: false)
            return
        }
        
        var delay: TimeInterval = 0
        if let delegate = self.delegate,
           let superView = self.superview,
           let supplyType = supplyType,
           var itemFrame = itemModels.first(where: { $0.type == supplyType })?.itemFrame
        {
            itemFrame = supplyListView.convert(itemFrame, to: superView)
            delegate.planetView(self, updateSuppliesFromSupplyType: supplyType, toItemFrame: itemFrame)
            delay = 0.3
        }
        
        Asyncs.mainDelay(delay) {
            self.supplyListView.updateSupplies(itemModels, animated: true)
        }
    }
}

// MARK: - 别人的补给
extension CosmicExplorationPlanetView {
    class OtherSupplyView: UIView {
        let userIcon = UIImageView()
        let supplyIcon = UIImageView()
        
        private var willHide: ((OtherSupplyView) -> ())?
        private var hideWorkItem: DispatchWorkItem? = nil
        
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
            
            supplyIcon.image = UIImage(named: "dragon_weideng")
            supplyIcon.frame = [(45 - 10 - 2.5).px, 2.px, 10.px, 10.px]
            addSubview(supplyIcon)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        static func show(on view: UIView, delay: TimeInterval, willHide: @escaping (OtherSupplyView) -> ()) -> OtherSupplyView {
            let osView = OtherSupplyView()
            view.addSubview(osView)
            
            osView.alpha = 0
            osView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 5.px)
            
            UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.88, initialSpringVelocity: 0, options: []) {
                osView.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { _ in }
            
            UIView.animate(withDuration: 0.17, delay: delay, options: []) {
                osView.alpha = 1
            } completion: { _ in }
            
            osView.hideWorkItem = Asyncs.mainDelay(3 + delay) {
                osView.hideAnim()
            }
            
            osView.willHide = willHide
            return osView
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
    
    func addSupplyFromOther() {
        JPrint("来了老弟")
        let delay: TimeInterval = otherSupplyViews.count == 0 ? 0 : 0.23
        
        otherSupplyViews.forEach { $0.topAnim() }
        
        let osView = OtherSupplyView.show(on: self, delay: delay) { [weak self] kOsView in
            guard let self = self else { return }
            self.otherSupplyViews.removeAll { $0 == kOsView }
        }
        
        otherSupplyViews.insert(osView, at: 0)
    }
}

// MARK: - 探索动画
extension CosmicExplorationPlanetView {
    func startExploringAnimtion(endDelay: TimeInterval) {
        exploringAnimView.pop_removeAllAnimations()
        
        exploringAnimView.play()
        if exploringAnimView.alpha == 1 { return }
        
        let anim1 = POPBasicAnimation(propertyNamed: kPOPViewAlpha)!
        anim1.toValue = 1
        anim1.duration = 0.12
        exploringAnimView.pop_add(anim1, forKey: "start")
        
        guard endDelay > 0 else { return }
        let anim2 = POPBasicAnimation(propertyNamed: kPOPViewAlpha)!
        anim2.toValue = 0
        anim2.duration = 0.12
        anim2.beginTime = CACurrentMediaTime() + endDelay
        anim2.completionBlock = { [weak exploringAnimView] _, finished in
            guard finished else { return }
            exploringAnimView?.stop()
        }
        exploringAnimView.pop_add(anim2, forKey: "end")
    }
    
    func stopExploringAnimtion() {
        exploringAnimView.pop_removeAllAnimations()
        
        guard exploringAnimView.alpha > 0 else {
            exploringAnimView.stop()
            return
        }
        
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)!
        anim.toValue = 0
        anim.duration = 0.12
        anim.completionBlock = { [weak exploringAnimView] _, finished in
            guard finished else { return }
            exploringAnimView?.stop()
        }
        exploringAnimView.pop_add(anim, forKey: "end")
    }
    
//    func
}

// MARK: - 中奖状态
extension CosmicExplorationPlanetView {
    func updateIsWinning(_ isWinning: Bool, animated: Bool = true) {
        if isWinning {
            startExploringAnimtion(endDelay: 0)
            
            guard winningAnimView == nil,
                  let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/spaceship_result_lottie"),
                  let animation = Animation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
            else {
                return
            }
            
            let animView = AnimationView(animation: animation, imageProvider: FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path))
            animView.backgroundBehavior = .pauseAndRestore
            animView.contentMode = .scaleAspectFill
            animView.frame = bounds
            animView.loopMode = .loop
            addSubview(animView)
            self.winningAnimView = animView
            
            if animated {
                animView.alpha = 0
                animView.play()
                UIView.animate(withDuration: 0.15) {
                    animView.alpha = 1
                }
            } else {
                animView.play()
            }
            
        } else {
            stopExploringAnimtion()
            
            guard let animView = winningAnimView else { return }
            if animated {
                UIView.animate(withDuration: 0.15) {
                    animView.alpha = 0
                } completion: { _ in
                    animView.stop()
                    animView.removeFromSuperview()
                }
            } else {
                animView.stop()
                animView.removeFromSuperview()
            }
        }
    }
}
