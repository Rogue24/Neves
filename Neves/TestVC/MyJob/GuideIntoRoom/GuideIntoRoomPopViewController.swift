//
//  GuideIntoRoomPopViewController.swift
//  Neves
//
//  Created by aa on 2022/12/28.
//

class GuideIntoRoomPopViewController: UIViewController {
    
    
    let popView: GuideIntoRoomPopView
    
    init(type: GuideIntoRoomType) {
        self.popView = GuideIntoRoomPopView(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(popView.viewSize)
            make.bottom.equalTo(view.snp.bottom).offset(popView.viewSize.height)
        }
    }
    
    @discardableResult
    static func show(from superVC: UIViewController, type: GuideIntoRoomType) -> GuideIntoRoomPopViewController {
        let popVC = GuideIntoRoomPopViewController(type: type)
//        popVC.delegate = delegate
        popVC.modalPresentationStyle = .overFullScreen
        superVC.present(popVC, animated: false) {
            popVC.show()
        }
        return popVC
    }
    
    private func show() {
        popView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-TabBarH)
        }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) {
            self.view.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0.5).cgColor
            self.view.layoutIfNeeded()
        } completion: { _ in
//            self.popView.loopEnable()
//            self.popView.loadData()
        }
    }
    
    func close(completion: (() -> Void)?) {
        popView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(popView.viewSize.height)
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layer.backgroundColor = UIColor.rgb(0, 0, 0, a: 0).cgColor
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false) {
//                self.delegate?.roomGameTeamBossMicQueuePopViewControllerDidClose(self)
                completion?()
            }
        }
    }
    
    @objc func closeAction() {
        close(completion: nil)
    }
    
//    func updateUI(with model: QWRoomGameTeamBossMicQueueModel, fulGameInfoMap: [UInt32 : UU_UU_UserSkillfulGameInfo], isBossMicNull: Bool) {
////        self.popView.tableView.isUserInteractionEnabled = false
//        QWRoomGameTeamBossMicQueueInfoModel.buildMicQueueInfoModels(with: model, fulGameInfoMap: fulGameInfoMap) { [weak self] result in
//            guard let self = self else { return }
////            self.popView.tableView.isUserInteractionEnabled = true
//            switch result {
//            case let .success(infoModels):
//                self.popView.updateUI(with: model.myRank, infoModels: infoModels, isBossMicNull: isBossMicNull)
//            case let .failed(error):
//                XLog.error("QWRoomGameTeamBossMicQueueInfoModel", message: "GetUserSkillfulGameReq error: \(error?.errorMsg ?? ""))")
//            }
//        }
//    }
}


