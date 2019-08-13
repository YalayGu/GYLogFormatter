//
//  ViewController.m
//  GYLogFormatter
//
//  Created by Yalay Gu on 2019/8/13.
//  Copyright © 2019 Yalay Gu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *unicodeString = @"\u6b22\u8fce\u6765\u5230\u4ee3\u7801\u7684\u4e16\u754c";
    NSString *infoString = @"\u53ef\u4ee5\u8f7b\u677e\u7684\u5c06\u4f60\u65e5\u5fd7\u8f93\u51fa\u4e2d\u7684Unicode\u5b57\u7b26\u4e32\u8f6c\u4e3a\u4e2d\u6587\uff0c\u4ec5\u9650\u4e8eDebug\u73af\u5883";
    NSDictionary *responseDic = @{@"unicode" : unicodeString};
    NSArray *testArray = @[infoString];
    NSLog(@"responseDic = responseDic%@\ntestArray = %@\n", responseDic, testArray);
}


@end
