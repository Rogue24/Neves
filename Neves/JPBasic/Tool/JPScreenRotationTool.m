//
//  JPScreenRotationTool.m
//  Neves
//
//  Created by aa on 2022/9/23.
//

#import "JPScreenRotationTool.h"
#import "JPMacro.h"
#import "JPConstant.h"

NSNotificationName const JPScreenOrientationDidChangeNotification = @"JPScreenOrientationDidChangeNotification";

static inline UIDeviceOrientation JPConvertInterfaceOrientationMaskToDeviceOrientation(UIInterfaceOrientationMask orientationMask) {
    switch (orientationMask) {
        case UIInterfaceOrientationMaskLandscapeLeft:
            return UIDeviceOrientationLandscapeRight;
        case UIInterfaceOrientationMaskLandscapeRight:
            return UIDeviceOrientationLandscapeLeft;
        case UIInterfaceOrientationMaskLandscape:
            return UIDeviceOrientationLandscapeLeft;
        default:
            return UIDeviceOrientationPortrait;
    }
}

static inline UIInterfaceOrientationMask JPConvertDeviceOrientationToInterfaceOrientationMask(UIDeviceOrientation orientation) {
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeLeft;
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}

@implementation JPScreenRotationTool
{
    BOOL _isEnabled;
    UIInterfaceOrientationMask _orientationMask;
}

#pragma mark - 单例

static JPScreenRotationTool *sharedInstance_;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [super allocWithZone:zone];
    });
    return sharedInstance_;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [[JPScreenRotationTool alloc] init];
    });
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return sharedInstance_;
}

#pragma mark - 生命周期

- (instancetype)init {
    if (self = [super init]) {
        _isEnabled = YES;
        _orientationMask = UIInterfaceOrientationMaskPortrait;
        _isLockOrientationMask = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter

- (void)setOrientationMask:(UIInterfaceOrientationMask)orientationMask {
    _orientationMask = orientationMask;
    !self.orientationMaskDidChange ? : self.orientationMaskDidChange(orientationMask);
    [[NSNotificationCenter defaultCenter] postNotificationName:JPScreenOrientationDidChangeNotification object:@(orientationMask)];
}

#pragma mark - getter

- (BOOL)isPortrait {
    return _orientationMask == UIInterfaceOrientationMaskPortrait;
}

- (JPScreenOrientation)orientation {
    switch (_orientationMask) {
        case UIInterfaceOrientationMaskLandscapeLeft:
            return JPScreenOrientationLandscapeRight;
        case UIInterfaceOrientationMaskLandscapeRight:
            return JPScreenOrientationLandscapeLeft;
        default:
            return JPScreenOrientationPortrait;
    }
}

- (UIInterfaceOrientationMask)orientationMask {
    return _orientationMask;
}

#pragma mark - 监听通知

// 不活跃了，也就是进后台了
- (void)__willResignActive {
    _isEnabled = NO;
}

// 活跃了，也就是从后台回来了
- (void)__didBecomeActive {
    _isEnabled = YES;
}

// 设备方向发生改变
- (void)__deviceOrientationDidChange {
    if (!_isEnabled) return;
    if (_isLockOrientationMask) return;

    UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
    if (deviceOrientation == UIDeviceOrientationUnknown ||
        deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
        deviceOrientation == UIDeviceOrientationFaceUp ||
        deviceOrientation == UIDeviceOrientationFaceDown) return;

    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(deviceOrientation);
    [self __rotationToOrientationMask:orientationMask];
}

#pragma mark - 私有方法

- (void)__rotationToOrientationMask:(UIInterfaceOrientationMask)orientationMask {
    if (!_isEnabled) return;
    if (orientationMask == _orientationMask) return;
    
    //【注意1】要先设置`UIInterfaceOrientationMaskAll`再设置【确定改变的方向】，
    // 否则可能会导致两种情况：1.无法旋转；2.如果竖转右，会先转左再转右的连续两次旋转。
    self.orientationMask = UIInterfaceOrientationMaskAll;
    
    //【注意2】要在设置【确定改变的方向】之前调用，如果在设置`UIInterfaceOrientationMaskAll`之前也调用，
    // 可能会导致两种情况：1.无法旋转；2.如果竖转右，会先转左再转右的连续两次旋转。
    [UIViewController attemptRotationToDeviceOrientation];
    
    // `iOS16`控制横竖屏
    // 由于不能再设置`UIDevice.orientation`来控制横竖屏了，所以`UIDeviceOrientationDidChangeNotification`将由系统自动发出，
    // 即手机的摆动就会自动收到通知，不能自己控制，因此不能监听该通知来适配UI，
    // 重写`UIViewController`的`-viewWillTransitionToSize:withTransitionCoordinator:`方法来监听屏幕的旋转并适配UI。
    // 参考1：https://www.jianshu.com/p/ff6ed9de906d
    // 参考2：https://blog.csdn.net/wujakf/article/details/126133680
    if (@available(iOS 16.0, *)) {
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:orientationMask];
        NSArray *connectedScenes = [UIApplication sharedApplication].connectedScenes.allObjects;
        for (UIScene *scene in connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) {
                // 一般来说app只有一个`windowScene`，而`windowScene`内可能有多个`window`。
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                // 例如`Neves`中至少有两个`window`：第一个是app主体的`window`，第二个则是`FunnyButton`所在的`window`。
                for (UIWindow *window in windowScene.windows) {
                    [window.windowScene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
                        JPLog(@"强制旋转错误: %@", error);
                    }];
                }
            }
        }
    } else {
        // `iOS16`之前修改"orientation"后会直接影响`UIDevice.currentDevice.orientation`；
        // `iOS16`之后不能再通过设置`UIDevice.orientation`来控制横竖屏了，修改"orientation"无效。
        UIDevice *currentDevice = UIDevice.currentDevice;
        UIDeviceOrientation deviceOrientation = JPConvertInterfaceOrientationMaskToDeviceOrientation(orientationMask);
        NSString *keyPath = JPKeyPath(currentDevice, orientation);
        [currentDevice setValue:@(deviceOrientation) forKeyPath:keyPath];
    }
    
    self.orientationMask = orientationMask;
}

