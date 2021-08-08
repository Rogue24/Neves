//
//  JPObject.h
//  Neves
//
//  Created by 周健平 on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPObject : NSObject
@property (nonatomic, assign) NSInteger x;
- (instancetype)initWithX:(NSInteger)x;
@end

NS_ASSUME_NONNULL_END
