//
//  JPDeviceTool.h
//  WoLive
//
//  Created by 周健平 on 2018/10/9.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JPDeviceOrientation) {
    JPDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    JPDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    JPDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
};

@interface JPDeviceTool : NSObject
+ (NSString *)deviceName;
+ (NSString *)systemVersion;

+ (BOOL)isPortrait;
+ (JPDeviceOrientation)currentOrientation;
+ (void)switchDeviceOrientation:(JPDeviceOrientation)orientation;

+ (int)getSignalIntensity:(BOOL)isWiFi;

+ (BOOL)goApplicationOpenSettings;
@end
