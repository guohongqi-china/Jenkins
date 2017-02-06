//
//  ChatCountDao.m
//  Sloth
//
//  Created by 焱 孙 on 13-7-1.
//
//

#import "ChatCountDao.h"

#define CHAT_COUNT_OBJ_KEY @"CHAT_COUNT_OBJ_KEY"    //保存聊天未查看数量
#define CHAT_PARA_SETTING @"CHAT_PARA_SETTING"      //用来保存当前登录用户的ID，当切换用户时清理聊天数量的 NSDictionary

@implementation ChatCountDao

//init chat setting
+(void)initChatParaSetting
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strPara = [userDefaults objectForKey:CHAT_PARA_SETTING];
    //当切换用户登录，清空之前账户保存的数据
    if (strPara == nil || ![strPara isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        [ChatCountDao clearUnseenChatNum];
        [userDefaults setObject:[Common getCurrentUserVo].strUserID forKey:CHAT_PARA_SETTING];
    }
}

//通过会话Key和会话Status获取提醒数字
+(NSInteger)getUnseenChatNumByKey:(NSString*)strKey status:(NSString*)strStatus
{
    NSInteger nNum = 0;
    NSMutableDictionary *dicSum = [[[NSUserDefaults standardUserDefaults] objectForKey:CHAT_COUNT_OBJ_KEY] mutableCopy];
    if (dicSum != nil)
    {
        NSMutableDictionary *dicType = [[dicSum objectForKey:strStatus] mutableCopy];//获取分类的dictionary
        NSNumber *num = [dicType objectForKey:strKey];
        nNum = [num integerValue];
    }
    return nNum;
}

//增加提醒数量
+(void)addOneUnseenChatNumByKey:(NSString*)strKey status:(NSString*)strStatus
{
    if (strKey == nil || strStatus == nil)
    {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //获取总的Dictionary
    NSMutableDictionary * dicSum = [[userDefaults objectForKey:CHAT_COUNT_OBJ_KEY] mutableCopy];
    if (dicSum == nil)
    {
        dicSum = [[NSMutableDictionary alloc]init];
    }
    
    //获取分类Dictionary
    NSMutableDictionary *dicType = [[dicSum objectForKey:strStatus] mutableCopy];
    if (dicType == nil)
    {
        dicType = [[NSMutableDictionary alloc]init];
    }
    
    //获取会话的数量
    NSNumber *num = [dicType objectForKey:strKey];
    if(num == nil)
    {
        num = [NSNumber numberWithInt:1];
    }
    else
    {
        num = [NSNumber numberWithInteger:[num integerValue]+1];
    }
    [dicType setObject:num forKey:strKey];
    [dicSum setObject:dicType forKey:strStatus];
    [userDefaults setObject:dicSum forKey:CHAT_COUNT_OBJ_KEY];
}

//移除会话提醒数字
+(void)removeObjectByKey:(NSString*)strKey status:(NSString*)strStatus
{
    if (strKey == nil || strStatus == nil)
    {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //获取总的Dictionary
    NSMutableDictionary * dicSum = [[userDefaults objectForKey:CHAT_COUNT_OBJ_KEY] mutableCopy];
    if (dicSum == nil)
    {
        dicSum = [[NSMutableDictionary alloc]init];
    }
    
    //获取分类Dictionary
    NSMutableDictionary *dicType = [[dicSum objectForKey:strStatus] mutableCopy];
    if (dicType == nil)
    {
        dicType = [[NSMutableDictionary alloc]init];
    }
    
    //移除指定Key的会话数量
    [dicType removeObjectForKey:strKey];
    [dicSum setObject:dicType forKey:strStatus];
    [userDefaults setObject:dicSum forKey:CHAT_COUNT_OBJ_KEY];
}

//获取指定会话状态提醒数字总和
+(NSInteger)getNumBySessionStatus:(NSString*)strStatus
{
    NSInteger nNum = 0;
    NSDictionary * dicSum = [[NSUserDefaults standardUserDefaults] objectForKey:CHAT_COUNT_OBJ_KEY];
    if (dicSum != nil)
    {
        NSDictionary *dicType = [dicSum objectForKey:strStatus];
        if (dicType != nil)
        {
            NSArray *aryKeys = [dicType allKeys];
            for (int i=0; i<aryKeys.count;i++)
            {
                NSNumber *num = [dicType objectForKey:aryKeys[i]];
                nNum += [num integerValue];
            }
        }
    }
    return nNum;
}

//获取指定会话状态的会话数量（未提醒）
+(NSNumber*)getSessionNumByStatus:(NSString*)strStatus
{
    NSInteger nNum = 0;
    NSDictionary * dicSum = [[NSUserDefaults standardUserDefaults] objectForKey:CHAT_COUNT_OBJ_KEY];
    if (dicSum != nil)
    {
        NSDictionary *dicType = [dicSum objectForKey:strStatus];
        if (dicType != nil)
        {
            NSArray *aryKeys = [dicType allKeys];
            for (int i=0; i<aryKeys.count;i++)
            {
                NSNumber *num = [dicType objectForKey:aryKeys[i]];
                if([num integerValue]>0)
                {
                    nNum += 1;
                }
            }
        }
    }
    return [NSNumber numberWithInteger:nNum];
}

//获取所有会话数字总和
+(NSInteger)getAllSessionNum
{
    NSInteger nSumNum = [ChatCountDao getNumBySessionStatus:SESSION_UNPROCESS_KEY];
    nSumNum += [ChatCountDao getNumBySessionStatus:SESSION_PROCESSING_KEY];
    nSumNum += [ChatCountDao getNumBySessionStatus:SESSION_SUSPEND_KEY];
    return nSumNum;
}

//clear all chat num
+(void)clearUnseenChatNum
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:CHAT_COUNT_OBJ_KEY];
}

//根据会话状态获取会话状态KEY，用于提醒数字
+(NSString*)getSessionKeyByStatus:(NSInteger)nStatus
{
    NSString *strRes = nil;
    if(nStatus == 1)
    {
        strRes = SESSION_UNPROCESS_KEY;
    }
    else if(nStatus == 2)
    {
        strRes = SESSION_PROCESSING_KEY;
    }
    else if(nStatus == 3)
    {
        strRes = SESSION_SUSPEND_KEY;
    }
    return strRes;
}


@end
