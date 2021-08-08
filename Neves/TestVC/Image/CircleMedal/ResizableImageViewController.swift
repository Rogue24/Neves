//
//  ResizableImageViewController.swift
//  Neves
//
//  Created by aa on 2021/4/29.
//

class ResizableImageViewController: TestBaseViewController {
    
    let activeImage = UIImage(named: "quanzi_mingpai_hyd")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image0: UIImage = UIImage(named: "quanzi_level_18")!
        
        let imageView0 = UIImageView(image: image0)
        imageView0.backgroundColor = .randomColor
        imageView0.frame = [20, 150, 202, 81]
        view.addSubview(imageView0)
        
        let image1 = image0.resizableImage(withCapInsets: .init(top: 0, left: image0.size.width * 0.80, bottom: 0, right: image0.size.width * 0.17), resizingMode: .stretch)
        
        let imageView1 = UIImageView(image: image1)
        imageView1.backgroundColor = .randomColor
        imageView1.frame = [20, (imageView0.maxY + 20), 350, 81]
        view.addSubview(imageView1)
        
        let imageView11 = UIImageView(image: image1)
        imageView11.backgroundColor = .randomColor
        imageView11.contentMode = .scaleAspectFit
        imageView11.frame = [20, (imageView1.maxY + 20), 250, 81]
        view.addSubview(imageView11)
        
        let imageView2 = UIImageView(image: image1)
        imageView2.backgroundColor = .randomColor
        imageView2.frame = [20, (imageView11.maxY + 20), 350, 40.5]
        view.addSubview(imageView2)
        
        
        levelView1.frame = .init(origin: [20, (imageView2.maxY + 20)], size: levelView1.frame.size)
        view.addSubview(levelView1)
        
        levelView2.frame = .init(origin: [20, (levelView1.maxY + 5)], size: levelView2.frame.size)
        view.addSubview(levelView2)
        
        levelView3.frame = .init(origin: [20, (levelView2.maxY + 5)], size: levelView3.frame.size)
        view.addSubview(levelView3)
        
        medalView1.frame = .init(origin: [20, (levelView3.maxY + 10)], size: medalView1.frame.size)
        view.addSubview(medalView1)
        
        medalView2.frame = .init(origin: [20, (medalView1.maxY + 5)], size: medalView2.frame.size)
        view.addSubview(medalView2)
        
        medalView3.frame = .init(origin: [20, (medalView2.maxY + 5)], size: medalView3.frame.size)
        view.addSubview(medalView3)
    }
    
    let levelView1: CircleLevelView = CircleLevelView(layout: .height27, level: 16, text: "遗臭万年")!
    let levelView2: CircleLevelView = CircleLevelView(layout: .height18, level: 17, text: "遗臭万年")!
    let levelView3: CircleLevelView = CircleLevelView(layout: .height14, level: 18, text: "遗臭万年")!
    
    let medalView1: CircleMedalView = CircleMedalView(layout: .height27, levelInfo: (level: 13, text: "嘻嘻"))
    let medalView2: CircleMedalView = CircleMedalView(layout: .height18, levelInfo: (level: 14, text: "嘻嘻"))
    let medalView3: CircleMedalView = CircleMedalView(layout: .height14, levelInfo: (level: 15, text: "嘻嘻"))
    
    let ssss: [String] = ["咦", "是啥", "热热热", "太皇太后", "他的父亲高", "如果如果如果"]
    var i: Int = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        levelView1.update(level: Int(arc4random_uniform(19)), text: ssss[i])
        levelView2.update(level: Int(arc4random_uniform(19)), text: ssss[i])
        levelView3.update(level: Int(arc4random_uniform(19)), text: ssss[i])
        
        
        medalView1.update(levelInfo: (level: Int(arc4random_uniform(19)), text: ssss[i]),
                          activeImage: arc4random_uniform(2) == 1 ? activeImage : nil,
                          signinImage: arc4random_uniform(2) == 1 ? activeImage : nil)
        medalView2.update(levelInfo: (level: Int(arc4random_uniform(19)), text: ssss[i]),
                          activeImage: arc4random_uniform(2) == 1 ? activeImage : nil,
                          signinImage: arc4random_uniform(2) == 1 ? activeImage : nil)
        medalView3.update(levelInfo: (level: Int(arc4random_uniform(19)), text: ssss[i]),
                          activeImage: arc4random_uniform(2) == 1 ? activeImage : nil,
                          signinImage: arc4random_uniform(2) == 1 ? activeImage : nil)
        
        i += 1
        if i == ssss.count {
            i = 0
        }
    }
}
