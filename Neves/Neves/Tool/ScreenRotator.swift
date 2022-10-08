//
//  ScreenRotator.swift
//  Neves
//
//  Created by aa on 2022/9/30.
//

/**
 * 屏幕旋转工具类
 *
 * - 目前仅支持三方向：
 *  1. 竖屏：手机头在上边
 *  2. 横屏：手机头在左边
 *  3. 横屏：手机头在右边
 *
 * - 使用：
 *  1. 让`ScreenRotator`全局控制屏幕方向，在`AppDelegate`中重写：
 *
 *      func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
 *          return ScreenRotator.shared.orientationMask
 *      }
 *
 *  2. 不需要再重写`ViewController`的`supportedInterfaceOrientations`和`shouldAutorotate`；
 *
 *  3. 如需获取屏幕实时尺寸，在对应`ViewController`中重写：
 *
 *      override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
 *
 *          // 当屏幕发生旋转时，系统会自动触发该函数，`size`为旋转后的屏幕尺寸
 *          JPrint("size", size) // --- (926.0, 428.0)
 *          // 或者通过`UIScreen`也能获取旋转后的屏幕尺寸
 *          JPrint("mainScreen", UIScreen.mainSize) // --- (926.0, 428.0)
 *
 *          // 注意：如果想通过`self.xxx`去获取屏幕相关的信息（如`self.view.frame`），【此时】获取的尺寸还是【旋转之前】的尺寸，
 *          // 想要获取【旋转之后】的屏幕信息，需要到`Runloop`的下一个循环才能获取。
 *
 *          // 🌰🌰🌰：竖屏 --> 横屏
 *          JPrint("----------- 屏幕即将旋转 -----------")
 *          JPrint("view.size", view.size) // - (428.0, 926.0)
 *          JPrint("window.size", view.window?.size ?? .zero) // - (428.0, 926.0)
 *          JPrint("window.safeAreaInsets", view.window?.safeAreaInsets ?? .zero) // - UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
 *
 *          DispatchQueue.main.async {
 *              JPrint("----------- 屏幕已经旋转 -----------")
 *              JPrint("view.size", self.view.size) // - (926.0, 428.0)
 *              JPrint("window.size", self.view.window?.size ?? .zero) // - (926.0, 428.0)
 *              JPrint("window.safeAreaInsets", self.view.window?.safeAreaInsets ?? .zero) // - UIEdgeInsets(top: 0.0, left: 47.0, bottom: 21.0, right: 47.0)
 *              JPrint("==================================")
 *          }
 *      }
 *
 *  4. 如需监听屏幕的旋转，不要再监听`UIDevice.orientationDidChangeNotification`通知，而是监听`ScreenRotator.orientationDidChangeNotification`通知，
 *  或者通过闭包的形式`ScreenRotator.shard.orientationMaskDidChange = { orientationMask in ...... }`实现监听。
 *
 * - API：
 *  1. 旋转至目标方向
 *      - func rotation(to orientation: Orientation)
 *  2. 旋转至竖屏
 *      - func rotationToPortrait()
 *  3. 旋转至横屏（如果锁定了屏幕，则转向手机头在左边）
 *      - func rotationToLandscape()
 *  4. 旋转至横屏（手机头在左边）
 *      - func rotationToLandscapeLeft()
 *  5. 旋转至横屏（手机头在右边）
 *      - func rotationToLandscapeRight()
 *  6. 横竖屏切换
 *      - func toggleOrientation()
 *  7. 是否正在竖屏
 *      - var isPortrait: Bool
 *  8. 当前屏幕方向（ScreenRotator.Orientation）
 *      - var orientation: Orientation
 *  9. 屏幕方向发生改变的回调
 *      - var orientationMaskDidChange: ((_ orientationMask: UIInterfaceOrientationMask) -> ())?
 *  10. 是否锁定屏幕方向（true则不随手机摆动改变，即便控制中心禁止了竖屏锁定）
 *      - var isLockOrientationMask = false
 */

final class ScreenRotator {
    /// 单例
    static let shared = ScreenRotator()
    
    /// 屏幕方向发生改变的通知
    /// - object: orientationMask（UIInterfaceOrientationMask）
    static let orientationDidChangeNotification = Notification.Name("ScreenRotatorOrientationDidChangeNotification")
    
    /// 可旋转的屏幕方向
    enum Orientation {
        case portrait       // 竖屏 手机头在上边
        case landscapeLeft  // 横屏 手机头在左边
        case landscapeRight // 横屏 手机头在右边
    }
    
    /// 可否旋转
    private(set) var isEnabled = true
    
    /// 当前屏幕方向（UIInterfaceOrientationMask）
    private(set) var orientationMask: UIInterfaceOrientationMask = .portrait {
        didSet {
            orientationMaskDidChange?(orientationMask)
            NotificationCenter.default.post(name: Self.orientationDidChangeNotification, object: orientationMask)
        }
    }
    
    /// 是否正在竖屏
    var isPortrait: Bool { orientationMask == .portrait }
    
