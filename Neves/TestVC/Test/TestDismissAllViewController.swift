//
//  TestDismissAllViewController.swift
//  Neves
//
//  Created by aa on 2023/2/8.
//

import FunnyButton

class TestDismissAllViewController: TestBaseViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceFunnyAction { [weak self] in
            guard let self = self else { return }
            let navCtr = UINavigationController(rootViewController: TestSuperVC())
            navCtr.modalPresentationStyle = .fullScreen
            self.present(navCtr, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunnyActions()
    }
}

/*
 * 如果已经`present`出一个控制器，所在的【控制器栈】都不能再`present`新的控制器（整个栈只能存在一个`presentedViewController`）。
    - 所在的【控制器栈】包括：self（自己）、parent（父控制器）、children（子控制器）
 * 如果想一次性dismiss全部通过`present`的方式打开的控制器，只需要对【根控制器】调用`dismiss`方法即可。
    - 参考：https://blog.csdn.net/nunchakushuang/article/details/45198969
 */

extension TestDismissAllViewController {
    class TestSuperVC: TestBaseViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            replaceFunnyActions([
                FunnyAction(name: "开始") { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.pushViewController(TestVC(tag: 0), animated: true)
                },
                
                FunnyAction(name: "根部present") { [weak self] in
                    guard let self = self else { return }
                    self.present(TestVC(tag: 200), animated: true)
                },
                
                FunnyAction(name: "根部dismiss") { [weak self] in
                    guard let self = self else { return }
                    self.dismiss(animated: true)
                },
                
                FunnyAction(name: "销毁根部") { [weak self] in
                    guard let self = self else { return }
                    self.presentingViewController?.dismiss(animated: false)
                },
                
                FunnyAction(name: "叫3号present") { [weak self] in
                    guard let self = self else { return }
                    guard let vc = self.navigationController?.viewControllers.first(where: { ($0 as? TestVC)?.tag == 3 }) else {
                        return
                    }
                    (vc as! TestVC).present100()
                },
                
                FunnyAction(name: "叫3号dismiss") { [weak self] in
                    guard let self = self else { return }
                    guard let vc = self.navigationController?.viewControllers.first(where: { ($0 as? TestVC)?.tag == 3 }) else {
                        return
                    }
                    vc.dismiss(animated: true)
                },
                
                FunnyAction(name: "直接移除3号") { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.viewControllers.removeAll(where: { ($0 as? TestVC)?.tag == 3 })
                },
            ])
        }
    }
}

extension TestDismissAllViewController {
    class TestVC: UIViewController {
        let tag: Int
        init(tag: Int) {
            self.tag = tag
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .fullScreen
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .randomColor
            JPrint("活了", tag)
            
            let btn1 = UIButton(type: .system)
            btn1.frame = [100, 150, 120, 60]
            btn1.setTitle("Push", for: .normal)
            btn1.setTitleColor(.randomColor, for: .normal)
            btn1.backgroundColor = .randomColor
            btn1.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
            view.addSubview(btn1)
            
            let btn2 = UIButton(type: .system)
            btn2.frame = [100, 220, 120, 60]
            btn2.setTitle("Present", for: .normal)
            btn2.setTitleColor(.randomColor, for: .normal)
            btn2.backgroundColor = .randomColor
            btn2.addTarget(self, action: #selector(presentVC), for: .touchUpInside)
            view.addSubview(btn2)
            
            let btn3 = UIButton(type: .system)
            btn3.frame = [100, 300, 120, 60]
            btn3.setTitle("Close", for: .normal)
            btn3.setTitleColor(.randomColor, for: .normal)
            btn3.backgroundColor = .randomColor
            btn3.addTarget(self, action: #selector(close), for: .touchUpInside)
            view.addSubview(btn3)
        }
        
        @objc func pushVC() {
            navigationController?.pushViewController(TestVC(tag: tag + 1), animated: true)
        }
        
        @objc func presentVC() {
            present(TestVC(tag: tag + 1), animated: true)
        }
        
        @objc func close() {
            if let navCtr = navigationController {
                navCtr.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        }
        
        @objc func present100() {
            guard tag == 3 else { return }
            present(TestVC(tag: 100), animated: true)
        }
        
        deinit {
            JPrint("死了", tag)
        }
    }
}
