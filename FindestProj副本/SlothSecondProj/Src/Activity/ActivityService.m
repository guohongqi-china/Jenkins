//
//  ActivityService.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityService.h"
#import "NSString+MD5.h"
#import "VNetworkFramework.h"
#import "BlogVo.h"
#import "ActivityProjectVo.h"
#import "FieldVo.h"
#import "TagVo.h"
#import "AttachmentVo.h"

@implementation ActivityService

//将分享JSON转换为对象数组
+(NSMutableArray*)getActivityListByJSONArray:(NSArray*)aryActivityJSON
{
    if (![aryActivityJSON isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryBlogList = [NSMutableArray array];
    for (int i=0;i<aryActivityJSON.count;i++)
    {
        NSDictionary *dicBlogInfo = aryActivityJSON[i];
        
        BlogVo *blogVo = [[BlogVo alloc]init];
        id blogID = [dicBlogInfo objectForKey:@"id"];
        if (blogID == [NSNull null]|| blogID == nil)
        {
            blogVo.streamId = @"";
        }
        else
        {
            blogVo.streamId = [blogID stringValue];
        }
        blogVo.imgContent = nil;
        blogVo.strTitle = [Common checkStrValue:[dicBlogInfo objectForKey:@"titleName"]];
        blogVo.strContent = [Common checkStrValue:[dicBlogInfo objectForKey:@"streamContent"]];
        blogVo.strText = [Common checkStrValue:[dicBlogInfo objectForKey:@"streamText"]];
        
        //子活动报名场次
        id projectNum = [dicBlogInfo objectForKey:@"projectNum"];
        if (projectNum == [NSNull null]|| projectNum == nil)
        {
            blogVo.nProjectJoinNum = 0;
        }
        else
        {
            blogVo.nProjectJoinNum = [projectNum integerValue];
        }
        
        //收藏
        id hasStore = [dicBlogInfo objectForKey:@"hasStore"];
        if (hasStore == nil || hasStore == [NSNull null])
        {
            blogVo.bCollection = NO;
        }
        else
        {
            blogVo.bCollection = ([hasStore integerValue]==1)?YES:NO;
        }
        
        //收藏的数量
        id storeCount = [dicBlogInfo objectForKey:@"storeCount"];
        if (storeCount == nil || storeCount == [NSNull null])
        {
            blogVo.nCollectCount = 0;
        }
        else
        {
            blogVo.nCollectCount = [storeCount integerValue];
        }
        
        id Comefrom = [dicBlogInfo objectForKey:@"streamComefrom"];
        if (Comefrom == [NSNull null]|| Comefrom == nil)
        {
            blogVo.nComefrom = 0;
        }
        else
        {
            blogVo.nComefrom = [Comefrom intValue];
        }
        
        id isSignup = [dicBlogInfo objectForKey:@"isSignup"];
        if (isSignup == [NSNull null]|| isSignup == nil)
        {
            blogVo.nBlogType = 0;
        }
        else
        {
            blogVo.nBlogType = [isSignup integerValue];
        }
        
        //分享类型
        blogVo.strBlogType = @"activity";
        
        id orgId = [dicBlogInfo objectForKey:@"orgId"];
        if (orgId == [NSNull null]|| orgId == nil)
        {
            blogVo.orgId = @"";
        }
        else
        {
            blogVo.orgId = [orgId stringValue];
        }
        
        id refId = [dicBlogInfo objectForKey:@"refId"];
        if (refId == [NSNull null] || refId == nil)
        {
            blogVo.strRefID = @"";
        }
        else
        {
            blogVo.strRefID = [refId stringValue];
        }
        
        blogVo.strCreateDate = [Common checkStrValue:[dicBlogInfo objectForKey:@"createDate"]];
        blogVo.strUpdateDate = [Common checkStrValue:[dicBlogInfo objectForKey:@"updateDate"]];
        
        blogVo.strPictureUrl = [Common checkStrValue:[dicBlogInfo objectForKey:@"picture"]];
        if (blogVo.strPictureUrl.length>0)
        {
            NSRange range = [blogVo.strPictureUrl rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
            if (range.length==0)
            {
                //需要追加前缀
                blogVo.strPictureUrl = [ServerURL getWholeURL:blogVo.strPictureUrl];
            }
        }
        
        blogVo.aryPictureUrl = [NSMutableArray array];
        id pictureList = [dicBlogInfo objectForKey:@"pictureList"];
        if(pictureList != [NSNull null] && [pictureList isKindOfClass:[NSArray class]])
        {
            for (NSString *strURL in pictureList)
            {
                NSString *strPictureURL = @"";
                NSRange range = [strURL rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
                if (range.length==0)
                {
                    //需要追加前缀
                    strPictureURL = [ServerURL getWholeURL:strURL];
                }
                else
                {
                    strPictureURL = strURL;
                }
                [blogVo.aryPictureUrl addObject:strPictureURL];
            }
        }
        
        //勋章
        id badge = [dicBlogInfo objectForKey:@"userBadge"];
        if (badge == [NSNull null]|| badge == nil)
        {
            blogVo.nBadge = 0;
        }
        else
        {
            blogVo.nBadge = [badge integerValue];
        }
        //积分
        id integral = [dicBlogInfo objectForKey:@"userIntegral"];
        if (integral == [NSNull null]|| integral == nil)
        {
            blogVo.fIntegral = 0.0f;
        }
        else
        {
            blogVo.fIntegral = [integral doubleValue];
        }
        
        //参加活动前N名积分
        id integralActivity = [dicBlogInfo objectForKey:@"integral"];
        if (integralActivity == [NSNull null]|| integralActivity == nil)
        {
            blogVo.nUpIntegral = -1;
        }
        else
        {
            blogVo.nUpIntegral = [integralActivity integerValue];
        }
        
        //参加活动后N名积分
        id integralSec = [dicBlogInfo objectForKey:@"integralSec"];
        if (integralSec == [NSNull null]|| integralSec == nil)
        {
            blogVo.nDownIntegral = -1;
        }
        else
        {
            blogVo.nDownIntegral = [integralSec integerValue];
        }
        
        //活动参加名次
        id signupRewardNum = [dicBlogInfo objectForKey:@"signupRewardNum"];
        if (signupRewardNum == [NSNull null]|| signupRewardNum == nil)
        {
            blogVo.nActivityJoinRank = -1;
        }
        else
        {
            blogVo.nActivityJoinRank = [signupRewardNum integerValue];
        }
        
        id strCreateBy = [dicBlogInfo objectForKey:@"createBy"];
        if (strCreateBy == [NSNull null]|| strCreateBy == nil)
        {
            blogVo.strCreateBy = @"";
        }
        else
        {
            blogVo.strCreateBy = [strCreateBy stringValue];
        }
        id strUpdateBy = [dicBlogInfo objectForKey:@"updateBy"];
        if (strUpdateBy == [NSNull null]|| strUpdateBy == nil)
        {
            blogVo.strUpdateBy = @"";
        }
        else
        {
            blogVo.strUpdateBy = [strUpdateBy stringValue];
        }
        blogVo.strCreateByName = [Common checkStrValue:[dicBlogInfo objectForKey:@"userNickname"]];//createName
        blogVo.strUpdateByName = [Common checkStrValue:[dicBlogInfo objectForKey:@"updateName"]];
        id praiseCount = [dicBlogInfo objectForKey:@"praiseCount"];
        if (praiseCount == [NSNull null]|| praiseCount == nil)
        {
            blogVo.nPraiseCount = 0;
        }
        else
        {
            blogVo.nPraiseCount = [praiseCount intValue];
        }
        id nCommentCount = [dicBlogInfo objectForKey:@"commentCount"];
        if (nCommentCount == [NSNull null]|| nCommentCount == nil)
        {
            blogVo.nCommentCount = 0;
        }
        else
        {
            blogVo.nCommentCount = [nCommentCount intValue];
        }
        
        blogVo.vestImg = [ServerURL getWholeURL:[Common checkStrValue:[dicBlogInfo objectForKey:@"userImgUrl"]]];
        blogVo.strStartTime = [Common checkStrValue:[dicBlogInfo objectForKey:@"startDate"]];
        blogVo.strEndTime = [Common checkStrValue:[dicBlogInfo objectForKey:@"endDate"]];
        id delFlag = [dicBlogInfo objectForKey:@"delFlag"];
        if (delFlag == [NSNull null]|| delFlag == nil)
        {
            blogVo.nDelFlag = 0;
        }
        else
        {
            blogVo.nDelFlag = [delFlag intValue];
        }
        id isDraft = [dicBlogInfo objectForKey:@"isDraft"];
        if (isDraft == [NSNull null]|| isDraft == nil)
        {
            blogVo.isDraft = 0;
        }
        else
        {
            blogVo.isDraft = [isDraft intValue];
        }
        
        //帖子的热度和排名
        id blogIntegral = [dicBlogInfo objectForKey:@"blogIntegral"];
        if (blogIntegral == [NSNull null]|| blogIntegral == nil)
        {
            blogVo.nHotValue = 0;
        }
        else
        {
            blogVo.nHotValue = (NSInteger)[blogIntegral floatValue];
        }
        
        blogVo.nIndex = i+1;
        
        //分享链接
        blogVo.strShareLink = [Common checkStrValue:[dicBlogInfo objectForKey:@"thirdLink"]];
        blogVo.strLinkTitle = [Common checkStrValue:[dicBlogInfo objectForKey:@"thirdTitle"]];
        
        //比赛场次
        id matchNum = [dicBlogInfo objectForKey:@"matchNum"];
        if (matchNum == [NSNull null]|| matchNum == nil)
        {
            blogVo.nContestNum = 0;
        }
        else
        {
            blogVo.nContestNum = [matchNum integerValue];
        }
        
        //会议报名-已报名人数
        id signupMemberNum = [dicBlogInfo objectForKey:@"signupMemberNum"];
        if (signupMemberNum == [NSNull null]|| signupMemberNum == nil)
        {
            blogVo.nSignupMemberNum = 1;
        }
        else
        {
            blogVo.nSignupMemberNum = [signupMemberNum integerValue];
        }
        
        //会议报名-报名人数上限
        id totalMemberNum = [dicBlogInfo objectForKey:@"totalMemberNum"];
        if (totalMemberNum == [NSNull null]|| totalMemberNum == nil)
        {
            blogVo.nTotalMemberNum = 1;
        }
        else
        {
            blogVo.nTotalMemberNum = [totalMemberNum integerValue];
        }
        
        //会议是否过期
        id overdue = [dicBlogInfo objectForKey:@"overdue"];
        if (overdue == [NSNull null]|| overdue == nil)
        {
            blogVo.bOverDue = NO;
        }
        else
        {
            blogVo.bOverDue = [overdue boolValue];
        }
        
        //会议自定义提交字段
        blogVo.aryMeetingField = [NSMutableArray array];
        NSArray *aryJSONField =[dicBlogInfo objectForKey:@"fieldList"];
        if (aryJSONField != nil && (id) aryJSONField != [NSNull null])
        {
            for (NSDictionary *dicField in aryJSONField)
            {
                FieldVo *fieldVo = [[FieldVo alloc]init];
                id fieldId = [dicField objectForKey:@"id"];
                if (fieldId == [NSNull null] || fieldId == nil)
                {
                    fieldVo.strID = @"";
                }
                else
                {
                    fieldVo.strID = [fieldId stringValue];
                }
                
                fieldVo.strName = [Common checkStrValue:[dicField objectForKey:@"fieldName"]];
                
                id maxLength = [dicField objectForKey:@"maxLength"];
                if (maxLength == [NSNull null] || maxLength == nil)
                {
                    fieldVo.nMaxLength = 100;
                }
                else
                {
                    fieldVo.nMaxLength = [maxLength integerValue];
                }
                [blogVo.aryMeetingField addObject:fieldVo];
            }
        }
        
        //标签列表
        blogVo.aryTagList = [NSMutableArray array];
        NSArray *aryJSONTagList =[dicBlogInfo objectForKey:@"tagVoList"];
        if (aryJSONTagList != nil && (id) aryJSONTagList != [NSNull null])
        {
            for (int i=0; i<aryJSONTagList.count; i++)
            {
                NSDictionary *dicTagVo = [aryJSONTagList objectAtIndex:i];
                TagVo *tagVo = [[TagVo alloc]init];
                id tagID = [dicTagVo objectForKey:@"id"];
                if (tagID == [NSNull null])
                {
                    tagVo.strID = @"";
                }
                else
                {
                    tagVo.strID = [[dicTagVo objectForKey:@"id"]stringValue];
                }
                tagVo.strTagName = [Common checkStrValue:[dicTagVo objectForKey:@"tagName"]];
                tagVo.strTagType = [Common checkStrValue:[dicTagVo objectForKey:@"orgFlag"]];
                [blogVo.aryTagList addObject:tagVo];
            }
        }
        
        //附件列表
        blogVo.aryAttachmentList = [NSMutableArray array];
        id attachmentList = [dicBlogInfo objectForKey:@"fileList"];
        if (attachmentList != nil && attachmentList != [NSNull null])
        {
            NSArray *aryAttachmentList = attachmentList;
            for (int i=0; i<aryAttachmentList.count; i++)
            {
                NSDictionary *dicAttachment = [aryAttachmentList objectAtIndex:i];
                AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
                id attachmentID = [dicAttachment objectForKey:@"id"];
                if (attachmentID == [NSNull null])
                {
                    attachmentVo.strID = @"";
                }
                else
                {
                    attachmentVo.strID = [attachmentID stringValue];
                }
                
                attachmentVo.strAttachmentName = [Common checkStrValue:[dicAttachment objectForKey:@"resourceName"]];
                attachmentVo.strAttachmentURL = [ServerURL getWholeURL:[Common checkStrValue:[dicAttachment objectForKey:@"resourceUri"]]];
                id attachmentSize = [dicAttachment objectForKey:@"size"];
                if (attachmentSize == [NSNull null])
                {
                    attachmentVo.lAttachmentSize = 0;
                }
                else
                {
                    attachmentVo.lAttachmentSize = [attachmentSize longLongValue];
                }
                
                [blogVo.aryAttachmentList addObject:attachmentVo];
            }
        }
        
        id mentionId = [dicBlogInfo objectForKey:@"mentionId"];
        if (mentionId == [NSNull null] || mentionId == nil)
        {
            blogVo.strMentionID = nil;//用于判断本人是否赞过，nil则没赞过
        }
        else
        {
            blogVo.strMentionID = [mentionId stringValue];
        }
        
        //项目列表
        blogVo.aryActivityProject = [ActivityService getProjectListByJSONArray:[dicBlogInfo objectForKey:@"projects"]];
        
        //活动已报名用户 - 前15用户列表
        blogVo.aryActivityUser = [ServerProvider getUserListByJSONArray:[dicBlogInfo objectForKey:@"activityUsers"]];
        
        blogVo.strActivityAddress = [Common checkStrValue:[dicBlogInfo objectForKey:@"projectAddress"]];
        blogVo.strActivityStartDateTime = [Common checkStrValue:[dicBlogInfo objectForKey:@"projectStartDate"]];
        
        id signupNum = [dicBlogInfo objectForKey:@"signupNum"];
        if (signupNum == [NSNull null] || signupNum == nil)
        {
            blogVo.nActivitySignupNum = 0;
        }
        else
        {
            blogVo.nActivitySignupNum = [signupNum integerValue];
        }
        
        [aryBlogList addObject:blogVo];
    }
    return aryBlogList;
}

//将活动项目JSON转换为对象数组
+(NSMutableArray*)getProjectListByJSONArray:(NSArray*)aryProjectJSON
{
    if (![aryProjectJSON isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryProjectList = [NSMutableArray array];
    for (int i=0;i<aryProjectJSON.count;i++)
    {
        ActivityProjectVo *projectVo = [[ActivityProjectVo alloc]init];
        
        NSDictionary *dicActivityProject = aryProjectJSON[i];
        id projectID = [dicActivityProject objectForKey:@"id"];
        if (projectID == [NSNull null] || projectID == nil)
        {
            projectVo.strID = @"";
        }
        else
        {
            projectVo.strID = [projectID stringValue];
        }
        
        id blogId = [dicActivityProject objectForKey:@"blogId"];
        if (blogId == [NSNull null] || blogId == nil)
        {
            projectVo.strBlogID = @"";
        }
        else
        {
            projectVo.strBlogID = [blogId stringValue];
        }
        
        id createId = [dicActivityProject objectForKey:@"createId"];
        if (createId == [NSNull null] || createId == nil)
        {
            projectVo.strCreateID = @"";
        }
        else
        {
            projectVo.strCreateID = [createId stringValue];
        }
        
        projectVo.strProjectName = [Common checkStrValue:[dicActivityProject objectForKey:@"projectName"]];
        
        id isShow = [dicActivityProject objectForKey:@"isShow"];
        if (isShow == [NSNull null] || isShow == nil)
        {
            projectVo.bShow = NO;
        }
        else
        {
            projectVo.bShow = ([isShow integerValue]==1)?YES:NO;
        }
        
        projectVo.strCreateDate = [Common checkStrValue:[dicActivityProject objectForKey:@"createDate"]];
        
        //项目信息
        projectVo.strEndDateTime = [Common checkStrValue:[dicActivityProject objectForKey:@"endDate"]];
        projectVo.strActivityStartTime = [Common checkStrValue:[dicActivityProject objectForKey:@"projectStartDate"]];
        projectVo.strActivityEndTime = [Common checkStrValue:[dicActivityProject objectForKey:@"projectEndDate"]];
        projectVo.strAddress = [Common checkStrValue:[dicActivityProject objectForKey:@"projectAddress"]];
        
        id status = [dicActivityProject objectForKey:@"status"];
        if (status == [NSNull null] || status == nil)
        {
            projectVo.nStatus = 0;
        }
        else
        {
            projectVo.nStatus = [status integerValue];
        }
        
        //报名人数
        id signupCount = [dicActivityProject objectForKey:@"signupCount"];
        if (signupCount == [NSNull null] || signupCount == nil)
        {
            projectVo.nSignupCount = 0;
        }
        else
        {
            projectVo.nSignupCount = [signupCount integerValue];
        }
        
        //本人是否已经报名
        id isSignUp = [dicActivityProject objectForKey:@"isSignUp"];
        if (isSignUp == [NSNull null] || isSignUp == nil)
        {
            projectVo.nSelfSignup = 0;
        }
        else
        {
            projectVo.nSelfSignup = [isSignUp integerValue];
        }
        
        //如果本人已经报名获取留资信息
        id signUpVo = dicActivityProject[@"signUpVo"];
        if (signUpVo != [NSNull null] && [signUpVo isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dicSignUpVo = signUpVo;
            projectVo.strRealName = [Common checkStrValue:[dicSignUpVo objectForKey:@"realName"]];
            projectVo.strDepartmentName = [Common checkStrValue:[dicSignUpVo objectForKey:@"orgInfo"]];
            id phoneNumber = [dicSignUpVo objectForKey:@"phoneNumber"];
            if (phoneNumber == [NSNull null]|| phoneNumber == nil)
            {
                projectVo.strPhoneNumber = @"";
            }
            else
            {
                projectVo.strPhoneNumber = [phoneNumber stringValue];
            }
        }
        
        projectVo.strProjectDesc = [Common checkStrValue:[dicActivityProject objectForKey:@"projectDesc"]];
        
        [aryProjectList addObject:projectVo];
    }
    return aryProjectList;
}

//报名/////////////////////////////////////////////////////////////////
//活动首页列表
+ (void)getHomeActivityList:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getHomeActivityListURL]];
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
            
            //最新活动
            NSArray *aryNewList = [responseObject objectForKey:@"current"];
            if (aryNewList != nil)
            {
                retInfo.data  = [ActivityService getActivityListByJSONArray:aryNewList];
            }
            
            //活动回顾
            NSArray *aryReviewList = [responseObject objectForKey:@"review"];
            if (aryReviewList != nil)
            {
                retInfo.data2 = [ActivityService getActivityListByJSONArray:aryReviewList];
            }
        }
        resultBlock(retInfo);
    }];
}

//活动详情
+ (void)getActivityDetail:(NSString*)strBlogID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getActivityDetailURL],strBlogID];
    
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
            
            NSMutableArray *aryBlogList = [ActivityService getActivityListByJSONArray:@[responseObject]];
            if (aryBlogList.count>0)
            {
                BlogVo *blogVo = [aryBlogList objectAtIndex:0];
                blogVo.strContent = [blogVo.strContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
                retInfo.data = blogVo;
            }
        }
        resultBlock(retInfo);
    }];
}

