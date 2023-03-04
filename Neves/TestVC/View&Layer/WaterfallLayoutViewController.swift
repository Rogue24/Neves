//
//  WaterfallLayoutViewController.swift
//  Neves
//
//  Created by aa on 2023/2/28.
//

import FunnyButton

class WaterfallLayoutViewController: TestBaseViewController {
    
    var colCount = 4
    
    var girls: [Girl] = []
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let bgView = UIView(frame: [0, 0, PortraitScreenWidth, PortraitScreenHeight - (DiffTabBarH + 5.px)])
//        bgView.backgroundColor = .randomColor
//        view.addSubview(bgView)
        
        let waterfallLayout = WaterfallLayout()
        waterfallLayout.delegate = self
        
        let collectionView = UICollectionView(frame: PortraitScreenBounds, collectionViewLayout: waterfallLayout)
        collectionView.jp.contentInsetAdjustmentNever()
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GirlCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction {
            
//            let s1 = WaterfallLayout.Seat(col: 1, row: 2)
//            let s2 = WaterfallLayout.Seat(col: 1, row: 2)
//            let s3 = WaterfallLayout.Seat(col: 2, row: 5)
//            JPrint(s1 == s2)
//            JPrint(s1 == s3)
//            JPrint(s2 == s3)
//            return
            
//            self.colCount = Int.random(in: 1...5)
//            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
////                UIView.animate(withDuration: 3) {
//                self.collectionView.performBatchUpdates {
//                    self.collectionView.reloadSections(IndexSet(integer: 0))
//                }
//            }
//            return
            
            self.reloadView()
        }
        
        reloadView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
    func reloadView() {
        var girls: [Girl] = []
        Asyncs.async {
            girls = Girl.fetchTestList()
        } mainTask: {
//                JPProgressHUD.dismiss()
            
//                if self.girls.count == 0 {
//                    self.girls = girls
//                    self.collectionView.reloadSections(IndexSet(integer: 0))
//                } else {
//                    var indexPaths: [IndexPath] = []
//                    for i in 0 ..< girls.count {
//                        indexPaths.append(IndexPath(item: self.girls.count + i, section: 0))
//                    }
//                    self.girls += girls
//                    self.collectionView.insertItems(at: indexPaths)
//                }
            
            self.girls = girls
//            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
            UIView.animate(withDuration: 3) {
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                }
            }
        }
    }
}

extension WaterfallLayoutViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        girls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GirlCell
        cell.girl = girls[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        girls.remove(at: indexPath.item)
//        girls[indexPath.item] = Girl(imgName: "Girl\(Int.random(in: 1...9))")
        girls.insert(Girl(imgName: "Girl\(Int.random(in: 1...9))"), at: indexPath.item)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
//        UIView.animate(withDuration: 3) {
            self.collectionView.performBatchUpdates {
//                self.collectionView.deleteItems(at: [indexPath])
//                self.collectionView.reloadItems(at: [indexPath])
                self.collectionView.insertItems(at: [indexPath])
            }
        }
    }
}

extension WaterfallLayoutViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ waterfallLayout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        let girl = girls[index]
        return itemWidth / girl.whRatio
    }
    
    func colCountInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> Int {
        colCount
    }
    
    func colMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat {
        5.px
    }
    
    func rowMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat {
        5.px
    }
    
    func edgeInsetsInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> UIEdgeInsets {
        UIEdgeInsets(top: NavTopMargin + 5.px, left: 5.px, bottom: DiffTabBarH + 5.px, right: 5.px)
    }
}

extension WaterfallLayoutViewController {
    struct Girl: Identifiable {
        let id = UUID()
        let imgName: String
        let whRatio: CGFloat
        
        init(imgName: String) {
            self.imgName = imgName
            let image = UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: imgName, type: "jpg"))!
            self.whRatio = image.size.width / image.size.height
        }
        
        static func fetchTestList() -> [Girl] {
            let girlList1 = Array(1...9).map { Girl(imgName: "Girl\($0)") }
            let girlList2 = Array(1...9).map { Girl(imgName: "Girl\($0)") }
            return girlList1.shuffled() + girlList2.shuffled()
        }
    }
    
    class GirlCell: UICollectionViewCell {
        var girl: Girl? {
            didSet {
                guard let girl = self.girl else { return }
                imgView.image = UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: girl.imgName, type: "jpg"))
            }
        }
        
        let imgView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.clipsToBounds = true
            contentView.backgroundColor = .randomColor
            
            imgView.contentMode = .scaleAspectFill
            contentView.addSubview(imgView)
            imgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
