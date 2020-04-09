//
//  GMRouter+gm.m
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

#import "QJRouter+gm.h"
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

/**
 增加一个魔块 需要在路由做映射
 */
NSString *const GMRouterTargetAI = @"Target_AI";
NSString *const GMRouterTargetBanking = @"Target_Banking";
NSString *const GMRouterTargetCommunity = @"Target_Community";
NSString *const GMRouterTargetWeb = @"Target_Web";

static NSMutableDictionary *routeMap = nil;

@implementation QJRouter (gm)

- (void)initializeRouteMap {
    routeMap = [[NSMutableDictionary alloc] initWithCapacity:50];
    NSArray *arr = @[GMRouterTargetAI, GMRouterTargetBanking, GMRouterTargetCommunity, GMRouterTargetWeb];
    for (NSString *clsStr in arr) {
        NSDictionary *dict = [self getMethods:clsStr];
        [routeMap addEntriesFromDictionary:dict];
    }
}

#pragma mark - 获取类的所有方法
// 获取所有的方法
- (NSDictionary *)getMethods:(NSString *)clsStr {
    Class cls = NSClassFromString(clsStr);
    NSRange range = [clsStr rangeOfString:@"Target_"];
    NSString *targetValue =  [clsStr substringFromIndex:range.length];
    
    NSAssert(targetValue.length != 0, @"Target_后不能为空！请注意Target");
    
    unsigned int count = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // 获取类的所有 Method
    Method *methods = class_copyMethodList([cls class], &count);
    
    for (NSUInteger i = 0; i < count; i ++) {
        
        // 获取方法 Name
        SEL methodSEL = method_getName(methods[i]);
        const char *methodName = sel_getName(methodSEL);
        NSString *name = [NSString stringWithUTF8String:methodName];
        //获取到的是这样的 pushToHospitalDetail: 因此要去掉：
        NSString *rangeStr = @":";
        if ([name containsString:rangeStr]) {
            NSRange range = [name rangeOfString:rangeStr];
            name = [name substringToIndex:range.location];
        }
        // 获取方法的参数列表
        int arguments = method_getNumberOfArguments(methods[i]);
        
        NSString *promoteStr = [NSString stringWithFormat:@"%@-内有重复的方法名-%@", clsStr, name];
        NSAssert(![dict.allKeys containsObject:name], promoteStr);
        
        //因为消息发送的时候会有两个默认的参数（消息接受者和方法名），所以需要减去2
        dict[name] = targetValue;
    }
    
    free(methods);
    return dict;
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
    NSString *encodeUrlScheme = [self URLEncodeString:urlScheme];
    NSURL *url = [NSURL URLWithString:encodeUrlScheme];
    if (!url) {
        //        debugLog(@"协议出错了!");
    }
    NSString *host = url.host;
    NSString *targetName = [routeMap objectForKey:host];
    NSDictionary *params = [self getParams:encodeUrlScheme withHost:host];
    
    host = [self getHostWithEncodeUrlScheme:encodeUrlScheme host:host];
    id vc = [self performTarget:targetName action:host params:params shouldCacheTarget:NO];
    return vc;
}


- (NSDictionary *)getParams:(NSString *)encodeUrlScheme withHost:(NSString *)host {
    NSDictionary *params;
    NSArray *array = [encodeUrlScheme componentsSeparatedByString:@"url="];
    if (([host isEqualToString:@"third_webview"] || [host isEqualToString:@"common_webview"]) && array.count > 1) {
        NSString *value = array[1];
        
        while ([value rangeOfString:@"%"].length != 0) {
            value = [self URLDecodedString:value];
        }
        params = @{@"url":value};
    } else {
        params = [self urlQueryToDictionary:encodeUrlScheme];
    }
    return params;
}

- (NSString *)getHostWithEncodeUrlScheme:(NSString *)encodeUrlScheme host:(NSString *)host {
    NSArray *array = [encodeUrlScheme componentsSeparatedByString:@"url="];
    if (([host isEqualToString:@"third_webview"] || [host isEqualToString:@"common_webview"]) && array.count > 1) {
        NSString *value = array[1];
        while ([value rangeOfString:@"%"].length != 0) {
            value = [ self URLDecodedString:value];
        }
    }
    return host;
}

- (id)pushScheme:(NSString *)urlScheme params:(NSDictionary *)params {
    NSString *encodeUrlScheme = [self URLEncodeString:urlScheme];
    NSURL *url = [NSURL URLWithString:encodeUrlScheme];
    if (!url) {
        //        debugLog(@"协议出错了!");
    }
    NSString *host = url.host;
    NSString *targetName = [routeMap objectForKey:host];
    NSDictionary *paramsDict = [self getParams:encodeUrlScheme withHost:host];
    host = [self getHostWithEncodeUrlScheme:encodeUrlScheme host:host];
    return [self performTarget:targetName action:host params:paramsDict shouldCacheTarget:NO];
}

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


- (NSString *)URLEncodeString:(NSString *)urlStr {
    NSString *encodedString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return encodedString;
}



@end

NSString *enActionFuncName(NSString *actionName){
    return [NSString stringWithFormat:@"%@:",actionName];
}

NSString *deActionFuncName(NSString *action){
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

