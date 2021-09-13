//
//  OCTestObject.m
//  Neves
//
//  Created by 周健平 on 2021/8/19.
//

#import "OCTestObject.h"

@implementation OCTestObject

- (BOOL)isEqual:(id)other {
    NSLog(@"OCTestObject 执行了 ‘isEqual’");
    if (other == self) {
        return YES;
    }
    
//    else if (![super isEqual:other]) { // <-- 默认实现，super返回NO
//        return NO;
//    }
    
    // 下面这两个是自己加的
    else if (![other isKindOfClass:self.class]) {
        return NO;
    }
    else {
        OCTestObject *obj = (OCTestObject *)other;
        return self.a == obj.a && self.b == obj.b;
    }
}

- (NSUInteger)hash {
    NSLog(@"OCTestObject 执行了 ‘hash’");
    return super.hash;
//    return self.a ^ self.b;
}

@end
