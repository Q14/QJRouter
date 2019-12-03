//
//  GMRouter+gm.h
//  GMRouter
//
//  Created by Q14 on 2019/11/28.
//

#import "GMRouter.h"
#import "Target_commons.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * 将函数名称编码成CTMediator能解析的方法名称
 *
 */
NSString *enActionFuncName(NSString *actionName);
/**
 * 通过函数名称解析出类的名称
 *
 */
NSString *deActionFuncName(NSString *action);

/**
 * 通过SEL参数解析出类的实例
 *
 */
Class getClassFromAtcion(SEL sel);

//extern NSString *const kCTMediatorClassName;
/**
 * 注册自定义的创建vc函数名称
 *
 */
void registerSelectorToMediator(NSString *clsName,NSString *selName);

/**
 * 删除自定义的创建vc函数名称
 *
 */
void removeSelectorToMediator(NSString *clsName);


@interface GMRouter (gm)

/**
* 通过vc类的名字创建vc,默认的vc创建函数为createVC:
*
* @param actionName vc类名称
*
* @param params 创建vc初始化要传递的参数
*
* @param shouldCacheTarget 是否需要缓存target，一般传NO
*
* @return vc的实例
*
*/
- (id)performAction:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;

/**
 * 通过vc类的名字创建vc
 *
 * @param actionName vc类名称
 *
 * @param dstSelName vc中实现的创建vc的函数，不要在这个方法中使用self关键字，获取当前类名则
 * 通过使用getClassFromAtcion(_cmd)来获取
 *
 * @param params 创建vc初始化要传递的参数
 *
 * @param shouldCacheTarget 是否需要缓存target，一般传NO
 *
 * @return vc的实例
 *
 */
- (id)performAction:(NSString *)actionName dstSel:(NSString *)dstSelName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;




/**
* 通过vc类的名字创建vc 兼容项目中的更美协议
*
* @param urlScheme 协议名字 * 例如gengmei://welfare_special?service_id=5930&is_new_special=0
*
*
*
* @return vc的实例
*
*/
- (id)pushScheme:(NSString *)urlScheme;



/**
 * 通过vc类的名字创建vc
 *
 * @param urlScheme vc类名称
 * 例如gengmei://welfare_special

 * @param dstSelName vc中实现的创建vc的函数，不要在这个方法中使用self关键字，获取当前类名则
 *
 * @param params 创建vc初始化要传递的参数
 * {@"service_id": @"5930",@"is_new_special": @0} 
 *
 * @return vc的实例
 *
 */
- (id)pushScheme:(NSString *)urlScheme dstSel:(NSString *)dstSelName params:(NSDictionary *)params ;
@end

NS_ASSUME_NONNULL_END
