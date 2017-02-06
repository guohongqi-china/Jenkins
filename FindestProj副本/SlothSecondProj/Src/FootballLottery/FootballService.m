//
//  FootballService.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "FootballService.h"
#import "NSString+MD5.h"
#import "VNetworkFramework.h"
#import "UploadFileVo.h"
#import "BusinessCommon.h"

@implementation FootballService

//将评论JSON转换为对象数组
+ (NSMutableArray*)getLeagueListByJSONArray:(NSArray*)aryLeagueJSONList
{
    if (![aryLeagueJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryLeague = [NSMutableArray array];
    for (NSDictionary *dicLeague in aryLeagueJSONList)
    {
        LeagueVo *leagueVo = [[LeagueVo alloc]init];
        
        id leagueId = [dicLeague objectForKey:@"id"];
        if (leagueId == [NSNull null]|| leagueId == nil)
        {
            leagueVo.strID = @"";
        }
        else
        {
            leagueVo.strID = [leagueId stringValue];
        }
        
        id leagueType = [dicLeague objectForKey:@"leagueType"];
        if (leagueType == [NSNull null]|| leagueType == nil)
        {
            leagueVo.nLeagueType = 0;
        }
        else
        {
            leagueVo.nLeagueType = [leagueType integerValue];
        }
        
        leagueVo.strLeagueTypeName = [BusinessCommon getLeagueTypeName:leagueVo.nLeagueType];
        
        //该比赛状态	1:未赛；3:完赛
        id matchStatus = [dicLeague objectForKey:@"matchStatus"];
        if (matchStatus == [NSNull null]|| matchStatus == nil)
        {
            leagueVo.nStatus = 0;
        }
        else
        {
            leagueVo.nStatus = [matchStatus integerValue];
        }
        
        //积分
        id integral = [dicLeague objectForKey:@"integral"];
        if (integral == [NSNull null]|| integral == nil)
        {
            leagueVo.fIntegration = 0;
        }
        else
        {
            leagueVo.fIntegration = [integral doubleValue];
        }
        
        //投注积分
        id consumeIntegral = [dicLeague objectForKey:@"betIntegral"];
        if (consumeIntegral == [NSNull null]|| consumeIntegral == nil)
        {
            leagueVo.nConsumeIntegral = 0;
        }
        else
        {
            leagueVo.nConsumeIntegral = [consumeIntegral integerValue];
        }
        
        //胜平负赔率
        id winOdds = [dicLeague objectForKey:@"win"];
        if (winOdds == [NSNull null]|| winOdds == nil)
        {
            leagueVo.fWinOdds = 0;
        }
        else
        {
            leagueVo.fWinOdds = [winOdds floatValue];
        }
        
        id equalOdds = [dicLeague objectForKey:@"draw"];
        if (equalOdds == [NSNull null]|| equalOdds == nil)
        {
            leagueVo.fEqualOdds = 0;
        }
        else
        {
            leagueVo.fEqualOdds = [equalOdds floatValue];
        }
        
        id loseOdds = [dicLeague objectForKey:@"lose"];
        if (loseOdds == [NSNull null]|| loseOdds == nil)
        {
            leagueVo.fLoseOdds = 0;
        }
        else
        {
            leagueVo.fLoseOdds = [loseOdds floatValue];
        }
        
        NSDate *date = [Common getDateFromString:[Common checkStrValue:[dicLeague objectForKey:@"date"]] format:@"yyyy-MM-dd HH:mm"];
        leagueVo.strDateTime = [Common getDateTimeStrFromDate:date format:@"yyyy-MM-dd HH:mm:ss"];
        leagueVo.strDate = [Common getDateTimeStrFromDate:date format:@"yyyy年MM月dd日"];
        leagueVo.strTime = [Common getDateTimeStrFromDate:date format:@"HH:mm"];
        
        id result = [dicLeague objectForKey:@"result"];
        if (result == [NSNull null]|| result == nil)
        {
            leagueVo.nCurrGuess = 0;
        }
        else
        {
            leagueVo.nCurrGuess = [result integerValue];
        }
        
        leagueVo.strTeam1 = [Common checkStrValue:[dicLeague objectForKey:@"team1"]];
        leagueVo.strTeam2 = [Common checkStrValue:[dicLeague objectForKey:@"team2"]];
        
        leagueVo.strTeam1Logo = [Common checkStrValue:[dicLeague objectForKey:@"flag1"]];
        leagueVo.strTeam2Logo = [Common checkStrValue:[dicLeague objectForKey:@"flag2"]];
        
        [aryLeague addObject:leagueVo];
    }
    return aryLeague;
}

//足彩竞猜///////////////////////////////////////////////////////////////////////////////
//获取赛程列表（10：国际联赛赛程、11：中超赛程）
+ (void)getLeagueList:(NSInteger)nType result:(ResultBlock)resultBlock
{
    NSString *strURL = nil;
    if (nType == 10)
    {
        strURL = [ServerURL getInterLeagueListURL];
    }
    else if (nType == 11)
    {
        strURL = [ServerURL getChinaLeagueListURL];
    }
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:strURL];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSArray *aryDicLeague = responseObject;
            retInfo.data  = [FootballService getLeagueListByJSONArray:aryDicLeague];
        }
        resultBlock(retInfo);
    }];
}

