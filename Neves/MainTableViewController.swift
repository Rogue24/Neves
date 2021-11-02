//
//  MainTableViewController.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    private static let headerID = "MainHeader"
    private static let cellID = "MainCell"
    
    struct SectionItem: Convertible {
        struct RowItem: Convertible {
            enum VcCreateWay: Int, ConvertibleEnum {
                case code, xib, storyboard, custom
            }
            
            var vcName: String = ""
            
            var vcCreateWay: VcCreateWay = .code
            
            var vcBuilder: VcBuilder? {
                let className = Bundle.jp.executable() + "." + vcName // Swift要加上模块前缀，OC的则不需要
                guard let vcType =
                        NSClassFromString(className) as? UIViewController.Type ??
                        NSClassFromString(vcName) as? UIViewController.Type
                else { return nil }
                
                switch vcCreateWay {
                case .code:
                    return .code(vcType)
                case .xib:
                    return .xib(vcType)
                case .storyboard:
                    return .storyboard(vcType, sbName: "Main")
                case .custom:
                    return .custom(vcType) { vcType in
                        if vcType is MarebulabulasViewController.Type {
                            return MarebulabulasViewController(type: .sing(true))
//                            return MarebulabulasViewController(type: .dialogue)
                        }
                        return nil
                    }
                }
            }
        }
        var header: String = ""
        var vcList: [RowItem] = []
    }
    
    private var dataSource: [SectionItem] = {
        do {
            let path = Bundle.jp.resourcePath(withName: "TestList", type: "json")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            return jsonData.kj.modelArray(SectionItem.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Neves"
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Self.headerID)
        
//        let currentDate = Date()
//        let refreshDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
//        let fm = DateFormatter()
//        fm.dateFormat = "yyyy-MM-dd hh:mm:ss"
//        let dateStr1 = fm.string(from: currentDate)
//        let dateStr2 = fm.string(from: refreshDate)
//        JPrint("时间？" , dateStr1, dateStr2)
        
        JPrint("时间？", Date().jp.mmssString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let window = view.window, FloatWindowContainer.shared.superview != window {
            FloatWindowContainer.shared.frame = window.bounds
            window.addSubview(FloatWindowContainer.shared)
            
            FloatWindowContainer.shared.addSubview(FunFloatButton.shared)
            FunFloatButton.shared.addDragonSlayerBannerAction()
        }
    }
}

// MARK: - Table view data source
extension MainTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int { dataSource.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionItem = dataSource[section]
        return sectionItem.vcList.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Self.headerID)
        let sectionItem = dataSource[section]
        header?.textLabel?.text = sectionItem.header
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath)

        let sectionItem = dataSource[indexPath.section]
        let rowItem = sectionItem.vcList[indexPath.row]
        cell.textLabel?.text = rowItem.vcName
        
        return cell
    }
}

// MARK: - Table view delegate
extension MainTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionItem = dataSource[indexPath.section]
        let rowItem = sectionItem.vcList[indexPath.row]
        if let vcBuilder = rowItem.vcBuilder, let vc = vcBuilder.build() {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            JPProgressHUD.showInfo(withStatus: "\(rowItem.vcName)还没构建")//, userInteractionEnabled: true)
        }
    }
}
