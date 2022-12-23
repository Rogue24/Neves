//
//  MainActorTestVC.swift
//  Neves
//
//  Created by 周健平 on 2022/12/23.
//

import FunnyButton

class MainActorTestVC: TestBaseViewController {
    
    let imgView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.frame = [20, 120, 300, 300]
        imgView.backgroundColor = .randomColor
        view.addSubview(imgView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyActions([
            FunnyAction(name: "1.Task { @MainActor in }", work: { [weak self] in
                guard let self = self else { return }
                JPrint("func begin")
                Task { @MainActor in
                    JPrint("task begin")
                    JPProgressHUD.show()
                    let image = await self.getImage()
                    self.imgView.image = image
                    JPProgressHUD.dismiss()
                    JPrint("task ended")
                }
                JPrint("func ended")
            }),
            
            FunnyAction(name: "2.await MainActor.run {}", work: { [weak self] in
                guard let self = self else { return }
                JPrint("func begin")
                Task {
                    JPrint("task begin")
                    JPProgressHUD.show()
                    let image = await self.getImage()
                    await MainActor.run {
                        self.imgView.image = image
                    }
                    JPProgressHUD.dismiss()
                    JPrint("task ended")
                }
                JPrint("func ended")
            }),
            
            FunnyAction(name: "3.@MainActor func", work: { [weak self] in
                guard let self = self else { return }
                JPrint("func begin")
                Task {
                    JPrint("task begin")
                    JPProgressHUD.show()
                    await self.setImage(self.getImage())
                    JPProgressHUD.dismiss()
                    JPrint("task ended")
                }
                JPrint("func ended")
            }),
            
            FunnyAction(name: "4.sleep test", work: {
                JPrint("func begin")
                Task {
                    JPrint("task begin1")
                    try! await Task.sleep(seconds: 3)
                    JPrint("task ended1")
                    
                    JPrint("task begin2")
                    try! await Task.sleep(seconds: 2)
                    JPrint("task ended2")
                    
                    JPrint("task begin3")
                    try! await Task.sleep(seconds: 1)
                    JPrint("task ended3")
                }
                JPrint("func ended")
            }),
        ])
    }
    
    func getImage() async -> UIImage? {
        let size: CGSize = [imgView.width * ScreenScale, imgView.height * ScreenScale]
        let url = LoremPicsum.photoURL(size: size, randomId: Int.random(in: 1...1000))
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return UIImage(data: data)
    }
    
    @MainActor
    func setImage(_ image: UIImage?) async {
        imgView.image = image
    }
}
