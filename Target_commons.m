//
//  Target_commons.m
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

#import "Target_commons.h"

NSString * const GMRouterTargetCommons = @"commons";

@implementation Target_commons

// 自定义push方法
- (UIViewController *)push_CommonViewController:(NSString *)stringVCName params:(NSDictionary *)params {
        // 因为action是从属于ModuleA的，所以action直接可以使用ModuleA里的所有声明
        Class class = NSClassFromString(stringVCName);
        UIViewController *controller = [[class alloc] init];
        return controller;
}

@end
