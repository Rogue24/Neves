//
//  WatermarkViewController.swift
//  Neves
//
//  Created by aa on 2021/5/20.
//

import UIKit

class WatermarkViewController: TestBaseViewController {
    
    lazy var originImage1: UIImage = {
//        UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: "girl.jpg"))!
        UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: "JPIcon.png"))!
    }()
    lazy var imgView1: UIImageView = { UIImageView(image: originImage1) }()
    
    lazy var originImage2: UIImage = {
        UIImage(contentsOfFile: Bundle.jp.resourcePath(withName: "JPIcon.png"))!
    }()
    lazy var imgView2: UIImageView = { UIImageView(image: originImage2) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView1.backgroundColor = .randomColor
        imgView1.frame = [0, NavTopMargin, PortraitScreenWidth, (PortraitScreenHeight - NavTopMargin - DiffTabBarH) * 0.5]
        imgView1.contentMode = .scaleAspectFit
        view.addSubview(imgView1)
        
        imgView2.backgroundColor = .randomColor
        imgView2.frame = [0, NavTopMargin + (PortraitScreenHeight - NavTopMargin - DiffTabBarH) * 0.5, PortraitScreenWidth, (PortraitScreenHeight - NavTopMargin - DiffTabBarH) * 0.5]
        imgView2.contentMode = .scaleAspectFit
        view.addSubview(imgView2)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        JPProgressHUD.show()
        var watermark1: UIImage? = nil
        var watermark2: UIImage? = nil
        Asyncs.async {
            watermark1 = self.originImage1.jp.watermark
//            watermark2 = self.originImage2.jp.watermark
            watermark2 = self.originImage2.jp.watermarkOnScreenWidth
        } mainTask: {
            JPProgressHUD.dismiss()
            guard let image1 = watermark1,
                  let image2 = watermark2 else { return }
            self.imgView1.image = image1
            self.imgView2.image = image2
        }
    }

}
