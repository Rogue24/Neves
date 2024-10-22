//
//  DiffableTestViewController.swift
//  Neves
//
//  Created by aa on 2022/7/12.
//

import UIKit

@available(iOS 15.0, *)
class DiffableTestViewController: TestBaseViewController {
    
    var models: [MoguBanner] = []
    
    lazy var tableView = UITableView(frame: PortraitScreenBounds, style: .insetGrouped)
    
    var dataSource: UITableViewDiffableDataSource<Int, MoguBanner?>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.jp.contentInsetAdjustmentNever()
        Setter(tableView)
            .backgroundColor(.randomColor)
            .rowHeight(80.px)
            .contentInset(UIEdgeInsets(top: NavTopMargin + 20, left: 0, bottom: DiffTabBarH + 20, right: 0))
            .subject.registerCell(MyCell.self)
        view.addSubview(tableView)
        
        dataSource = UITableViewDiffableDataSource<Int, MoguBanner?>(tableView: tableView) {
            kTableView, indexPath, model -> UITableViewCell? in
            let cell = kTableView.dequeueReusableCell(withIdentifier: MyCell.reuseIdentifier, for: indexPath) as! MyCell
            cell.model = model
            return cell
        }
        dataSource.defaultRowAnimation = .fade
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self, let dataSource = self.dataSource else { return }
            
            Task {
                JPHUD.show()
                
                var models = await MoguBanner.requestDataModel()
                models = models.shuffled()
                models = Array(models.prefix(Int.random(in: 0...models.count)))
                
                var snapshot = dataSource.snapshot()//NSDiffableDataSourceSnapshot<Int, MoguBanner?>()
                if snapshot.sectionIdentifiers.count == 0 {
                    snapshot.appendSections([0, 1, 2, 3, 4, 5])
                }
                
                let section = Int.random(in: 0...5)
                snapshot.appendItems(models, toSection: section)
                JPrint("在第[\(section)]section搞事", "新增\(models.count)个model")
                
                await dataSource.apply(snapshot, animatingDifferences: true)
                
                JPHUD.dismiss()
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
    class MyCell: UITableViewCell, CellReusable {
        static var nib: UINib? { nil }
        
        let imgView = UIImageView()
        let titleLabel = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            imgView.contentMode = .scaleAspectFill
            imgView.backgroundColor = .lightGray
            imgView.frame = [5.px, 5.px, 70.px, 70.px]
            imgView.layer.cornerRadius = 8.px
            imgView.layer.masksToBounds = true
            contentView.addSubview(imgView)
            
            titleLabel.font = .systemFont(ofSize: 15.px, weight: .semibold)
            titleLabel.frame = [imgView.maxX + 10.px, 0, 200.px, 80.px]
            titleLabel.textAlignment = .left
            contentView.addSubview(titleLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var model: MoguBanner? = nil {
            didSet {
                guard let model = model else {
                    imgView.kf.cancelDownloadTask()
                    imgView.image = nil
                    titleLabel.text = "毛都木有"
                    return
                }
                imgView.kf.setImage(with: URL(string: model.image), options: [.transition(.fade(0.25))])
                titleLabel.text = model.title
            }
        }
    }
    
}