    /// 当前屏幕方向（ScreenRotator.Orientation）
    var orientation: Orientation {
        switch orientationMask {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    /// 屏幕方向发生改变的回调
    var orientationMaskDidChange: ((_ orientationMask: UIInterfaceOrientationMask) -> ())?
    
    /// 是否锁定屏幕方向（true则不随手机摆动改变，即便控制中心禁止了竖屏锁定）
    var isLockOrientationMask = false
    
    // MARK: - 构造器
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 私有API
private extension ScreenRotator {
    static func convertInterfaceOrientationMaskToDeviceOrientation(_ orientationMask: UIInterfaceOrientationMask) -> UIDeviceOrientation {
        switch orientationMask {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .landscape:
            return .landscapeLeft
        default:
            return .portrait
        }
    }

    static func convertDeviceOrientationToInterfaceOrientationMask(_ orientation: UIDeviceOrientation) -> UIInterfaceOrientationMask {
        switch orientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    func rotation(to orientationMask: UIInterfaceOrientationMask) {
        guard isEnabled else { return }
        guard self.orientationMask != orientationMask else { return }

        //【注意1】要先设置`UIInterfaceOrientationMaskAll`再设置【确定改变的方向】，
        // 否则可能会导致两种情况：1.无法旋转；2.如果竖转右，会先转左再转右的连续两次旋转。
        self.orientationMask = .all
        
        //【注意2】要在设置【确定改变的方向】之前调用，如果在设置`UIInterfaceOrientationMaskAll`之前也调用，
        // 可能会导致两种情况：1.无法旋转；2.如果竖转右，会先转左再转右的连续两次旋转。
        UIViewController.attemptRotationToDeviceOrientation()
        
        if #available(iOS 16.0, *) {
            // `iOS16`控制横竖屏
            // 由于不能再设置`UIDevice.orientation`来控制横竖屏了，所以`UIDeviceOrientationDidChangeNotification`将由系统自动发出，
            // 即手机的摆动就会自动收到通知，不能自己控制，因此不能监听该通知来适配UI，
            // 重写`UIViewController`的`-viewWillTransitionToSize:withTransitionCoordinator:`方法来监听屏幕的旋转并适配UI。
            // 参考1：https://www.jianshu.com/p/ff6ed9de906d
            // 参考2：https://blog.csdn.net/wujakf/article/details/126133680
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientationMask)
            for scene in UIApplication.shared.connectedScenes {
                // 一般来说app只有一个`windowScene`，而`windowScene`内可能有多个`window`。
                guard let windowScene = scene as? UIWindowScene else { continue }
                // 例如`Neves`中至少有两个`window`：第一个是app主体的`window`，第二个则是`FunnyButton`所在的`window`。
                for window in windowScene.windows {
                    window.windowScene?.requestGeometryUpdate(geometryPreferences)
                }
            }
        } else {
            // `iOS16`之前修改"orientation"后会直接影响`UIDevice.currentDevice.orientation`；
            // `iOS16`之后不能再通过设置`UIDevice.orientation`来控制横竖屏了，修改"orientation"无效。
            let currentDevice = UIDevice.current
            let deviceOrientation = Self.convertInterfaceOrientationMaskToDeviceOrientation(orientationMask)
            currentDevice.setValue(NSNumber(value: deviceOrientation.rawValue), forKeyPath: "orientation")
        }
        
        self.orientationMask = orientationMask
    }
}

// MARK: - 监听通知
private extension ScreenRotator {
    // 不活跃了，也就是进后台了
    @objc func willResignActive() {
        isEnabled = false
    }
    
    // 活跃了，也就是从后台回来了
    @objc func didBecomeActive() {
        isEnabled = true
    }
    
    // 设备方向发生改变
    @objc func deviceOrientationDidChange() {
        guard isEnabled, !isLockOrientationMask else { return }
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .unknown, .portraitUpsideDown, .faceUp, .faceDown:
            return
        default:
            break
        }
        let orientationMask = Self.convertDeviceOrientationToInterfaceOrientationMask(deviceOrientation)
        rotation(to: orientationMask)
    }
}

// MARK: - 公开API
extension ScreenRotator {
    /// 旋转至目标方向
    /// - Parameters:
    ///   - orientation: 目标方向（ScreenRotator.Orientation）
    func rotation(to orientation: Orientation) {
        guard isEnabled else { return }
        let orientationMask: UIInterfaceOrientationMask
        switch orientation {
        case .landscapeLeft:
            orientationMask = .landscapeRight
        case .landscapeRight:
            orientationMask = .landscapeLeft
        default:
            orientationMask = .portrait
        }
        rotation(to: orientationMask)
    }
    
    /// 旋转至竖屏
    func rotationToPortrait() {
        rotation(to: UIInterfaceOrientationMask.portrait)
    }
    
    /// 旋转至横屏（如果锁定了屏幕，则转向手机头在左边）
    func rotationToLandscape() {
        guard isEnabled else { return }
        var orientationMask = Self.convertDeviceOrientationToInterfaceOrientationMask(UIDevice.current.orientation)
        if orientationMask == .portrait {
            orientationMask = .landscapeRight
        }
        rotation(to: orientationMask)
    }
    
    /// 旋转至横屏（手机头在左边）
    func rotationToLandscapeLeft() {
        rotation(to: UIInterfaceOrientationMask.landscapeRight)
    }
    
    /// 旋转至横屏（手机头在右边）
    func rotationToLandscapeRight() {
        rotation(to: UIInterfaceOrientationMask.landscapeLeft)
    }
    
    /// 横竖屏切换
    func toggleOrientation() {
        guard isEnabled else { return }
        var orientationMask = Self.convertDeviceOrientationToInterfaceOrientationMask(UIDevice.current.orientation)
        if orientationMask == self.orientationMask {
            orientationMask = self.orientationMask == .portrait ? .landscapeRight : .portrait
        }
        rotation(to: orientationMask)
    }
}
