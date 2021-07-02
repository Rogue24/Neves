//
//  MarebulabulasManager.swift
//  Neves
//
//  Created by aa on 2020/11/2.
//

import UIKit

class MarebulabulasManager: NSObject {
    
    let type: MarebulabulasType

    let lrcView: MarebulabulasLrcView
    var tableView: UITableView { lrcView.tableView }
    
    let operationView: MarebulabulasOperationView
    var recordControl: MarebulabulasRecordControl { operationView.recordControl }
    
    var cellModels: [MarebulabulasLrcCellModel] = []
    
    init(type: MarebulabulasType, lrcView: MarebulabulasLrcView, operationView: MarebulabulasOperationView) {
        self.type = type
        self.lrcView = lrcView
        self.operationView = operationView
        super.init()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        var firstCm = MarebulabulasLrcCellModel(iconURL: Bundle.jp.resourcePath(withName: "JPIcon.png"), content: "还要多久我才能在你身边\n等到放晴的那天也许我会比较好一点", index: 0)
        firstCm.isPlaying = true
        
        cellModels = [firstCm,
                      MarebulabulasLrcCellModel(iconURL: Bundle.jp.resourcePath(withName: "JPIcon.png"), content: "没想到失去的勇气我还留着\n好想再问一遍\n你会等待还是离开", index: 1),
                      MarebulabulasLrcCellModel(iconURL: Bundle.jp.resourcePath(withName: "JPIcon.png"), content: "为你翘课的那一天\n花落的那一天\n教室的那一间\n我怎么看不见", index: 2)]
    }
    
}

extension MarebulabulasManager: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cellModels.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MarebulabulasLrcCell
        
        cell.setupUI(cellModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cellModels[indexPath.row].cellHeight
    }
}

extension MarebulabulasManager {
//    func <#name#>(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
}
