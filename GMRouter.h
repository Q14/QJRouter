//
//  GMRouter.h
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

//#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GMRouterParamsKeySwiftTargetModuleName;

@interface GMRouter : NSObject
+ (instancetype)sharedInstance;

// 远程App调用入口 universalLink
- (id)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;

// 本地组件调用入口
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

@end

NS_ASSUME_NONNULL_END
