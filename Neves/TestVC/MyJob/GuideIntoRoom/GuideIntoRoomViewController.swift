//
//  GuideIntoRoomViewController.swift
//  Neves
//
//  Created by aa on 2022/12/28.
//

class GuideIntoRoomViewController: TestBaseViewController {
    
    weak var popVC: GuideIntoRoomPopViewController? {
        didSet {
            setupActions()
        }
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActions()
    }
    
    func setupActions() {
        guard let popVC = self.popVC else {
            replaceFunnyActions([
                FunnyAction(name: "相亲模板") { [weak self] in
                    guard let self = self else { return }
                    self.popVC = GuideIntoRoomPopViewController.show(from: self, type: .blindDate)
                },
            
                FunnyAction(name: "娱乐基础模板或聚会模板") { [weak self] in
                    guard let self = self else { return }
                    self.popVC = GuideIntoRoomPopViewController.show(from: self, type: .joyParty)
                },
                
                FunnyAction(name: "电台模板") { [weak self] in
                    guard let self = self else { return }
                    self.popVC = GuideIntoRoomPopViewController.show(from: self, type: .fm)
                },
                
                FunnyAction(name: "游戏组队模板") { [weak self] in
                    guard let self = self else { return }
                    self.popVC = GuideIntoRoomPopViewController.show(from: self, type: .gameTeam(UInt32.random(in: 1...3)))
                },
            ])
            return
        }
        
        replaceFunnyAction { [weak self, weak popVC] in
            guard let popVC = popVC else {
                self?.popVC = nil
                return
            }
            
            if let cardListView = popVC.popView.contentView as? GuideIntoRoomGameTeamCardListView {
                cardListView.testShow()
                return
            }
            
            popVC.close(completion: nil)
            self?.popVC = nil
        }
    }
    
}
