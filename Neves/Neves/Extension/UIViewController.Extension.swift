//
//  UIViewController.Extension.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

enum VcBuilder {
    typealias Vc = UIViewController
    
    case code(_ vcType: Vc.Type)
    case xib(_ vcType: Vc.Type, nibName: String? = nil, bundle: Bundle? = nil)
    case storyboard(_ vcType: Vc.Type, sbName: String, bundle: Bundle? = nil, identifier: String? = nil)
    case custom(_ vcType: Vc.Type, build: (Vc.Type) -> Vc?)
    case other(_ context: String, build: (String) -> Vc?)
    
    func build() -> Vc? {
        switch self {
        case let .code(vcType):
            return vcType.init()
            
        case let .xib(vcType, nibName, bundle):
            let nibName = nibName ?? "\(vcType)"
            let bundle = bundle ?? Bundle.main
            return vcType.init(nibName: nibName, bundle: bundle)
            
        case let .storyboard(vcType, sbName, bundle, identifier):
            let bundle = bundle ?? Bundle.main
            let identifier = identifier ?? "\(vcType)"
            return UIStoryboard(name: sbName, bundle: bundle).instantiateViewController(withIdentifier: identifier)
            
        case let .custom(vcType, build):
            return build(vcType)
            
        case let .other(context, build):
            return build(context)
        }
    }
}

extension UIViewController: JPCompatible {}
extension JP where Base: UIViewController {
    var topVC: UIViewController? { base.view.jp.topVC }
    var topNavCtr: UINavigationController? { topVC?.navigationController }
    
    func contentInsetAdjustmentNever(_ scrollView: UIScrollView? = nil) {
        if #available(iOS 11.0, *) {
            scrollView?.jp.contentInsetAdjustmentNever()
        } else {
            base.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func dismissAll(animated: Bool = false, presentedVC: UIViewController? = nil) {
        let currentPresentedVC = base.presentedViewController
        
        if let currentPresentedVC = currentPresentedVC, currentPresentedVC != presentedVC {
            JPrint("dismissAll", base)
            base.dismiss(animated: animated)
        }
        
        base.children.forEach {
            $0.jp.dismissAll(animated: animated, presentedVC: currentPresentedVC)
        }
    }
    
    func checkAllViewControllers(presentedVC: UIViewController? = nil) {
        JPrint("check", base)
        
        let currentPresentedVC = base.presentedViewController
        
        if let currentPresentedVC = currentPresentedVC, currentPresentedVC != presentedVC {
            currentPresentedVC.jp.checkAllViewControllers()
        }
        
        base.children.forEach {
            $0.jp.checkAllViewControllers(presentedVC: currentPresentedVC)
        }
    }
}
