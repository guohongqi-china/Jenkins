//
//  GroupDao.m
//  Sloth
//
//  Created by 焱 孙 on 13-6-24.
//
//

#import "GroupAndUserDao.h"
#import "VersionControlDao.h"
#import "VersionControlVo.h"
#import "ChatObjectVo.h"
#import "UserVo.h"
#import "ServerURL.h"
#import "ChineseToPinyin.h"

@implementation GroupAndUserDao

-(id)init
{
    self = [super init];
    if(self)
    {
        dbOperator = [SQLiteDBOperator getDBInstance];
    }
    return self;
}

-(NSMutableArray*)getGroupChatUserList:(NSMutableArray*)aryUser
{
    NSMutableArray *aryDBUser = [NSMutableArray array];
    if(aryUser != nil && aryUser.count>0)
    {
        NSMutableString *strIDList = [NSMutableString string];
        for(int i=0;i<aryUser.count-1;i++)
        {
            UserVo *userVo = aryUser[i];
            [strIDList appendFormat:@"'%@',",userVo.strUserID];
        }
        UserVo *userVo = aryUser[aryUser.count-1];
        [strIDList appendFormat:@"'%@'",userVo.strUserID];
        
        
        NSString *strSql = [NSString stringWithFormat:@"select * from T_USER where USER_ID IN (%@) and USER_ID<>'%@' ;",strIDList,[Common getCurrentUserVo].strUserID];
        
        NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
        if (aryData.count>0)
        {
            for (int i=0; i<aryData.count; i++)
            {
                NSDictionary *dicData = [aryData objectAtIndex:i];
                UserVo *model         = [[UserVo alloc] init];
                model.strUserID       = [dicData objectForKey:@"USER_ID"];
                model.strLoginAccount = [dicData objectForKey:@"LOGIN_ACCOUNT"];
                model.strRealName     = [dicData objectForKey:@"USER_NAME"];
                model.strHeadImageURL = [ServerURL getWholeURL:[dicData objectForKey:@"IMG_URL"]];

                model.strEmail        = [dicData objectForKey:@"USER_EMAIL"];
                
                model.gender         = [[dicData objectForKey:@"GENDER"]stringValue];
                model.strPosition    = [dicData objectForKey:@"POSITION"];
                model.strCompanyID   = [dicData objectForKey:@"COMPANY_ID"];
                model.strCompanyName = [dicData objectForKey:@"COMPANY_NAME"];
                model.strPhoneNumber = [dicData objectForKey:@"PHONE_NUM"];

                model.bViewPhone     = ([[dicData objectForKey:@"VIEW_PHONE"]intValue]==1)?YES:NO;
                model.strBirthday    = [dicData objectForKey:@"BIRTHDAY"];
                model.strJP          = [dicData objectForKey:@"NAME_JP"];
                model.strQP          = [dicData objectForKey:@"NAME_QP"];
                [aryDBUser addObject:model];
            }
        }
    }
    return aryDBUser;
}

//获取缓存的用户(参数：是否不包含自己)
-(NSMutableArray*)getDBUserList:(BOOL)bIsIncludeSelf
{
    NSMutableArray *aryUser = [NSMutableArray array];    
    NSString *strSql = @"select * from T_USER where RECORD_STATUS=0";
    if (!bIsIncludeSelf)
    {
        //不包含自己
        strSql = [NSString stringWithFormat:@"%@ and USER_ID<>'%@' ",strSql,[Common getCurrentUserVo].strUserID];
    }
    
    strSql = [strSql stringByAppendingString:@" order by NAME_JP ASC;"];
    
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData.count>0) 
    {
        for (int i=0; i<aryData.count; i++)
        {
            NSDictionary *dicData = [aryData objectAtIndex:i];
            UserVo *model = [[UserVo alloc] init];
            model.strUserID = [dicData objectForKey:@"USER_ID"];
            model.strLoginAccount = [dicData objectForKey:@"LOGIN_ACCOUNT"];
            model.strRealName = [dicData objectForKey:@"USER_NAME"];
            model.strHeadImageURL = [ServerURL getWholeURL:[dicData objectForKey:@"IMG_URL"]];
            
            model.strEmail = [dicData objectForKey:@"USER_EMAIL"];
            
            model.gender = [[dicData objectForKey:@"GENDER"]stringValue];
            model.strPosition = [dicData objectForKey:@"POSITION"];
            model.strCompanyID = [dicData objectForKey:@"COMPANY_ID"];
            model.strCompanyName = [dicData objectForKey:@"COMPANY_NAME"];
            model.strPhoneNumber = [dicData objectForKey:@"PHONE_NUM"];
            
            model.bViewPhone = ([[dicData objectForKey:@"VIEW_PHONE"]intValue]==1)?YES:NO;
            model.strBirthday = [dicData objectForKey:@"BIRTHDAY"];
            model.strJP = [dicData objectForKey:@"NAME_JP"];
            model.strQP = [dicData objectForKey:@"NAME_QP"];
            
            [aryUser addObject:model];
        }
    }
    return aryUser;
}

