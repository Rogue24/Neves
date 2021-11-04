//
//  DragonSlayerViewController.swift
//  Neves
//
//  Created by aa on 2021/11/3.
//

class DragonSlayerViewController: TestBaseViewController {
    
    var currNum = 0
    let meNum = 20
    
    var entrance: DragonSlayerEntrance!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inspireBtn: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
            btn.setTitle("龙之召唤师", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [20, 250, 150, 80]
            btn.addTarget(self, action: #selector(inspireAction), for: .touchUpInside)
            return btn
        }()
        view.addSubview(inspireBtn)
        
        let btn1: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.setTitle("停留", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [20, 350, 80, 40]
            btn.addTarget(self, action: #selector(tingliu), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn1)
        
        let btn2: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.setTitle("金币", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [110, 350, 80, 40]
            btn.addTarget(self, action: #selector(jinbi), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn2)
        
        let btn3: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.setTitle("鼓舞", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [200, 350, 80, 40]
            btn.addTarget(self, action: #selector(guwu), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn3)
        
        let btn4: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.setTitle("全部完成", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [290, 350, 80, 40]
            btn.addTarget(self, action: #selector(allDone), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn4)
        
        let btn5: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.setTitle("30s", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [20, 400, 80, 40]
            btn.addTarget(self, action: #selector(s30), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn5)
        
        let btn6: UIButton = {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.setTitle("60s", for: .normal)
            btn.setTitleColor(.randomColor, for: .normal)
            btn.backgroundColor = .randomColor
            btn.layer.cornerRadius = 10
            btn.layer.masksToBounds = true
            btn.frame = [110, 400, 80, 40]
            btn.addTarget(self, action: #selector(s60), for: .touchUpInside)
            return btn
        }()
        view.addSubview(btn6)
        
        entrance = DragonSlayerEntrance.build(on: view, superviewFrame: PortraitScreenBounds)
    }
    
    weak var inspireView: DragonSlayerInspireView? = nil
    
    @objc func inspireAction() {
        
        guard let inspireView = self.inspireView else {
            self.inspireView = DragonSlayerInspireView.show(withNames: [], on: view) {
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
    
    @objc func tingliu() {
        JPrint("停留")
        entrance.task = .stayRoom
    }
    
    @objc func jinbi() {
        JPrint("金币")
        entrance.task = .giveGift
    }
    
    @objc func guwu() {
        JPrint("鼓舞")
        entrance.task = .inspire
    }
    
    @objc func allDone() {
        JPrint("全部完成")
        entrance.task = .allDone
    }
    
    @objc func s30() {
        JPrint("倒计时30s")
        entrance.prepareSecond = 30
    }
    
    @objc func s60() {
        JPrint("倒计时60s")
        entrance.fightSecond = 30
    }
}
