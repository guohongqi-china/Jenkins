//
//  GHQTimeToCalculate.h
//  Creative
//
//  Created by MacBook on 16/3/30.
//  Copyright © 2016年 王文静. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHQTimeToCalculate : NSObject

@property (nonatomic, strong) id allView;/** <#注释#> */
/**
 *  提供毫秒数  和    时间戳就可以计算出日期时间
 */
+ (NSString *)getTimeFromNumberofmilliseconds:(NSString *)timeFromSM dateFormat:(NSString *)dateFormatString;
/**
 *  判断输入的数字是否是手机号
 */
+ (NSString *)valiMobile:(NSString *)mobile;
/**
 * 判断字符串是否为空
 */
+(NSString*)checkStrValue:(NSString*)strValue;
/**
 * 给出一个字符串输出数字，如果为空就返回@“ ”
 */
+(NSInteger)GetNSIntegerFromStrValue:(NSString*)strValue;
/**
 * 视图跟随键盘位置发生变化
 */
+ (void)UIKeyboardWillChangeFrameNotification:(id)tagetSelf selector:(SEL)selectorAction name:(NSString *)UIKEYNAME;
+ (void)notifer:(NSNotification *)NOTIFICATION TABLEVIEW:(id)TABLEVIEW ARRAY:(NSArray *)ARRAY;

@end
