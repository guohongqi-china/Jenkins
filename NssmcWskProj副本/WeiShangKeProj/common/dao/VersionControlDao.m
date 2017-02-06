//
//  VersionControlDao.m
//  Sloth
//
//  Created by 焱 孙 on 13-6-26.
//
//

#import "VersionControlDao.h"

@implementation VersionControlDao

-(id)init
{
    self = [super init];
    if(self)
    {
        dbOperator = [SQLiteDBOperator getDBInstance];
    }
    return self;
}

-(VersionControlVo *)getSelfVersionControlInfo
{
    VersionControlVo *versionControlVo = nil;    
    NSString *strSql = [NSString stringWithFormat:@"select * from T_VERSION_CONTROL where COMPANY_ID='%@';",[Common getCurrentUserVo].strCompanyID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData.count>0) 
    {
        NSDictionary *dicData = [aryData objectAtIndex:0];
        versionControlVo = [[VersionControlVo alloc] init];
        versionControlVo.strCompanyID = [dicData objectForKey:@"COMPANY_ID"];
        
        NSString *strTime = [dicData objectForKey:@"USER_UPDATE_TIME"];
        if(strTime == nil || strTime.length==0)
        {
            strTime = @"2000-01-01 12:12:12";
        }
        versionControlVo.strUserUpdateTime = strTime;
    }
    else
    {
        versionControlVo = [[VersionControlVo alloc] init];
        versionControlVo.strCompanyID = [Common getCurrentUserVo].strCompanyID;
        versionControlVo.strUserUpdateTime = @"2000-01-01 12:12:12";
    }
    
    return versionControlVo;
}

//
-(BOOL)updateVersionCtrlLastTime:(NSString*)strLastUpdateTime andType:(TableUpdateType)tableUpdateType
{
    BOOL bRes = NO;
    NSString *strSql = [NSString stringWithFormat:@"select COMPANY_ID from T_VERSION_CONTROL where COMPANY_ID='%@';",[Common getCurrentUserVo].strCompanyID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    NSString *strType = nil;
    
    if (tableUpdateType == UserTableType)
    {
        strType = @"USER_UPDATE_TIME";
    }
    else
    {
        return bRes;
    }
    
    if (aryData == nil || aryData.count == 0)
    {
        //insert
        NSString *strSql = [NSString stringWithFormat:@"insert into T_VERSION_CONTROL (COMPANY_ID,%@) values ('%@','%@')",strType,[Common getCurrentUserVo].strCompanyID,strLastUpdateTime];
        bRes = [dbOperator executeSql:strSql];
    }
    else
    {
        //update
        NSString *strSql = [NSString stringWithFormat:@"update T_VERSION_CONTROL set %@='%@' where COMPANY_ID='%@'",strType,strLastUpdateTime,[Common getCurrentUserVo].strCompanyID];
        bRes = [dbOperator executeSql:strSql];
    }
    return bRes;
}

//check buffer other company data or not
-(BOOL)checkBufferOtherCompanyData
{
    BOOL bRes = NO;
    NSString *strSql = [NSString stringWithFormat:@"select * from T_VERSION_CONTROL where COMPANY_ID<>'%@';",[Common getCurrentUserVo].strCompanyID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData.count>0)
    {
        bRes = YES;
    }
    else
    {
        bRes = NO;
    }
    return bRes;
}

@end
