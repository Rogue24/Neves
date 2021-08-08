//
//  JPPerson.m
//  Neves
//
//  Created by aa on 2021/6/2.
//

#import "JPPerson.h"
#import "JPConstant.h"

@implementation JPPerson
- (NSUInteger)hash {
    NSUInteger hash = [super hash];
    JPLog(@"JPPerson hash %zd --- self: %p", hash, self);
    return hash;
}
- (BOOL)isEqual:(id)object {
    if (self == object) {
        JPLog(@"JPPerson isEqual YES --- self: %p, other: %p", self, object);
        return YES;
    }

    if (![object isKindOfClass:[JPPerson class]]) {
        JPLog(@"JPPerson isEqual NO --- self: %p, other: %p", self, object);
        return NO;
    }

    JPPerson *other = (JPPerson *)object;
    BOOL isEq = self.a == other.a && self.b == other.b;
    JPLog(@"JPPerson isEqual %@ --- self: %p, other: %p", isEq ? @"YES" : @"NO", self, object);
    return isEq;
}
- (void)dealloc {
    JPLog(@"JPPerson 死了 --- self: %p", self);
}
@end
