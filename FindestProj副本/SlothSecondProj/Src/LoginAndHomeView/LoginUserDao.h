//
//  LoginUserDao.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-10-25.
//
//

#import <Foundation/Foundation.h>
#import "LoginUserVo.h"
#import "SQLiteDBOperator.h"

@interface LoginUserDao : NSObject
{
    SQLiteDBOperator *dbOperator;
}

//根据账号获取用户信息
- (LoginUserVo *)getUserByID:(NSString *)strUserID;

//保存登录用户
- (BOOL)insertUser:(LoginUserVo *)user;

//更新登录用户
- (BOOL)updateUser:(LoginUserVo *)user;

- (BOOL)updateUserRememberPwdState:(int)nIsRemember andUserID:(NSString*)strUserID;

- (LoginUserVo *)getLastLoginUser;

- (void)deleteAllLoginUser;

@end
