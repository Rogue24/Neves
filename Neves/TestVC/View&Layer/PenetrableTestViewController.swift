//
//  PenetrableTestViewController.swift
//  Neves
//
//  Created by aa on 2023/1/17.
//

class PenetrableTestViewController: TestBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupSubviews1()
        setupSubviews2()
        setupSubviews3()
    }
    
    class TestContainer: UIView, Penetrable {}
    
    class TestView: UIView {
        init() {
            super.init(frame: .zero)
            backgroundColor = .randomColor
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMe)))
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func tapMe() {
            backgroundColor = .randomColor
        }
    }
}

extension PenetrableTestViewController {
    func setupSubviews1() {
        let testView10 = TestView()
        testView10.frame = [30, 200, 100, 100]
        view.addSubview(testView10)
        
        let testView11 = TestView()
        testView11.frame = [280, 400, 100, 100]
        view.addSubview(testView11)
    }
    
    func setupSubviews2() {
        let container1 = TestContainer()
        container1.backgroundColor = .randomColor(0.2)
        container1.frame = [50, 220, 350, 350]
        view.addSubview(container1)
        
        let testView20 = TestView()
        testView20.frame = [10, 20, 100, 100]
        container1.addSubview(testView20)
        
        let testView21 = TestView()
        testView21.frame = [170, 150, 100, 100]
        container1.addSubview(testView21)
    }
    
    func setupSubviews3() {
        let container2 = TestContainer()
        container2.backgroundColor = .randomColor(0.2)
        container2.frame = [90, 120, 280, 600]
        view.addSubview(container2)
        
        let testView30 = TestView()
        testView30.frame = [10, 50, 100, 100]
        container2.addSubview(testView30)
        
        let testView31 = TestView()
        testView31.frame = [170, 210, 100, 100]
        container2.addSubview(testView31)
    }
}
