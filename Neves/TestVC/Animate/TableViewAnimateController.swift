//
//  TableViewAnimateController.swift
//  Neves
//
//  Created by 周健平 on 2021/8/2.
//

class TableViewAnimateController: TestBaseViewController {
    
    var models: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: PortraitScreenBounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        
        for _ in 0 ... 40 {
            models.append(40)
        }
    }
    
}


extension TableViewAnimateController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1) --- \(model)"
        cell.backgroundColor = .randomColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.performBatchUpdates {
            let model = models[indexPath.row]
            if model == 40 {
                models[indexPath.row] = 80
            } else {
                models[indexPath.row] = 40
            }
            
            models.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [IndexPath(row: indexPath.row - 1, section: 0)], with: .fade)
            
            models.insert(40, at: indexPath.row + 1)
            tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .fade)
        } completion: { _ in
            
        }

        
//        tableView.beginUpdates()
        

        
//        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.row]
        return model
    }
}
