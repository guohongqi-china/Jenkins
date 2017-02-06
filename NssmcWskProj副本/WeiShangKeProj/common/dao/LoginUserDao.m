//
//  LoginUserDao.m
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-10-25.
//
//

#import "LoginUserDao.h"

@implementation LoginUserDao

-(id)init
{
    self = [super init];
    if(self)
    {
        dbOperator = [SQLiteDBOperator getDBInstance];
    }
    return self;
}

//根据账号获取用户信息
- (LoginUserVo *)getUserByID:(NSString *)strUserID
{
    NSString *strSql = [NSString stringWithFormat:@"SELECT * FROM T_LOGIN_USER WHERE USER_ID='%@'",strUserID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    LoginUserVo *model = nil;
    
    if (aryData.count>0) 
    {
        NSDictionary *dicData = [aryData objectAtIndex:0];
        model = [[LoginUserVo alloc] init];
        model.strUserID = [dicData objectForKey:@"USER_ID"];
        model.strUserAccount = [dicData objectForKey:@"USER_ACCOUNT"];
        model.strPwd = [dicData objectForKey:@"PASSWORD"];
        model.strEmail = [dicData objectForKey:@"USER_EMAIL"];
        model.strLastLoginTime = [dicData objectForKey:@"LAST_LOGIN_TIME"];
        model.nIsRemember = [[dicData objectForKey:@"IS_REMEMBER"]intValue];
    }
    return model;    
}

//保存登录用户
- (BOOL)insertUser:(LoginUserVo *)user
{
    //1.删除所有已登录用户信息
    [self deleteAllLoginUser];
    
    //2.插入新的登录用户
    NSString *strSql = [NSString stringWithFormat:@"INSERT INTO T_LOGIN_USER (USER_ID,USER_ACCOUNT,PASSWORD,USER_EMAIL,LAST_LOGIN_TIME,IS_REMEMBER) VALUES ('%@','%@','%@','%@','%@',%i)",
                        user.strUserID,user.strUserAccount,user.strPwd,user.strEmail,user.strLastLoginTime,user.nIsRemember];
    return [dbOperator executeSql:strSql];
}

//更新登录用户
- (BOOL)updateUser:(LoginUserVo *)user
{
    NSString *strSql = [NSString stringWithFormat:@"UPDATE T_LOGIN_USER SET USER_ACCOUNT='%@',PASSWORD='%@',USER_EMAIL='%@',LAST_LOGIN_TIME='%@',IS_REMEMBER=%i WHERE USER_ID='%@'",
                        user.strUserAccount,user.strPwd,user.strEmail,user.strLastLoginTime,user.nIsRemember,user.strUserID];
    return [dbOperator executeSql:strSql];
}

//更新登录用户 IS_AUTO_LOGIN State
- (BOOL)updateUserRememberPwdState:(int)nIsRemember andUserID:(NSString*)strUserID
{
    NSString *strSql = [NSString stringWithFormat:@"UPDATE T_LOGIN_USER SET IS_REMEMBER=%i WHERE USER_ID='%@'",nIsRemember,strUserID];
    return [dbOperator executeSql:strSql];
}

//获取最后一次登录的用户
- (LoginUserVo *)getLastLoginUser
{
    NSString *strSql = @"SELECT * FROM T_LOGIN_USER ORDER BY LAST_LOGIN_TIME DESC";
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    LoginUserVo *model = nil;
    
    if (aryData.count>0) 
    {
        NSDictionary *dicData = [aryData objectAtIndex:0];
        model = [[LoginUserVo alloc] init];
        model.strUserID = [dicData objectForKey:@"USER_ID"];
        model.strUserAccount = [dicData objectForKey:@"USER_ACCOUNT"];
        model.strPwd = [dicData objectForKey:@"PASSWORD"];
        model.strEmail = [dicData objectForKey:@"USER_EMAIL"];
        model.strLastLoginTime = [dicData objectForKey:@"LAST_LOGIN_TIME"];
        model.nIsRemember = [[dicData objectForKey:@"IS_REMEMBER"]intValue];
    }
    return model;    
}

- (void)deleteAllLoginUser
{
    NSString *strSql = @"delete from T_LOGIN_USER";
    [dbOperator executeSql:strSql];
}

@end
