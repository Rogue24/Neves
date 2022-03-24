//
//  MoonMaskViewController.swift
//  Neves
//
//  Created by aa on 2022/3/24.
//

class MoonMaskViewController: TestBaseViewController {
    
    let imageView = UIImageView(image: UIImage(named: "jp_icon"))
    let maskLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = [100, 200, 100, 100]
        view.addSubview(imageView)
        
        maskLayer.fillColor = UIColor.randomColor.cgColor
        maskLayer.strokeColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        maskLayer.path = getPath().cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            if self.imageView.layer.mask == nil {
                self.imageView.layer.cornerRadius = 50
                self.imageView.layer.masksToBounds = true
                self.imageView.layer.mask = self.maskLayer
            } else {
                self.imageView.layer.cornerRadius = 0
                self.imageView.layer.masksToBounds = false
                self.imageView.layer.mask = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }
    
    func getPath() -> UIBezierPath {
        let path = UIBezierPath(roundedRect: [0, 0, 100, 100], cornerRadius: 50)
        
        let path2 = UIBezierPath(roundedRect: [80, 0, 100, 100], cornerRadius: 50)
        path.append(path2)
        
        return path
    }
}
