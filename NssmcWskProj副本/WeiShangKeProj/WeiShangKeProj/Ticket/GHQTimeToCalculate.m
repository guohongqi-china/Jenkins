//
//  GHQTimeToCalculate.m
//  Creative
//
//  Created by MacBook on 16/3/30.
//  Copyright © 2016年 王文静. All rights reserved.
//

#import "GHQTimeToCalculate.h"

@implementation GHQTimeToCalculate

#pragma -----------------毫秒数转换成时间－－－－－－－－－－－－－－－
/**
 *  提供毫秒数  和    时间戳就可以计算出日期时间
 */
+ (NSString *)getTimeFromNumberofmilliseconds:(NSString *)timeFromSM dateFormat:(NSString *)dateFormatString{
//    @"yyyy-MM-dd HH:MM:ss"
    if ([timeFromSM isEqualToString:@" "]) {
        return @" ";
    }
    if (timeFromSM.length == 0 || dateFormatString.length == 0) {
        return @" ";
    }
    NSDate *nd = [NSDate dateWithTimeIntervalSince1970:[timeFromSM longLongValue] / 1000];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:dateFormatString];
    return [dateFormat stringFromDate:nd];

}
/**
 *  判断输入的数字是否是手机号
 */
+ (NSString *)valiMobile:(NSString *)mobile{
    if (mobile.length != 11)
    {
//        [MBProgressHUD showSuccess:@"请输入正确的手机号" toView:nil];
        
        return nil;
    }else{
        
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return mobile;
        }else{
//            [MBProgressHUD showSuccess:@"输入的不是手机" toView:nil];
            return nil;
        }
    }
    return mobile;
}
/**
 * 检测是否为空
 */
+(NSString*)checkStrValue:(NSString*)strValue
{
    if (strValue.length == 0 || (id) strValue == [NSNull null] || strValue == nil)
    {
        strValue = @" ";
    }
    return strValue;
}
+(NSInteger)GetNSIntegerFromStrValue:(NSString*)strValue
{
    if (strValue == nil || (id) strValue == [NSNull null])
    {
        strValue = @" ";
    }
    return [strValue integerValue];
    
}

+ (void)UIKeyboardWillChangeFrameNotification:(id)tagetSelf selector:(SEL)selectorAction name:(NSString *)UIKEYNAME{
  
    [[NSNotificationCenter defaultCenter]addObserver:tagetSelf selector:selectorAction name:UIKEYNAME object:nil];
    
}

- (void)selectorAction:(NSNotification *)Notification VIEW:(id)allKindsOfView distanceToTop:(NSInteger)nsinteger{
    
    //获取键盘结束的Frame
    CGRect kbEndFrame = [Notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //获取键盘结束时的起始坐标
    CGFloat kbEndY = kbEndFrame.origin.y;
    
    if (kbEndY ==  555) {
        
        //当再次点击returen时，键盘消失执行以下方法
        kbEndY = 0;
        [allKindsOfView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }else{
        
        [allKindsOfView setContentOffset:CGPointMake(0,  kbEndFrame.size.height - nsinteger) animated:YES];
        
    }
    
}
+ (void)alllll:(CGFloat)nsinter notifer:(NSNotification *)notifier cgf:(CGFloat)ffff TABLEVIEW:(id)TABLEVIEW{
    if (11 == nsinter) {
        [[GHQTimeToCalculate alloc] selectorAction:notifier VIEW:TABLEVIEW distanceToTop:ffff];
    }
   
}

+ (void)notifer:(NSNotification *)NOTIFICATION TABLEVIEW:(id)TABLEVIEW ARRAY:(NSArray *)ARRAY{
    [self alllll:480.0 notifer:NOTIFICATION cgf:[ARRAY[0] floatValue] TABLEVIEW:TABLEVIEW];
    [self alllll:568.0 notifer:NOTIFICATION cgf:[ARRAY[1] floatValue] TABLEVIEW:TABLEVIEW];
    [self alllll:667.0 notifer:NOTIFICATION cgf:[ARRAY[2] floatValue] TABLEVIEW:TABLEVIEW];
    [self alllll:736.0 notifer:NOTIFICATION cgf:[ARRAY[3] floatValue] TABLEVIEW:TABLEVIEW];

}


@end
