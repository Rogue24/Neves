//
//  JKRChatRoomMedalModel.h
//  Falla
//
//  Created by Howie on 2021/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRChatRoomMedalModel : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *rq_icon;

@end

NS_ASSUME_NONNULL_END
