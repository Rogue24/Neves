//
//  JPScreenRotationTool.h
//  Neves
//
//  Created by aa on 2022/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Notification: 屏幕方向发生改变的通知
 * object: orientationMask（UIInterfaceOrientationMask）
 * userInfo: nil
 */
UIKIT_EXTERN NSNotificationName const JPScreenOrientationDidChangeNotification;

/** 可旋转的屏幕方向 */
typedef NS_ENUM(NSUInteger, JPScreenOrientation) {
    JPScreenOrientationPortrait,        // 竖屏 手机头在上边
    JPScreenOrientationLandscapeLeft,   // 横屏 手机头在左边
    JPScreenOrientationLandscapeRight,  // 横屏 手机头在右边
};

@interface JPScreenRotationTool : NSObject
/** 单例 */
+ (instancetype)sharedInstance;

/** 是否正在竖屏 */
@property (nonatomic, assign, readonly) BOOL isPortrait;
/** 当前屏幕方向（JPScreenOrientation） */
@property (nonatomic, assign, readonly) JPScreenOrientation orientation;
/** 当前屏幕方向（UIInterfaceOrientationMask）  */
@property (nonatomic, assign, readonly) UIInterfaceOrientationMask orientationMask;

/** 屏幕方向发生改变的回调 */
@property (nonatomic, copy) void (^_Nullable orientationMaskDidChange)(UIInterfaceOrientationMask orientationMask);
/** 是否锁定屏幕方向（YES则不随手机摆动改变，即便控制中心禁止了竖屏锁定） */
@property (nonatomic, assign) BOOL isLockOrientationMask;

/** 旋转至目标方向 */
- (void)rotationToOrientation:(JPScreenOrientation)orientation;

/** 旋转至竖屏 */
- (void)rotationToPortrait;

/** 旋转至横屏（如果锁定了屏幕，则转向手机头在左边） */
- (void)rotationToLandscape;

/** 旋转至横屏（手机头在左边） */
- (void)rotationToLandscapeLeft;

/** 旋转至横屏（手机头在右边） */
- (void)rotationToLandscapeRight;

/** 横竖屏切换 */
- (void)toggleOrientation;
@end

NS_ASSUME_NONNULL_END
 