//获取用户（即时聊天搜索）
-(NSMutableArray*)getChatUserList
{
    NSMutableArray *aryUser = [NSMutableArray array];    
    //union查询，列名采用第一个查询作
    NSString *strSql = [NSString stringWithFormat:@"select * from T_USER where RECORD_STATUS=0 and USER_ID<>'%@' order by NAME_JP ASC;",[Common getCurrentUserVo].strUserID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData.count>0) 
    {
        for (int i=0; i<aryData.count; i++)
        {
            NSDictionary *dicData = [aryData objectAtIndex:i];
            ChatObjectVo *model = [[ChatObjectVo alloc] init];
            model.strVestID = [dicData objectForKey:@"USER_ID"];
            model.strNAME = [dicData objectForKey:@"USER_NAME"];
            model.strIMGURL = [ServerURL getWholeURL:[dicData objectForKey:@"IMG_URL"]];
            model.strLastChatCon = [dicData objectForKey:@"POSITION"];
            model.strJP = [dicData objectForKey:@"NAME_JP"];
            model.strQP = [dicData objectForKey:@"NAME_QP"];
            model.nType = 1;
            [aryUser addObject:model];
        }
    }
    return aryUser;
}

//获取群组数据
-(NSMutableArray*)getGroupListByType:(GroupListType)groupListType
{
    NSMutableString *strSql = [[NSMutableString alloc] init];
    [strSql setString:@"select * from T_GROUP "];
    if (groupListType == GroupListAllType)
    {
        [strSql appendString:@"order by GROUP_TYPE asc,GROUP_NAME asc"];
    }
    else if (groupListType == GroupListCreatedType)
    {
        [strSql appendString:@"where GROUP_TYPE = 1 order by GROUP_NAME asc"];
    }
    else if (groupListType == GroupListJoinedType)
    {
        [strSql appendString:@"where GROUP_TYPE = 1 OR GROUP_TYPE = 2 order by GROUP_NAME asc"];
    }
    else if (groupListType == GroupListOtherType)
    {
        [strSql appendString:@"where GROUP_TYPE = 3 order by GROUP_NAME asc"];
    }
    else if (groupListType == GroupListCouldSendType)
    {
        [strSql appendString:@"where (IS_MEMBER = 1 or ALLOW_SEND_MSG = 1) order by GROUP_NAME asc"];
    }

    NSMutableArray *aryGroupList = [NSMutableArray array];
    NSArray *aryGroupDic = [dbOperator QueryInfoFromSQL:strSql];
    if (aryGroupDic.count>0)
    {
        for (int i=0; i<aryGroupDic.count; i++)
        {
            NSDictionary *dicData = [aryGroupDic objectAtIndex:i];
            GroupVo *model = [[GroupVo alloc] init];
            model.strGroupID = [dicData objectForKey:@"GROUP_ID"];
            model.strGroupName = [dicData objectForKey:@"GROUP_NAME"];
            model.nAllowSee = [[dicData objectForKey:@"ALLOW_SEND_MSG"]intValue];
            model.nAllowJoin = [[dicData objectForKey:@"ALLOW_JOIN"]intValue];
            model.nIsGroupMember = [[dicData objectForKey:@"IS_MEMBER"]intValue];
            model.nGroupType = [[dicData objectForKey:@"GROUP_TYPE"]intValue];
            model.strCreatorID = [dicData objectForKey:@"CREATOR_ID"];
            model.strCreatorName = [dicData objectForKey:@"CREATOR_NAME"];
            model.strMemListJSON = [dicData objectForKey:@"MEMBER_LIST_JSON"];
            model.aryMemberVo = [self getUserVoListByJSON:model.strMemListJSON];
            
            model.strMemberNum = [dicData objectForKey:@"MEMBER_NUM"];
            model.strJP = [dicData objectForKey:@"NAME_JP"];
            model.strQP = [dicData objectForKey:@"NAME_QP"];
            model.bIsExpanded = NO;
            [aryGroupList addObject:model];
        }
    }
    return aryGroupList;
}

