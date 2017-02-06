//
//  LoginUserVo.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-10-25.
//
//

#import <Foundation/Foundation.h>

@interface LoginUserVo : NSObject

@property (nonatomic, retain) NSString *strUserID;              //用户ID
@property (nonatomic, retain) NSString *strUserAccount;         //登录账户
@property (nonatomic, retain) NSString *strPwd;                 //密码
@property (nonatomic, retain) NSString *strEmail;               //邮箱
@property (nonatomic, retain) NSString *strLastLoginTime;       //上次登录时间
@property (nonatomic, assign) int nIsRemember;                  //是否记住密码    1:记住，0：不记住

@end
