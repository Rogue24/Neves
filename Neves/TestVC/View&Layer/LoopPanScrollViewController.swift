//
//  LoopPanScrollViewController.swift
//  Neves
//
//  Created by aa on 2022/12/30.
//

class LoopPanScrollViewController: TestBaseViewController {
    
    private var container: UIView!
    private var flowLayout: AdjacentScaleLayout!
    private var collectionView: UICollectionView!
    private var panView: UIScrollView!
    
    private var pageWidth: CGFloat {
        flowLayout.itemSize.width + flowLayout.lineSpacing
    }
    private var currentIndexPath: IndexPath {
        collectionView.indexPathForItem(at: [(collectionView.contentOffset.x + collectionView.bounds.width * 0.5), 0]) ?? .init(item: 0, section: 0)
    }
    
    private let largeCount = 1000 // 不能为2！！！建议10的倍数！
    // 如果为2时，数据为5个，最后一个下标则为9，此时取中间下标 = 5 * 2 / 2 + 4 = 9，跟最后一个下标相等，导致死循环！
    
    private let scrollSecond: TimeInterval = 0.5
    private let staySecond: TimeInterval = 3.5
    
    private var dataTotal: Int = 0
    private var dataIndex: Int = 0
    
    private var itemTotal: Int = 0
    private var itemIndex: Int = 0
    
    private var isLoopShow: Bool { dataTotal > 1 }
    private var loopWorkItem: DispatchWorkItem?
    
    private var isFirstDecelerate = true
    private var isDecelerate = false
    private var isDragging = false
    private var isLoopEnabled = false
    
    
    private(set) var dataList: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIView(frame: [16, 180, PortraitScreenWidth - 32, PortraitScreenWidth - 32])
        container.backgroundColor = .randomColor
        view.addSubview(container)
        self.container = container
        
        let itemSize: CGSize = [250.px, 75.px]
        let horInset = HalfDiffValue(container.width, itemSize.width)
        let flowLayout = AdjacentScaleLayout(adjacentScale: 0.8,
                                             adjacentAlpha: 0.5,
                                             itemSize: itemSize,
                                             horInset: horInset,
                                             lineSpacing: 0)
        
        let collectionView = UICollectionView(frame: [0, HalfDiffValue(container.height, itemSize.height), container.width, itemSize.height], collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        container.addSubview(collectionView)
        self.flowLayout = flowLayout
        self.collectionView = collectionView
        
        let panView = UIScrollView(frame: [HalfDiffValue(container.width, pageWidth), collectionView.maxY + 10, pageWidth, 50])
        panView.isUserInteractionEnabled = false // 不用响应了，因为滑动collectionView就是滑动panView
        panView.alwaysBounceHorizontal = true
        panView.isPagingEnabled = true
        panView.delegate = self
        panView.backgroundColor = .randomColor(0.5)
        container.addSubview(panView)
        self.panView = panView
        
        // 自定义页面滑动区域：
        // 往collectionView添加panView的滑动手势，这样对collectionView的滑动就会转嫁到panView上，
        // 也就是滑动collectionView，变成滑动panView了，而collectionView自身不会动，
        // 这时候只要将panView的偏移量同步到collectionView上，这样就能实现自定义页面滑动区域。
        collectionView.addGestureRecognizer(panView.panGestureRecognizer)
        
        let slider = UISlider()
        slider.frame = [16, container.maxY + 20, PortraitScreenWidth - 32, 20]
        slider.minimumValue = -50
        slider.maximumValue = 50
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderDidChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyActions([
            FunnyAction(name: "\(isLoopEnabled ? "关闭自动循环" : "开启自动循环")") { [weak self] in
                guard let self = self else { return }
                if self.isLoopEnabled { self.unLoopEnable() } else { self.loopEnable() }
            },
            
            FunnyAction(name: "刷新数据") { [weak self] in
                guard let self = self else { return }
                
                JPHUD.show()
                Asyncs.mainDelay(0.2) {
                    JPHUD.dismiss()
                    let dataList = (1 ..< Int.random(in: 2...10)).map { $0 }
                    self.reloadData(dataList)
                }
            },
        ])
    }
    