//获取单个群组详情
-(GroupVo*)getGroupVoByID:(NSString*)strID
{
    NSString *strSql = [NSString stringWithFormat:@"select * from T_GROUP where GROUP_ID = '%@'",strID];
    GroupVo *model = nil;
    NSArray *aryGroupDic = [dbOperator QueryInfoFromSQL:strSql];
    if (aryGroupDic.count>0)
    {
        model = [[GroupVo alloc] init];
        NSDictionary *dicData = [aryGroupDic objectAtIndex:0];
        model.strGroupID = [dicData objectForKey:@"GROUP_ID"];
        model.strGroupName = [dicData objectForKey:@"GROUP_NAME"];
        model.nAllowJoin = [[dicData objectForKey:@"ALLOW_JOIN"]intValue];
        model.nAllowSee = [[dicData objectForKey:@"ALLOW_SEND_MSG"]intValue];
        model.nIsGroupMember = [[dicData objectForKey:@"IS_MEMBER"]intValue];
        model.nGroupType = [[dicData objectForKey:@"GROUP_TYPE"]intValue];
        model.strCreatorID = [dicData objectForKey:@"CREATOR_ID"];
        model.strCreatorName = [dicData objectForKey:@"CREATOR_NAME"];
        model.strMemListJSON = [dicData objectForKey:@"MEMBER_LIST_JSON"];
        model.aryMemberVo = [self getUserVoListByJSON:model.strMemListJSON];
        
        model.strMemberNum = [dicData objectForKey:@"MEMBER_NUM"];
        model.strJP = [dicData objectForKey:@"NAME_JP"];
        model.strQP = [dicData objectForKey:@"NAME_QP"];
        model.bIsExpanded = NO;
    }
    return model;
}

-(NSMutableArray*)getUserVoListByJSON:(NSString*)strMemberListJSON
{
    NSMutableArray *aryMemList = [NSMutableArray array];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[strMemberListJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if (error != nil)
    {
        DLog(@"error:%@",error);
        return aryMemList;
    }
    
    NSArray *aryUserListJSON = (NSArray*)jsonObject;
    if ([aryUserListJSON isKindOfClass:[NSArray class]])
    {
        for (int i=0; i<aryUserListJSON.count; i++)
        {
            NSDictionary *dicUserJSON = [aryUserListJSON objectAtIndex:i];
            UserVo *userVo = [[UserVo alloc]init];
            userVo.strUserID = [[dicUserJSON objectForKey:@"id"]stringValue];
            userVo.strRealName = [Common checkStrValue:[dicUserJSON objectForKey:@"aliasName"]];
            userVo.strHeadImageURL = [ServerURL getWholeURL:[Common checkStrValue:[dicUserJSON objectForKey:@"imageUrl"]]];
            //拼音
            NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:userVo.strRealName];
            if(aryPinyin!=nil && aryPinyin.count>0)
            {
                userVo.strQP = [aryPinyin objectAtIndex:0];
                if (aryPinyin.count>1)
                {
                    userVo.strJP = [aryPinyin objectAtIndex:1];
                }
            }
            
            id orgId = [dicUserJSON objectForKey:@"orgId"];
            if (orgId == nil || orgId == [NSNull null])
            {
                userVo.strCompanyID = @"";
            }
            else
            {
                userVo.strCompanyID = [orgId stringValue];
            }
            userVo.strPosition = [Common checkStrValue:[dicUserJSON objectForKey:@"title"]];
            id phoneNumber = [dicUserJSON objectForKey:@"phoneNumber"];
            if (phoneNumber == [NSNull null] || phoneNumber == nil )
            {
                userVo.strPhoneNumber = @"";
            }
            else
            {
                userVo.strPhoneNumber = [phoneNumber stringValue];
            }
            [aryMemList addObject:userVo];
        }
    }
    
    return aryMemList;
}

