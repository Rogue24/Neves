//
//  MainTableViewController.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import KakaJSON


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
                else {
                    return .other(vcName) { context in
                        switch context {
                        case "KFImageTestView":
                            if #available(iOS 15.0.0, *) {
                                return KFImageTestView().intoUIVC()
                            } else {
                                return nil
                            }
                        case "ResultBuilderView":
                            if #available(iOS 14.0.0, *) {
                                return ResultBuilderView().intoUIVC()
                            } else {
                                return nil
                            }
                        case "WidgetView":
                            let vc = WidgetView().intoUIVC()
                            vc.replaceFunnyAction {
                                JPrint("wahahaha")
                            }
                            return vc
                        default:
                            return nil
                        }
                    }
                }
                
                switch vcCreateWay {
                case .code:
                    return .code(vcType)
                case .xib:
                    return .xib(vcType)
                case .storyboard:
                    return .storyboard(vcType, sbName: "Main")
                case .custom:
                    return .custom(vcType) { vcType in
                        switch vcType {
                        case is MarebulabulasViewController.Type:
                            return MarebulabulasViewController(type: .sing(true))
//                            return MarebulabulasViewController(type: .dialogue)
                        default:
                            return nil
                        }
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
        
        JPrint("111 StatusBar", StatusBarH, DiffStatusBarH)
        JPrint("111 TabBar", TabBarH, DiffTabBarH)
        
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
    
    enum JPStatus: Equatable {
        case received
        case canReceive
        case countdown(_ text: String)
        case waitCountdown(_ text: String)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addFunnyAction {
            let s1 = JPStatus.received
            let s2 = JPStatus.countdown("1")
            let s3 = JPStatus.countdown("1")
            let s4 = JPStatus.countdown("2")
            let s5 = JPStatus.waitCountdown("2")

            JPrint("s1 == s2", s1 == s2) // false
            JPrint("s2 == s3", s2 == s3) // true
            JPrint("s3 == s4", s3 == s4) // false
            JPrint("s4 == s5", s4 == s5) // false
        }
        
        addFunnyAction(name: "哈哈") {
            JPrint("哈哈")
        }
        
        addFunnyAction(name: "嘻嘻") {
            JPrint("嘻嘻", GetTopMostViewController() ?? "毛都没有")
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
            JPProgressHUD.showInfo(withStatus: "\(rowItem.vcName)还没构建", userInteractionEnabled: true)
        }
    }
}
