//
//  FocusOnFacesViewController.swift
//  Neves
//
//  Created by aa on 2022/3/8.
//

import UIKit

class FocusOnFacesViewController: TestBaseViewController {
    
    let fofImgView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let image = UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: "Girl3.jpg"))!

        let names = [
            "Girl1.jpg",
            "Girl2.jpg",
            "Girl3.jpg",
            "Girl4.jpg",
            "Girl5.jpg",
            "Girl6.jpg",
            "Girl7.jpg",
            "Girl8.jpg",
            "Girl9.jpg",
            "girl.jpg",
        ]
        let image = UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: names.randomElement()!))!
        
        let imgSize: CGSize = [300, 300]

        fofImgView.clipsToBounds = true
        fofImgView.contentMode = .scaleAspectFill
        fofImgView.backgroundColor = .randomColor
        fofImgView.frame = [HalfDiffValue(PortraitScreenWidth, imgSize.width), HalfDiffValue(PortraitScreenHeight, imgSize.height), imgSize.width, imgSize.height]
        fofImgView.image = image
        view.addSubview(fofImgView)
        
        fofImgView.debugFaceAware = true
        fofImgView.didFocusOnFaces = {
            JPrint("找好了")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            
            JPrint(self.fofImgView.focusOnFaces ? "恢复" : "开始找")
            self.fofImgView.focusOnFaces.toggle()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
    
}