//我的竞猜(nLeagueType:-1,不筛选)
+ (void)getMyLeagueList:(NSInteger)nLeagueType page:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if(nLeagueType != -1)
    {
        [bodyDic setObject:[NSNumber numberWithInteger:nLeagueType] forKey:@"leagueType"];
    }
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getMyLeagueListURL]];
    [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSArray *aryLeagueJSON = [responseObject objectForKey:@"content"];
            if (aryLeagueJSON != nil)
            {
                retInfo.data  = [FootballService getLeagueListByJSONArray:aryLeagueJSON];
            }
            
            //最后一页
            id lastPage = responseObject[@"lastPage"];
            if (lastPage == nil || lastPage == [NSNull null])
            {
                retInfo.data2 = @false;
            }
            else
            {
                retInfo.data2 = lastPage;
            }
        }
        resultBlock(retInfo);
    }];
}

//提交竞猜
//nSingleBet:单场押注积分（现在是相同的）
+ (void)commitLeague:(NSMutableArray*)aryLeague singleBet:(NSInteger)nSingleBet result:(ResultBlock)resultBlock
{
    NSMutableArray *aryData = [NSMutableArray array];
    for (LeagueVo *leagueVo in aryLeague)
    {
        NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
        [dicBody setObject:leagueVo.strID forKey:@"fixtureId"];
        [dicBody setObject:[NSNumber numberWithInteger:leagueVo.nLeagueType] forKey:@"leagueType"];
        [dicBody setObject:[NSNumber numberWithInteger:leagueVo.nCommitGuess] forKey:@"result"];
        [dicBody setObject:[NSNumber numberWithInteger:nSingleBet] forKey:@"integral"];
        [aryData addObject:dicBody];
    }
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCommitLeagueURL]];
    [networkFramework startRequestToServer:@"POST" parameter:aryData result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

//获取押注积分的列表
+ (void)getBetList:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getBetListURL]];
    [networkFramework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryBet = [NSMutableArray array];
            NSArray *aryBetJSON = responseObject;
            for (NSDictionary *dicLeague in aryBetJSON)
            {
                NSNumber *numBet;
                id betValue = [dicLeague objectForKey:@"integral"];
                if (betValue == [NSNull null]|| betValue == nil)
                {
                    numBet = @0;
                }
                else
                {
                    numBet = [NSNumber numberWithInteger:[betValue integerValue]];
                }
                [aryBet addObject:numBet];
            }
            retInfo.data = aryBet;
        }
        
        resultBlock(retInfo);
    }];
}

@end
