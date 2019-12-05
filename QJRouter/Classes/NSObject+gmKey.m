//
//  NSObject+gmKey.m
//  MJExtension
//
//  Created by Q14 on 2019/12/4.
//

#import "NSObject+gmKey.h"
#import <MJExtension/MJExtension.h>

@implementation NSObject (gmKey)
+ (id)mj_replacedKeyFromPropertyName121:(NSString *)propertyName {
    return [propertyName mj_underlineFromCamel];
}
@end
