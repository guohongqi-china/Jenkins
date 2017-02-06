//
//  MobAnalytics.h
//  MobAnalytics
//
//  Created by christlee on 16/3/24.
//  Copyright © 2016年 Visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 REALTIME只在“集成测试”设备的DEBUG模式下有效，其它情况下的REALTIME会改为使用BATCH策略。
 */
typedef enum {
    REALTIME = 0,       //实时发送              
    BATCH = 1           //启动发送(包括从后台切换到前台)
} MAReportPolicy;

@interface MobAnalytics : NSObject

#pragma mark - basics

///---------------------------------------------------------------------------------------
/// @name  设置
///---------------------------------------------------------------------------------------
/** 设置是否打印sdk的log信息, 默认NO(不打印log).
 @param value 设置为YES, 会输出log信息可供调试参考. 除非特殊需要，否则发布产品时需改回NO.
 @return void.
 */
+ (void)setLogEnabled:(BOOL)value;

/** 设置是否对日志信息进行加密, 默认NO(不加密).
 @param value 设置为YES, 会将日志信息做加密处理
 @return void.
 */
+ (void)setEncryptEnabled:(BOOL)value;


///---------------------------------------------------------------------------------------
/// @name  开启统计
///---------------------------------------------------------------------------------------

/** 初始化统计模块
 @param appKey appKey.
 @return void
 */
+ (void)startWithAppkey:(NSString *)appKey;

/** 初始化统计模块
 @param appKey appKey.
 @param serverURL 服务器端接口地址
 @return void
 */
+ (void)startWithAppkey:(NSString *)appKey serverURL:(NSString *)serverURL;

/** 初始化统计模块
 @param appKey appKey.
 @param reportPolicy 发送策略, 默认值为：BATCH，即“启动发送”模式
 @return void
 */
+ (void)startWithAppkey:(NSString *)appKey reportPolicy:(MAReportPolicy)rp;

/** 初始化统计模块
 @param appKey appKey.
 @param reportPolicy 发送策略, 默认值为：BATCH，即“启动发送”模式
 @param serverURL 服务器端接口地址
 @return void
 */
+ (void)startWithAppkey:(NSString *)appKey reportPolicy:(MAReportPolicy)rp serverURL:(NSString *)serverURL;

///---------------------------------------------------------------------------------------
/// @name  页面计时
///---------------------------------------------------------------------------------------
/** 自动页面时长统计, 开始记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 @param pageName 统计的页面名称.
 @return void.
 */
+ (void)beginLogPageView:(NSString *)pageName;

/** 自动页面时长统计, 结束记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 @param pageName 统计的页面名称.
 @return void.
 */
+ (void)endLogPageView:(NSString *)pageName;

#pragma mark - event

///---------------------------------------------------------------------------------------
/// @name  事件统计
///---------------------------------------------------------------------------------------
/** 自定义事件,数量统计.
 使用前，请先到APP管理后台的自定义事件->事件管理 中添加相应的事件ID，然后在工程中传入相应的事件ID
 @param  eventId 网站上注册的事件Id.
 @param  label 分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比,为nil或空字符串时后台会生成和eventId同名的标签.
 @param  accumulation 累加值。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数。
 @return void.
 */
+ (void)event:(NSString *)eventId; //等同于 event:eventId label:eventId;

/** 自定义事件,数量统计.
 使用前，请先到APP管理后台的自定义事件->事件管理 中添加相应的事件ID，然后在工程中传入相应的事件ID
 */
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;

#pragma mark - user methods

/** 绑定用户
 @param uid : 登录账号
 @return void.
 */
+ (void)bindUID:(NSString *)uid;

#pragma mark - check update

/** 设置默认方式进行版本更新检查。
 @return void.
 */
+ (void)checkUpdate;

/** 自定义Delegate模式进行版本更新检查
 @param delegate
 @param callBackSelectorWithDictionary 这个方法接收一个(NSDictionary *)类型的参数,是服务器传回来的相关信息
 @return void.
 */
+ (void)checkUpdateWithDelegate:(id)delegate selector:(SEL)callBackSelectorWithDictionary;

@end
