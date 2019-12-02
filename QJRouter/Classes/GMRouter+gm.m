//
//  GMRouter+gm.m
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

#import "GMRouter+gm.h"
#import <objc/message.h>

//nsstring
static inline BOOL verifiedString(id strlike) {
    if (strlike && ![strlike isEqual:[NSNull null]] && [[strlike class] isSubclassOfClass:[NSString class]] && ((NSString*)strlike).length > 0) {
        return YES;
    }else{
        return NO;
    }
}

NSString *const GMRouterActionPrefix = @"Action_";
NSString *const GMRouterActionSuffix = @":";
NSString *const GMRouterTargetPrefix = @"Target_";

NSMapTable *routeMap = nil;
@implementation GMRouter (gm)
- (id)performAction:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget{
    
    NSString *selName = @"createVC:";
    NSString *sel = [routeMap objectForKey:actionName];
    if (verifiedString(sel)) selName = sel;
    
    return [self performAction:actionName dstSel:selName params:params shouldCacheTarget:shouldCacheTarget];
}

- (id)performAction:(NSString *)actionName dstSel:(NSString *)dstSelName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget{
    
    Class class = NSClassFromString(actionName);
    SEL sel = NSSelectorFromString(dstSelName);
    IMP imp = [class instanceMethodForSelector:sel];
    if (!imp || imp == _objc_msgForward) {
        imp = [class methodForSelector:sel];
    }
    SEL selector = NSSelectorFromString(enActionFuncName(actionName));
    
    Class targetCls = NSClassFromString([NSString stringWithFormat:@"%@%@",GMRouterTargetPrefix,GMRouterTargetCommons]);
    
    if (!class_respondsToSelector(targetCls, selector)) {
        BOOL flag = class_addMethod(targetCls, selector, imp, "@@:@");
        if (!flag) {
            return nil;
        }
    }
    
    id action = [self performTarget:GMRouterTargetCommons action:actionName params:params shouldCacheTarget:shouldCacheTarget];
    
    if (![action isKindOfClass:class]) {
        
        Class class = NSClassFromString(@"ErrorViewController");
        UIViewController *vc = [[class alloc] init];
        return vc;
    }else {
        
        return [action isKindOfClass:class] ? action : nil;
    }
}

@end

NSString *enActionFuncName(NSString *actionName){
    return [NSString stringWithFormat:@"%@%@:",GMRouterActionPrefix,actionName];
}

NSString *deActionFuncName(NSString *action){
    //    NSString *prefix = @"Action_";
    //    NSString *suffix = @":";TargetCommons
    if ([action hasPrefix:GMRouterActionPrefix] &&
        [action hasSuffix:GMRouterActionSuffix]) {
        return [action substringWithRange:NSMakeRange(GMRouterActionPrefix.length, action.length - GMRouterActionPrefix.length - GMRouterActionSuffix.length)];
    }
    return action;
}

Class getClassFromAtcion(SEL sel){
    return NSClassFromString(deActionFuncName(NSStringFromSelector(sel)));
}

void registerSelectorToMediator(NSString *clsName,NSString *selName){
    if (!routeMap) {
        routeMap = [NSMapTable new];
    }
    [routeMap setObject:selName forKey:clsName];
}

void removeSelectorToMediator(NSString *clsName){
    [routeMap removeObjectForKey:clsName];
}

