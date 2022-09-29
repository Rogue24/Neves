//
//  JPScreenRotationTool.h
//  Neves
//
//  Created by aa on 2022/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSNotificationName const JPScreenOrientationDidChangeNotification;

typedef NS_ENUM(NSUInteger, JPScreenOrientation) {
    JPScreenOrientationPortrait,            // vertically, home button on the bottom
    JPScreenOrientationLandscapeLeft,       // horizontally, home button on the right
    JPScreenOrientationLandscapeRight,      // horizontally, home button on the left
};

@interface JPScreenRotationTool : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isPortrait;
@property (nonatomic, assign, readonly) JPScreenOrientation orientation;
@property (nonatomic, assign, readonly) UIInterfaceOrientationMask orientationMask;

@property (nonatomic, copy) void (^_Nullable orientationMaskDidChange)(UIInterfaceOrientationMask orientationMask);

- (void)rotationToOrientation:(JPScreenOrientation)orientation;
- (void)rotationToPortrait;
- (void)rotationToLandscapeLeft;
- (void)rotationToLandscapeRight;
- (void)rotationToLandscape;
- (void)toggleOrientation;
@end

NS_ASSUME_NONNULL_END
 
