//
//  DragonSlayerViewController.swift
//  Neves
//
//  Created by aa on 2021/11/3.
//

class DragonSlayerViewController: TestBaseViewController {
    
    var currNum = 0
    let meNum = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inspireBtn: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
            btn.setTitle("鼓舞哥", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [50, 150, 150, 80]
            btn.addTarget(self, action: #selector(inspireAction), for: .touchUpInside)
            return btn
        }()
        view.addSubview(inspireBtn)
    }
    
    weak var inspireView: DragonSlayerInspireView? = nil
    
    @objc func inspireAction() {
        
        guard let inspireView = self.inspireView else {
            self.inspireView = DragonSlayerInspireView.show(withNames: ["黑夜使者"], on: view) {
                JPrint("鼓舞结束")
                self.currNum = 0
            }
            return
        }
        
        currNum += 1
        if currNum == meNum {
            inspireView.inspireFor("你平爷我")
        } else {
            inspireView.inspireFor("光明使者")
        }
    }
}
