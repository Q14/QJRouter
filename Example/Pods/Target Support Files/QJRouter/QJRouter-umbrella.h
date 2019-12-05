#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GMRouter+gm.h"
#import "GMRouter.h"
#import "NSObject+gmKey.h"
#import "Target_commons.h"
#import "UIViewController+Router.h"

FOUNDATION_EXPORT double QJRouterVersionNumber;
FOUNDATION_EXPORT const unsigned char QJRouterVersionString[];

