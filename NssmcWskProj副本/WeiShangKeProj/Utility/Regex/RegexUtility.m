//
//  RegexUtility.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/18.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RegexUtility.h"

@implementation RegexUtility

+ (BOOL)validateMobile:(NSString *)strMobilePhone
{
    //手机号以13，15，17，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[0-9])|(17[0-9])|(18[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:strMobilePhone];
}

+ (BOOL)validateEmail:(NSString *)strEmail
{
    //手机号以13，15，17，18开头，八个 \d 数字字符
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

//身份证号
+ (BOOL)validateIdentityCard:(NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

//网址检测
+(BOOL)validateURL:(NSString *)strURL
{
    BOOL flag;
    if (strURL.length <= 0)
    {
        flag = NO;
        return flag;
    }
    //NSString *regex2 = @"^https?://(([a-zA-z0-9]|-){1,}\\.){1,}[a-zA-z0-9]{1,}-*$";
    //NSString *regex2 = @"^https?://(\\w)*$";//http://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?
    NSString *regex2 = @"^(h|H)(t|T)(t|T)(p|P)(s|S)?://.*$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:strURL];
}

@end