-(ChatObjectVo*)getUserInfoByUserID:(NSString*)strUserID
{
    ChatObjectVo *tempVo = nil;
    NSString *strSql = [NSString stringWithFormat:@"select USER_NAME,IMG_URL from T_USER where USER_ID='%@'",strUserID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData != nil && aryData.count > 0)
    {
        NSDictionary *dicData = [aryData objectAtIndex:0];
        tempVo = [[ChatObjectVo alloc] init];
        tempVo.strNAME = [dicData objectForKey:@"USER_NAME"];
        tempVo.strIMGURL = [ServerURL getWholeURL:[dicData objectForKey:@"IMG_URL"]];
    }
    return tempVo;
}

-(UserVo*)getUserVoByVestID:(NSString*)strVestID andName:(NSString*)strName
{
    UserVo *userVo = nil;
    NSString *strSuffix = nil;
    if (strVestID != nil && strVestID.length>0)
    {
        strSuffix = [NSString stringWithFormat:@"USER_ID = '%@'",strVestID];
    }
    else if(strName != nil && strName.length>0)
    {
        strSuffix = [NSString stringWithFormat:@"USER_NAME = '%@'",strName];
    }
    else
    {
        return userVo;
    }
    
    NSString *strSql = [NSString stringWithFormat:@"select * from T_USER where %@",strSuffix];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData != nil && aryData.count > 0)
    {
        NSDictionary *dicData = [aryData objectAtIndex:0];
        userVo = [[UserVo alloc] init];
        userVo.strUserID = [dicData objectForKey:@"USER_ID"];
        userVo.strLoginAccount = [dicData objectForKey:@"LOGIN_ACCOUNT"];
        userVo.strRealName = [dicData objectForKey:@"USER_NAME"];
        userVo.strHeadImageURL = [ServerURL getWholeURL:[dicData objectForKey:@"IMG_URL"]];
        userVo.strEmail = [dicData objectForKey:@"USER_EMAIL"];
        
        userVo.gender = [[dicData objectForKey:@"GENDER"]stringValue];
        userVo.strPosition = [dicData objectForKey:@"POSITION"];
        userVo.strCompanyID = [dicData objectForKey:@"COMPANY_ID"];
        userVo.strCompanyName = [dicData objectForKey:@"COMPANY_NAME"];
        userVo.strPhoneNumber = [dicData objectForKey:@"PHONE_NUM"];
        
        userVo.bViewPhone = ([[dicData objectForKey:@"VIEW_PHONE"]intValue]==1)?YES:NO;
        userVo.strBirthday = [dicData objectForKey:@"BIRTHDAY"];
        userVo.strJP = [dicData objectForKey:@"NAME_JP"];
        userVo.strQP = [dicData objectForKey:@"NAME_QP"];
    }
    return userVo;
}

