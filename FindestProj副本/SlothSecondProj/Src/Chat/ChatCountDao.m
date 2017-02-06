//
//  ChatCountDao.m
//  Sloth
//
//  Created by 焱 孙 on 13-7-1.
//
//

#import "ChatCountDao.h"
#import "UserVo.h"
#define CHAT_COUNT_OBJ_KEY @"CHAT_COUNT_OBJ_KEY"
#define CHAT_PARA_SETTING @"CHAT_PARA_SETTING"

@implementation ChatCountDao

//init chat setting
+(void)initChatParaSetting
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strPara = [userDefaults objectForKey:CHAT_PARA_SETTING];
    if (strPara == nil || ![strPara isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        [ChatCountDao clearUnseenChatNum];
        [userDefaults setObject:[Common getCurrentUserVo].strUserID forKey:CHAT_PARA_SETTING];
    }
}

//get unsee num by key
+(int)getUnseenChatNumByKey:(NSString*)strKey
{
    int nNum = 0;
    NSDictionary * dicChatCount = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHAT_COUNT_OBJ_KEY];
    if (dicChatCount != nil)
    {
        NSNumber *num = [dicChatCount objectForKey:strKey];
        nNum += [num intValue];
    }
    return nNum;
}

//set unsee num by key
+(void)addOneUnseenChatNumByKey:(NSString*)strKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSUserDefaults data
    NSDictionary * dicOld = [userDefaults dictionaryForKey:CHAT_COUNT_OBJ_KEY];
    if (dicOld == nil)
    {
        dicOld = [[NSDictionary alloc]init];
    }
    
    //new data
    NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dicOld];
    NSNumber *number = [dicNew objectForKey:strKey];
    if(number == nil)
    {
        number = [NSNumber numberWithInt:1];
    }
    else
    {
        number = [NSNumber numberWithInt:[number intValue]+1];
    }
    [dicNew setObject:number forKey:strKey];
    [userDefaults setObject:dicNew forKey:CHAT_COUNT_OBJ_KEY];
}

//get sum unsee num by key
+(int)getUnseenChatSumNum
{
    int nNum = 0;
    NSDictionary * dicChatCount = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHAT_COUNT_OBJ_KEY];
    if (dicChatCount != nil)
    {
        NSArray *aryKeys = [dicChatCount allKeys];
        for (int i=0; i<aryKeys.count;i++)
        {
            NSString *strKey = [aryKeys objectAtIndex:i];
            NSNumber *num = [dicChatCount objectForKey: strKey];
            nNum += [num intValue];
        }
    }
    return nNum;
}

+(void)removeObjectByKey:(NSString*)strKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSUserDefaults data
    NSDictionary * dicOld = [userDefaults dictionaryForKey:CHAT_COUNT_OBJ_KEY];
    if (dicOld == nil)
    {
        return;
    }
    
    //new data
    NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dicOld];
    [dicNew removeObjectForKey:strKey];
    [userDefaults setObject:dicNew forKey:CHAT_COUNT_OBJ_KEY];
}

//clear all chat num
+(void)clearUnseenChatNum
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:CHAT_COUNT_OBJ_KEY];
}

//清理无用的聊天数量(aryKeys:有效的key/value)
+(void)clearUselessChatNum:(NSArray*)aryKeys
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSUserDefaults data
    NSDictionary * dicOld = [userDefaults dictionaryForKey:CHAT_COUNT_OBJ_KEY];
    if (dicOld == nil)
    {
        return;
    }

    //filter dictionary
    NSDictionary *dicFilter = [dicOld dictionaryWithValuesForKeys:aryKeys];
    NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dicFilter];
    
    //delete null value
    if (dicNew != nil)
    {
        NSArray *aryNewKeys = [dicNew allKeys];
        for (NSString *strKey in aryNewKeys)
        {
            id objChatNum = [dicNew objectForKey:strKey];
            if (objChatNum == [NSNull null] || objChatNum == nil)
            {
                [dicNew removeObjectForKey:strKey];
            }
        }
    }
    
    //set new dictionary
    [userDefaults setObject:dicNew forKey:CHAT_COUNT_OBJ_KEY];
}

@end
