//
//  JPDog.m
//  Neves
//
//  Created by aa on 2021/6/2.
//

#import "JPDog.h"
#import "JPConstant.h"

@implementation JPDog
- (NSUInteger)hash {
    NSUInteger hash = [@(self.a) hash] ^ [@(self.b) hash];
    JPLog(@"JPDog hash %zd --- self: %p", hash, self);
    return hash;
}
- (BOOL)isEqual:(id)object {
    if (self == object) {
        JPLog(@"JPDog isEqual YES --- self: %p, other: %p", self, object);
        return YES;
    }
    
    if (![object isKindOfClass:[JPDog class]]) {
        JPLog(@"JPDog isEqual NO --- self: %p, other: %p", self, object);
        return NO;
    }
    
    JPDog *other = (JPDog *)object;
    BOOL isEq = self.a == other.a && self.b == other.b;
    JPLog(@"JPDog isEqual %@ --- self: %p, other: %p", isEq ? @"YES" : @"NO", self, object);
    return isEq;
}
- (void)dealloc {
    JPLog(@"JPDog 死了 --- self: %p", self);
}
@end
