//
//  RegisterData.h
//  assistant
//
//  Created by Apple on 15/8/21.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
//static NSString *r_userPhone;
//static NSString *r_userRole;
//static NSString *r_userPwd;
@interface RegisterData : NSObject


+(void)setUserPhone:(NSString *)phone;
+(NSString *)getUserPhone;

+(void)setUserPwd:(NSString *)strPwd;
+(NSString *)getUserPwd;

+(void)setUserRole:(NSString *)role;
+(NSString *)getUserRole;


+(void)setIsLogin:(BOOL)isLogin;
+(BOOL)getIsLogin;


+(void)setIsLabelPwd:(BOOL)isLabel;
+(BOOL)getIsLabel;
@end