    deinit {
        loopWorkItem?.cancel()
    }
    
    @objc func sliderDidChanged(_ slider: UISlider) {
        let value = CGFloat(slider.value)
        JPrint("value", value)
        
        stopAutoLoopShow()
        
        let indexPath = currentIndexPath
        
        flowLayout.lineSpacing = value
        
        panView.frame = [HalfDiffValue(container.width, pageWidth), collectionView.maxY + 10, pageWidth, 50]
        panView.contentSize = [CGFloat(itemTotal) * pageWidth, 0]
        
        scrollToItem(at: indexPath.item, animated: false)
        
        startAutoLoopShow()
    }
}

extension LoopPanScrollViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemTotal
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .randomColor
        
        let label = cell.viewWithTag(10086) as? UILabel ?? {
            let label = UILabel()
            label.tag = 10086
            label.font = .boldSystemFont(ofSize: 50)
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            return label
        }()
        let itemIndex = indexPath.item
        let dataIndex = getDataIndex(itemIndex)
        let data = dataList[dataIndex]
        label.textColor = .randomColor
        label.text = "\(data)"
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stopAutoLoopShow()
        scrollToItem(at: indexPath.item, animated: true)
        startAutoLoopShow()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == panView else { return }
        isDragging = true
        stopAutoLoopShow()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == panView else { return }
        scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == panView else { return }
        if isFirstDecelerate {
            isFirstDecelerate = false
            isDecelerate = decelerate
        }
        if !isDecelerate { scrollViewDidEndDecelerating(scrollView) }
    }

    // 手指滑动动画停止时会调用该方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == panView else { return }
        scrollDidEnd()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == panView else { return }
        collectionView.contentOffset = scrollView.contentOffset
    }
}

// MARK: - loop enable
extension LoopPanScrollViewController {
    func loopEnable() {
        guard !isLoopEnabled else { return }
        isLoopEnabled = true
        isDragging = false
        startAutoLoopShow()
    }
    
    func unLoopEnable() {
        guard isLoopEnabled else { return }
        isLoopEnabled = false
        isDragging = false
        stopAutoLoopShow()
    }
}

// MARK: - Reload
private extension LoopPanScrollViewController {
    func reloadData(_ dataList: [Int]) {
        isDragging = false
        stopAutoLoopShow()
        
        self.dataList = dataList
        
        dataTotal = dataList.count
        if dataIndex >= dataTotal { dataIndex = dataTotal > 0 ? (dataTotal - 1) : 0 }
        itemTotal = isLoopShow ? (dataTotal * largeCount) : dataTotal
        itemIndex = getMidItemIndex(dataIndex)
        
        collectionView.reloadData()
        panView.contentSize = [CGFloat(itemTotal) * pageWidth, 0]
        
        if dataTotal > 0 {
            scrollToItem(at: itemIndex, animated: false)
            UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve) {} completion: { _ in
                self.startAutoLoopShow()
            }
        }
    }
}

// MARK: - Scroll
private extension LoopPanScrollViewController {
    func scrollToItem(at itemIndex: Int, animated: Bool) {
        JPrint("itemIndex", itemIndex)
        
        let offset: CGPoint = [CGFloat(itemIndex) * pageWidth, 0]
        
        if !animated {
            panView.setContentOffset(offset, animated: false)
            scrollDidEnd()
            return
        }
        
        guard let scrollAnim = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset) else {
            panView.setContentOffset(offset, animated: true)
            return
        }
        scrollAnim.duration = scrollSecond
        scrollAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scrollAnim.toValue = offset
        scrollAnim.completionBlock = { [weak self] _, _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            self.scrollDidEnd()
        }
        collectionView.isUserInteractionEnabled = false
        panView.pop_add(scrollAnim, forKey: kPOPScrollViewContentOffset)
    }
    
    func scrollDidEnd() {
        isFirstDecelerate = true
        
        let indexPath = currentIndexPath
        let itemIndex = indexPath.item
        let dataIndex = getDataIndex(itemIndex)
        
        if isLoopShow, itemIndex >= (itemTotal - 1) {
            scrollToItem(at: getMidItemIndex(dataIndex), animated: false)
            return
        }
        
        self.itemIndex = itemIndex
        self.dataIndex = dataIndex
        
        if isDragging {
            isDragging = false
            startAutoLoopShow()
        }
    }
}