//回答详情
+ (void)getAnswerDetail:(BlogVo *)blogVo result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getAnswerDetailURL],blogVo.streamId];
    
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
            blogVo.nCommentCount = [responseObject[@"commentCount"] integerValue];
            blogVo.nPraiseCount = [responseObject[@"praiseCount"] integerValue];
            retInfo.data = blogVo;
        }
        resultBlock(retInfo);
    }];
}

//活动报名
+ (void)signupActivityProject:(NSString *)strProjectID andUserVO:(UserVo*)userVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:strProjectID forKey:@"pId"];
    [dicBody setObject:userVo.strUserName forKey:@"realName"];
    [dicBody setObject:userVo.strPhoneNumber forKey:@"phoneNumber"];
    [dicBody setObject:userVo.strCompanyName forKey:@"orgInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSignupActivityProjectURL]];
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

//获取活动列表
+ (void)getActivityList:(NSString*)strSearch myActivity:(NSInteger)nSelfFlag page:(NSInteger)nPage size:(NSInteger)nSize result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (strSearch != nil)
    {
        [bodyDic setObject:strSearch forKey:@"titleName"];
    }
    
    if (nSelfFlag == 1)
    {
        //我的活动
        [bodyDic setObject:@1 forKey:@"selfFlag"];
    }
    else
    {
        //活动回顾
        [bodyDic setObject:@1 forKey:@"reviewFlag"];
    }
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nSize] forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getActivityListURL]];
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
            
            NSArray *aryActivityList = [responseObject objectForKey:@"content"];
            if (aryActivityList != nil)
            {
                retInfo.data  = [ActivityService getActivityListByJSONArray:aryActivityList];
            }
            
            //是否为最后一页
            id lastPage = [responseObject objectForKey:@"lastPage"];
            if (lastPage != [NSNull null] && lastPage != nil)
            {
                retInfo.data2 = lastPage;
            }
            else
            {
                retInfo.data2 = [NSNumber numberWithBool:NO];
            }
        }
        resultBlock(retInfo);
    }];
}

//获取已报名人员列表
+ (void)getActivityUserList:(NSString *)strActivityID page:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPageInfo setObject:[NSNumber numberWithInteger:15] forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    [bodyDic setObject:strActivityID forKey:@"id"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getActivityUserListURL]];
    [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            NSMutableArray *aryMemberList = nil;
            NSArray *aryJSONUserList = [responseObject objectForKey:@"content"];
            if (aryJSONUserList != nil && aryJSONUserList.count>0)
            {
                aryMemberList = [ServerProvider getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryMemberList;
            retInfo.bSuccess = YES;
            
            //是否为最后一页
            id lastPage = [responseObject objectForKey:@"lastPage"];
            if (lastPage != [NSNull null] && lastPage != nil)
            {
                retInfo.data2 = lastPage;
            }
            else
            {
                retInfo.data2 = [NSNumber numberWithBool:NO];
            }
        }
        resultBlock(retInfo);
    }];
}

@end
