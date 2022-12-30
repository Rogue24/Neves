//
//  GuideIntoRoomGameTeamCardListView.swift
//  Neves
//
//  Created by aa on 2022/12/30.
//


class GuideIntoRoomGameTeamCardListView: UICollectionView, GuideIntoRoomContentViewCompatible {
    var viewSize: CGSize = .zero
    
    let gameId: UInt32
    
    let flowLayout = GuideIntoRoomGameTeamLayout()
    
    private(set) var dataList: [Int] = []
    
    private let largeCount = 1000
    private let scrollSecond: TimeInterval = 0.5
    private let staySecond: TimeInterval = 0.5 + 1.5
    
    private var dataTotal: Int = 0
    private var dataIndex: Int = 0
    
    private var itemTotal: Int = 0
    private var itemIndex: Int = 0
    
    private var isLoopShow: Bool { dataTotal > 1 }
    private var loopWorkItem: DispatchWorkItem?
    
    private var isFirstDecelerate = true
    private var isDecelerate = false
    private var isLoopEnabled = false
    
    private var pageWidth: CGFloat {
        flowLayout.itemSize.width + flowLayout.minimumLineSpacing
    }
    private var currentIndexPath: IndexPath {
        indexPathForItem(at: [(contentOffset.x + frame.width * 0.5), 0]) ?? .init(item: 0, section: 0)
    }
    
    init(gameId: UInt32) {
        self.gameId = gameId
        self.viewSize = [GuideIntoRoomPopView.baseSize.width, flowLayout.itemSize.height]
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        backgroundColor = .randomColor
        clipsToBounds = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        isScrollEnabled = false
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        loopEnable()
        Asyncs.mainDelay(0.1) {
            self.reloadData([1, 2, 3, 4, 5])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        loopWorkItem?.cancel()
    }
}

extension GuideIntoRoomGameTeamCardListView: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemTotal
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .black
        
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
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isFirstDecelerate {
            isFirstDecelerate = false
            isDecelerate = decelerate
        }
        if !isDecelerate { scrollViewDidEndDecelerating(scrollView) }
    }

    // 手指滑动动画停止时会调用该方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEnd()
    }
}

// MARK: - API
extension GuideIntoRoomGameTeamCardListView {
    func loopEnable() {
        guard !isLoopEnabled else { return }
        isLoopEnabled = true
        startAutoLoopShow()
    }
    
    func unLoopEnable() {
        guard isLoopEnabled else { return }
        isLoopEnabled = false
        stopAutoLoopShow()
    }
}

// MARK: - Reload
private extension GuideIntoRoomGameTeamCardListView {
    func reloadData(_ dataList: [Int]) {
        stopAutoLoopShow()
        
        self.dataList = dataList
        
        dataTotal = dataList.count
        if dataIndex >= dataTotal { dataIndex = dataTotal > 0 ? (dataTotal - 1) : 0 }
        itemTotal = isLoopShow ? (dataTotal * largeCount) : dataTotal
        itemIndex = getMidItemIndex(dataIndex)
        
        reloadData()
        
        if dataTotal > 0 {
            scrollToItem(at: itemIndex, animated: false)
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {} completion: { _ in
                self.startAutoLoopShow()
            }
        }
    }
}

// MARK: - Scroll
private extension GuideIntoRoomGameTeamCardListView {
    func scrollToItem(at itemIndex: Int, animated: Bool) {
        JPrint("itemIndex", itemIndex)
        
        let offsetX = (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * CGFloat(itemIndex)
        
        if !animated {
            scrollToItem(at: IndexPath(item: itemIndex, section: 0), at: .centeredHorizontally, animated: false)
            scrollDidEnd()
            return
        }
        
        guard let scrollAnim = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset) else {
            scrollToItem(at: IndexPath(item: itemIndex, section: 0), at: .centeredHorizontally, animated: true)
            return
        }
        scrollAnim.duration = scrollSecond
        scrollAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scrollAnim.toValue = offsetX
        scrollAnim.completionBlock = { [weak self] _, _ in
            guard let self = self else { return }
            self.isUserInteractionEnabled = true
            self.scrollDidEnd()
        }
        isUserInteractionEnabled = false
        self.pop_add(scrollAnim, forKey: kPOPScrollViewContentOffset)
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
    }
}

// MARK: - AutoLoopShow
private extension GuideIntoRoomGameTeamCardListView {
    func startAutoLoopShow() {
        guard isLoopShow, isLoopEnabled else {
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
        guard isLoopShow, isLoopEnabled else {
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
private extension GuideIntoRoomGameTeamCardListView {
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


class GuideIntoRoomGameTeamLayout: UICollectionViewFlowLayout {
    
    private let diffScale: CGFloat
    private let diffAlpha: CGFloat
    private var baseDist: CGFloat = 0
    
    override init() {
        let minScale = 0.8
        let minAlpha = 0.5
        self.diffScale = 1 - minScale
        self.diffAlpha = 1 - minAlpha
        super.init()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        itemSize = [250, 75]
        
        let horInset = HalfDiffValue(GuideIntoRoomPopView.baseSize.width, itemSize.width)
        sectionInset = .init(top: 0, left: horInset, bottom: 0, right: horInset)
        
        let lineSpacing: CGFloat = 10
        let halfDiffItemW = HalfDiffValue(itemSize.width, itemSize.width * minScale)
        minimumLineSpacing = lineSpacing - halfDiffItemW
        
        baseDist = itemSize.width * 0.5 + minimumLineSpacing + itemSize.width * 0.5
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
            var disScale = distance / baseDist
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