////////////////////////////////////////////////////////////////////////////////////
//用户表insert和update操作
-(BOOL)insertAndUpdateUserData:(UserVo*)userVo
{
    //对插入的值进行判断，包括单引号
    userVo.strLoginAccount = [userVo.strLoginAccount stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strRealName = [userVo.strRealName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strPartImageURL = [userVo.strPartImageURL stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strEmail = [userVo.strEmail stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strPosition = [userVo.strPosition stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    userVo.strCompanyName = [userVo.strCompanyName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strPhoneNumber = [userVo.strPhoneNumber stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strBirthday = [userVo.strBirthday stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strJP = [userVo.strJP stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    userVo.strQP = [userVo.strQP stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    //1.check 
    BOOL bRes = NO;
    NSString *strSql = [NSString stringWithFormat:@"select USER_ID from T_USER where USER_ID='%@'",userVo.strUserID];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:strSql];
    if (aryData == nil || aryData.count == 0)
    {
        //1.insert
        NSString *strSql = [NSString stringWithFormat:@"insert into T_USER (USER_ID,LOGIN_ACCOUNT,USER_NAME,IMG_URL,USER_EMAIL,GENDER,POSITION,COMPANY_ID,COMPANY_NAME,PHONE_NUM,VIEW_PHONE,BIRTHDAY,RECORD_STATUS,NAME_JP,NAME_QP \
                            ) values ('%@','%@','%@','%@','%@',%i,'%@','%@','%@','%@',%i,'%@', %i,'%@','%@')",
                            userVo.strUserID,userVo.strLoginAccount,userVo.strRealName,userVo.strPartImageURL,userVo.strEmail,userVo.gender,userVo.strPosition,userVo.strCompanyID,
                            userVo.strCompanyName,userVo.strPhoneNumber,userVo.bViewPhone?1:0,userVo.strBirthday,userVo.nRecordStatus,userVo.strJP,userVo.strQP];
        bRes = [dbOperator executeSql:strSql];
    }
    else
    {
        //2.update
        NSString *strSql = [NSString stringWithFormat:@"update T_USER set LOGIN_ACCOUNT='%@',USER_NAME='%@',IMG_URL='%@',USER_EMAIL='%@',GENDER=%i,POSITION='%@',COMPANY_ID='%@',\
                            COMPANY_NAME='%@',PHONE_NUM='%@',VIEW_PHONE=%i,BIRTHDAY='%@',RECORD_STATUS=%i,NAME_JP='%@',NAME_QP='%@' where USER_ID='%@'",
                            userVo.strLoginAccount,userVo.strRealName,userVo.strPartImageURL,userVo.strEmail,userVo.gender,userVo.strPosition,userVo.strCompanyID,userVo.strCompanyName,
                            userVo.strPhoneNumber,userVo.bViewPhone?1:0,userVo.strBirthday,userVo.nRecordStatus,userVo.strJP,userVo.strQP,userVo.strUserID];
        bRes = [dbOperator executeSql:strSql];
    }
    return bRes;
}

//群组表不做增量更新（一次性更新，不存在UPDATE）
- (BOOL)insertAndUpdateGroupData:(GroupVo*)groupVo
{
    //对插入的值进行判断，包括单引号
    groupVo.strGroupName = [groupVo.strGroupName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    groupVo.strCreatorName = [groupVo.strCreatorName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    groupVo.strArticleNum = [groupVo.strArticleNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    groupVo.strMemberNum = [groupVo.strMemberNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    groupVo.strMemListJSON = [groupVo.strMemListJSON stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    groupVo.strJP = [groupVo.strJP stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    groupVo.strQP = [groupVo.strQP stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *strSql = [NSString stringWithFormat:@"insert into T_GROUP (GROUP_ID,GROUP_NAME,ALLOW_JOIN,ALLOW_SEND_MSG,IS_MEMBER,GROUP_TYPE,CREATOR_ID,CREATOR_NAME,ARTICLE_NUM,MEMBER_NUM,MEMBER_LIST_JSON,NAME_JP,NAME_QP) values ('%@','%@',%i,%i,%i,%i,'%@','%@','%@','%@','%@','%@','%@');",
                        groupVo.strGroupID,groupVo.strGroupName,groupVo.nAllowJoin,groupVo.nAllowSee,groupVo.nIsGroupMember,groupVo.nGroupType,groupVo.strCreatorID,groupVo.strCreatorName,groupVo.strArticleNum,groupVo.strMemberNum,groupVo.strMemListJSON,groupVo.strJP,groupVo.strQP];
    return [dbOperator executeSql:strSql];
}

//更新用户表
-(void)updateUserTable
{
    //0:get last update time
    VersionControlDao *versionControlDao = [[VersionControlDao alloc]init];
    VersionControlVo *versionControlVo = [versionControlDao getSelfVersionControlInfo];
    
    //1.group
    NSString *strLastTime;
    if (versionControlVo == nil)
    {
        strLastTime = @"";
    }
    else
    {
        strLastTime = versionControlVo.strUserUpdateTime;
    }
    
    //1.1 get server info
    ServerReturnInfo *retInfo = [ServerProvider syncAllMember:strLastTime];
    if (retInfo.bSuccess)
    {
        //a:insert db
        NSMutableArray *aryData = (NSMutableArray *)retInfo.data;
        NSString *strLastUpdateTime = (NSString*)retInfo.data2;
        if (aryData != nil && aryData.count>0)
        {
            sqlite3_exec(dbOperator.getSqliteDB, "BEGIN TRANSACTION;", NULL, NULL, NULL);
            BOOL bRes = NO;
            for (int i=0; i<aryData.count; i++)
            {
                UserVo *userVo = [aryData objectAtIndex:i];
                
                bRes = [self insertAndUpdateUserData:userVo];
                if (!bRes) 
                {
                    break;
                }
            }
            
            if (bRes)
            {
                if(sqlite3_exec(dbOperator.getSqliteDB, "COMMIT TRANSACTION;", NULL, NULL, NULL) == SQLITE_OK)
                {
                    //complete update group table,then update group time
                    [versionControlDao updateVersionCtrlLastTime:strLastUpdateTime andType:UserTableType];
                }
                else
                {
                    sqlite3_exec(dbOperator.getSqliteDB, "ROLLBACK", NULL, NULL, NULL);
                }
            }
            else
            {
                sqlite3_exec(dbOperator.getSqliteDB, "ROLLBACK", NULL, NULL, NULL);
            }
        }
    }
}

//更新群组表
-(void)updateGroupTable
{
    //1: get server info
    ServerReturnInfo *retInfo = [ServerProvider getAllGroupList];
    if (retInfo.bSuccess)
    {
        //a:清除之前的数据
        NSString *strSql = @"delete from T_GROUP;";
        [dbOperator executeSql:strSql];
        
        //b:所有群组(insert db)
        NSMutableArray *aryData = (NSMutableArray *)retInfo.data;
        if (aryData != nil && aryData.count>0)
        {
            sqlite3_exec(dbOperator.getSqliteDB, "BEGIN TRANSACTION;", NULL, NULL, NULL);
            BOOL bRes = NO;
            for (int i=0; i<aryData.count; i++)
            {
                GroupVo *groupVo = [aryData objectAtIndex:i];
                bRes = [self insertAndUpdateGroupData:groupVo];
                if (!bRes)
                {
                    break;
                }
            }
            
            if (bRes)
            {
                if(sqlite3_exec(dbOperator.getSqliteDB, "COMMIT TRANSACTION;", NULL, NULL, NULL) == SQLITE_OK)
                {
                    //complete update group table,then update group time
                }
                else
                {
                    sqlite3_exec(dbOperator.getSqliteDB, "ROLLBACK", NULL, NULL, NULL);
                }
            }
            else
            {
                sqlite3_exec(dbOperator.getSqliteDB, "ROLLBACK", NULL, NULL, NULL);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////
//清空所有缓存数据（公司成员表，群组表，版本更新控制表）
-(void)clearAllBufferDBData
{
    //T_VERSION_CONTROL、T_USER、T_GROUP
    NSString *strSql = @"delete from T_VERSION_CONTROL;";
    [dbOperator executeSql:strSql];
    
    strSql = @"delete from T_USER;";
    [dbOperator executeSql:strSql];
    
    strSql = @"delete from T_GROUP;";
    [dbOperator executeSql:strSql];
}

//检查该登录用户同时缓存了用户和群组，没有则再次缓存
-(BOOL)checkBufferUserAndGroup
{
    BOOL bRes = NO; 
    NSString *strSqlUser = [NSString stringWithFormat:@"select RECORD_ID from T_USER where RECORD_STATUS=0 and USER_ID<>'%@'",[Common getCurrentUserVo].strUserID];
    NSArray *aryUser = [dbOperator QueryInfoFromSQL:strSqlUser];
    
    NSString *strSqlGroup = @"select RECORD_ID from T_GROUP";
    NSArray *aryGroup = [dbOperator QueryInfoFromSQL:strSqlGroup];
    
    if (aryUser != nil && aryUser.count>0 && aryGroup != nil && aryGroup.count>0)
    {
        bRes = YES;
    }
    return bRes;
}

@end
