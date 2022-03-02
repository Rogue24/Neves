//
//  NestScrollViewController.swift
//  Neves
//
//  Created by aa on 2022/1/25.
//

import UIKit

private let SubViewSize: CGSize = [PortraitScreenWidth - 60.px, PortraitScreenHeight - NavTopMargin - DiffTabBarH - 60.px]

class NestScrollViewController: TestBaseViewController {
    
    let mainScrollView = MainScrollView()
    
    var isCanScroll = true {
        didSet {
            mainScrollView.isScrollEnabled = isCanScroll
        }
    }
    
    var popViews = NSHashTable<UIView>.weakObjects()
    func checkIsCanScroll() {
        isCanScroll = popViews.anyObject == nil
        
        JPrint("popViews.count", popViews.count)
        if popViews.anyObject != nil {
            JPrint("有东西的")
        } else {
            JPrint("没东西了")
        }
        JPrint("--------------")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainScrollView.origin = [HalfDiffValue(PortraitScreenWidth, SubViewSize.width), NavTopMargin + 30.px]
        view.addSubview(mainScrollView)
        mainScrollView.ptDelegate = self
        
        var h: CGFloat = 0
        for i in 0 ..< 3 {
            let subLabel = UILabel(frame: CGRect(origin: [0, SubViewSize.height * CGFloat(i)], size: SubViewSize))
            subLabel.font = .boldSystemFont(ofSize: 80.px)
            subLabel.textColor = .randomColor
            subLabel.layer.backgroundColor = UIColor.randomColor.cgColor
            subLabel.textAlignment = .center
            subLabel.text = "\(i + 1)"
            subLabel.clipsToBounds = true
            subLabel.isUserInteractionEnabled = true
            subLabel.tag = i + 1
            mainScrollView.addSubview(subLabel)
            h = subLabel.maxY
        }
        mainScrollView.jp.contentInsetAdjustmentNever()
        mainScrollView.isPagingEnabled = true
        mainScrollView.contentSize = [0, h]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            self.showPopView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFunAction()
    }
    
}

extension NestScrollViewController {
    func showPopView() {
        let index = Int(round(Double(mainScrollView.contentOffset.y / mainScrollView.height)))
        guard let subview = mainScrollView.viewWithTag(index + 1) else { return }
        showPopView(on: subview)
    }
    
    func showPopView(on superView: UIView) {
        let popView = PopScrollView.show(on: superView) { [weak self] in
            guard let self = self else { return }
            self.hidePopView($0)
        }
        showPopView(popView)
    }
    
    func showPopView(_ popView: PopScrollView) {
        popViews.add(popView)
        popView.tag = popViews.count
        checkIsCanScroll()
    }

    func hidePopView(_ popView: PopScrollView?) {
        popViews.remove(popView)
        checkIsCanScroll()
    }
}

extension NestScrollViewController: MainScrollViewDelegate {
    func scrollViewIsCanScroll(_ scrollView: UIScrollView) -> Bool {
        isCanScroll
    }
}

// MARK: - MainScrollView

protocol MainScrollViewDelegate: NSObjectProtocol {
    func scrollViewIsCanScroll(_ scrollView: UIScrollView) -> Bool
}

class MainScrollView: UIScrollView {
    weak var ptDelegate: (AnyObject & MainScrollViewDelegate)? = nil
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: SubViewSize))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard super.gestureRecognizerShouldBegin(gestureRecognizer) else { return false }
        if let ptDelegate = self.ptDelegate, !ptDelegate.scrollViewIsCanScroll(self) {
            return false
        }
        return true
    }
}

// MARK: - PopScrollView

class PopScrollView: UIView {
    
    let contentView: UIView
    let collectionView: UICollectionView
    
    typealias Closed = (PopScrollView) -> ()
    var closed: Closed? = nil
    
    init() {
        self.contentView = UIView(frame: [0, SubViewSize.height, SubViewSize.width, SubViewSize.height * 0.5])
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = [(SubViewSize.width - 30.px) / 3 - 0.1, (SubViewSize.width - 30.px) / 3 - 0.1]
        layout.sectionInset = .zero
        self.collectionView = UICollectionView(frame: [15.px, 15.px, SubViewSize.width - 30.px, SubViewSize.height * 0.5 - 15.px], collectionViewLayout: layout)
        
        super.init(frame: CGRect(origin: .zero, size: SubViewSize))
        layer.backgroundColor = UIColor(white: 0, alpha: 0).cgColor
        
        contentView.backgroundColor = .randomColor
        addSubview(contentView)
        
        collectionView.jp.contentInsetAdjustmentNever()
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        JPrint("老子死了", tag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        if !contentView.frame.contains(point) {
            close()
        }
    }
    
    @discardableResult
    static func show(on superView: UIView, closed: @escaping Closed) -> PopScrollView {
        let popView = PopScrollView()
        popView.closed = closed
        superView.addSubview(popView)
        popView.show()
        return popView
    }
    
    func show() {
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.layer.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
            self.contentView.y = self.height - self.contentView.height
        }, completion: nil)
    }
    
    func close() {
        UIView.animate(withDuration: 0.3) {
            self.layer.backgroundColor = UIColor(white: 0, alpha: 0).cgColor
            self.contentView.y = self.height
        } completion: { _ in
            self.removeFromSuperview()
            self.closed?(self)
        }
    }
}

extension PopScrollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let label = cell.contentView.viewWithTag(10086) as? UILabel ?? {
            let label = UILabel(frame: cell.contentView.bounds)
            label.font = .boldSystemFont(ofSize: 30.px)
            label.textColor = .randomColor
            label.layer.backgroundColor = UIColor.randomColor.cgColor
            label.textAlignment = .center
            label.tag = 10086
            cell.contentView.addSubview(label)
            return label
        }()
        label.text = "\(indexPath.item + 1)"
        
        return cell
    }
}
