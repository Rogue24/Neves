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

static inline UIDeviceOrientation JPConvertInterfaceOrientationMaskToDeviceOrientation(UIInterfaceOrientationMask orientationMark) {
    switch (orientationMark) {
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__didEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
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

- (void)__didEnterBackground {
    _isEnabled = NO;
}

- (void)__didBecomeActive {
    _isEnabled = YES;
}

- (void)__deviceOrientationDidChange {
    if (!_isEnabled) return;

    UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
    if (deviceOrientation == UIDeviceOrientationUnknown ||
        deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
        deviceOrientation == UIDeviceOrientationFaceUp ||
        deviceOrientation == UIDeviceOrientationFaceDown) return;

    UIInterfaceOrientationMask orientationMark = JPConvertDeviceOrientationToInterfaceOrientationMask(deviceOrientation);
    [self __rotationToOrientationMark:orientationMark];
}

#pragma mark - 私有方法

- (void)__rotationToOrientationMark:(UIInterfaceOrientationMask)orientationMask {
    if (!_isEnabled) return;
    if (orientationMask == _orientationMask) return;
    
    //【注意1】要先设置`UIInterfaceOrientationMaskAll`再设置【确定改变的方向】，
    // 否则可能会导致两种情况：1.无法旋转；2.如果转右，会先转左再转右的连续两次旋转。
    !self.orientationMaskDidChange ? : self.orientationMaskDidChange(UIInterfaceOrientationMaskAll);
    _orientationMask = UIInterfaceOrientationMaskAll;
    
    //【注意2】要在设置【确定改变的方向】之前调用，如果在设置`UIInterfaceOrientationMaskAll`之前也调用，
    // 可能会导致两种情况：1.如果转右，会先转左再转右的连续两次旋转；2.不会旋转。
    [UIViewController attemptRotationToDeviceOrientation];
    
    // `iOS16`控制横竖屏
    // 参考1：https://www.jianshu.com/p/ff6ed9de906d
    // 参考2：https://blog.csdn.net/wujakf/article/details/126133680
    // 重写`UIViewController`的`viewWillTransitionToSize:withTransitionCoordinator:`方法即可监听屏幕的旋转。
    if (@available(iOS 16.0, *)) {
        UIWindowSceneGeometryPreferencesIOS *geometryPreferencesIOS = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:orientationMask];
        
        NSArray *connectedScenes = [UIApplication sharedApplication].connectedScenes.allObjects;
        for (UIScene *scene in connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) {
                // 一般来说app只有一个windowScene，而windowScene内可能有多个window。
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                // 例如Neves中至少有两个window：第一个是app主体的window，第二个则是FunnyButton所在的window。
                for (UIWindow *window in windowScene.windows) {
                    [window.windowScene requestGeometryUpdateWithPreferences:geometryPreferencesIOS errorHandler:^(NSError * _Nonnull error) {
                        JPLog(@"强制旋转错误: %@", error);
                    }];
                }
            }
        }
        
        self.orientationMask = orientationMask;
        return;
    }
    
    // `iOS16`之前修改"orientation"后会直接影响`UIDevice.currentDevice.orientation`；
    // `iOS16`之后不能再通过设置`UIDevice.orientation`来控制横竖屏了，修改"orientation"无效。
    UIDevice *currentDevice = UIDevice.currentDevice;
    UIDeviceOrientation deviceOrientation = JPConvertInterfaceOrientationMaskToDeviceOrientation(orientationMask);
    NSString *keyPath = JPKeyPath(currentDevice, orientation);
    [currentDevice setValue:@(deviceOrientation) forKey:keyPath];
    
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
    
    [self __rotationToOrientationMark:orientationMask];
}

- (void)rotationToPortrait {
    [self __rotationToOrientationMark:UIInterfaceOrientationMaskPortrait];
}

- (void)rotationToLandscapeLeft {
    [self __rotationToOrientationMark:UIInterfaceOrientationMaskLandscapeRight];
}

- (void)rotationToLandscapeRight {
    [self __rotationToOrientationMark:UIInterfaceOrientationMaskLandscapeLeft];
}

- (void)rotationToLandscape {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(UIDevice.currentDevice.orientation);
    
    if (orientationMask == UIInterfaceOrientationMaskPortrait) {
        orientationMask = UIInterfaceOrientationMaskLandscapeRight;
    }
    
    [self __rotationToOrientationMark:orientationMask];
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
    
    [self __rotationToOrientationMark:orientationMask];
}

@end
