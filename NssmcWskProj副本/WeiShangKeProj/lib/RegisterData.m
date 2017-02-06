//
//  RegisterData.m
//  assistant
//
//  Created by Apple on 15/8/21.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "RegisterData.h"

static NSString *r_userPhone;
static NSString *r_userRole;
static NSString *r_userPwd;
static BOOL r_isLogin = NO;
static BOOL r_isLabel = NO;
@implementation RegisterData


+(void)setIsLabelPwd:(BOOL)isLabel
{
    r_isLabel = isLabel;
}
+(BOOL)getIsLabel
{

    return r_isLabel;
}
+(void)setIsLogin:(BOOL)isLogin
{
    
    r_isLogin = isLogin;
}
+(BOOL)getIsLogin
{
    
    return r_isLogin;
}

+(void)setUserPhone:(NSString *)phone
{

    if (r_userPhone != phone)
    {
        r_userPhone = [phone copy];
    }
}
+(NSString *)getUserPhone
{

    return r_userPhone;
}

+(void)setUserPwd:(NSString *)strPwd
{
    if (r_userPwd != strPwd)
    {
        r_userPwd = [strPwd copy];
    }
}
+(NSString *)getUserPwd
{
    return r_userPwd;
}

+(void)setUserRole:(NSString *)role
{
    if (r_userRole != role)
    {
        r_userRole = [role copy];
    }
}
+(NSString *)getUserRole
{
    return r_userRole;
}
@end