#pragma mark - 公开方法

- (void)rotationToOrientation:(JPScreenOrientation)orientation {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask;
    switch (orientation) {
        case JPScreenOrientationLandscapeLeft:
            orientationMask = UIInterfaceOrientationMaskLandscapeRight;
            break;
        case JPScreenOrientationLandscapeRight:
            orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        default:
            orientationMask = UIInterfaceOrientationMaskPortrait;
            break;
    }
    
    [self __rotationToOrientationMask:orientationMask];
}

- (void)rotationToPortrait {
    [self __rotationToOrientationMask:UIInterfaceOrientationMaskPortrait];
}

- (void)rotationToLandscape {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(UIDevice.currentDevice.orientation);
    if (orientationMask == UIInterfaceOrientationMaskPortrait) {
        orientationMask = UIInterfaceOrientationMaskLandscapeRight;
    }
    
    [self __rotationToOrientationMask:orientationMask];
}

- (void)rotationToLandscapeLeft {
    [self __rotationToOrientationMask:UIInterfaceOrientationMaskLandscapeRight];
}

- (void)rotationToLandscapeRight {
    [self __rotationToOrientationMask:UIInterfaceOrientationMaskLandscapeLeft];
}

- (void)toggleOrientation {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(UIDevice.currentDevice.orientation);
    if (orientationMask == _orientationMask) {
        if (_orientationMask == UIInterfaceOrientationMaskPortrait) {
            orientationMask = UIInterfaceOrientationMaskLandscapeRight;
        } else {
            orientationMask = UIInterfaceOrientationMaskPortrait;
        }
    }
    
    [self __rotationToOrientationMask:orientationMask];
}

@end
