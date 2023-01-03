//
//  GuideIntoRoomUserIconListView.swift
//  Neves
//
//  Created by aa on 2022/12/30.
//

import Lottie

class GuideIntoRoomUserIconListView: UIView, GuideIntoRoomContentViewCompatible {
    var viewSize: CGSize = .zero
    
    let isBlindDate: Bool
    
    var animView: LottieAnimationView!
    
    var models: [ItemModel] = []
    
    init(isBlindDate: Bool) {
        self.isBlindDate = isBlindDate
        self.viewSize = [GuideIntoRoomPopView.viewWidth, CGFloat(53 + 26)]
        super.init(frame: .zero)
        
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "lottie/roomguide_picture_lottie"),
              let animation = LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        else {
            JPrint("路径错误！")
            return
        }
        let provider = FilepathImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path)
        animView = LottieAnimationView(animation: animation, imageProvider: provider)
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop
        animView.backgroundBehavior = .pauseAndRestore
        addSubview(animView)
        animView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(53)
            make.top.equalToSuperview()
        }
        animView.play()
        
        if isBlindDate {
            setupBlindDateUI()
        } else {
            setupTagList()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBlindDateUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
        
        let model1 = ItemModel(name: "互相交流")
        let model2 = ItemModel(name: "选择心动")
        let model3 = ItemModel(name: "成功牵手")
        
        let item1 = Item()
        item1.model = model1
        stackView.addArrangedSubview(item1)
        item1.snp.makeConstraints { make in
            make.size.equalTo(model1.nameSize)
        }
        
        let line1 = UIImageView(image: UIImage(named: "roomguide_flow_line"))
        stackView.addArrangedSubview(line1)
        line1.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(24)
        }
        
        let item2 = Item()
        item2.model = model2
        stackView.addArrangedSubview(item2)
        item2.snp.makeConstraints { make in
            make.size.equalTo(model2.nameSize)
        }
        
        let line2 = UIImageView(image: UIImage(named: "roomguide_flow_line"))
        stackView.addArrangedSubview(line2)
        line2.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(24)
        }
        
        let item3 = Item()
        item3.model = model3
        stackView.addArrangedSubview(item3)
        item3.snp.makeConstraints { make in
            make.size.equalTo(model3.nameSize)
        }
        
        viewSize.height += 24
    }
    
    func setupTagList() {
        models = [
            ItemModel(name: "互相交流"),
            ItemModel(name: "选择心动"),
            ItemModel(name: "成功牵手"),
            ItemModel(name: "成功牵手"),
            ItemModel(name: "选择心动成功牵手"),
            ItemModel(name: "成功牵手"),
            ItemModel(name: "成功牵手选择心动"),
            ItemModel(name: "成功牵手"),
            ItemModel(name: "成功牵手"),
        ]
        
        guard models.count > 0 else { return }
        
        let contentWidth = GuideIntoRoomPopView.contentWidth
        
        let layout = Layout(maxWidth: contentWidth)
        
        var collectionViewW: CGFloat = 0
        var row: CGFloat = 1
        
        for i in 0..<models.count {
            let model = models[i]
            
            if collectionViewW > 0 {
                collectionViewW += 10
            }
            collectionViewW += model.nameSize.width
            
            if collectionViewW > contentWidth {
                collectionViewW = model.nameSize.width
                row += 1
            }
        }
        
        let collectionViewH = 24 * row + 4 * (row - 1)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.width.equalTo(contentWidth)
            make.height.equalTo(collectionViewH)
        }
        
        viewSize.height += collectionViewH
    }
}

extension GuideIntoRoomUserIconListView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.model = models[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = models[indexPath.item]
        return model.nameSize
    }
}

extension GuideIntoRoomUserIconListView {
    struct ItemModel {
        let name: String
        let nameSize: CGSize
        
        init(name: String) {
            self.name = name
            
            let nameWidth = (name as NSString).boundingRect(with: [999, 999],
                                                            options: .usesLineFragmentOrigin,
                                                            attributes: [.font: UIFont.systemFont(ofSize: 13)],
                                                            context: nil).size.width
            self.nameSize = [nameWidth + 20, 24]
        }
    }
    
    class Item: UIView {
        let nameLabel = UILabel()
        
        var model: ItemModel? = nil {
            didSet {
                guard let model = self.model else { return }
                nameLabel.text = model.name
            }
        }
        
        init() {
            super.init(frame: .zero)
            
            nameLabel.font = .systemFont(ofSize: 13)
            nameLabel.textColor = UIColor(white: 1, alpha: 0.8)
            nameLabel.textAlignment = .center
            addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            layer.cornerRadius = 12
            layer.borderColor = UIColor(white: 1, alpha: 0.3).cgColor
            layer.borderWidth = 1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class Cell: UICollectionViewCell {
        let item = Item()
        
        var model: ItemModel? = nil {
            didSet {
                item.model = model
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(item)
            item.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class Layout: UICollectionViewFlowLayout {
        let maxWidth: CGFloat
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        init(maxWidth: CGFloat) {
            self.maxWidth = maxWidth
            super.init()
            sectionInset = .zero
            minimumLineSpacing = 4
            minimumInteritemSpacing = 10
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepare() {
            super.prepare()
            
            attributes = []
            
            guard let count = collectionView?.numberOfItems(inSection: 0) else { return }
            
            var itemY: CGFloat = -10
            var sameLineAttributes: [UICollectionViewLayoutAttributes] = []
            
            for i in 0 ..< count {
                guard let attri = layoutAttributesForItem(at: IndexPath(item: i, section: 0)) else { continue }
                if itemY == attri.frame.origin.y {
                    sameLineAttributes.append(attri)
                } else {
                    addSameLineAttributes(sameLineAttributes)
                    sameLineAttributes = [attri]
                    itemY = attri.frame.origin.y
                }
            }
            addSameLineAttributes(sameLineAttributes)
        }
        
        func addSameLineAttributes(_ sameLineAttributes: [UICollectionViewLayoutAttributes]) {
            guard sameLineAttributes.count > 0 else { return }
            let totalW = sameLineAttributes.reduce(0) { partialResult, attri in
                var result = partialResult
                if partialResult > 0 {
                    result += minimumInteritemSpacing
                }
                result += attri.frame.width
                return result
            }
            var x = (maxWidth - totalW) * 0.5
            for i in 0 ..< sameLineAttributes.count {
                let attri = sameLineAttributes[i]
                attri.frame.origin.x = x
                x = attri.frame.maxX + minimumInteritemSpacing
            }
            attributes.append(contentsOf: sameLineAttributes)
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            attributes
        }
    }
}
