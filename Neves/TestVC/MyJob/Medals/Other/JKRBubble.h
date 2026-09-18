//
//  JKRBubble.h
//  Falla
//
//  Created by Howie on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import "JKRCSSSRemoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKRBubble : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *fromBg;
@property (nonatomic, copy) NSString *fromBgAr;
@property (nonatomic, copy) NSString *fromColour;
@property (nonatomic, copy) NSString *toBg;
@property (nonatomic, copy) NSString *toBgAr;
@property (nonatomic, copy) NSString *toColour;
/// 气泡类型 1-静态 2-动态
@property (nonatomic, assign) NSInteger bubbleChartType;

@property (nonatomic, strong, nullable) JKRCSSSRemoteModel *eml_config1;
@property (nonatomic, strong, nullable) JKRCSSSRemoteModel *eml_config2;
@property (nonatomic, strong, nullable) JKRCSSSRemoteModel *eml_config3;
@property (nonatomic, strong, nullable) JKRCSSSRemoteModel *eml_config4;

@end

NS_ASSUME_NONNULL_END
