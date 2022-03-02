//
//  AnimScrollViewController.swift
//  Neves
//
//  Created by aa on 2022/3/2.
//

class AnimScrollViewController: TestBaseViewController {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = [PortraitScreenWidth - 200, 40]
        
        let cv = UICollectionView(frame: [100, NavTopMargin + 20, PortraitScreenWidth - 200, PortraitScreenHeight - NavTopMargin - 20 - DiffTabBarH], collectionViewLayout: layout)
        cv.jp.contentInsetAdjustmentNever()
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.contentInset = .init(top: 400, left: 0, bottom: 0, right: 0)
        cv.backgroundColor = .black
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    var isAnimating = false
    var isAdd = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self, !self.isAnimating else { return }
            self.isAnimating = true
            
            self.collectionView.frame.size.height += 500
            
            UIView.animate(withDuration: 1) {
                var contentInset = self.collectionView.contentInset
                
                if self.isAdd {
                    contentInset.top += 200
                } else {
                    contentInset.top -= 200
                }
                    
                if contentInset.top == 400 {
                    self.isAdd = false
                } else if contentInset.top == 0 {
                    self.isAdd = true
                }
                
                /**
                 * 通过动画设置`contentInset.top`变小往上挪（需要一起修改`contentInset`和`contentOffset`）
                 * 问题：挪动过程会出现下面空了一截cell的情况。
                 * 原因：因为系统动画【只】会拿`collectionView`的`初始位置`和`最终位置`来做动画，实际上并没有慢慢挪动的过程，再加上`collectionView`的重用机制，会让后续的cell直接重用，所以下面会空了一截。
                 * 解决：先扩大显示区域，用于加载后续cell，确保动画过程中能保持显示，动画结束后再还原区域（空间换效果）。
                 */
                
                self.collectionView.contentInset = contentInset
                self.collectionView.contentOffset = [0, -contentInset.top]
                
            } completion: { _ in
                self.isAnimating = false
                self.collectionView.frame.size.height -= 500
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }

}

extension AnimScrollViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        200
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let label = cell.viewWithTag(10086) as? UILabel ?? {
            let l = UILabel()
            l.frame = cell.bounds
            l.font = .boldSystemFont(ofSize: 30)
            l.textAlignment = .center
            l.textColor = .randomColor
            l.tag = 10086
            cell.addSubview(l)
            return l
        }()
        
        cell.backgroundColor = .randomColor
        label.textColor = .randomColor
        label.text = "\(indexPath.item)"
        
        return cell
    }
    
    
}

