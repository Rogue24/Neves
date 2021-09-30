//
//  ImageVideoMakeViewController.swift
//  Neves
//
//  Created by aa on 2021/9/30.
//

class ImageVideoMakeViewController: TestBaseViewController {
    
    let maker = ImageVideoMaker()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        JPProgressHUD.show()
        
        var indexs: Set<Int> = Set()
        for i in 1 ... 8 { indexs.insert(i) }
        
        var imageInfos = [ImageVideoMaker.ImageInfo]()
        while let i = indexs.first {
            indexs.remove(i)
            imageInfos.append(.init(image: UIImage.jp.fromBundle("Girl\(i).jpg")!, duration: 2))
        }
        
        maker.createVideo(with: imageInfos) { result in
            Asyncs.main {
                JPProgressHUD.dismiss()
            }
            switch result {
            case let .success(cachePath):
                JPrint("成功！", cachePath, Thread.current)
            default:
                JPrint("失败！", Thread.current)
            }
        }
    }
    
}

