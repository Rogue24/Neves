//
//  ImageVideoMakeViewController.swift
//  Neves
//
//  Created by aa on 2021/9/30.
//

import UIKit

class ImageVideoMakeViewController: TestBaseViewController {
    
    let maker = VideoMaker()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        JPHUD.show()
        
        var indexs: Set<Int> = Set()
        for i in 1 ... 8 { indexs.insert(i) }
        
        var imageInfos = [VideoMaker.ImageInfo]()
        while let i = indexs.first {
            indexs.remove(i)
            imageInfos.append(.init(image: UIImage.jp.fromBundle("Girl\(i).jpg")!,
                                    duration: TimeInterval.random(in: 1...3)))
        }
        
        maker.makeVideo(with: imageInfos) { result in
            Asyncs.main {
                JPHUD.dismiss()
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

