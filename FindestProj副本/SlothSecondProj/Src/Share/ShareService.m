//
//  ShareService.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareService.h"
#import "NSString+MD5.h"
#import "VNetworkFramework.h"
#import "UploadFileVo.h"
#import "BusinessCommon.h"
#import "TagVo.h"

@implementation ShareService

//屏蔽用户
+ (void)shieldUserByID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getShieldUserByIdURL],strUserID];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
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
        }
        resultBlock(retInfo);
    }];
}

//恢复用户
+ (void)restoreShieldUserByID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getRestoreShieldUserByIdURL],strUserID];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
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
        }
        resultBlock(retInfo);
    }];
}

//被屏蔽用户list
+ (void)getShieldUserList:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:@"1" forKey:@"pageNumber"];
    [dicBody setObject:@15 forKey:@"pageSize"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getShieldUserListURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryMemberList = nil;
            NSArray *aryJSONUserList = [responseObject objectForKey:@"content"];
            if (aryJSONUserList != nil && aryJSONUserList.count>0)
            {
                aryMemberList = [ServerProvider getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryMemberList;
            
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

//举报用户
+ (void)reportUser:(ReportUserVo *)userVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    dicBody[@"reportUserId"] = userVo.strReportUserID;
    dicBody[@"reportRefId"] = userVo.strReportRefID;
    dicBody[@"reportRefType"] = userVo.strReportRefType;
    dicBody[@"reportReasonId"] = userVo.strReasonID;
    if(userVo.strReason.length > 0)
    {
        dicBody[@"reportReasonName"] = userVo.strReason;
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getReportUserURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//搜索首页（热门搜索、热门标签、精华区）
+ (void)getHomeSearchData:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getHomeSearchDataURL]];
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
            
            //精华区
            NSMutableArray *aryEssence = [NSMutableArray array];
            NSArray *aryEssenceJSON = [responseObject objectForKey:@"tabTag"];
            if (aryEssenceJSON != nil && aryEssenceJSON.count>0)
            {
                for (NSDictionary *dicEssence in aryEssenceJSON)
                {
                    TagVo *tagVo = [[TagVo alloc]init];
                    
                    id tagId = dicEssence[@"id"];
                    if (tagId == [NSNull null]|| tagId == nil)
                    {
                        tagVo.strID = @"";
                    }
                    else
                    {
                        tagVo.strID = [tagId stringValue];
                    }
                    tagVo.strTagName = [Common checkStrValue:dicEssence[@"name"]];
                    tagVo.strSearchType = @"essence";
                    
                    [aryEssence addObject:tagVo];
                }
            }
            retInfo.data = aryEssence;
            
            //热门搜索
            NSMutableArray *aryHotSearch = [NSMutableArray array];
            NSArray *aryHotSearchJSON = [responseObject objectForKey:@"queryWord"];
            if (aryHotSearchJSON != nil && aryHotSearchJSON.count>0)
            {
                for (NSDictionary *dicHotSearch in aryHotSearchJSON)
                {
                    TagVo *tagVo = [[TagVo alloc]init];
                    
                    id num = dicHotSearch[@"num"];
                    if (num == [NSNull null]|| num == nil)
                    {
                        tagVo.nFrequency = 0;
                    }
                    else
                    {
                        tagVo.nFrequency = [num integerValue];
                    }
                    tagVo.strTagName = [Common checkStrValue:dicHotSearch[@"name"]];
                    tagVo.strSearchType = @"hotSearch";
                    
                    [aryHotSearch addObject:tagVo];
                }
            }
            retInfo.data2 = aryHotSearch;
            
            //热门话题
            NSMutableArray *aryHotTag = [NSMutableArray array];
            NSArray *aryHotTagJSON = [responseObject objectForKey:@"hotTags"];
            if (aryHotTagJSON != nil && aryHotTagJSON.count>0)
            {
                for (NSDictionary *dicHotTag in aryHotTagJSON)
                {
                    TagVo *tagVo = [[TagVo alloc]init];
                    
                    id tagId = dicHotTag[@"id"];
                    if (tagId == [NSNull null]|| tagId == nil)
                    {
                        tagVo.strID = @"";
                    }
                    else
                    {
                        tagVo.strID = [tagId stringValue];
                    }
                    
                    id num = dicHotTag[@"num"];
                    if (num == [NSNull null]|| num == nil)
                    {
                        tagVo.nFrequency = 0;
                    }
                    else
                    {
                        tagVo.nFrequency = [num integerValue];
                    }
                    tagVo.strTagName = [Common checkStrValue:dicHotTag[@"name"]];
                    tagVo.strSearchType = @"hotTag";
                    
                    [aryHotTag addObject:tagVo];
                }
            }
            retInfo.data3 = aryHotTag;
        }
        resultBlock(retInfo);
    }];
}

@end
