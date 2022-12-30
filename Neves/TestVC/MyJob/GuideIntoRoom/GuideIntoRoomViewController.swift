//
//  GuideIntoRoomViewController.swift
//  Neves
//
//  Created by aa on 2022/12/28.
//

class GuideIntoRoomViewController: TestBaseViewController {
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyActions([
            FunnyAction(name: "相亲模板") { [weak self] in
                guard let self = self else { return }
                
                
                GuideIntoRoomPopViewController.show(from: self, type: .blindDate)
            },
        
            FunnyAction(name: "娱乐基础模板或聚会模板") { [weak self] in
                guard let self = self else { return }
                
                GuideIntoRoomPopViewController.show(from: self, type: .joyParty)
            },
            
            FunnyAction(name: "电台模板") { [weak self] in
                guard let self = self else { return }
                
                GuideIntoRoomPopViewController.show(from: self, type: .fm)
            },
            
            FunnyAction(name: "游戏组队模板") { [weak self] in
                guard let self = self else { return }
                
                GuideIntoRoomPopViewController.show(from: self, type: .gameTeam(1))
            },
        ])
    }
    
}
