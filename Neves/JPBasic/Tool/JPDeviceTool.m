//
//  JPDeviceTool.m
//  WoLive
//
//  Created by 周健平 on 2018/10/9.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import "JPDeviceTool.h"
#import "JPMacro.h"
#import "JPConstant.h"

@implementation JPDeviceTool

+ (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString *)systemVersion {
    static NSString *systemVersion_ = nil;
    if (!systemVersion_) {
        systemVersion_ = [[UIDevice currentDevice] systemVersion];
    }
    return systemVersion_;
}

+ (JPDeviceOrientation)convertUIDeviceOrientation:(UIDeviceOrientation)orientation {
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            return JPDeviceOrientationLandscapeLeft;
        case UIDeviceOrientationLandscapeRight:
            return JPDeviceOrientationLandscapeRight;
        default:
            return JPDeviceOrientationPortrait;
    }
}

+ (JPDeviceOrientation)convertUIInterfaceOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
            return JPDeviceOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeLeft:
            return JPDeviceOrientationLandscapeRight;
        default:
            return JPDeviceOrientationPortrait;
    }
}

+ (JPDeviceOrientation)currentOrientation {
    if (@available(iOS 16.0, *)) {
        UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        return [self convertUIInterfaceOrientation:scene.interfaceOrientation];
    }
    return [self convertUIDeviceOrientation:[UIDevice currentDevice].orientation];
}

+ (BOOL)isPortrait {
    return self.currentOrientation == JPDeviceOrientationPortrait;
}

+ (void)switchDeviceOrientation:(JPDeviceOrientation)orientation {
    [UIViewController attemptRotationToDeviceOrientation];
    
    // 屏幕旋转适配iOS16
    // 参考1：https://www.jianshu.com/p/ff6ed9de906d
    // 参考2：https://blog.csdn.net/wujakf/article/details/126133680
    // `iOS16`之后监听`UIDeviceOrientationDidChangeNotification`通知就不好使了（有时候有，有时候没有），
    // 重写`UIViewController`的`viewWillTransitionToSize:withTransitionCoordinator:`方法即可监听屏幕的旋转。
    if (@available(iOS 16.0, *)) {
        UIInterfaceOrientationMask orientationMark;
        switch (orientation) {
            case JPDeviceOrientationLandscapeLeft:
                orientationMark = UIInterfaceOrientationMaskLandscapeRight;
                break;
            case JPDeviceOrientationLandscapeRight:
                orientationMark = UIInterfaceOrientationMaskLandscapeLeft;
                break;
            default:
                orientationMark = UIInterfaceOrientationMaskPortrait;
                break;
        }
        
        UIWindowSceneGeometryPreferencesIOS *geometryPreferencesIOS = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:orientationMark];
        
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
        
        return;
    }
    
    UIDeviceOrientation deviceOrientation;
    switch (orientation) {
        case JPDeviceOrientationLandscapeLeft:
            deviceOrientation = UIDeviceOrientationLandscapeLeft;
            break;
        case JPDeviceOrientationLandscapeRight:
            deviceOrientation = UIDeviceOrientationLandscapeRight;
            break;
        default:
            deviceOrientation = UIDeviceOrientationPortrait;
            break;
    }
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *keyStr = JPKeyPath(currentDevice, orientation);
    [currentDevice setValue:@(deviceOrientation) forKey:keyStr];
}

+ (int)getSignalIntensity:(BOOL)isWiFi {
    int signalStrength = 0;
    if (@available(iOS 13.0, *)) {
        id statusBar = nil;
        // 一般来说第一个window就是app主体的window。
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                statusBar = [localStatusBar performSelector:@selector(statusBar)];
            }
        }
#pragma clang diagnostic pop
        if (statusBar) {
            id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_currentData"];
            // 层级：_UIStatusBarDataNetworkEntry、_UIStatusBarDataIntegerEntry、_UIStatusBarDataEntry
            if (isWiFi) {
                id wifiEntry = [currentData valueForKeyPath:@"_wifiEntry"];
                if ([wifiEntry isKindOfClass:NSClassFromString(@"_UIStatusBarDataIntegerEntry")]) {
                    signalStrength = [[wifiEntry valueForKey:@"displayValue"] intValue];
                }
            } else {
                id cellularEntry = [currentData valueForKeyPath:@"_cellularEntry"];
                if ([cellularEntry isKindOfClass:NSClassFromString(@"_UIStatusBarDataCellularEntry")]) {
                    signalStrength = [[cellularEntry valueForKey:@"displayValue"] intValue];
                }
            }
        }
    } else {
        id statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (statusBar) {
            NSArray *subviews;
            NSString *className;
            NSString *key;
            if (JPis_iphoneX) {
                id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
                UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
                subviews = [[foregroundView subviews][2] subviews];
                className = isWiFi ? @"_UIStatusBarWifiSignalView" : @"_UIStatusBarCellularSignalView";
                key = @"_numberOfActiveBars";
            } else {
                UIView *foregroundView = [statusBar valueForKey:@"foregroundView"];
                subviews = [foregroundView subviews];
                className = isWiFi ? @"UIStatusBarDataNetworkItemView" : @"UIStatusBarSignalStrengthItemView";
                key = isWiFi ? @"_wifiStrengthBars" : @"_signalStrengthBars";
            }
            for (id subview in subviews) {
                if ([subview isKindOfClass:[NSClassFromString(className) class]]) {
                    signalStrength = [[subview valueForKey:key] intValue];
                    break;
                }
            }
        }
    }
    return signalStrength;
}

+ (BOOL)goApplicationOpenSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
        }
        return YES;
    } else {
        return NO;
    }
}

@end
