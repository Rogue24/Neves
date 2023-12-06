//
//  TestCollectionViewController.swift
//  Neves
//
//  Created by aa on 2023/10/16.
//

import UIKit
import FunnyButton

class TestCollectionViewController: TestBaseViewController {
    
    var dataSource: [String] = []
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = [80, 80]
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: [20, 200, PortraitScreenWidth - 40, PortraitScreenWidth - 40], collectionViewLayout: layout)
        collectionView.backgroundColor = .randomColor
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
//        dataSource = (0..<10).map { "\($0)" }
//        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyActions([
            .init(name: "insert", work: {
                let index = self.dataSource.count
                self.dataSource.append("\(index)")
                self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
            }),
            .init(name: "delete", work: {
                guard self.dataSource.count > 0 else { return }
                self.dataSource.remove(at: 0)
                self.collectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
            }),
        ])
    }
    
}

extension TestCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let label = cell.contentView.viewWithTag(10086) as? UILabel ?? {
            let lab = UILabel(frame: [0, 0, 80, 80])
            lab.font = .systemFont(ofSize: 30, weight: .bold)
            lab.textAlignment = .center
            lab.tag = 10086
            cell.contentView.addSubview(lab)
            return lab
        }()
        
        cell.contentView.backgroundColor = .randomColor
        label.textColor = .randomColor
        label.text = dataSource[indexPath.item]
        
        return cell
    }
}
