//
//  RegexUtility.h
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/18.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegexUtility : NSObject

+ (BOOL)validateMobile:(NSString *)strMobilePhone;
+ (BOOL)validateEmail:(NSString *)strEmail;
//身份证号
+ (BOOL)validateIdentityCard:(NSString *)identityCard;
//网址检测
+(BOOL)validateURL:(NSString *)strURL;

@end
