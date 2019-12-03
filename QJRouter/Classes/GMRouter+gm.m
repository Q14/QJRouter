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

static NSMutableDictionary *routeMap = nil;
@implementation GMRouter (gm)

+ (void)initialize {
    //私有库中只能这样写
    NSBundle *bundle = [NSBundle bundleForClass:[GMRouter class]];
    NSURL *bundleURL = [bundle URLForResource:@"QJRouter" withExtension:@"bundle"];
    NSBundle *plistBundle = [NSBundle bundleWithURL:bundleURL];
    NSURL *plistUrl = [plistBundle URLForResource:@"gm_router" withExtension:@"plist"];
    if (!routeMap) {
       routeMap = [[NSMutableDictionary alloc] initWithContentsOfURL:plistUrl];
    }
}

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





- (id)pushScheme:(NSString *)urlScheme {
    NSString *encodeUrlScheme = [self URLDecodedString:urlScheme];
    NSURL *url = [NSURL URLWithString:encodeUrlScheme];
    if (!url) {
//        debugLog(@"协议出错了!");
    }

    NSString *host = url.host;
    NSDictionary *dict = [routeMap objectForKey:host];
    NSString *sel = dict[@"sel"];
    NSString *targetName = dict[@"target"];
    NSDictionary *params = [self urlQueryToDictionary:encodeUrlScheme];

    return [self performTarget:targetName action:sel params:params shouldCacheTarget:NO];
}

- (id)pushScheme:(NSString *)urlScheme dstSel:(NSString *)dstSelName params:(NSDictionary *)params {
    NSDictionary *dict = [routeMap objectForKey:urlScheme];
    NSString *sel = dict[@"sel"];
    NSString *targetName = dict[@"target"];
    return [self performTarget:targetName action:sel params:params shouldCacheTarget:NO];
}

//- (id)performAction:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget{
//
//    NSString *selName = @"createVC:";
//    NSString *sel = [routeMap objectForKey:actionName];
//    if (verifiedString(sel)) selName = sel;
//
//    return [self performAction:actionName dstSel:selName params:params shouldCacheTarget:shouldCacheTarget];
//}

//- (id)performAction:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget{
//
////    NSString *selName = @"createVC:";
////    NSString *sel = [routeMap objectForKey:actionName];
////    if (verifiedString(sel)) selName = sel;
//
////    return [self performAction:actionName dstSel:selName params:params shouldCacheTarget:shouldCacheTarget];
//
//    NSString *selName = @"createVC:";
//    NSDictionary *dict = [routeMap objectForKey:actionName];
//    NSString *sel = dict[@"sel"];
//    NSString *targetName = dict[@"target"];
//    NSString *vc = dict[@"vc"];
//    if (verifiedString(sel)) selName = sel;
//    return [self performTarget:targetName Action:vc dstSel:selName params:params shouldCacheTarget:NO];
//}
//
//- (id)performTarget:(NSString *)target Action:(NSString *)actionName dstSel:(NSString *)dstSelName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget {
//
//    Class class = NSClassFromString(actionName);
//    SEL sel = NSSelectorFromString(dstSelName);
//    IMP imp = [class instanceMethodForSelector:sel];
//    if (!imp || imp == _objc_msgForward) {
//        imp = [class methodForSelector:sel];
//    }
//    SEL selector = NSSelectorFromString(enActionFuncName(dstSelName));
//    Class targetCls;
//    if (NSClassFromString(target)) {
//        targetCls = NSClassFromString(target);
//    } else {
//        targetCls = NSClassFromString([NSString stringWithFormat:@"%@%@",GMRouterTargetPrefix,GMRouterTargetCommons]);
//    }
//    if (!class_respondsToSelector(targetCls, selector)) {
//        BOOL flag = class_addMethod(targetCls, selector, imp, "@@:@");
//        if (!flag) {
//            return nil;
//        }
//    }
//
//    id action = [self performTarget:target action:dstSelName params:params shouldCacheTarget:shouldCacheTarget];
//
//    if (![action isKindOfClass:class]) {
//
//        Class class = NSClassFromString(@"ErrorViewController");
//        UIViewController *vc = [[class alloc] init];
//        return vc;
//    } else {
//        return [action isKindOfClass:class] ? action : nil;
//    }
//}
//

#pragma mark - string to dict
- (NSDictionary*)urlQueryToDictionary:(NSString *)urlScheme {
    NSURL* url1 = [NSURL URLWithString:urlScheme];
    if (!url1) {
        return nil;
    }
    NSString *query = [url1 query];
    return [self queryToDictionary:query];
}

- (NSDictionary*)queryToDictionary:(NSString *)query {
    @try {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSArray* components = [query componentsSeparatedByString:@"&"];
        for (NSString* component in components) {
            NSArray* keyValue = [component componentsSeparatedByString:@"="];
            if ([keyValue count] > 1) {
                NSString * key = [self URLDecodedString:[keyValue objectAtIndex:0]];
                NSString * value = [keyValue objectAtIndex:1];
                
                //参数中依然包含超过2个“=”号（多数发生在common_webview后的url参数中），则后面的数组的元素需要拼接成一个字符串
                if ([keyValue count]>2) {
                    for (int i=2; i<[keyValue count]; i++) {
                        value=[value stringByAppendingString:@"="];
                        value=[value stringByAppendingString:keyValue[i]];
                    }
                }
                
                //因为这种情况服务器和客户端都转义了一次，所以要两次反转义还原中文
                while ([value rangeOfString:@"%"].length != 0) {
                    value = [self URLDecodedString:value];
                }
                [dict setObject: value forKey: key];
            }
        }
        return dict;
    }
    @catch (NSException *exception) {}
}

- (NSString*)URLDecodedString:(NSString *)urlStr {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)urlStr,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}




@end

NSString *enActionFuncName(NSString *actionName){
    return [NSString stringWithFormat:@"%@:",actionName];
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
        routeMap = [[NSMutableDictionary alloc] init];
    }
    [routeMap setObject:selName forKey:clsName];
}

void removeSelectorToMediator(NSString *clsName){
    [routeMap removeObjectForKey:clsName];
}