// MARK: - AutoLoopShow
private extension LoopPanScrollViewController {
    func startAutoLoopShow() {
        guard isLoopShow, isLoopEnabled, !isDragging else {
            stopAutoLoopShow()
            return
        }
        
        guard loopWorkItem == nil else { return }
        loopWorkItem = Asyncs.mainDelay(staySecond) { [weak self] in
            guard let self = self else { return }
            self.stopAutoLoopShow()
            self.showNextItem()
            self.startAutoLoopShow()
        }
    }
    
    func stopAutoLoopShow() {
        loopWorkItem?.cancel()
        loopWorkItem = nil
    }
    
    func showNextItem() {
        guard isLoopShow, isLoopEnabled, !isDragging else {
            stopAutoLoopShow()
            return
        }
        
        if (itemIndex + 1) >= itemTotal {
            scrollToItem(at: getMidItemIndex(dataIndex), animated: false)
        }
        
        let nextItemIndex = itemIndex + 1
        scrollToItem(at: nextItemIndex, animated: true)
    }
}

// MARK: - Getter
private extension LoopPanScrollViewController {
    func getDataIndex(_ itemIndex: Int) -> Int {
        if isLoopShow {
            return itemIndex % dataTotal
        } else {
            return itemIndex < dataTotal ? itemIndex : 0
        }
    }
    
    func getDataSection(_ itemIndex: Int) -> Int {
        if isLoopShow {
            let dataIndex = itemIndex % dataTotal
            return itemIndex - dataIndex
        } else {
            return 0
        }
    }
    
    func getItemIndex(_ dataIndex: Int) -> Int {
        if isLoopShow {
            return getDataSection(itemIndex) + dataIndex
        } else {
            return dataIndex
        }
    }
    
    func getMidItemIndex(_ dataIndex: Int) -> Int {
        if isLoopShow, itemTotal > 0 {
            return itemTotal / 2 + dataIndex
        } else {
            return dataIndex
        }
    }
}


class AdjacentScaleLayout: UICollectionViewFlowLayout {
    
    let adjacentScale: CGFloat
    let adjacentAlpha: CGFloat
    
    private let diffScale: CGFloat
    private let diffAlpha: CGFloat
    
    private var adjacentDistance: CGFloat = 0
    
    var lineSpacing: CGFloat {
        set { resetLineSpacing(newValue) }
        get { minimumLineSpacing }
    }
    
    init(adjacentScale: CGFloat, adjacentAlpha: CGFloat, itemSize: CGSize, horInset: CGFloat, lineSpacing: CGFloat) {
        self.adjacentScale = adjacentScale
        self.adjacentAlpha = adjacentAlpha
        self.diffScale = 1 - adjacentScale
        self.diffAlpha = 1 - adjacentAlpha
        super.init()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        sectionInset = .init(top: 0, left: horInset, bottom: 0, right: horInset)
        self.itemSize = itemSize
        resetLineSpacing(lineSpacing)
    }
    
    private func resetLineSpacing(_ value: CGFloat) {
        let halfDiffItemW = HalfDiffValue(itemSize.width, itemSize.width * adjacentScale)
        minimumLineSpacing = value - halfDiffItemW
        adjacentDistance = itemSize.width * 0.5 + minimumLineSpacing + itemSize.width * 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView,
              var attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        attributes = attributes.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        
        let halfViewW = collectionView.bounds.width * 0.5
        let centerX = collectionView.contentOffset.x + halfViewW
        
        attributes.forEach { att in
            let distance = abs(att.center.x - centerX)
            var disScale = distance / adjacentDistance
            if disScale > 1 {
                disScale = 1
            }
            
            let scale = 1 - diffScale * disScale
            let alpha = 1 - diffAlpha * disScale
            att.transform = CGAffineTransform(scaleX: scale, y: scale)
            att.alpha = alpha
        }
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
