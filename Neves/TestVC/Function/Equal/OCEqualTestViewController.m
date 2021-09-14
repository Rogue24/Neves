//
//  OCEqualTestViewController.m
//  Neves
//
//  Created by 周健平 on 2021/8/19.
//

#import "OCEqualTestViewController.h"
#import "JPConstant.h"
#import "UIColor+JPExtension.h"
#import "Neves-Swift.h"
#import "OCTestObject.h"

@interface OCEqualTestViewController ()
@property (nonatomic, strong) TestObject2 *testObject21;
@property (nonatomic, strong) TestObject2 *testObject22;

@property (nonatomic, strong) OCTestObject *testObject31;
@property (nonatomic, strong) OCTestObject *testObject32;
@end

@implementation OCEqualTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    self.testObject21 = [[TestObject2 alloc] initWithA:3 b:9];
    
    self.testObject22 = [[TestObject2 alloc] initWithA:3 b:9];

    self.testObject31 = [[OCTestObject alloc] init];
    self.testObject31.a = 3;
    self.testObject31.b = 9;
    
    self.testObject32 = [[OCTestObject alloc] init];
    self.testObject32.a = 3;
    self.testObject32.b = 9;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.testObject21 == self.testObject22) {
        JPLog(@"a: 1");
    } else {
        JPLog(@"a: 0");
    }
    if (self.testObject21 == self.testObject21) {
        JPLog(@"aa: 1");
    } else {
        JPLog(@"aa: 0");
    }
    
    if (self.testObject31 == self.testObject32) {
        JPLog(@"b: 1");
    } else {
        JPLog(@"b: 0");
    }
    
    if ([self.testObject21 isEqual:self.testObject22]) {
        JPLog(@"c: 1");
    } else {
        JPLog(@"c: 0");
    }
    
    if ([self.testObject31 isEqual:self.testObject32]) {
        JPLog(@"d: 1");
    } else {
        JPLog(@"d: 0");
    }
}

@end
