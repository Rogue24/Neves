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
    
    private var pageWidth: CGFloat {
        flowLayout.itemSize.width + flowLayout.minimumLineSpacing
    }
    private var currentIndexPath: IndexPath {
        indexPathForItem(at: [(contentOffset.x + frame.width * 0.5), 0]) ?? .init(item: 0, section: 0)
    }
    
    init(gameId: UInt32) {
        self.gameId = gameId
        self.viewSize = [GuideIntoRoomPopView.viewWidth, flowLayout.itemSize.height]
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        backgroundColor = .clear
        clipsToBounds = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        isScrollEnabled = false
        register(Cell.self, forCellWithReuseIdentifier: "cell")
        Asyncs.mainDelay(0.1) {
            let dataList = Array(1...Int.random(in: 1...10))
            self.reloadData(dataList)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        loopWorkItem?.cancel()
    }
    
    var showTag = 0
    func testShow() {
        showTag += 1
        if showTag > 3 {
            showTag = 0
        }
        reloadData(dataList)
    }
}

extension GuideIntoRoomGameTeamCardListView: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemTotal
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.showTag = showTag
        
//        let label = cell.viewWithTag(10086) as? UILabel ?? {
//            let label = UILabel()
//            label.tag = 10086
//            label.font = .boldSystemFont(ofSize: 50)
//            label.textAlignment = .center
//            cell.contentView.addSubview(label)
//            label.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
//            }
//            return label
//        }()
//        let itemIndex = indexPath.item
//        let dataIndex = getDataIndex(itemIndex)
//        let data = dataList[dataIndex]
//        label.textColor = .randomColor
//        label.text = "\(data)"
        
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEnd()
    }
}

// MARK: - Reload
private extension GuideIntoRoomGameTeamCardListView {
    func reloadData(_ dataList: [Int]) {
        JPrint("dataList.count", dataList.count)
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
        guard isLoopShow else {
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
        guard isLoopShow else {
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
        itemSize = GuideIntoRoomGameTeamCardListView.Cell.size
        
        let horInset = HalfDiffValue(GuideIntoRoomPopView.viewWidth, itemSize.width)
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

extension GuideIntoRoomGameTeamCardListView {
    class Cell: UICollectionViewCell {
        static let size: CGSize = [250, 75]
        
        var showTag = 0 {
            didSet {
                switch showTag {
                case 1:
                    voiceBgView.isHidden = true
                case 2:
                    demandLabel1.isHidden = true
                case 3:
                    demandLabel2.isHidden = true
                default:
                    voiceBgView.isHidden = false
                    demandLabel1.isHidden = false
                    demandLabel2.isHidden = false
                }
            }
        }
        
        let userIcon = UIImageView()
        
        let voiceBgView = UIView()
        let voiceLabel = UILabel()
        
        let demandLabel1 = UILabel()
        
        let demandLabel2 = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let bgImgView = UIImageView(image: UIImage(named: "roomguide_game_listbg"))
            contentView.addSubview(bgImgView)
            bgImgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            userIcon.image = UIImage(named: "jp_icon")
            userIcon.contentMode = .scaleAspectFill
            userIcon.layer.cornerRadius = 29
            userIcon.layer.borderWidth = 1
            userIcon.layer.borderColor = UIColor.white.cgColor
            userIcon.layer.masksToBounds = true
            contentView.addSubview(userIcon)
            userIcon.snp.makeConstraints { make in
                make.width.height.equalTo(58)
                make.left.equalTo(20)
                make.centerY.equalToSuperview()
            }
            
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 3
            stackView.distribution = .fillProportionally
            contentView.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.left.equalTo(userIcon.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
            
            stackView.addArrangedSubview(voiceBgView)
            voiceBgView.snp.makeConstraints { make in
                make.height.equalTo(14)
            }
            
            let gradientView = GradientView()
            gradientView.startPoint = [0, 0.5]
            gradientView.endPoint = [1, 0.5]
            gradientView.colors = [.rgb(255, 89, 158), .rgb(255, 129, 117)]
            gradientView.layer.cornerRadius = 4
            gradientView.layer.masksToBounds = true
            voiceBgView.addSubview(gradientView)
            gradientView.snp.makeConstraints { make in
                make.top.left.bottom.equalToSuperview()
            }
            
            voiceLabel.font = .systemFont(ofSize: 9)
            voiceLabel.textColor = .white
            voiceLabel.text = "美男音"
            gradientView.addSubview(voiceLabel)
            voiceLabel.snp.makeConstraints { make in
                make.left.equalTo(3)
                make.right.equalTo(-3)
                make.top.bottom.equalToSuperview()
            }
            
            demandLabel1.font = .systemFont(ofSize: 11)
            demandLabel1.textColor = UIColor(white: 1, alpha: 0.8)
            demandLabel1.text = "王者荣耀·永恒钻石·微信"
            stackView.addArrangedSubview(demandLabel1)
            demandLabel1.snp.makeConstraints { make in
                make.height.equalTo(18)
            }
            
            demandLabel2.font = .systemFont(ofSize: 11)
            demandLabel2.textColor = UIColor(white: 1, alpha: 0.8)
            demandLabel2.text = "和平精英·战神·QQ"
            stackView.addArrangedSubview(demandLabel2)
            demandLabel2.snp.makeConstraints { make in
                make.height.equalTo(18)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
