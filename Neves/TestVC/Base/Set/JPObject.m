//
//  JPObject.m
//  Neves
//
//  Created by 周健平 on 2021/6/1.
//

#import "JPObject.h"

@implementation JPObject

- (instancetype)initWithX:(NSInteger)x {
    if (self = [super init]) {
        self.x = x;
    }
    return self;
}

- (BOOL)isEqual:(JPObject *)object {

    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[JPObject class]]) return NO;

    return object.x == self.x;
}

@end
