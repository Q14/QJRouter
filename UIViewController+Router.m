//
//  UIViewController+Router.m
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

#import "UIViewController+Router.h"
#import "GMRouter+gm.h"

@implementation UIViewController (Router)
- (id)createVC:(NSDictionary *)dict{
    
    Class class = getClassFromAtcion(_cmd);
    if (class) {
        
        UIViewController *doc = self;
        doc = [[class alloc]init];
//        doc = [doc mj_setKeyValues:dict];
        return doc;
    }
    return nil;
}

@end
