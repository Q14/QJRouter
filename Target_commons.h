//
//  Target_commons.h
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GMRouterTargetCommons;
@interface Target_commons : NSObject
// 自定义push方法
- (UIViewController *)push_CommonViewController:(NSString *)stringVCName params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
