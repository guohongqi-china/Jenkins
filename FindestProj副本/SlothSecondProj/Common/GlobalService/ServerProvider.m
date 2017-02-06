//
//  ServerProvider.m
//  Sloth
//
//  Created by Ann Yao on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServerProvider.h"
#import "Utils.h"
#import "Common.h"
#import "ServerURL.h"
#import "CommentVo.h"
#import "NotifyVo.h"
#import "ServerURL.h"
#import "VoteOptionVo.h"
#import "ChatObjectVo.h"
#import "SendChatVo.h"
#import "ChineseToPinyin.h"
#import "ChatContentVo.h"
#import "PublishVo.h"
#import "UserVo.h"
#import "FaceModel.h"
#import "ScheduleJoinStateVo.h"
#import "AttachmentVo.h"
#import "KeyValueVo.h"
#import "TagVo.h"
#import "ReceiverVo.h"
#import "BlogVo.h"
#import "AlbumInfoVO.h"
#import "AlbumImageVO.h"
#import "UploadFileVo.h"
#import "PraiseVo.h"
#import "LotteryOptionVo.h"
#import "ActivityProjectVo.h"
#import "DepartmentVo.h"
#import "AnnouncementVo.h"
#import "ShareInfoVo.h"
#import "QuestionSurveyVo.h"
#import "QuestionVo.h"
#import "FieldVo.h"
#import "SuggestionBaseVo.h"
#import "SuggestionRoleVo.h"
#import "IntegrationDetailVo.h"
#import "RedPacketVo.h"
#import "CompanyRankingVo.h"
#import "VNetworkFramework.h"
#import "SYTextAttachment.h"
#import "SkinManage.h"
#import "FindestProj-Swift.h"

#define BODY_NULL @"获取数据失败"

@implementation ServerProvider

//将消息JSON转换为对象数组
+(NSMutableArray*)getMessageListByJSONArray:(NSArray*)aryResponse
{
    if ([aryResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSMutableArray *aryMessageList = [NSMutableArray array];
    for (int i = 0; i < [aryResponse count]; i++)
    {
        NSDictionary *dicAllNews = (NSDictionary*)[aryResponse objectAtIndex:i];
        //消息(基本信息)
        MessageVo *messageVo = [[MessageVo alloc]init];
        id Id = [dicAllNews objectForKey:@"id"];
        if (Id == [NSNull null])
        {
            messageVo.strID = @"";
        }
        else
        {
            messageVo.strID = [Id stringValue];
        }
        
        messageVo.strTitle = [Common checkStrValue:[dicAllNews objectForKey:@"titleName"]];
        
        id titleId = [dicAllNews objectForKey:@"titleId"];
        if (titleId == [NSNull null] || titleId == nil)
        {
            messageVo.strTitleID = @"";
        }
        else
        {
            messageVo.strTitleID = [titleId stringValue];
        }
        
        messageVo.strHtmlContent = [Common checkStrValue:[dicAllNews objectForKey:@"streamContent"]];
        messageVo.strTextContent = [Common checkStrValue:[dicAllNews objectForKey:@"streamText"]];
        messageVo.strMsgType = [Common checkStrValue:[dicAllNews objectForKey:@"streamType"]];
        
        id comefrom = [dicAllNews objectForKey:@"streamComefrom"];
        if (comefrom == [NSNull null])
        {
            messageVo.nComeFromType = -1;
        }
        else
        {
            messageVo.nComeFromType = [comefrom intValue];
        }
        
        messageVo.strCreateDate = [Common checkStrValue:[dicAllNews objectForKey:@"createDate"]];
        id createBy = [dicAllNews objectForKey:@"createBy"];
        if (createBy == [NSNull null])
        {
            messageVo.strAuthorID  = @"";
        }
        else
        {
            messageVo.strAuthorID  = [createBy stringValue];
        }
        
        //星标
        id starTag = [dicAllNews objectForKey:@"starTag"];
        if (starTag == [NSNull null])
        {
            messageVo.bHasStarTag = NO;
        }
        else
        {
            messageVo.bHasStarTag = ([starTag integerValue])==1?YES:NO;
        }
        
        messageVo.strAuthorName = [Common checkStrValue:[dicAllNews objectForKey:@"userNickname"]];//createByName
        messageVo.strAuthorHeadImg = [ServerURL getWholeURL:[Common checkStrValue:[dicAllNews objectForKey:@"userImgUrl"]]];
        
        //解析收件人,抄送人，密送人
        messageVo.aryReceiverList = [NSMutableArray array];
        messageVo.aryCCList = [NSMutableArray array];
        messageVo.aryBCCList = [NSMutableArray array];
        NSArray  *aryReceiverList= [dicAllNews objectForKey:@"streamReadShipList"];
        for (int i= 0;i<aryReceiverList.count;i++)
        {
            NSDictionary *dicReceiver = [aryReceiverList objectAtIndex:i];
            ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
            receiverVo.strID = [dicReceiver objectForKey:@"receiverId"];
            receiverVo.strName = [dicReceiver objectForKey:@"receiverName"];
            receiverVo.strType = [dicReceiver objectForKey:@"receiverType"];
            receiverVo.strCCType = [dicReceiver objectForKey:@"ccType"];
            
            if ([receiverVo.strCCType isEqualToString:@"T"])
            {
                [messageVo.aryReceiverList addObject:receiverVo];//发送
            }
            else if ([receiverVo.strCCType isEqualToString:@"C"])
            {
                [messageVo.aryCCList addObject:receiverVo];//抄送
            }
            else if ([receiverVo.strCCType isEqualToString:@"B"])
            {
                [messageVo.aryBCCList addObject:receiverVo];//秘送
            }
        }
        
        id delFlag = [dicAllNews objectForKey:@"delFlag"];
        if (delFlag == [NSNull null])
        {
            messageVo.nDeleteFlag = -1;
        }
        else {
            messageVo.nDeleteFlag = [[dicAllNews objectForKey:@"delFlag"]intValue];
        }
        
        id nureader = [dicAllNews objectForKey:@"unreader"];
        if (nureader == [NSNull null])
        {
            messageVo.nUnreader = -1;
        }
        else
        {
            messageVo.nUnreader = [[dicAllNews objectForKey:@"unreader"]intValue];
        }
        
        //设置【已转发或已回复的邮件】状态
        NSString *actionMark = [Common checkStrValue:[dicAllNews objectForKey:@"actionMark"]];
        if (actionMark.length != 0)
        {
            if(messageVo.nUnreader != 1)
            {
                messageVo.nUnreader = 3;
            }
        }
        
        messageVo.strContentType = [Common checkStrValue:[dicAllNews objectForKey:@"annexation"]];
        
        //投票
        NSDictionary * dicVote =[dicAllNews objectForKey:@"vote"];
        if (dicVote == nil || (id) dicVote == [NSNull null])
        {
            messageVo.voteVo = nil;
        }
        else
        {
            messageVo.voteVo = [[VoteVo alloc]init];
            messageVo.voteVo.strID = [[dicVote objectForKey:@"id"]stringValue];
            
            id votetype = [dicVote objectForKey:@"voteType"];
            if (votetype == [NSNull null])
            {
                messageVo.voteVo.nVoteType = -1;
            }
            else
            {
                messageVo.voteVo.nVoteType = [[dicVote objectForKey:@"voteType"]intValue];
            }
            //投票数量总数
            id votetolal = [dicVote objectForKey:@"voteTotal"];
            if (votetolal == [NSNull null])
            {
                messageVo.voteVo.nVoteTotal = 0;
            }
            else
            {
                messageVo.voteVo.nVoteTotal = [[dicVote objectForKey:@"voteTotal"]intValue];
            }
            //投票人总数
            id votePersonTolal = [dicVote objectForKey:@"numberPeople"];
            if (votePersonTolal == [NSNull null])
            {
                messageVo.voteVo.nVotePersonTotal = 0;
            }
            else
            {
                messageVo.voteVo.nVotePersonTotal = [votePersonTolal intValue];
            }
            
            //当前用户是否投过票
            id voted = [dicVote objectForKey:@"voted"];
            if (votePersonTolal == [NSNull null])
            {
                messageVo.voteVo.bAlreadVote = NO;
            }
            else
            {
                messageVo.voteVo.bAlreadVote = [voted boolValue];
            }
            
            //投票选项
            messageVo.voteVo.aryVoteOption = [NSMutableArray array];
            NSArray *aryVoteOption = [dicVote objectForKey:@"voteOptionList"];
            if ( (id)aryVoteOption != [NSNull null] && aryVoteOption != nil)
            {
                for (int i=0; i<aryVoteOption.count; i++)
                {
                    NSDictionary *dicObject = [aryVoteOption objectAtIndex:i];
                    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
                    id optionId = [dicObject objectForKey:@"id"];
                    if (optionId == [NSNull null])
                    {
                        voteOptionVo.nOptionId = 0;
                    }
                    else
                    {
                        voteOptionVo.nOptionId = [optionId intValue];
                    }
                    
                    voteOptionVo.strOptionName = [Common checkStrValue:[dicObject objectForKey:@"content"]];
                    id count = [dicObject objectForKey:@"count"];
                    if (count == [NSNull null])
                    {
                        voteOptionVo.nCount = 0;
                    }
                    else
                    {
                        voteOptionVo.nCount = [count intValue];
                    }
                    
                    voteOptionVo.strVoterName = [Common checkStrValue:[dicObject objectForKey:@"voter"]];
                    NSString *strImgURL = [Common checkStrValue:[dicObject objectForKey:@"downloadImageUri"]];
                    if (strImgURL.length>0)
                    {
                        voteOptionVo.strImage = [ServerURL getWholeURL:strImgURL];
                    }
                    
                    //当前用户是否投过该选项
                    id selected = [dicObject objectForKey:@"selected"];
                    if (selected == [NSNull null])
                    {
                        voteOptionVo.bAlreadyVote = NO;
                    }
                    else
                    {
                        voteOptionVo.bAlreadyVote = [selected boolValue];
                    }
                    
                    [messageVo.voteVo.aryVoteOption addObject:voteOptionVo];
                }
            }
        }
        
        //约会
        NSDictionary * dicSchedule =[dicAllNews objectForKey:@"schedule"];
        if (dicSchedule == nil || (id) dicSchedule == [NSNull null])
        {
            messageVo.scheduleVo = nil;
        }
        else
        {
            messageVo.scheduleVo = [[ScheduleVo alloc]init];
            messageVo.scheduleVo.strId = [[dicSchedule objectForKey:@"id"]stringValue];
            messageVo.scheduleVo.strStartTime = [Common checkStrValue:[dicSchedule objectForKey:@"startTime"]];
            
            id duration = [dicSchedule objectForKey:@"duration"];
            if (duration == [NSNull null])
            {
                messageVo.scheduleVo.lDuration = -1;
            }
            else
            {
                messageVo.scheduleVo.lDuration = [[dicSchedule objectForKey:@"duration"]intValue];
            }
            messageVo.scheduleVo.strAddress = [Common checkStrValue:[dicSchedule objectForKey:@"place"]];
            
            messageVo.scheduleVo.strScheduleContent = [NSString stringWithFormat:@"<br><hr/><br>时间：%@<br><br> 地点：%@<br>",messageVo.scheduleVo.strStartTime,messageVo.scheduleVo.strAddress];
            //追加时间和地点
            messageVo.strHtmlContent = [NSString stringWithFormat:@"%@%@",messageVo.strHtmlContent,messageVo.scheduleVo.strScheduleContent];
            
            //约会人员回应状态列表
            messageVo.scheduleVo.aryUserJoinState = [NSMutableArray array];
            NSArray *aryUserJoinState = [dicSchedule objectForKey:@"scheduleUserList"];
            if ( (id)aryUserJoinState != [NSNull null] && aryUserJoinState != nil)
            {
                for (int i=0; i<aryUserJoinState.count; i++)
                {
                    NSDictionary *dicObject = [aryUserJoinState objectAtIndex:i];
                    ScheduleJoinStateVo *scheduleJoinStateVo = [[ScheduleJoinStateVo alloc]init];
                    scheduleJoinStateVo.strID = [[dicObject objectForKey:@"id"]stringValue];
                    scheduleJoinStateVo.strUserID = [[dicObject objectForKey:@"userId"]stringValue];
                    
                    id objReply = [dicObject objectForKey:@"reply"];
                    if (objReply == [NSNull null])
                    {
                        //默认为3
                        scheduleJoinStateVo.nReply = 3;
                    }
                    else
                    {
                        scheduleJoinStateVo.nReply = [objReply intValue];
                    }
                    
                    scheduleJoinStateVo.strUserName = [Common checkStrValue:[dicObject objectForKey:@"userName"]];
                    [messageVo.scheduleVo.aryUserJoinState addObject:scheduleJoinStateVo];
                }
            }
        }
        
        //标签列表
        messageVo.aryTagList = [NSMutableArray array];
        NSArray *aryJSONTagList =[dicAllNews objectForKey:@"tagVoList"];
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
                [messageVo.aryTagList addObject:tagVo];
            }
        }
        
        //抽奖信息
        NSDictionary * dicLottery =[dicAllNews objectForKey:@"lotteryVo"];
        if (dicLottery == nil || (id) dicLottery == [NSNull null])
        {
            messageVo.lotteryVo = nil;
        }
        else
        {
            messageVo.lotteryVo = [[LotteryVo alloc]init];
            messageVo.lotteryVo.strLotteryID = [[dicLottery objectForKey:@"id"]stringValue];
            
            id numberPeople = [dicLottery objectForKey:@"numberPeople"];
            if (numberPeople == [NSNull null])
            {
                messageVo.lotteryVo.nLotterySumNum = -1;
            }
            else
            {
                messageVo.lotteryVo.nLotterySumNum = [numberPeople integerValue];
            }
            
            id finished = [dicLottery objectForKey:@"finished"];
            if (finished == [NSNull null])
            {
                messageVo.lotteryVo.bDrawLottery = NO;
            }
            else
            {
                messageVo.lotteryVo.bDrawLottery = ([finished integerValue]==1)?YES:NO;
            }
            
            messageVo.lotteryVo.strEndTime = [Common checkStrValue:[dicLottery objectForKey:@"endDate"]];
            
            id lotteryOptionId = [dicLottery objectForKey:@"lotteryOptionId"];
            if (lotteryOptionId == [NSNull null])
            {
                messageVo.lotteryVo.strWinOptionID = @"";
            }
            else
            {
                messageVo.lotteryVo.strWinOptionID = [lotteryOptionId stringValue];
            }
            
            id expired = [dicLottery objectForKey:@"expired"];
            if (expired == [NSNull null])
            {
                messageVo.lotteryVo.bExpired = NO;
            }
            else
            {
                messageVo.lotteryVo.bExpired = ([expired integerValue]==1)?YES:NO;
            }
            
            //奖项
            messageVo.lotteryVo.aryLotteryOption = [NSMutableArray array];
            NSArray *aryLotteryOption = [dicLottery objectForKey:@"lotteryOptionVoList"];
            if ( (id)aryLotteryOption != [NSNull null] && aryLotteryOption != nil)
            {
                for (int i=0; i<aryLotteryOption.count; i++)
                {
                    NSDictionary *dicLotteryOption = [aryLotteryOption objectAtIndex:i];
                    
                    LotteryOptionVo *lotteryOptionVo = [[LotteryOptionVo alloc]init];
                    id lotteryID = [dicLotteryOption objectForKey:@"id"];
                    if (lotteryID == nil || lotteryID == [NSNull null])
                    {
                        lotteryOptionVo.strLotteryOptionID = @"";
                    }
                    else
                    {
                        lotteryOptionVo.strLotteryOptionID = [lotteryID stringValue];
                    }
                    
                    lotteryOptionVo.strLotteryName = [dicLotteryOption objectForKey:@"content"];
                    
                    id numberPeople = [dicLotteryOption objectForKey:@"numberPeople"];
                    if (numberPeople == nil || numberPeople == [NSNull null])
                    {
                        lotteryOptionVo.nLotteryNum = 0;
                    }
                    else
                    {
                        lotteryOptionVo.nLotteryNum = [numberPeople integerValue];
                    }
                    
                    id surplus = [dicLotteryOption objectForKey:@"surplus"];
                    if (surplus == nil || surplus == [NSNull null])
                    {
                        lotteryOptionVo.nLotteryLeftNum = 0;
                    }
                    else
                    {
                        lotteryOptionVo.nLotteryLeftNum = [surplus integerValue];
                    }
                    
                    lotteryOptionVo.strLotteryImgUrl = [Common checkStrValue:[dicLotteryOption objectForKey:@"downloadImageUri"]];
                    if (lotteryOptionVo.strLotteryImgUrl.length > 0)
                    {
                        lotteryOptionVo.strLotteryImgUrl = [ServerURL getWholeURL:lotteryOptionVo.strLotteryImgUrl];
                    }
                    
                    lotteryOptionVo.strWinLotteryName = [Common checkStrValue:[dicLotteryOption objectForKey:@"userNames"]];
                    lotteryOptionVo.bExpansion = NO;
                    
                    [messageVo.lotteryVo.aryLotteryOption addObject:lotteryOptionVo];
                }
            }
        }
        
        //附件列表
        messageVo.aryAttachmentList = [NSMutableArray array];
        id attachmentList = [dicAllNews objectForKey:@"attaList"];
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
                
                [messageVo.aryAttachmentList addObject:attachmentVo];
            }
        }
        
        //逻辑删除的数据不加入到数组里面
        if (messageVo.nDeleteFlag == 1)
        {
            continue;
        }
        else
        {
            [aryMessageList addObject:messageVo];
        }
    }
    return aryMessageList;
}

//将用户JSON转换为对象数组
+(NSMutableArray*)getUserListByJSONArray:(NSArray*)aryUserList
{
    NSMutableArray *aryMemberList = [NSMutableArray array];
    for (NSDictionary *dicUserInfo in aryUserList)
    {
        UserVo *userVo = [[UserVo alloc]init];
        
        id userID = [dicUserInfo objectForKey:@"id"];
        if (userID == [NSNull null]|| userID == nil)
        {
            userVo.strUserID = @"";
        }
        else
        {
            userVo.strUserID = [userID stringValue];
        }
        
        userVo.strLoginAccount = [Common checkStrValue:[dicUserInfo objectForKey:@"loginName"]];
        
        userVo.strSignature = [Common checkStrValue:[dicUserInfo objectForKey:@"signature"]];
        
        userVo.strQQ = [Common checkStrValue:[dicUserInfo objectForKey:@"qq"]];
        
        id phoneNumber = [dicUserInfo objectForKey:@"phoneNumber"];
        if (phoneNumber == [NSNull null]|| phoneNumber == nil)
        {
            userVo.strPhoneNumber = @"";
        }
        else
        {
            userVo.strPhoneNumber = [phoneNumber stringValue];
        }
        
        id gender = [dicUserInfo objectForKey:@"gender"];
        if (gender == [NSNull null]|| userID == nil)
        {
            userVo.gender = 2;
        }
        else
        {
            userVo.gender = [gender intValue];
        }
        
        userVo.strBirthday = [Common checkStrValue:[dicUserInfo objectForKey:@"birthdayFormat"]];
        userVo.strUserName = [Common checkStrValue:[dicUserInfo objectForKey:@"userName"]];//userName userNickname(列表内用userName)
        userVo.strRealName = [Common checkStrValue:[dicUserInfo objectForKey:@"trueName"]];
        userVo.strPosition = [Common checkStrValue:[dicUserInfo objectForKey:@"title"]];
        userVo.strEmail = [Common checkStrValue:[dicUserInfo objectForKey:@"email"]];
        userVo.strAddress = [Common checkStrValue:[dicUserInfo objectForKey:@"address"]];
        userVo.strFirstLetter = [[Common checkStrValue:[dicUserInfo objectForKey:@"firstLetter"]] uppercaseString];
        
        //推荐说明
        userVo.strRecommendDes = [Common checkStrValue:[dicUserInfo objectForKey:@"recommend"]];
        
        //是否逻辑删除
        id isLock = [dicUserInfo objectForKey:@"isLock"];
        if (isLock == [NSNull null]|| isLock == nil)
        {
            userVo.nRecordStatus = 0;
        }
        else
        {
            userVo.nRecordStatus = [isLock intValue];
        }
        
        userVo.strPartImageURL = [Common checkStrValue:[dicUserInfo objectForKey:@"userImgUrl"]];
        userVo.strHeadImageURL = [ServerURL getWholeURL:userVo.strPartImageURL];
        userVo.strMaxHeadImageURL = [ServerURL getWholeURL:[Common checkStrValue:[dicUserInfo objectForKey:@"maxImageUrl"]]];//头像大图
        
        userVo.strCoverImageURL = [Common checkStrValue:[dicUserInfo objectForKey:@"backPicUrl"]];
        if (userVo.strCoverImageURL.length>0)
        {
            NSRange range = [userVo.strCoverImageURL rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
            if (range.length==0)
            {
                //需要追加前缀
                userVo.strCoverImageURL = [ServerURL getWholeURL:userVo.strCoverImageURL];
            }
        }
        
        //是否显示手机号码	1:显示 0:不显示
        id viewPhone = [dicUserInfo objectForKey:@"viewPhone"];
        if (viewPhone == [NSNull null]|| viewPhone == nil)
        {
            userVo.bViewPhone = NO;
        }
        else
        {
            userVo.bViewPhone = ([viewPhone intValue] == 1) ? YES : NO;
        }
        
        //是否显示收藏夹	1:显示 0:不显示
        id viewStore = [dicUserInfo objectForKey:@"viewStore"];
        if (viewStore == [NSNull null]|| viewStore == nil)
        {
            userVo.bViewFavorite = NO;
        }
        else
        {
            userVo.bViewFavorite = ([viewStore integerValue] == 1) ? YES : NO;
        }
        
        id isFollow = [dicUserInfo objectForKey:@"isFollow"];
        if (isFollow == [NSNull null]|| isFollow == nil)
        {
            userVo.bAttentioned = NO;
        }
        else
        {
            int nIsFollow = [isFollow intValue];
            if (nIsFollow == 1)
            {
                userVo.bAttentioned = YES;
            }
            else
            {
                userVo.bAttentioned = NO;
            }
        }
        
        //消息数量
        id streamCount = [dicUserInfo objectForKey:@"streamCount"];
        if (streamCount == [NSNull null]|| streamCount == nil)
        {
            userVo.nArticleCount = 0;
        }
        else
        {
            userVo.nArticleCount = [streamCount intValue];
        }
        
        //分享数量
        id blogCount = [dicUserInfo objectForKey:@"blogCount"];
        if (blogCount == [NSNull null]|| blogCount == nil)
        {
            userVo.nShareCount = 0;
        }
        else
        {
            userVo.nShareCount = [blogCount intValue];
        }
        
        //提问数量
        id questionCount = [dicUserInfo objectForKey:@"questionCount"];
        if (questionCount == [NSNull null]|| questionCount == nil)
        {
            userVo.nQACount = 0;
        }
        else
        {
            userVo.nQACount = [questionCount intValue];
        }
        
        //关注人数
        id attentionCount = [dicUserInfo objectForKey:@"attentionCount"];
        if (attentionCount == [NSNull null]|| attentionCount == nil)
        {
            userVo.nAttentionCount = 0;
        }
        else
        {
            userVo.nAttentionCount = [attentionCount integerValue];
        }
        
        //粉丝人数
        id fansCount = [dicUserInfo objectForKey:@"fansCount"];
        if (fansCount == [NSNull null]|| fansCount == nil)
        {
            userVo.nFansCount = 0;
        }
        else
        {
            userVo.nFansCount = [fansCount integerValue];
        }
        
        //用户积分
        id integral = [dicUserInfo objectForKey:@"integral"];
        if (integral == [NSNull null]|| integral == nil)
        {
            userVo.fIntegrationCount = 0.0f;
        }
        else
        {
            userVo.fIntegrationCount = [integral doubleValue];
        }
        
        id integralBadge = [dicUserInfo objectForKey:@"integralBadge"];
        if (integralBadge == [NSNull null]|| integralBadge == nil)
        {
            userVo.fBadgeIntegral = 0;
        }
        else
        {
            userVo.fBadgeIntegral = [integralBadge doubleValue];
        }
        
        //昨日积分
        id integralDaily = [dicUserInfo objectForKey:@"integralDaily"];
        if (integralDaily == [NSNull null]|| integralDaily == nil)
        {
            userVo.fIntegralDaily = 0;
        }
        else
        {
            userVo.fIntegralDaily = [integralDaily doubleValue];
        }
        
        //排名
        id ranking = [dicUserInfo objectForKey:@"ranking"];
        if (ranking == [NSNull null]|| ranking == nil)
        {
            userVo.nIndex = 0;
        }
        else
        {
            userVo.nIndex = [ranking integerValue];
        }
        userVo.strRankingState = [Common checkStrValue:[dicUserInfo objectForKey:@"integralUpDown"]];
        
        id badge = [dicUserInfo objectForKey:@"badge"];
        if (badge == [NSNull null]|| badge == nil)
        {
            userVo.nBadge = 0;
        }
        else
        {
            userVo.nBadge = [badge integerValue];
        }
        
        id receiveMessage = [dicUserInfo objectForKey:@"receiveMessage"];
        if (receiveMessage == [NSNull null]|| receiveMessage == nil)
        {
            userVo.strReceiveMessage = @"0";
        }
        else
        {
            userVo.strReceiveMessage = [receiveMessage stringValue];
        }
        
        id orgId = [dicUserInfo objectForKey:@"orgId"];
        if (orgId == [NSNull null]|| orgId == nil)
        {
            userVo.strCompanyID = @"0";
        }
        else
        {
            userVo.strCompanyID = [orgId stringValue];
        }
        
        userVo.strCompanyName = [Common checkStrValue:[dicUserInfo objectForKey:@"orgName"]];
        
        id departmentId = [dicUserInfo objectForKey:@"departmentId"];
        if (departmentId == [NSNull null]|| departmentId == nil)
        {
            userVo.strDepartmentId = @"";
        }
        else
        {
            userVo.strDepartmentId = [departmentId stringValue];
        }
        
        userVo.strDepartmentName = [Common checkStrValue:[dicUserInfo objectForKey:@"departmentName"]];
        
        userVo.aryDepartmentList = [NSMutableArray array];
        id deptList = [dicUserInfo objectForKey:@"deptList"];
        if (deptList != nil && deptList != [NSNull null] && [deptList isKindOfClass:[NSArray class]])
        {
            NSArray *aryDepartmentList = deptList;
            for (int i=0; i<aryDepartmentList.count; i++)
            {
                NSDictionary *dicDepartment = [aryDepartmentList objectAtIndex:i];
                DepartmentVo *departmentVo = [[DepartmentVo alloc]init];
                id departmentId = [dicDepartment objectForKey:@"id"];
                if (departmentId == nil || departmentId == [NSNull null])
                {
                    
                    departmentVo.strDepartmentID = @"";
                }
                else
                {
                    departmentVo.strDepartmentID = [departmentId stringValue];
                }
                departmentVo.strDepartmentName = [Common checkStrValue:[dicDepartment objectForKey:@"departmentName"]];
                [userVo.aryDepartmentList addObject:departmentVo];
            }
        }
        
        //get pinyin
        NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:userVo.strUserName];
        if(aryPinyin!=nil && aryPinyin.count>0)
        {
            userVo.strQP = [aryPinyin objectAtIndex:0];
            //简拼以web端的首字母为标准,全拼以本地为主
            if (userVo.strQP.length == 0)
            {
                userVo.strQP = userVo.strFirstLetter;
            }
            
            if (aryPinyin.count>1)
            {
                userVo.strJP = [aryPinyin objectAtIndex:1];
                if (userVo.strFirstLetter.length>0)
                {
                    userVo.strJP = userVo.strFirstLetter;
                }
            }
        }
        else
        {
            userVo.strQP = userVo.strFirstLetter;
            userVo.strJP = userVo.strFirstLetter;
        }
        
        [aryMemberList addObject:userVo];
    }
    return aryMemberList;
}

//获取聊天记录
+ (NSMutableArray*)getChatListByJSONArray:(NSArray*)aryChatJSONList andType:(NSInteger)nType
{
    NSMutableArray *aryChatContent = [NSMutableArray array];
    for (NSDictionary *dicContent in aryChatJSONList)
    {
        ChatContentVo *chatContentVo = [[ChatContentVo alloc]init];
        chatContentVo.strCId = [Common checkStrValue:[dicContent objectForKey:@"id"]];
        id tempVestID = [dicContent objectForKey:@"fromUserId"];
        if ([tempVestID isKindOfClass:[NSString class]])
        {
            chatContentVo.strVestId = tempVestID;
        }
        else
        {
            chatContentVo.strVestId = [tempVestID stringValue];
        }
        chatContentVo.strVestNodeId = [Common checkStrValue:[dicContent objectForKey:@"from"]];
        chatContentVo.strName = [Common checkStrValue:[dicContent objectForKey:@"fromUserName"]];
        
        chatContentVo.strHeadImg = [Common checkStrValue:[dicContent objectForKey:@"fromUserPhoto"]];
        chatContentVo.strHeadImg = [ServerURL getWholeURL:chatContentVo.strHeadImg];
        
        chatContentVo.strChatTime = [Common checkStrValue:[dicContent objectForKey:@"createDateFmt"]];
        
        chatContentVo.strContent = [Common checkStrValue:[dicContent objectForKey:@"contentText"]];
        chatContentVo.strContent = [Common replaceLineBreak:chatContentVo.strContent];
        
        id createDate = [dicContent objectForKey:@"createDate"];
        if (createDate == [NSNull null] || createDate == nil)
        {
            chatContentVo.nChatTime = 0;
        }
        else
        {
            chatContentVo.nChatTime = [createDate longLongValue];
        }
        
        chatContentVo.nChatType = nType;
        id contentType = [dicContent objectForKey:@"type"];
        if (contentType == [NSNull null] || contentType == nil)
        {
            chatContentVo.nContentType = -1;
        }
        else
        {
            chatContentVo.nContentType = [contentType intValue];
        }
        
        if (chatContentVo.nContentType == 1)
        {
            //图片
            chatContentVo.strImgURL = [Common checkStrValue:[dicContent objectForKey:@"filePathUri"]];
            chatContentVo.strImgURL = [ServerURL getWholeURL:chatContentVo.strImgURL];
            
            chatContentVo.strSmallImgURL = [Common checkStrValue:[dicContent objectForKey:@"filePathMidUri"]];
            chatContentVo.strSmallImgURL = [ServerURL getWholeURL:chatContentVo.strSmallImgURL];
        }
        else if (chatContentVo.nContentType == 2)
        {
            //附件
            chatContentVo.strFileURL = [Common checkStrValue:[dicContent objectForKey:@"filePathUri"]];
            chatContentVo.strFileURL = [ServerURL getWholeURL:chatContentVo.strFileURL];
            chatContentVo.strFileName = [Common checkStrValue:[dicContent objectForKey:@"fileName"]];
            
            id fileId = [dicContent objectForKey:@"fileId"];
            if (fileId == [NSNull null] || fileId == nil)
            {
                chatContentVo.strFileID = @"";
            }
            else
            {
                chatContentVo.strFileID = [fileId stringValue];
            }
            
            id fileLength = [dicContent objectForKey:@"fileLength"];
            if (fileLength == [NSNull null] || fileLength == nil)
            {
                chatContentVo.lFileSize = 0;
            }
            else
            {
                chatContentVo.lFileSize = [fileLength longLongValue];
            }
        }
        else if (chatContentVo.nContentType == 3)
        {
            //语音
            chatContentVo.strContent = [Common checkStrValue:[dicContent objectForKey:@"content"]];
            
            //语音文件
            NSArray *aryFileJSONList  = [dicContent objectForKey:@"filePath"];
            if (aryFileJSONList != nil && aryFileJSONList.count>0)
            {
                chatContentVo.strFileURL = [ServerURL getWholeURL:[aryFileJSONList objectAtIndex:0]];
            }
            chatContentVo.strFileName = [Common checkStrValue:[dicContent objectForKey:@"fileName"]];
            chatContentVo.bAudioPlaying = NO;
            
            id fileId = [dicContent objectForKey:@"fileId"];
            if (fileId == [NSNull null] || fileId == nil)
            {
                chatContentVo.strFileID = @"";
            }
            else
            {
                chatContentVo.strFileID = [fileId stringValue];
            }
        }
        
        [aryChatContent addObject:chatContentVo];
    }
    return aryChatContent;
}

//将分享JSON转换为对象数组
+(NSMutableArray*)getBlogListByJSONArray:(NSArray*)aryBlogJSONList
{
    if (![aryBlogJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryBlogList = [NSMutableArray array];
    for (int i=0;i<aryBlogJSONList.count;i++)
    {
        NSDictionary *dicBlogInfo = aryBlogJSONList[i];
        
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
        if ([SkinManage getCurrentSkin] == SkinNightType)
        {
            blogVo.strContent = [blogVo.strContent stringByReplacingOccurrencesOfString:@"class=\"article-content\"" withString:@"class=\"article-content-night\""];
        }
        
        blogVo.strText = [Common checkStrValue:[dicBlogInfo objectForKey:@"streamText"]];
        
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
        blogVo.strBlogType = [Common checkStrValue:[dicBlogInfo objectForKey:@"type"]];
        
        
        if (blogVo.nBlogType == 1)
        {
            blogVo.strBlogType = @"activity";//活动
        }
        
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
        
        //video list
        blogVo.aryVideoUrl = [NSMutableArray array];
        id videoList = [dicBlogInfo objectForKey:@"videoList"];
        if(videoList != [NSNull null] && [videoList isKindOfClass:[NSArray class]])
        {
            [blogVo.aryVideoUrl removeAllObjects];
            for (NSDictionary *dicVideo in videoList)
            {
                NSString *strVideoURL = [Common checkStrValue:dicVideo[@"resourceUri"]];
                
                NSRange range = [strVideoURL rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
                if (range.length==0)
                {
                    //需要追加前缀
                    strVideoURL = [ServerURL getWholeURL:strVideoURL];
                }
                [blogVo.aryVideoUrl addObject:strVideoURL];
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
        
        //问卷调查
        id surveyFlag = [dicBlogInfo objectForKey:@"surveyFlag"];
        if (surveyFlag == [NSNull null]|| surveyFlag == nil)
        {
            blogVo.nSurveyFlag = 1;
        }
        else
        {
            blogVo.nSurveyFlag = [surveyFlag integerValue];
        }
        
        //获取前三个评论列表
        id jsonComment = [dicBlogInfo objectForKey:@"commentVoList"];
        if (jsonComment == [NSNull null] || jsonComment == nil)
        {
            blogVo.aryComment = nil;
        }
        else
        {
            blogVo.aryComment = [ServerProvider getCommentListByJSONArray:jsonComment];
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
        
        //        //赞列表
        //        blogVo.aryPraiseList = [NSMutableArray array];
        //        id mentionList =  [dicBlogInfo objectForKey:@"mentionList"];
        //        if (mentionList != [NSNull null] && mentionList != nil && [mentionList isKindOfClass:[NSArray class]])
        //        {
        //            NSArray *aryJSONPraiseList =  mentionList;
        //            for (NSDictionary *dic in aryJSONPraiseList)
        //            {
        //                PraiseVo *praiseVo = [[PraiseVo alloc]init];
        //                id paiserId = [dic objectForKey:@"id"];
        //                if (paiserId == [NSNull null]|| paiserId == nil)
        //                {
        //                    praiseVo.strID = @"";
        //                }
        //                else
        //                {
        //                    praiseVo.strID = [paiserId stringValue];
        //                }
        //                
        //                praiseVo.strAliasName = [Common checkStrValue:[dic objectForKey:@"aliasName"]];
        //                praiseVo.imageUrl = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"imageUrl"]]];
        //                
        //                id orgId = [dic objectForKey:@"orgId"];
        //                if (orgId == [NSNull null]|| orgId == nil)
        //                {
        //                    praiseVo.orgId = @"";
        //                }
        //                else
        //                {
        //                    praiseVo.orgId = [orgId stringValue];
        //                }
        //                praiseVo.strTitle = [Common checkStrValue:[dic objectForKey:@"title"]];
        //                
        //                id phoneNumber = [dic objectForKey:@"phoneNumber"];
        //                if (phoneNumber == [NSNull null]|| phoneNumber == nil)
        //                {
        //                    praiseVo.phoneNumber = @"";
        //                }
        //                else
        //                {
        //                    praiseVo.phoneNumber = [phoneNumber stringValue];
        //                }
        //                
        //                [blogVo.aryPraiseList addObject:praiseVo];
        //            }
        //        }
        
        //投票
        NSDictionary * dicVote =[dicBlogInfo objectForKey:@"vote"];
        if (dicVote == nil || (id) dicVote == [NSNull null])
        {
            blogVo.voteVo = nil;
        }
        else
        {
            blogVo.voteVo = [[VoteVo alloc]init];
            blogVo.voteVo.strID = [[dicVote objectForKey:@"id"]stringValue];
            
            id votetype = [dicVote objectForKey:@"voteType"];
            if (votetype == [NSNull null])
            {
                blogVo.voteVo.nVoteType = -1;
            }
            else
            {
                blogVo.voteVo.nVoteType = [[dicVote objectForKey:@"voteType"]intValue];
            }
            
            //最少选项
            id minItem = [dicVote objectForKey:@"minItem"];
            if (minItem == [NSNull null])
            {
                blogVo.voteVo.nMinOption = 0;
            }
            else
            {
                blogVo.voteVo.nMinOption = [minItem integerValue];
            }
            
            //最多选项
            id maxItem = [dicVote objectForKey:@"maxItem"];
            if (maxItem == [NSNull null])
            {
                blogVo.voteVo.nMaxOption = 0;
            }
            else
            {
                blogVo.voteVo.nMaxOption = [maxItem integerValue];
            }
            
            //投票数量总数
            id votetolal = [dicVote objectForKey:@"voteTotal"];
            if (votetolal == [NSNull null])
            {
                blogVo.voteVo.nVoteTotal = 0;
            }
            else
            {
                blogVo.voteVo.nVoteTotal = [[dicVote objectForKey:@"voteTotal"]intValue];
            }
            //投票人总数
            id votePersonTolal = [dicVote objectForKey:@"numberPeople"];
            if (votePersonTolal == [NSNull null])
            {
                blogVo.voteVo.nVotePersonTotal = 0;
            }
            else
            {
                blogVo.voteVo.nVotePersonTotal = [votePersonTolal intValue];
            }
            
            //当前用户是否投过票
            id voted = [dicVote objectForKey:@"voted"];
            if (votePersonTolal == [NSNull null])
            {
                blogVo.voteVo.bAlreadVote = NO;
            }
            else
            {
                blogVo.voteVo.bAlreadVote = [voted boolValue];
            }
            
            //默认文字投票
            blogVo.voteVo.nContentType = 2;
            
            //是否过期
            id overdue = [dicVote objectForKey:@"overdue"];
            if (overdue == [NSNull null])
            {
                blogVo.voteVo.bOverdue = NO;
            }
            else
            {
                blogVo.voteVo.bOverdue = [overdue boolValue];
            }
            
            //投票选项
            blogVo.voteVo.aryVoteOption = [NSMutableArray array];
            NSArray *aryVoteOption = [dicVote objectForKey:@"voteOptionList"];
            if ( (id)aryVoteOption != [NSNull null] && aryVoteOption != nil)
            {
                for (int i=0; i<aryVoteOption.count; i++)
                {
                    NSDictionary *dicObject = [aryVoteOption objectAtIndex:i];
                    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
                    id optionId = [dicObject objectForKey:@"id"];
                    if (optionId == [NSNull null])
                    {
                        voteOptionVo.nOptionId = 0;
                    }
                    else
                    {
                        voteOptionVo.nOptionId = [optionId intValue];
                    }
                    
                    voteOptionVo.strOptionName = [Common checkStrValue:[dicObject objectForKey:@"content"]];
                    id count = [dicObject objectForKey:@"count"];
                    if (count == [NSNull null])
                    {
                        voteOptionVo.nCount = 0;
                    }
                    else
                    {
                        voteOptionVo.nCount = [count intValue];
                    }
                    
                    voteOptionVo.strVoterName = [Common checkStrValue:[dicObject objectForKey:@"voter"]];
                    NSString *strImgURL = [Common checkStrValue:[dicObject objectForKey:@"downloadImageUri"]];
                    if (strImgURL.length>0)
                    {
                        voteOptionVo.strImage = [ServerURL getWholeURL:strImgURL];
                        blogVo.voteVo.nContentType = 1;
                    }
                    
                    //当前用户是否投过该选项
                    id selected = [dicObject objectForKey:@"selected"];
                    if (selected == [NSNull null])
                    {
                        voteOptionVo.bAlreadyVote = NO;
                    }
                    else
                    {
                        voteOptionVo.bAlreadyVote = [selected boolValue];
                    }
                    
                    [blogVo.voteVo.aryVoteOption addObject:voteOptionVo];
                }
            }
        }
        
        //抽奖信息
        NSDictionary * dicLottery =[dicBlogInfo objectForKey:@"lotteryVo"];
        if (dicLottery == nil || (id) dicLottery == [NSNull null])
        {
            blogVo.lotteryVo = nil;
        }
        else
        {
            blogVo.lotteryVo = [[LotteryVo alloc]init];
            blogVo.lotteryVo.strLotteryID = [[dicLottery objectForKey:@"id"]stringValue];
            
            id numberPeople = [dicLottery objectForKey:@"numberPeople"];
            if (numberPeople == [NSNull null])
            {
                blogVo.lotteryVo.nLotterySumNum = -1;
            }
            else
            {
                blogVo.lotteryVo.nLotterySumNum = [numberPeople integerValue];
            }
            
            id finished = [dicLottery objectForKey:@"finished"];
            if (finished == [NSNull null])
            {
                blogVo.lotteryVo.bDrawLottery = NO;
            }
            else
            {
                blogVo.lotteryVo.bDrawLottery = ([finished integerValue]==1)?YES:NO;
            }
            
            //消耗积分
            id integral = [dicLottery objectForKey:@"integral"];
            if (integral == [NSNull null])
            {
                blogVo.lotteryVo.nConsumeIntegral = 0;
            }
            else
            {
                blogVo.lotteryVo.nConsumeIntegral = [integral integerValue];
            }
            
            blogVo.lotteryVo.strEndTime = [Common checkStrValue:[dicLottery objectForKey:@"endDate"]];
            
            blogVo.lotteryVo.strImageBK = [Common checkStrValue:[dicLottery objectForKey:@"imageUrl"]];
            blogVo.lotteryVo.strImageBK = [blogVo.lotteryVo.strImageBK stringByReplacingOccurrencesOfString:@"-mid" withString:@""];
            
            id lotteryOptionId = [dicLottery objectForKey:@"lotteryOptionId"];
            if (lotteryOptionId == [NSNull null])
            {
                blogVo.lotteryVo.strWinOptionID = @"";
            }
            else
            {
                blogVo.lotteryVo.strWinOptionID = [lotteryOptionId stringValue];
            }
            
            id expired = [dicLottery objectForKey:@"expired"];
            if (expired == [NSNull null])
            {
                blogVo.lotteryVo.bExpired = NO;
            }
            else
            {
                blogVo.lotteryVo.bExpired = ([expired integerValue]==1)?YES:NO;
            }
            
            //抽奖历史记录
            blogVo.lotteryVo.aryHistory = [NSMutableArray array];
            NSArray *aryJSONHistory = [dicLottery objectForKey:@"lotteryUserList"];
            if ( (id)aryJSONHistory != [NSNull null] && aryJSONHistory != nil)
            {
                for (int i=0; i<aryJSONHistory.count; i++)
                {
                    NSDictionary *dicHistory = [aryJSONHistory objectAtIndex:i];
                    
                    LotteryOptionVo *lotteryOptionVo = [[LotteryOptionVo alloc]init];
                    id lotteryID = [dicHistory objectForKey:@"id"];
                    if (lotteryID == nil || lotteryID == [NSNull null])
                    {
                        lotteryOptionVo.strLotteryOptionID = @"";
                    }
                    else
                    {
                        lotteryOptionVo.strLotteryOptionID = [lotteryID stringValue];
                    }
                    
                    lotteryOptionVo.strLotteryName = [dicHistory objectForKey:@"optionName"];
                    lotteryOptionVo.strDateTime = [dicHistory objectForKey:@"createDate"];
                    
                    [blogVo.lotteryVo.aryHistory addObject:lotteryOptionVo];
                }
            }
            
            //奖项
            blogVo.lotteryVo.aryLotteryOption = [NSMutableArray array];
            NSArray *aryLotteryOption = [dicLottery objectForKey:@"lotteryOptionVoList"];
            if ( (id)aryLotteryOption != [NSNull null] && aryLotteryOption != nil)
            {
                for (int i=0; i<aryLotteryOption.count; i++)
                {
                    NSDictionary *dicLotteryOption = [aryLotteryOption objectAtIndex:i];
                    
                    LotteryOptionVo *lotteryOptionVo = [[LotteryOptionVo alloc]init];
                    id lotteryID = [dicLotteryOption objectForKey:@"id"];
                    if (lotteryID == nil || lotteryID == [NSNull null])
                    {
                        lotteryOptionVo.strLotteryOptionID = @"";
                    }
                    else
                    {
                        lotteryOptionVo.strLotteryOptionID = [lotteryID stringValue];
                    }
                    
                    lotteryOptionVo.strLotteryName = [dicLotteryOption objectForKey:@"content"];
                    
                    id numberPeople = [dicLotteryOption objectForKey:@"numberPeople"];
                    if (numberPeople == nil || numberPeople == [NSNull null])
                    {
                        lotteryOptionVo.nLotteryNum = 0;
                    }
                    else
                    {
                        lotteryOptionVo.nLotteryNum = [numberPeople integerValue];
                    }
                    
                    id surplus = [dicLotteryOption objectForKey:@"surplus"];
                    if (surplus == nil || surplus == [NSNull null])
                    {
                        lotteryOptionVo.nLotteryLeftNum = 0;
                    }
                    else
                    {
                        lotteryOptionVo.nLotteryLeftNum = [surplus integerValue];
                    }
                    
                    lotteryOptionVo.strLotteryImgUrl = [Common checkStrValue:[dicLotteryOption objectForKey:@"downloadImageUri"]];
                    if (lotteryOptionVo.strLotteryImgUrl.length > 0)
                    {
                        lotteryOptionVo.strLotteryImgUrl = [ServerURL getWholeURL:lotteryOptionVo.strLotteryImgUrl];
                    }
                    
                    lotteryOptionVo.strWinLotteryName = [Common checkStrValue:[dicLotteryOption objectForKey:@"userNames"]];
                    lotteryOptionVo.bExpansion = NO;
                    
                    [blogVo.lotteryVo.aryLotteryOption addObject:lotteryOptionVo];
                }
            }
        }
        
        //红包信息
        NSDictionary * dicRedPacket =[dicBlogInfo objectForKey:@"redPacketVo"];
        if (dicRedPacket == nil || (id) dicRedPacket == [NSNull null])
        {
            blogVo.redPacketVo = nil;
        }
        else
        {
            blogVo.redPacketVo = [[RedPacketVo alloc]init];
            id redPacketId = [dicRedPacket objectForKey:@"id"];
            if (redPacketId == [NSNull null])
            {
                blogVo.redPacketVo.strID = @"";
            }
            else
            {
                blogVo.redPacketVo.strID = [redPacketId stringValue];
            }
            
            blogVo.redPacketVo.strRemark = [Common checkStrValue:[dicRedPacket objectForKey:@"remark"]];
            
            id integralTotal = [dicRedPacket objectForKey:@"integralTotal"];
            if (integralTotal == [NSNull null])
            {
                blogVo.redPacketVo.nIntegralTotal = 0;
            }
            else
            {
                blogVo.redPacketVo.nIntegralTotal = [integralTotal integerValue];
            }
            
            id nIntegralRemain = [dicRedPacket objectForKey:@"integralSurplus"];
            if (nIntegralRemain == [NSNull null])
            {
                blogVo.redPacketVo.nIntegralRemain = 0;
            }
            else
            {
                blogVo.redPacketVo.nIntegralRemain = [nIntegralRemain integerValue];
            }
            
            id finished = [dicRedPacket objectForKey:@"finished"];
            if (finished == [NSNull null])
            {
                blogVo.redPacketVo.nNum = 0;
            }
            else
            {
                blogVo.redPacketVo.nNum = [finished integerValue];
            }
            
            //获取当前人积分
            if(blogVo.redPacketVo.nNum>0)
            {
                NSArray *aryUserPacket = [dicRedPacket objectForKey:@"redPacketUserList"];
                if ( (id)aryUserPacket != [NSNull null] && aryUserPacket != nil)
                {
                    for (NSDictionary *dicUser in aryUserPacket)
                    {
                        NSString *strUserID = @"";
                        id userId = [dicUser objectForKey:@"userId"];
                        if (redPacketId == [NSNull null])
                        {
                            strUserID = @"";
                        }
                        else
                        {
                            strUserID = [userId stringValue];
                        }
                        
                        if([strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                        {
                            //如果是当前用户，则解析
                            id integral = [dicUser objectForKey:@"integral"];
                            if (integral == [NSNull null])
                            {
                                blogVo.redPacketVo.nGetIntegral = 0;
                            }
                            else
                            {
                                blogVo.redPacketVo.nGetIntegral = [integral integerValue];
                            }
                            blogVo.redPacketVo.strGetDateTime = [Common checkStrValue:[dicUser objectForKey:@"createDate"]];
                            break;
                        }
                    }
                }
            }
        }
        
        [aryBlogList addObject:blogVo];
    }
    return aryBlogList;
}

//将问题JSON转换为对象数组
+(NSMutableArray*)getQAListByJSONArray:(NSArray*)aryQAJSONList
{
    if (![aryQAJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryQAList = [NSMutableArray array];
    for (NSDictionary *questDic in aryQAJSONList)
    {
        BlogVo *blogVo = [[BlogVo alloc]init];
        blogVo.strBlogType = @"qa";
        
        id blogID = [questDic objectForKey:@"id"];
        if (blogID == [NSNull null]|| blogID == nil)
        {
            blogVo.streamId = @"";
        }
        else
        {
            blogVo.streamId = [blogID stringValue];
        }
        blogVo.strTitle = [Common checkStrValue:[questDic objectForKey:@"titleName"]];
        blogVo.strContent = [Common checkStrValue:[questDic objectForKey:@"questionContent"]];
        blogVo.strContent = [blogVo.strContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        blogVo.strText = [Common checkStrValue:[questDic objectForKey:@"questionText"]];
        //收藏
        id hasStore = [questDic objectForKey:@"hasStore"];
        if (hasStore == nil || hasStore == [NSNull null])
        {
            blogVo.bCollection = NO;
        }
        else
        {
            blogVo.bCollection = ([hasStore integerValue]==1)?YES:NO;
        }
        
        //收藏的数量
        id storeCount = [questDic objectForKey:@"storeCount"];
        if (storeCount == nil || storeCount == [NSNull null])
        {
            blogVo.nCollectCount = 0;
        }
        else
        {
            blogVo.nCollectCount = [storeCount integerValue];
        }
        
        id Comefrom = [questDic objectForKey:@"questionComefrom"];
        if (Comefrom == [NSNull null]|| Comefrom == nil)
        {
            blogVo.nComefrom = 0;
        }
        else
        {
            blogVo.nComefrom = [Comefrom intValue];
        }
        id orgId = [questDic objectForKey:@"orgId"];
        if (orgId == [NSNull null]|| orgId == nil)
        {
            blogVo.orgId = @"";
        }
        else
        {
            blogVo.orgId = [orgId stringValue];
        }
        id isSolution = [questDic objectForKey:@"isSolution"];
        if (isSolution == [NSNull null]|| isSolution == nil)
        {
            blogVo.isSolution = 0;
        }
        else
        {
            blogVo.isSolution = [isSolution intValue];
        }
        blogVo.vestImg = [ServerURL getWholeURL:[Common checkStrValue:[questDic objectForKey:@"userImgUrl"]]];
        blogVo.strCreateDate = [Common checkStrValue:[questDic objectForKey:@"createDate"]];
        blogVo.strUpdateDate = [Common checkStrValue:[questDic objectForKey:@"updateDate"]];
        id strCreateBy = [questDic objectForKey:@"createBy"];
        if (strCreateBy == [NSNull null]|| strCreateBy == nil)
        {
            blogVo.strCreateBy = @"";
        }
        else
        {
            blogVo.strCreateBy = [strCreateBy stringValue];
        }
        
        //勋章
        id badge = [questDic objectForKey:@"userBadge"];
        if (badge == [NSNull null]|| badge == nil)
        {
            blogVo.nBadge = 0;
        }
        else
        {
            blogVo.nBadge = [badge integerValue];
        }
        //积分
        id integral = [questDic objectForKey:@"userIntegral"];
        if (integral == [NSNull null]|| integral == nil)
        {
            blogVo.fIntegral = 0;
        }
        else
        {
            blogVo.fIntegral = [integral doubleValue];
        }
        
        id strUpdateBy = [questDic objectForKey:@"updateBy"];
        if (strUpdateBy == [NSNull null]|| strUpdateBy == nil)
        {
            blogVo.strUpdateBy = @"";
        }
        else
        {
            blogVo.strUpdateBy = [strUpdateBy stringValue];
        }
        blogVo.strCreateByName = [Common checkStrValue:[questDic objectForKey:@"userNickname"]];//createName
        blogVo.strUpdateByName = [Common checkStrValue:[questDic objectForKey:@"updateName"]];
        id praiseCount = [questDic objectForKey:@"praiseCount"];
        if (praiseCount == [NSNull null]|| praiseCount == nil)
        {
            blogVo.nPraiseCount = 0;
        }
        else
        {
            blogVo.nPraiseCount = [praiseCount intValue];
        }
        id nCommentCount = [questDic objectForKey:@"answerCount"];
        if (nCommentCount == [NSNull null]|| nCommentCount == nil)
        {
            blogVo.nCommentCount = 0;
        }
        else
        {
            blogVo.nCommentCount = [nCommentCount intValue];
        }
        
        blogVo.strStartTime = [Common checkStrValue:[questDic objectForKey:@"startDate"]];
        blogVo.strEndTime = [Common checkStrValue:[questDic objectForKey:@"endDate"]];
        id delFlag = [questDic objectForKey:@"delFlag"];
        if (delFlag == [NSNull null]|| delFlag == nil)
        {
            blogVo.nDelFlag = 0;
        }
        else
        {
            blogVo.nDelFlag = [delFlag intValue];
        }
        id isDraft = [questDic objectForKey:@"isDraft"];
        if (isDraft == [NSNull null]|| isDraft == nil)
        {
            blogVo.isDraft = 0;
        }
        else
        {
            blogVo.isDraft = [isDraft intValue];
        }
        
        [aryQAList addObject:blogVo];
    }
    return aryQAList;
}

//将分享答案转换为对象数组
+(NSMutableArray*)getAnswerListByJSONArray:(NSArray*)aryAnswerJSONList
{
    if (![aryAnswerJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryAnswerList = [NSMutableArray array];
    for (NSDictionary *dicAnswer in aryAnswerJSONList)
    {
        BlogVo *answerVo = [[BlogVo alloc]init];
        
        answerVo.strBlogType = @"answer";
        
        id answerId = [dicAnswer objectForKey:@"id"];
        if (answerId == [NSNull null]|| answerId == nil)
        {
            answerVo.streamId = @"";
        }
        else
        {
            answerVo.streamId = [answerId stringValue];
        }
        
        id questionId = [dicAnswer objectForKey:@"questionId"];
        if (questionId == [NSNull null]|| questionId == nil)
        {
            answerVo.strQuestionID = @"";
        }
        else
        {
            answerVo.strQuestionID = [questionId stringValue];
        }
        answerVo.strContent = [Common checkStrValue:[dicAnswer objectForKey:@"answerHtml"]];
        answerVo.strText = [Common checkStrValue:[dicAnswer objectForKey:@"answerText"]];
        
        id userId = [dicAnswer objectForKey:@"userId"];
        if (userId == [NSNull null]|| userId == nil)
        {
            answerVo.strCreateBy = @"";
        }
        else
        {
            answerVo.strCreateBy = [userId stringValue];
        }
        answerVo.strCreateByName = [Common checkStrValue:[dicAnswer objectForKey:@"userName"]];
        answerVo.vestImg = [ServerURL getWholeURL:[Common checkStrValue:[dicAnswer objectForKey:@"userImgUrl"]]];
        
        //勋章
        id badge = [dicAnswer objectForKey:@"userBadge"];
        if (badge == [NSNull null]|| badge == nil)
        {
            answerVo.nBadge = 0;
        }
        else
        {
            answerVo.nBadge = [badge integerValue];
        }
        
        //积分
        id integral = [dicAnswer objectForKey:@"userIntegral"];
        if (integral == [NSNull null]|| integral == nil)
        {
            answerVo.fIntegral = 0;
        }
        else
        {
            answerVo.fIntegral = [integral doubleValue];
        }
        
        answerVo.strPictureUrl = [Common checkStrValue:[dicAnswer objectForKey:@"picture"]];
        if (answerVo.strPictureUrl.length>0)
        {
            NSRange range = [answerVo.strPictureUrl rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
            if (range.length==0)
            {
                //需要追加前缀
                answerVo.strPictureUrl = [ServerURL getWholeURL:answerVo.strPictureUrl];
            }
        }
        
        id orgId = [dicAnswer objectForKey:@"orgId"];
        if (orgId == [NSNull null]|| orgId == nil)
        {
            answerVo.orgId = @"";
        }
        else
        {
            answerVo.orgId = [orgId stringValue];
        }
        
        answerVo.strCreateDate = [Common checkStrValue:[dicAnswer objectForKey:@"createDate"]];
        
        id praiseCount = [dicAnswer objectForKey:@"praiseCount"];
        if (praiseCount == [NSNull null]|| praiseCount == nil)
        {
            answerVo.nPraiseCount = 0;
        }
        else
        {
            answerVo.nPraiseCount = [praiseCount intValue];
        }
        
        id isSolution = [dicAnswer objectForKey:@"isSolution"];
        if (isSolution == [NSNull null]|| isSolution == nil)
        {
            answerVo.isSolution = 0;
        }
        else
        {
            answerVo.isSolution = [isSolution intValue];
        }
        id mentionId = [dicAnswer objectForKey:@"mentionId"];
        if (mentionId == [NSNull null]|| mentionId == nil)
        {
            answerVo.strMentionID = nil;//是否本人赞过
        }
        else
        {
            answerVo.strMentionID = [mentionId stringValue];
        }
        [aryAnswerList addObject:answerVo];
    }
    return aryAnswerList;
}

//将评论JSON转换为对象数组
+(NSMutableArray*)getCommentListByJSONArray:(NSArray*)aryCommentJSONList
{
    if (![aryCommentJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryCommentList = [NSMutableArray array];
    for (NSDictionary *dicComment in aryCommentJSONList)
    {
        CommentVo *commentVo = [[CommentVo alloc]init];
        commentVo.praiseState = PraiseStateNomal;
        id commentID = [dicComment objectForKey:@"id"];
        if (commentID == [NSNull null])
        {
            commentVo.strID = @"";
        }
        else
        {
            commentVo.strID = [commentID stringValue];
        }
        
        id articleID = [dicComment objectForKey:@"blogId"];
        if (articleID == [NSNull null])
        {
            commentVo.strBlogID = @"";
        }
        else
        {
            commentVo.strBlogID = [articleID stringValue];
        }
        
        //父评论信息
        id parentId = [dicComment objectForKey:@"parentId"];
        if (parentId == [NSNull null])
        {
            commentVo.strparentId = @"";
        }
        else
        {
            commentVo.strparentId = [parentId stringValue];
            
        }
        
        id parentUserId = [dicComment objectForKey:@"parentUserId"];
        if (parentUserId == [NSNull null])
        {
            commentVo.strParentUserId = @"";
        }
        else
        {
            commentVo.strParentUserId = [parentUserId stringValue];
        }
        
        commentVo.strParentUserName = [Common checkStrValue:[dicComment objectForKey:@"parentUserName"]];
        
        id orgId = [dicComment objectForKey:@"orgId"];
        if (orgId == [NSNull null])
        {
            commentVo.strOrgId = @"";
        }
        else
        {
            commentVo.strOrgId = [orgId stringValue];
        }
        
        id mentionId = [dicComment objectForKey:@"mentionId"];
        if (mentionId == [NSNull null] || mentionId == nil)
        {
            commentVo.strMentionID = nil;//用于判断本人是否赞过，nil则没赞过
        }
        else
        {
            commentVo.strMentionID = [mentionId stringValue];
        }
        
        id praiseCount = [dicComment objectForKey:@"praiseCount"];
        if (praiseCount == [NSNull null]|| praiseCount == nil)
        {
            commentVo.nPraiseCount = 0;
        }
        else
        {
            commentVo.nPraiseCount = [praiseCount intValue];
        }
        
        //获取纯文本评论内容
        commentVo.strContent = [Common checkStrValue:[dicComment objectForKey:@"commentText"]];
        commentVo.strContentHtml = [Common checkStrValue:[dicComment objectForKey:@"commentHtml"]];
        commentVo.strUserName = [Common checkStrValue:[dicComment objectForKey:@"userNickname"]];//userName
        commentVo.strUserImage = [ServerURL getWholeURL:[Common checkStrValue:[dicComment objectForKey:@"userImgUrl"]]];
        
        id createBy = [dicComment objectForKey:@"userId"];
        if (createBy == [NSNull null])
        {
            commentVo.strUserID = @"";
        }
        else
        {
            commentVo.strUserID = [createBy stringValue];
        }
        
        //勋章
        id badge = [dicComment objectForKey:@"userBadge"];
        if (badge == [NSNull null]|| badge == nil)
        {
            commentVo.nBadge = 0;
        }
        else
        {
            commentVo.nBadge = [badge integerValue];
        }
        
        //积分
        id integral = [dicComment objectForKey:@"userIntegral"];
        if (integral == [NSNull null]|| integral == nil)
        {
            commentVo.fIntegral = 0;
        }
        else
        {
            commentVo.fIntegral = [integral doubleValue];
        }
        
        commentVo.strCreateDate = [Common checkStrValue:[dicComment objectForKey:@"createDate"]];
        commentVo.strDeleteDate = [Common checkStrValue:[dicComment objectForKey:@"deleteDate"]];
        
        id delFlag = [dicComment objectForKey:@"delFlag"];
        if (delFlag == [NSNull null])
        {
            commentVo.delFlag = 0;
        }
        else
        {
            commentVo.delFlag = [delFlag intValue];
        }
        [aryCommentList addObject:commentVo];
    }
    return aryCommentList;
}

//将赞JSON转换为对象数组
+(NSMutableArray*)getPraiseListByJSONArray:(NSArray*)aryPraiseJSONList
{
    if (![aryPraiseJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryPraiseList = [NSMutableArray array];
    for (NSDictionary *dic in aryPraiseJSONList)
    {
        PraiseVo *praiseVo = [[PraiseVo alloc]init];
        id paiserId = [dic objectForKey:@"id"];
        if (paiserId == [NSNull null]|| paiserId == nil)
        {
            praiseVo.strID = @"";
        }
        else
        {
            praiseVo.strID = [paiserId stringValue];
        }
        
        praiseVo.strAliasName = [Common checkStrValue:[dic objectForKey:@"aliasName"]];
        praiseVo.imageUrl = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"imageUrl"]]];
        
        id orgId = [dic objectForKey:@"orgId"];
        if (orgId == [NSNull null]|| orgId == nil)
        {
            praiseVo.orgId = @"";
        }
        else
        {
            praiseVo.orgId = [orgId stringValue];
        }
        praiseVo.strTitle = [Common checkStrValue:[dic objectForKey:@"title"]];
        
        id phoneNumber = [dic objectForKey:@"phoneNumber"];
        if (phoneNumber == [NSNull null]|| phoneNumber == nil)
        {
            praiseVo.phoneNumber = @"";
        }
        else
        {
            praiseVo.phoneNumber = [phoneNumber stringValue];
        }
        
        [aryPraiseList addObject:praiseVo];
    }
    
    return aryPraiseList;
}

///////////////////////////////////////////////////////////////////////////////////////
//登录到REST server(获取程序版本信息)
+ (void)loginToRestServer:(NSString*)strLoginPhone andPwd:(NSString*)strPwd result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strLoginPhone forKey:@"username"];
    [bodyDic setObject:strPwd forKey:@"password"];
    [bodyDic setObject:@"ios" forKey:@"client_flag"];
    [bodyDic setObject:[Common getDevicePlatform] forKey:@"model"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getLoginToRESTServerURL]];
    [networkFramework loginToRestServer:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            FaceModel *model =  [FaceModel sharedManager];
            NSDictionary *responseDic = responseObject;
            for (NSDictionary *dic in responseObject[@"roleList"]) {
                FaceModel *mo = [[FaceModel alloc]init];
                [mo setValuesForKeysWithDictionary:dic];
//                if ([mo.name isEqualToString:@"approve"]) {
//                    model.ISnO = YES;
//                    
//                }else{
//                    model.ISnO = NO;
//
//                }
                model.ISnO = [mo.name isEqualToString:@"approve"] ? YES : NO;
            }
            //版本号
            retInfo.data = [Common checkStrValue:[responseDic objectForKey:@"version"]];
            [Common setServerAppVersion:retInfo.data];
            
            //登录用户ID
            retInfo.data2 = [Common checkStrValue:[responseDic objectForKey:@"id"]];
            
            //app update url
            NSString *strAppUpdateURL = [Common checkStrValue:[responseDic objectForKey:@"iospath"]];
            [ServerURL setVersionUpdateURL:strAppUpdateURL];
            
            //登录密码
            [Common setUserPwd:strPwd];
            //真实姓名和部门是否填写整(true:完整；false:不完整)
            NSString *strTrueNameCheck = [Common checkStrValue:[responseDic objectForKey:@"trueNameCheck"]];
            if ([strTrueNameCheck isEqualToString:@"false"])
            {
                [Common setInfoCompleteState:NO];
            }
            else
            {
                [Common setInfoCompleteState:YES];
            }
        }
        resultBlock(retInfo);
    }];
}

//手机用户登出
+ (void)logoutAction:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getLogoutActionURL]];
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
        }
        
        resultBlock(retInfo);
    }];
}

+ (void)getAllCompanyList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getAllCompanyListURL]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            NSArray *aryDepartmentList = responseObject;
            NSMutableArray *aryCompanyList = [NSMutableArray array];
            if ([aryDepartmentList isKindOfClass:[NSArray class]])
            {
                for (int i=0; i<aryDepartmentList.count; i++)
                {
                    NSDictionary *dicDepartment = [aryDepartmentList objectAtIndex:i];
                    DepartmentVo *departmentVo = [[DepartmentVo alloc]init];
                    id departmentId = [dicDepartment objectForKey:@"id"];
                    if (departmentId == nil || departmentId == [NSNull null])
                    {
                        departmentVo.strDepartmentID = @"";
                    }
                    else
                    {
                        departmentVo.strDepartmentID = [departmentId stringValue];
                    }
                    departmentVo.strDepartmentName = [Common checkStrValue:[dicDepartment objectForKey:@"departmentName"]];
                    [aryCompanyList addObject:departmentVo];
                }
            }
            retInfo.data = aryCompanyList;
            retInfo.bSuccess = YES;
        }
        
        resultBlock(retInfo);
    }];
}

//群组相关////////////////////////////////////////////////////////////////////////
//创建群组
+ (void)createGroup:(GroupVo *)groupVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:groupVo.strGroupName forKey:@"teamName"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",groupVo.nAllowSee] forKey:@"isWrite"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",groupVo.nAllowJoin] forKey:@"isOpen"];
    //群组成员
    if (groupVo.aryMemberVo != nil || groupVo.aryMemberVo.count>0)
    {
        NSMutableArray *aryIDs = [NSMutableArray array];
        for (int i=0; i<groupVo.aryMemberVo.count; i++)
        {
            UserVo *userVo = [groupVo.aryMemberVo objectAtIndex:i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:userVo.strUserID forKey:@"id"];
            [aryIDs addObject:dic];
        }
        [bodyDic setObject:aryIDs forKey:@"userList"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCreateGroupURL]];
    [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            id teamId = [responseObject objectForKey:@"teamId"];
            if (teamId != nil && teamId != [NSNull null])
            {
                retInfo.data = [teamId stringValue];
            }
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

//修改群组(不能修改创建者)
+ (void)editGroup:(GroupVo*)groupVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:groupVo.strGroupID forKey:@"id"];
    [bodyDic setObject:groupVo.strGroupName forKey:@"teamName"];
    [bodyDic setObject:groupVo.strCreatorID forKey:@"createId"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",groupVo.nAllowJoin] forKey:@"isOpen"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",groupVo.nAllowSee] forKey:@"isWrite"];
    
    //群组成员
    if (groupVo.aryMemberVo != nil || groupVo.aryMemberVo.count>0)
    {
        NSMutableArray *aryIDs = [NSMutableArray array];
        for (int i=0; i<groupVo.aryMemberVo.count; i++)
        {
            UserVo *userVo = [groupVo.aryMemberVo objectAtIndex:i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:userVo.strUserID forKey:@"id"];
            [aryIDs addObject:dic];
        }
        [bodyDic setObject:aryIDs forKey:@"userList"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getEditGroupURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//加入群组
+ (void)joinGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTeamId forKey:@"teamId"];
    [bodyDic setObject:strUserID forKey:@"userId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getJoinGroupURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//退出群组
+ (void)exitGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTeamId forKey:@"teamId"];
    [bodyDic setObject:strUserID forKey:@"userId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getExitGroupURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//解散(删除)群组
+ (void)dismissGroup:(NSString *)strTeamId result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDismissGroupURL],strTeamId];
    
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

//转移群组
+ (void)transferGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTeamId forKey:@"id"];
    [bodyDic setObject:strUserID forKey:@"createId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getTransferGroupURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//获取所有的群组
+ (void)getAllGroupList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getAllGroupListURL]];
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
            
            NSMutableArray *aryGroupList = [NSMutableArray array];
            NSArray *aryJSONGroup = [responseObject objectForKey:@"list"];
            //一级群组
            for (int i=0; i<aryJSONGroup.count; i++)
            {
                NSDictionary *dicGroupJSON = (NSDictionary*)[aryJSONGroup objectAtIndex:i];
                GroupVo *groupVo = [[GroupVo alloc]init];
                groupVo.strGroupID = [[dicGroupJSON objectForKey:@"id"]stringValue];
                groupVo.strGroupName = [Common checkStrValue:[dicGroupJSON objectForKey:@"teamName"]];
                groupVo.strGroupDesc = [Common checkStrValue:[dicGroupJSON objectForKey:@"teamDesc"]];
                groupVo.strGroupImage = [Common checkStrValue:[dicGroupJSON objectForKey:@"imageUrl"]];
                id isOpen = [dicGroupJSON objectForKey:@"isOpen"];
                if (isOpen == nil || isOpen == [NSNull null])
                {
                    groupVo.nAllowJoin = -1;
                }
                else
                {
                    groupVo.nAllowJoin = [isOpen intValue];
                }
                
                id isWrite = [dicGroupJSON objectForKey:@"isWrite"];
                if (isWrite == nil || isWrite == [NSNull null])
                {
                    groupVo.nAllowSee = -1;
                }
                else
                {
                    groupVo.nAllowSee = [isWrite intValue];
                }
                
                id createId = [dicGroupJSON objectForKey:@"createId"];
                if (createId == nil || createId == [NSNull null])
                {
                    groupVo.strCreatorID = @"";
                }
                else
                {
                    groupVo.strCreatorID = [createId stringValue];
                }
                groupVo.strCreatorName = [Common checkStrValue:[dicGroupJSON objectForKey:@"userNickname"]];// createName
                
                id streamCount = [dicGroupJSON objectForKey:@"streamCount"];
                if (streamCount == nil || streamCount == [NSNull null])
                {
                    groupVo.strArticleNum = @"0";
                }
                else
                {
                    groupVo.strArticleNum = [streamCount stringValue];
                }
                
                //get pinyin
                NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:groupVo.strGroupName];
                if(aryPinyin!=nil && aryPinyin.count>0)
                {
                    groupVo.strQP = [aryPinyin objectAtIndex:0];
                    if (aryPinyin.count>1)
                    {
                        groupVo.strJP = [aryPinyin objectAtIndex:1];
                    }
                }
                
                //get group member(自己计算成员数量和是否是成员)
                groupVo.nIsGroupMember = 0;
                groupVo.strMemListJSON = @"";
                groupVo.aryMemberVo = [NSMutableArray array];
                NSArray *aryMember = [dicGroupJSON objectForKey:@"userList"];
                if (aryMember != nil && aryMember.count)
                {
                    for (int j=0; j<aryMember.count; j++)
                    {
                        NSDictionary *dicGroupMem = [aryMember objectAtIndex:j];
                        NSString *strUserID = [[dicGroupMem objectForKey:@"id"]stringValue];
                        
                        //check is member
                        if ([strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                        {
                            groupVo.nIsGroupMember = 1;
                        }
                    }
                    //将UserList JSON 存放到DB
                    NSError *error;
                    NSData *data = [NSJSONSerialization dataWithJSONObject:aryMember options:NSJSONWritingPrettyPrinted error:&error];
                    if (error != nil)
                    {
                        DLog(@"error:%@",error);
                        groupVo.strMemListJSON = @"";
                        groupVo.strMemberNum = @"0";
                    }
                    else
                    {
                        groupVo.strMemListJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        groupVo.strMemberNum = [NSString stringWithFormat:@"%lu",(unsigned long)aryMember.count];
                    }
                }
                else
                {
                    groupVo.strMemberNum = @"0";
                }
                
                //group type (1:我创建的，2:我参与的，3:其他群组)
                if ([groupVo.strCreatorID isEqualToString:[Common getCurrentUserVo].strUserID])
                {
                    groupVo.nGroupType = 1;
                }
                else if(groupVo.nIsGroupMember == 1)
                {
                    groupVo.nGroupType = 2;
                }
                else
                {
                    groupVo.nGroupType = 3;
                }
                
                [aryGroupList addObject:groupVo];
            }
            retInfo.data = aryGroupList;
        }
        resultBlock(retInfo);
    }];
}

//////////////////////////////////////////////////////////////////////////////
//查询用户详情
+ (void)getUserDetail:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getUserDetailURL],strUserID];
    
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
            NSDictionary *dicUserInfo =  [responseObject objectForKey:@"userInfo"];
            if ([dicUserInfo isKindOfClass:[NSDictionary class]])
            {
                UserVo *userVo = nil;
                
                NSMutableArray *aryUserList = [self getUserListByJSONArray:@[dicUserInfo]];
                if (aryUserList.count>0)
                {
                    userVo = [aryUserList objectAtIndex:0];
                }
                
                //查询圈子列表
                userVo.aryCommunity = [NSMutableArray array];
                id orgList = responseObject[@"orgList"];
                if (orgList != [NSNull null] && [orgList isKindOfClass:[NSArray class]])
                {
                    NSArray *aryOrgList = (NSArray*)orgList;
                    for (int i=0; i<aryOrgList.count; i++)
                    {
                        NSDictionary *dicOrg = aryOrgList[i];
                        CommunityVo *communityVo = [[CommunityVo alloc]init];
                        
                        id orgId = dicOrg[@"id"];
                        if (orgId == [NSNull null] || orgId == nil)
                        {
                            communityVo.strID = @"";
                        }
                        else
                        {
                            communityVo.strID = [orgId stringValue];
                        }
                        
                        communityVo.strName = [Common checkStrValue:dicOrg[@"fullName"]];
                        communityVo.strShortName = [Common checkStrValue:dicOrg[@"shortName"]];
                        
                        if ([communityVo.strID isEqualToString:[Common getCurrentUserVo].strCompanyID]) {
                            communityVo.bSelected = YES;
                        } else {
                            communityVo.bSelected = NO;
                        }
                        
                        [userVo.aryCommunity addObject:communityVo];
                    }
                }

                //查询每日签到
                id daySign = [responseObject objectForKey:@"daySign"];
                if (daySign == [NSNull null]|| daySign == nil)
                {
                    userVo.bDaySign = false;
                }
                else
                {
                    userVo.bDaySign = [daySign boolValue];
                }
                
                //合理化建议权限
                userVo.arySuggestionRole = [NSMutableArray array];
                id suggestionUserRoleList = [responseObject objectForKey:@"suggestionUserRoleList"];
                if (suggestionUserRoleList != nil && suggestionUserRoleList != [NSNull null] && [suggestionUserRoleList isKindOfClass:[NSArray class]])
                {
                    NSArray *arySuggestionRoleJSON = (NSArray*)suggestionUserRoleList;
                    for (int i=0; i<arySuggestionRoleJSON.count; i++)
                    {
                        NSDictionary *dicSuggestionRole = [arySuggestionRoleJSON objectAtIndex:i];
                        SuggestionRoleVo *suggestionRoleVo = [[SuggestionRoleVo alloc]init];
                        suggestionRoleVo.strRoleCode = [Common checkStrValue:[dicSuggestionRole objectForKey:@"suggestRoleCode"]];
                        suggestionRoleVo.strRoleName = [Common checkStrValue:[dicSuggestionRole objectForKey:@"suggestRoleName"]];
                        
                        id departmentId = [dicSuggestionRole objectForKey:@"departmentId"];
                        if (departmentId == [NSNull null]|| departmentId == nil)
                        {
                            suggestionRoleVo.strDepartmentID = @"";
                        }
                        else
                        {
                            suggestionRoleVo.strDepartmentID = [departmentId stringValue];
                        }
                        
                        [userVo.arySuggestionRole addObject:suggestionRoleVo];
                    }
                }
                
                //保存当前登录用户信息
                if ([userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                {
                    [Common setCurrentUserVo:userVo];
                }
                
                retInfo.data = userVo;
                retInfo.bSuccess = YES;
            }
            else
            {
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = ERROR_TO_DATA;
            }
        }
        resultBlock(retInfo);
    }];
}

//获取用户头像
+ (void)getUserHeaderImage:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getUserHeaderImageURL],strUserID];
    
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
            UserVo *userVo = [[UserVo alloc]init];
            userVo.strUserID = strUserID;
            userVo.strHeadImageURL = [ServerURL getWholeURL:[responseObject objectForKey:@"userImgUrl"]];
            
            retInfo.data = userVo;
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

//修改用户密码
+ (void)editUserPassword:(NSString*)strUserID andNewPwd:(NSString*)strNewPwd andOldPwd:(NSString*)strOldPwd result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strUserID forKey:@"id"];
    [bodyDic setObject:strNewPwd forKey:@"plainPassword"];
    [bodyDic setObject:strOldPwd forKey:@"password"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getEditUserPasswordURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//修改用户详情
+ (void)editUserInfo:(UserVo*)userVo result:(ResultBlock)resultBlock
{
    //更新用户信息block
    void (^postJSONBlock)(NSString *) = ^(NSString *strImageID){
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        [bodyDic setObject:userVo.strUserID forKey:@"id"];
        [bodyDic setObject:userVo.strSignature forKey:@"signature"];
        [bodyDic setObject:userVo.strQQ forKey:@"qq"];
        [bodyDic setObject:userVo.strPhoneNumber forKey:@"phoneNumber"];
        [bodyDic setObject:userVo.bViewPhone?@"1":@"0" forKey:@"viewPhone"];
        [bodyDic setObject:[NSNumber numberWithInteger:userVo.gender] forKey:@"gender"];
        [bodyDic setObject:userVo.strBirthday forKey:@"birthday"];
        [bodyDic setObject:userVo.strUserName forKey:@"userName"];
        [bodyDic setObject:userVo.strRealName forKey:@"trueName"];
        [bodyDic setObject:userVo.strDepartmentId forKey:@"departmentId"];
        [bodyDic setObject:userVo.strPosition forKey:@"title"];
        [bodyDic setObject:userVo.strEmail forKey:@"email"];
        [bodyDic setObject:userVo.strAddress forKey:@"address"];
        [bodyDic setObject:userVo.strReceiveMessage forKey:@"receiveMessage"];//是否接收推送消息
        
        if (userVo.bHasHeadImg && strImageID)
        {
            [bodyDic setObject:strImageID forKey:@"imageId"];
        }
        
        VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getEditUserInfoURL]];
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
            }
            resultBlock(retInfo);
        }];
    };
    
    //头像附件
    if (userVo.bHasHeadImg)
    {
        VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
        [networkFrameworkFile uploadBatchFileToServer:@[userVo.strHeadImgPath] result:^(NSArray *aryResult, NSError *error) {
            if (error)
            {
                ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = error.localizedDescription;
                resultBlock(retInfo);
            }
            else
            {
                UploadFileVo *uploadFileVo = aryResult[0];
                postJSONBlock(uploadFileVo.strID);
            }
        }];
    }
    else
    {
        postJSONBlock(nil);
    }
}

//更新用户的某个字段
+ (void)updateUserInfoByDictionary:(NSMutableDictionary*)dicBody result:(ResultBlock)resultBlock
{
    //更新用户信息block
    void (^postJSONBlock)(UploadFileVo *) = ^(UploadFileVo *uploadFileVo){
        VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getEditUserInfoURL]];
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
                if (uploadFileVo)
                {
                    retInfo.data = [ServerURL getWholeURL:uploadFileVo.strMinURL];
                    retInfo.data2 = [ServerURL getWholeURL:uploadFileVo.strURL];
                }
            }
            resultBlock(retInfo);
        }];
    };
    
    //头像附件
    NSString *strImagePath = dicBody[@"HeaderImagePath"];
    if (strImagePath != nil && strImagePath.length>0)
    {
        VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
        [networkFrameworkFile uploadBatchFileToServer:@[strImagePath] result:^(NSArray *aryResult, NSError *error) {
            if (error)
            {
                ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = error.localizedDescription;
                resultBlock(retInfo);
            }
            else
            {
                UploadFileVo *uploadFileVo = aryResult[0];
                [dicBody setObject:uploadFileVo.strID forKey:@"imageId"];
                [dicBody removeObjectForKey:@"HeaderImagePath"];
                postJSONBlock(uploadFileVo);
            }
        }];
    }
    else
    {
        postJSONBlock(nil);
    }
}

//我关注的所有用户列表（不分页）
+ (void)getAllMyAttentionUserList:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:@"1" forKey:@"pageNumber"];
    [dicPageInfo setObject:@1000000 forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getMyAttentionUserListURL]];
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
            
            NSMutableArray *aryMemberList = nil;
            NSArray *aryJSONUserList = [responseObject objectForKey:@"content"];
            if (aryJSONUserList != nil && aryJSONUserList.count>0)
            {
                aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryMemberList;
        }
        resultBlock(retInfo);
    }];
}

//获取所有用户列表（分页）
+ (void)getAllUserListByPage:(NSInteger)nPage andSearchText:(NSString*)strSearchText andPageSize:(NSInteger)nPageSize result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nPageSize] forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    [bodyDic setObject:strSearchText forKey:@"userName"];
    [bodyDic setObject:strSearchText forKey:@"firstLetter"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getAllUserListByPageURL]];
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
                aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
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

//推荐关注的用户列表
+ (void)getRecommendAttentionUserList:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [bodyDic setObject:@5 forKey:@"pageSize"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getRecommendAttentionUserListURL]];
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
                aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
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

//增加或取消关注(bAttention:YES 增加关注,NO 取消关注)
+ (void)attentionUserAction:(BOOL)bAttention andOtherUserID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSString *strURL = nil;
    if (bAttention)
    {
        //加关注
        strURL = [ServerURL getAddAttentionURL];
    }
    else
    {
        //取消关注
        strURL = [ServerURL getCancelAttentionURL];
    }
    
    strURL = [NSString stringWithFormat:@"%@/%@",strURL,strUserID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//发送用于获取注册的验证码
+ (void)sendIdentifyingCode:(NSString *)strPhoneNum result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",[ServerURL getSendIdentifyingCodeURL],strPhoneNum];//?phoneNumber=123
    
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
        }
        resultBlock(retInfo);
    }];
}

//注册
+ (void)registerUserAction:(UserVo*)userVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:userVo.strLoginAccount forKey:@"loginName"];
    [bodyDic setObject:userVo.strPassword forKey:@"plainPassword"];
    [bodyDic setObject:userVo.strUserName forKey:@"aliasName"];
    [bodyDic setObject:userVo.strRealName forKey:@"trueName"];
    
    
//    [bodyDic setObject:userVo.strIdentifyCode forKey:@"validateCode"];
//    
//    if (userVo.strDepartmentId != nil && userVo.strDepartmentId.length > 0)
//    {
//        [bodyDic setObject:userVo.strDepartmentId forKey:@"departmentId"];
//    }
    
    if (userVo.strPhoneNumber != nil && userVo.strPhoneNumber.length > 0)
    {
        [bodyDic setObject:userVo.strPhoneNumber forKey:@"phoneNumber"];
    }
    
    if (userVo.strBirthday != nil && userVo.strBirthday.length > 0)
    {
        [bodyDic setObject:userVo.strBirthday forKey:@"birthday"];
    }
    
    if (userVo.strAddress != nil && userVo.strAddress.length > 0)
    {
        [bodyDic setObject:userVo.strAddress forKey:@"address"];
    }
    
    if (userVo.strEmail != nil && userVo.strEmail.length > 0)
    {
        [bodyDic setObject:userVo.strEmail forKey:@"email"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getRegisterUserURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//发送用于获取找回密码的验证码
+ (void)sendChangePwdIdentifyingCode:(NSString *)strPhoneNum result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",[ServerURL getSendIdentifyingCodeURL],strPhoneNum];
    
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
        }
        resultBlock(retInfo);
    }];
}

//验证手机是否存在
+ (void)checkPhone:(NSString *)strPhoneNum result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",[ServerURL getCheckLoginPhoneServerURL],strPhoneNum];
    
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
            retInfo.data = responseObject[@"code"];
        }
        resultBlock(retInfo);
    }];
}

//验证 - 手机和验证码的有效性
+ (void)validatePhoneAndCode:(NSString*)mobile code:(NSString *)strCode result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:mobile forKey:@"phoneNumber"];
    [bodyDic setObject:strCode forKey:@"validateCode"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getPhoneCodeServerURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//重置登录密码
+ (void)resetLoginPwd:(NSString*)strLoginName andPwd:(NSString*)strPwd andIdentifyingCode:(NSString*)strCode result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strLoginName forKey:@"loginName"];
    [bodyDic setObject:strPwd forKey:@"plainPassword"];
    [bodyDic setObject:strCode forKey:@"validateCode"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getChangePasswordURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//我关注的,0:用户、1:粉丝
+ (void)getAttentionOrFansList:(NSString*)strUserID search:(NSString*)strSearchText type:(NSInteger)nType page:(NSInteger)nPage size:(NSInteger)nSize result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nSize] forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    [bodyDic setObject:strUserID forKey:@"id"];
    
    if (strSearchText.length>0)
    {
        [bodyDic setObject:strSearchText forKey:@"userName"];
    }
    
    NSString *strURL;
    if (nType == 0)
    {
        //用户
        strURL = [ServerURL getMyAttentionUserListURL];
    }
    else
    {
        //粉丝
        strURL = [ServerURL getFansListURL];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
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
                aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryMemberList;
            retInfo.bSuccess = YES;
            
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

//更换个人主页封面图
+ (void)updateUserCoverImage:(NSString*)strImagePath result:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
    [networkFrameworkFile uploadBatchFileToServer:@[strImagePath] result:^(NSArray *aryResult, NSError *error) {
        if (error)
        {
            ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
            resultBlock(retInfo);
        }
        else
        {
            UploadFileVo *uploadFileVo = aryResult[0];
            
            NSString *strImageURL = uploadFileVo.strURL;
            NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
            [bodyDic setObject:[Common getCurrentUserVo].strUserID forKey:@"id"];
            [bodyDic setObject:strImageURL forKey:@"backPicUrl"];
            
            VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getEditUserInfoURL]];
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
                    retInfo.data = [ServerURL getWholeURL:strImageURL];
                }
                resultBlock(retInfo);
            }];
        }
    }];
}

//消息相关/////////////////////////////////////////////////////////////////////////////////////////////////
//获取消息列表,可以筛选(A-附件，B-约会，C-投票, D-图片,T-标签,E-抽奖,W-工单)
+ (void)getMessageListByType:(MessageListType)messageListType andFilterType:(NSString*)strFilterType andPageNum:(int)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",nPage] forKey:@"pageNumber"];
    
    NSString *strUrl = @"";
    if(messageListType == MessageListAllType)
    {
        //我的所有消息
        if(strFilterType == nil || strFilterType.length == 0)
        {
            strUrl = [ServerURL getMessageListMyAllURL];
        }
        else
        {
            strUrl = [NSString stringWithFormat:@"%@/%@",[ServerURL getMessageListMyAllURL],strFilterType];
        }
    }
    else if(messageListType == MessageListPersonalType)
    {
        //我的私人消息
        if(strFilterType == nil || strFilterType.length == 0)
        {
            strUrl = [ServerURL getMessageListPersonalURL];
        }
        else
        {
            strUrl = [NSString stringWithFormat:@"%@/%@",[ServerURL getMessageListPersonalURL],strFilterType];
        }
    }
    else if(messageListType == MessageListMyGroupType)
    {
        //我的群组消息
        if(strFilterType == nil || strFilterType.length == 0)
        {
            strUrl = [ServerURL getMessageListMyGroupURL];
        }
        else
        {
            strUrl = [NSString stringWithFormat:@"%@/%@",[ServerURL getMessageListMyGroupURL],strFilterType];
        }
    }
    else if(messageListType == MessageListFromMeType)
    {
        //我发送的消息
        if(strFilterType == nil || strFilterType.length == 0)
        {
            strUrl = [ServerURL getMessageListFromMeURL];
        }
        else
        {
            strUrl = [NSString stringWithFormat:@"%@/%@",[ServerURL getMessageListFromMeURL],strFilterType];
        }
    }
    else if(messageListType == MessageListStarType)
    {
        //我的星标消息
        strUrl = [ServerURL getSearchMessageListURL];
        
        [bodyDic removeObjectForKey:@"pageNumber"];
        
        NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
        [dicPageInfo setObject:[NSString stringWithFormat:@"%i",nPage] forKey:@"pageNumber"];
        [dicPageInfo setObject:@10 forKey:@"pageSize"];
        [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
        
        [bodyDic setObject:@"1" forKey:@"starTag"];//星标消息
        
        if(strFilterType != nil && strFilterType.length > 0)
        {
            //筛选条件(投票、约会、奖品)
            [bodyDic setObject:strFilterType forKey:@"annexation"];
        }
    }
    else if(messageListType == MessageListWorkOrderType)
    {
        //我的工单消息
        strUrl = [ServerURL getSearchMessageListURL];
        
        [bodyDic removeObjectForKey:@"pageNumber"];
        
        NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
        [dicPageInfo setObject:[NSString stringWithFormat:@"%i",nPage] forKey:@"pageNumber"];
        [dicPageInfo setObject:@10 forKey:@"pageSize"];
        [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
        
        [bodyDic setObject:@"15" forKey:@"streamComefrom"]; //工单消息标志
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strUrl];
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
            NSArray *aryMessageList = [responseObject objectForKey:@"content"];
            if (aryMessageList != nil)
            {
                retInfo.data  = [ServerProvider getMessageListByJSONArray:aryMessageList];
                
                //获取数据总数（用于停止刷新）
                id totalElements = [responseObject objectForKey:@"totalElements"];
                if (totalElements != [NSNull null] && totalElements != nil)
                {
                    retInfo.data2 = totalElements;
                }
                else
                {
                    retInfo.data2 = nil;
                }
            }
        }
        resultBlock(retInfo);
    }];
}

//获取同一会话的消息列表
+(void)getSessionMsgList:(NSString*)strMessageID andTitleID:(NSString*)strTitleID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@/%@",[ServerURL getSessionMsgListURL],strTitleID,strMessageID];
    
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
            NSMutableArray *aryMessageList = [ServerProvider getMessageListByJSONArray:(NSArray*)responseObject];
            if(aryMessageList != nil)
            {
                //放在详情接口里面，不是所有的消息都需要替换，加快列表的解析速度
                for (MessageVo *messageVo in aryMessageList)
                {
                    messageVo.strHtmlContent = [messageVo.strHtmlContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
                }
            }
            retInfo.data  = aryMessageList;
        }
        resultBlock(retInfo);
    }];
}

//查寻消息列表（(A-附件，B-约会，C-投票, D-图片,T-标签,E-抽奖,W-工单)）
+ (void)searchMessageList:(NSString*)strSearchText type:(MessageListType)messageListType andPageNum:(int)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    //分页信息
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSString stringWithFormat:@"%i",nPage] forKey:@"pageNumber"];
    [dicPageInfo setObject:@"20" forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    if (messageListType == MessageListWorkOrderType)
    {
        [bodyDic setObject:@"15" forKey:@"streamComefrom"];
        [bodyDic setObject:strSearchText forKey:@"searchTitleText"];
    }
    else
    {
        [bodyDic setObject:strSearchText forKey:@"queryName"];//默认创建者
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSearchMessageListURL]];
    [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            NSArray *aryMessageList = [responseObject objectForKey:@"content"];
            if (aryMessageList != nil)
            {
                retInfo.data  = [ServerProvider getMessageListByJSONArray:aryMessageList];
                
                //获取数据总数（用于停止刷新）
                id totalElements = [responseObject objectForKey:@"totalElements"];
                if (totalElements != [NSNull null] && totalElements != nil)
                {
                    retInfo.data2 = totalElements;
                }
                else
                {
                    retInfo.data2 = nil;
                }
            }
            
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

//我收到的公告（不是消息，只是图片然后关联一个分享id，跳转到分享）
+ (void)getAnnouncementList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getNoticeListURL]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            NSMutableArray *aryNoticeList = [NSMutableArray array];
            NSArray *aryResponse = responseObject;
            for (int i = 0; i < [aryResponse count]; i++)
            {
                NSDictionary *dicAnnouncement = (NSDictionary*)[aryResponse objectAtIndex:i];
                //公告消息(基本信息)
                AnnouncementVo *announcementVo = [[AnnouncementVo alloc]init];
                id announcementID = [dicAnnouncement objectForKey:@"id"];
                if (announcementID == [NSNull null] || announcementID == nil)
                {
                    announcementVo.strID = @"";
                }
                else
                {
                    announcementVo.strID = [announcementID stringValue];
                }
                announcementVo.strTitle = [Common checkStrValue:[dicAnnouncement objectForKey:@"noticeTitle"]];
                announcementVo.strImageURL = [Common checkStrValue:[dicAnnouncement objectForKey:@"imageUri"]];
                if (announcementVo.strImageURL.length > 0)
                {
                    announcementVo.strImageURL = [ServerURL getWholeURL:announcementVo.strImageURL];
                }
                
                id blogId = [dicAnnouncement objectForKey:@"blogId"];
                if (blogId == [NSNull null] || blogId == nil)
                {
                    announcementVo.strBlogID = @"";
                }
                else
                {
                    announcementVo.strBlogID = [blogId stringValue];
                }
                
                id noticeType = [dicAnnouncement objectForKey:@"noticeType"];
                if (noticeType == [NSNull null] || noticeType == nil)
                {
                    announcementVo.nNoticeType = 0;
                }
                else
                {
                    announcementVo.nNoticeType = [noticeType integerValue];
                }
                
                announcementVo.strCreateDate = [Common checkStrValue:[dicAnnouncement objectForKey:@"createDate"]];
                announcementVo.strStartDate = [Common checkStrValue:[dicAnnouncement objectForKey:@"posterStartdate"]];
                announcementVo.strEndDate = [Common checkStrValue:[dicAnnouncement objectForKey:@"posterEnddate"]];
                
                [aryNoticeList addObject:announcementVo];
            }
            
            retInfo.bSuccess = YES;
            retInfo.data = aryNoticeList;
        }
        resultBlock(retInfo);
    }];
}

//获取特定消息详情
+ (void)getMessageDetailByID:(NSString *)strArticledID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getMessageDetailURL],strArticledID];
    
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
            retInfo.data  = [ServerProvider getMessageListByJSONArray:@[responseObject]];
        }
        resultBlock(retInfo);
    }];
}

//3.参加、不参加、不确定 约会功能接口
+ (void)operateSchedule:(NSString *)strScheduleID andType:(int)nType result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strScheduleID forKey:@"id"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",nType] forKey:@"reply"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getOperateScheduleURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//4.参与投票 （实名和匿名:1匿名 0实名）
+ (void)operateVote:(NSString *)strVoteID andVoteOption:(NSMutableArray*)aryVoteOption andType:(int)nVoteType result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strVoteID forKey:@"id"];
    [bodyDic setObject:aryVoteOption forKey:@"voteOpionIdArr"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",nVoteType] forKey:@"anonymity"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getOperateVoteURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//5.删除消息(只能删除属于自己的消息)
+ (void)deleteMessage:(NSString *)strMessageID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDeleteMessageURL],strMessageID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//发表消息（普通消息、投票、日程）
+ (void)publishMsg:(MessageVo *)messageVo andPublishType:(PublishMessageFromType)publishMessageFromType result:(ResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //处理线程同步
        dispatch_group_t group = dispatch_group_create();
        
        //发送JSON数据
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        retInfo.bSuccess = YES;
        
        //上传消息图片
        if(messageVo.aryImageList != nil && messageVo.aryImageList.count > 0)
        {
            dispatch_group_enter(group);
            VNetworkFramework *networkMessageImage = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
            [networkMessageImage uploadBatchFileToServer:messageVo.aryImageList result:^(NSArray *aryResult, NSError *error) {
                if (error)
                {
                    retInfo.bSuccess = NO;
                    retInfo.strErrorMsg = error.localizedDescription;
                    resultBlock(retInfo);
                }
                else
                {
                    NSMutableArray *aryImgList = [NSMutableArray array];
                    for (UploadFileVo *uploadFileVo in aryResult)
                    {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:uploadFileVo.strID forKey:@"id"];
                        [aryImgList addObject:dic];
                    }
                    [bodyDic setObject:aryImgList forKey:@"imgList"];
                }
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        if (!retInfo.bSuccess)
        {
            return;
        }
        
        //上传投票图片
        if (messageVo.voteVo)
        {
            for (VoteOptionVo *voteOptionVo in messageVo.voteVo.aryVoteOption)
            {
                if (voteOptionVo.strImage)
                {
                    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);//保证投票图片上传的线程同步，避免失败的时候多次调用resultBlock
                    if (!retInfo.bSuccess)
                    {
                        return;
                    }
                    
                    dispatch_group_enter(group);
                    VNetworkFramework *networkVoteImage = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
                    [networkVoteImage uploadBatchFileToServer:@[voteOptionVo.strImage] result:^(NSArray *aryResult, NSError *error) {
                        if (error)
                        {
                            retInfo.bSuccess = NO;
                            retInfo.strErrorMsg = error.localizedDescription;
                            resultBlock(retInfo);
                        }
                        else
                        {
                            UploadFileVo *uploadFileVo = aryResult[0];
                            voteOptionVo.strImage = uploadFileVo.strURL;
                        }
                        dispatch_group_leave(group);
                    }];
                }
            }
        }
        
        //发送JSON数据操作
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (!retInfo.bSuccess)
            {
                return;
            }
            
            if (publishMessageFromType == PublishMessageReplyType)
            {
                //1.回复发表 有titleId
                if (messageVo.strTitleID != nil && messageVo.strTitleID.length>0)
                {
                    [bodyDic setObject:messageVo.strTitleID forKey:@"titleId"];
                }
                
                //回复消息 父ID
                if (messageVo.strReturnID != nil && messageVo.strReturnID.length>0)
                {
                    [bodyDic setObject:messageVo.strReturnID forKey:@"returnId"];
                }
            }
            else if (publishMessageFromType == PublishMessageForwardType)
            {
                //2.转发消息 父ID
                if (messageVo.strParentID != nil && messageVo.strParentID.length>0)
                {
                    [bodyDic setObject:messageVo.strParentID forKey:@"parentId"];
                }
            }
            else if (publishMessageFromType == PublishMessageDraftType)
            {
                //3.草稿 id (有id表示草稿的修改、发布，无id表示新发消息、草稿)
                if (messageVo.strID != nil && messageVo.strID.length>0)
                {
                    [bodyDic setObject:messageVo.strID forKey:@"id"];
                }
            }
            
            [bodyDic setObject:messageVo.strTitle forKey:@"titleName"];
            [bodyDic setObject:messageVo.strTextContent forKey:@"streamContent"];
            [bodyDic setObject:messageVo.strMsgType forKey:@"streamType"];
            [bodyDic setObject:[NSNumber numberWithInt:messageVo.nComeFromType] forKey:@"streamComefrom"];
            [bodyDic setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
            
            //外部邮箱接收列表
            NSMutableString *strReceiveEmail = [NSMutableString string];
            if (messageVo.aryReceiveEmail != nil && messageVo.aryReceiveEmail.count>0)
            {
                for (int i=0; i<messageVo.aryReceiveEmail.count; i++)
                {
                    [strReceiveEmail appendFormat:@"%@;",[messageVo.aryReceiveEmail objectAtIndex:i]];
                }
            }
            [bodyDic setObject:strReceiveEmail forKey:@"allReceiverMails"];
            
            //外部邮箱抄送列表
            NSMutableString *strCCEmail = [NSMutableString string];
            if (messageVo.aryCCEmail != nil && messageVo.aryCCEmail.count>0)
            {
                for (int i=0; i<messageVo.aryCCEmail.count; i++)
                {
                    [strCCEmail appendFormat:@"%@;",[messageVo.aryCCEmail objectAtIndex:i]];
                }
            }
            [bodyDic setObject:strCCEmail forKey:@"allCcReceiverMails"];
            
            //外部邮箱密送列表
            NSMutableString *strBCEmail = [NSMutableString string];
            if (messageVo.aryBCEmail != nil && messageVo.aryBCEmail.count>0)
            {
                for (int i=0; i<messageVo.aryBCEmail.count; i++)
                {
                    [strBCEmail appendFormat:@"%@;",[messageVo.aryBCEmail objectAtIndex:i]];
                }
            }
            [bodyDic setObject:strBCEmail forKey:@"allBccReceiverMails"];
            
            //是否短信提醒	非空	1:是,0:否
            [bodyDic setObject:[NSNumber numberWithBool:NO] forKey:@"sendSMS"];
            
            //vote
            if (messageVo.voteVo != nil)
            {
                NSMutableDictionary *dicVote = [NSMutableDictionary dictionary];
                [dicVote setObject:[NSNumber numberWithInteger:messageVo.voteVo.nVoteType] forKey:@"voteType"];
                
                NSMutableArray *aryVoteOption = [NSMutableArray array];
                for (int i=0; i<messageVo.voteVo.aryVoteOption.count; i++)
                {
                    VoteOptionVo *voteOptionVo = [messageVo.voteVo.aryVoteOption objectAtIndex:i];
                    NSDictionary *dicVoteOption = nil;
                    if (voteOptionVo.strImage)
                    {
                        //container vote image
                        dicVoteOption = @{@"content":voteOptionVo.strOptionName,@"imageUrl":voteOptionVo.strImage};
                    }
                    else
                    {
                        dicVoteOption = @{@"content":voteOptionVo.strOptionName};
                    }
                    [aryVoteOption addObject:dicVoteOption];
                }
                [dicVote setObject:aryVoteOption forKey:@"voteOptionList"];
                
                //vote object
                [bodyDic setObject:dicVote forKey:@"vote"];
            }
            
            //schedule
            if (messageVo.scheduleVo != nil)
            {
                NSMutableDictionary *dicSchedule = [NSMutableDictionary dictionary];
                [dicSchedule setObject:messageVo.scheduleVo.strStartTime forKey:@"startTimeFmt"];
                [dicSchedule setObject:[Common getCurrentUserVo].strUserID forKey:@"createBy"];
                [dicSchedule setObject:messageVo.scheduleVo.strAddress forKey:@"place"];
                
                //schedule object
                [bodyDic setObject:dicSchedule forKey:@"schedule"];
            }
            
            [bodyDic setObject:[NSNumber numberWithInt:messageVo.nSendAllPeople] forKey:@"sendAllPeople"];
            
            NSMutableArray *aryReceiver = [NSMutableArray array];
            //收件人列表(当收件人不为所有人)
            if (messageVo.nSendAllPeople == 0 && messageVo.aryReceiverList.count>0)
            {
                
                for (int i=0; i<messageVo.aryReceiverList.count; i++)
                {
                    ReceiverVo *receiverVo = [messageVo.aryReceiverList objectAtIndex:i];
                    
                    NSMutableDictionary *dicReceiver = [NSMutableDictionary dictionary];
                    [dicReceiver setObject:receiverVo.strID forKey:@"receiverId"];
                    [dicReceiver setObject:receiverVo.strName forKey:@"receiverName"];
                    [dicReceiver setObject:receiverVo.strType forKey:@"receiverType"];
                    [dicReceiver setObject:receiverVo.strCCType forKey:@"ccType"];
                    [aryReceiver addObject:dicReceiver];
                }
            }
            
            //抄送人列表
            if (messageVo.nSendAllPeople == 0 && messageVo.aryCCList!=nil && messageVo.aryCCList.count>0)
            {
                for (int i=0; i<messageVo.aryCCList.count; i++)
                {
                    ReceiverVo *receiverVo = [messageVo.aryCCList objectAtIndex:i];
                    
                    NSMutableDictionary *dicReceiver = [NSMutableDictionary dictionary];
                    [dicReceiver setObject:receiverVo.strID forKey:@"receiverId"];
                    [dicReceiver setObject:receiverVo.strName forKey:@"receiverName"];
                    [dicReceiver setObject:receiverVo.strType forKey:@"receiverType"];
                    [dicReceiver setObject:receiverVo.strCCType forKey:@"ccType"];
                    [aryReceiver addObject:dicReceiver];
                }
            }
            
            //密送人列表
            if (messageVo.nSendAllPeople == 0 && messageVo.aryBCCList!=nil && messageVo.aryBCCList.count>0)
            {
                for (int i=0; i<messageVo.aryBCCList.count; i++)
                {
                    ReceiverVo *receiverVo = [messageVo.aryBCCList objectAtIndex:i];
                    
                    NSMutableDictionary *dicReceiver = [NSMutableDictionary dictionary];
                    [dicReceiver setObject:receiverVo.strID forKey:@"receiverId"];
                    [dicReceiver setObject:receiverVo.strName forKey:@"receiverName"];
                    [dicReceiver setObject:receiverVo.strType forKey:@"receiverType"];
                    [dicReceiver setObject:receiverVo.strCCType forKey:@"ccType"];
                    [aryReceiver addObject:dicReceiver];
                }
            }
            
            //receiver list object
            [bodyDic setObject:aryReceiver forKey:@"streamReadShipList"];
            
            VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getPublishMsgURL]];
            [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
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
        });
    });
}

//即时聊天/////////////////////////////////////////////////////////////////////////////////////////////////
//1.获取历史聊天过的人和组（会话列表）
+ (void)getHistoryChatSessionList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getHistoryChatSessionURL]];
    [framework startRequestToChatServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryChatMemList = [NSMutableArray array];
            NSMutableArray *aryChatKeys = [NSMutableArray array];
            
            NSArray *aryUserList = (NSArray*)responseObject;
            for (NSDictionary *dicUser in aryUserList)
            {
                ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
                id isGroup = [dicUser objectForKey:@"isGroup"];
                if (isGroup == [NSNull null] || isGroup == nil)
                {
                    chatObjectVo.nType = 1;
                }
                else
                {
                    chatObjectVo.nType = [isGroup boolValue]?2:1;
                }
                
                if (chatObjectVo.nType == 2)
                {
                    //群聊
                    id toRefId = [dicUser objectForKey:@"toRefId"];//group id
                    if (toRefId == [NSNull null] || toRefId == nil)
                    {
                        chatObjectVo.strGroupID = @"";
                    }
                    else
                    {
                        chatObjectVo.strGroupID = [toRefId stringValue];
                    }
                    chatObjectVo.strGroupNodeID = [dicUser objectForKey:@"to"]; //node id
                    chatObjectVo.strGroupName = [Common checkStrValue:[dicUser objectForKey:@"toNickName"]];
                    chatObjectVo.strIMGURL = [ServerURL getWholeURL:[Common checkStrValue:[dicUser objectForKey:@"toProfilePhoto"]]];
                    
                    id fromRefId = [dicUser objectForKey:@"fromRefId"];//vest id
                    if (fromRefId == [NSNull null] || fromRefId == nil)
                    {
                        chatObjectVo.strVestID = @"";
                    }
                    else
                    {
                        chatObjectVo.strVestID = [fromRefId stringValue];
                    }
                    chatObjectVo.strVestNodeID = [dicUser objectForKey:@"from"];
                    chatObjectVo.strNAME = [Common checkStrValue:[dicUser objectForKey:@"fromNickName"]];
                    //生成ID数组，为了清理无用的缓存推送数量
                    [aryChatKeys addObject:[NSString stringWithFormat:@"group_%@",chatObjectVo.strGroupNodeID]];
                }
                else
                {
                    //私聊
                    NSString *strUserID = @"";
                    id fromRefId = [dicUser objectForKey:@"fromRefId"];//vest id
                    if (fromRefId == [NSNull null] || fromRefId == nil)
                    {
                        strUserID = @"";
                    }
                    else
                    {
                        strUserID = [fromRefId stringValue];
                    }
                    
                    //获取聊天对方ID
                    if ([strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                    {
                        //如果是自己发的聊天并且不来自群组，则获取对方ID(toRefId)
                        id toRefId = [dicUser objectForKey:@"toRefId"];//vest id
                        if (toRefId == [NSNull null] || toRefId == nil)
                        {
                            chatObjectVo.strVestID = @"";
                        }
                        else
                        {
                            chatObjectVo.strVestID = [toRefId stringValue];
                        }
                        chatObjectVo.strVestNodeID = [Common checkStrValue:[dicUser objectForKey:@"to"]];//node id
                        chatObjectVo.strNAME = [Common checkStrValue:[dicUser objectForKey:@"toNickName"]];
                        chatObjectVo.strIMGURL = [ServerURL getWholeURL:[Common checkStrValue:[dicUser objectForKey:@"toProfilePhoto"]]];
                    }
                    else
                    {
                        //如果是别人发的聊天或者来自群组，则获取fromRefId
                        chatObjectVo.strVestID = strUserID;//vest id
                        chatObjectVo.strVestNodeID = [Common checkStrValue:[dicUser objectForKey:@"from"]];//node id
                        chatObjectVo.strNAME = [Common checkStrValue:[dicUser objectForKey:@"fromNickName"]];
                        chatObjectVo.strIMGURL = [ServerURL getWholeURL:[Common checkStrValue:[dicUser objectForKey:@"fromProfilePhoto"]]];
                    }
                    
                    //生成ID数组，为了清理无用的缓存推送数量
                    [aryChatKeys addObject:[NSString stringWithFormat:@"vest_%@",chatObjectVo.strVestID]];
                }
                
                chatObjectVo.strLastChatTime = [Common checkStrValue:[dicUser objectForKey:@"dateFmt"]];
                
                //是否被讨论组管理员踢出讨论组
                id reject = [dicUser objectForKey:@"reject"];
                if (reject == [NSNull null] || reject == nil)
                {
                    chatObjectVo.bReject = NO;
                }
                else
                {
                    chatObjectVo.bReject = [reject boolValue];
                }
                
                id stick = [dicUser objectForKey:@"stick"];
                if (stick == [NSNull null] || stick == nil)
                {
                    chatObjectVo.bTopMsg = NO;
                }
                else
                {
                    chatObjectVo.bTopMsg = [stick boolValue];
                }
                
                int nContentType = [[dicUser objectForKey:@"type"]intValue];
                if (nContentType == 0)
                {
                    //文本
                    chatObjectVo.strLastChatCon = [Common checkStrValue:[dicUser objectForKey:@"contentText"]];
                }
                else if (nContentType == 1)
                {
                    //图片
                    chatObjectVo.strLastChatCon = @"图片";
                }
                else if (nContentType == 3)
                {
                    //语音
                    chatObjectVo.strLastChatCon = @"[语音]";
                }
                else
                {
                    //文件或者未知类型
                    chatObjectVo.strLastChatCon = [Common checkStrValue:[dicUser objectForKey:@"contentText"]];
                }
                
                NSString *strName = @"";
                if (chatObjectVo.nType == 2)
                {
                    //群聊
                    strName = chatObjectVo.strGroupName;
                }
                else
                {
                    strName = chatObjectVo.strNAME;
                }
                //get pinyin
                NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:strName];
                if(aryPinyin!=nil && aryPinyin.count>0)
                {
                    chatObjectVo.strQP = [aryPinyin objectAtIndex:0];
                    if (aryPinyin.count>1)
                    {
                        chatObjectVo.strJP = [aryPinyin objectAtIndex:1];
                    }
                }
                
                [aryChatMemList addObject:chatObjectVo];
            }
            
            retInfo.data = aryChatMemList;
            retInfo.data2 = aryChatKeys;
        }
        resultBlock(retInfo);
    }];
}

//2.发送单聊信息
+ (void)sendSingleChat:(SendChatVo *)sendChatVo result:(ResultBlock)resultBlock
{
    //JSON信息请求 block
    void (^postJSONBlock)(UploadFileVo *) = ^(UploadFileVo *uploadFileVo){
        NSString *strFileID;
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        if (uploadFileVo != nil)
        {
            if (sendChatVo.nContentType == 1)
            {
                //添加图片
                NSString *strURL = uploadFileVo.strURL;
                NSString *strMidURL = uploadFileVo.strURL;
                NSString *strMinURL = uploadFileVo.strURL;
                
                NSArray *aryImg = @[strURL,strMidURL,strMinURL];
                [bodyDic setObject:aryImg forKey:@"filePath"];//图片地址的数组，排序为原图，中图，缩略图，手机图
                [bodyDic setObject:[sendChatVo.strFilePath lastPathComponent] forKey:@"fileName"];
            }
            else
            {
                //文件
                NSString *strURL = uploadFileVo.strURL;
                
                [bodyDic setObject:strURL forKey:@"filePath"];
                [bodyDic setObject:[sendChatVo.strFilePath lastPathComponent] forKey:@"fileName"];
                [bodyDic setObject:uploadFileVo.strID forKey:@"fileId"];
                strFileID = uploadFileVo.strID;
            }
        }
        
        if(sendChatVo.strStreamContent == nil || sendChatVo.strStreamContent.length == 0)
        {
            sendChatVo.strStreamContent = @"";
        }
        
        if (sendChatVo.strOtherVestID)
        {
            [bodyDic setObject:sendChatVo.strOtherVestID forKey:@"toUserId"];
        }
        if (sendChatVo.strOtherVestNodeID)
        {
            [bodyDic setObject:sendChatVo.strOtherVestNodeID forKey:@"to"];
        }
        
        [bodyDic setObject:[NSString stringWithFormat:@"%i",sendChatVo.nContentType] forKey:@"type"];
        [bodyDic setObject:sendChatVo.strStreamContent forKey:@"content"];
        
        VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSendSingleChatURL]];
        [networkFramework startRequestToChatServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
            ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
            if (error)
            {
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = error.localizedDescription;
            }
            else
            {
                retInfo.bSuccess = YES;
                retInfo.data = strFileID;
            }
            resultBlock(retInfo);
        }];
    };
    
    //附件上传
    if (sendChatVo.nContentType == 1 || sendChatVo.nContentType == 2 || sendChatVo.nContentType == 3)
    {
        VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
        [networkFrameworkFile uploadBatchFileToServer:@[sendChatVo.strFilePath] result:^(NSArray *aryResult, NSError *error) {
            if (error)
            {
                ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = error.localizedDescription;
                resultBlock(retInfo);
            }
            else
            {
                UploadFileVo *uploadFileVo = aryResult[0];
                postJSONBlock(uploadFileVo);
            }
        }];
    }
    else
    {
        postJSONBlock(nil);
    }
}

//3.通过ID获取聊天记录(单聊)
+ (void)getChatContentByCId:(NSString*)strChatContentID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getSingleChatConByCIdURL],strChatContentID];
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:strURL];
    [framework startRequestToChatServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            NSMutableArray *aryChatContent = [ServerProvider getChatListByJSONArray:@[responseObject] andType:1];
            if (aryChatContent.count>0)
            {
                retInfo.data = [aryChatContent objectAtIndex:0];
            }
        }
        resultBlock(retInfo);
    }];
}

//4.历史单聊记录
+ (void)getSingleHistoryChatList:(NSString*)strOtherVestId andStartDateTime:(long long)nStartDateTime andPageNum:(NSInteger)nPageNum result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strOtherVestId forKey:@"refId"];
    if (nPageNum != 1)
    {
        [bodyDic setObject:[NSNumber numberWithLongLong:nStartDateTime] forKey:@"startDate"];
    }
    [bodyDic setObject:[NSNumber numberWithInteger:nPageNum] forKey:@"pageNum"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getHistoryChatUserURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            long long nQueryDateTime = 0;
            NSMutableArray *aryChatContent = [ServerProvider getChatListByJSONArray:(NSArray*)responseObject andType:1];
            if (nPageNum == 1 && aryChatContent.count>0)
            {
                ChatContentVo *chatContentVo = [aryChatContent objectAtIndex:(aryChatContent.count-1)];
                nQueryDateTime = chatContentVo.nChatTime;
            }
            retInfo.data = aryChatContent;
            retInfo.data2 = [NSNumber numberWithLongLong:nQueryDateTime];
        }
        resultBlock(retInfo);
    }];
}

//5.发送群聊信息
+ (void)sendGroupChat:(SendChatVo *)sendChatVo result:(ResultBlock)resultBlock
{
    //JSON信息请求 block
    void (^postJSONBlock)(UploadFileVo *) = ^(UploadFileVo *uploadFileVo){
        NSString *strFileID;
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        if (uploadFileVo != nil)
        {
            if (sendChatVo.nContentType == 1)
            {
                //图片
                NSString *strURL = uploadFileVo.strURL;
                NSString *strMidURL = uploadFileVo.strMidURL;
                NSString *strMinURL = uploadFileVo.strMinURL;
                
                NSArray *aryImg = @[strURL,strMidURL,strMinURL];
                [bodyDic setObject:aryImg forKey:@"filePath"];//图片地址的数组，排序为原图，中图，缩略图，手机图
                [bodyDic setObject:[sendChatVo.strFilePath lastPathComponent] forKey:@"fileName"];
            }
            else
            {
                //附件
                NSString *strURL = uploadFileVo.strURL;
                
                [bodyDic setObject:strURL forKey:@"filePath"];
                [bodyDic setObject:[sendChatVo.strFilePath lastPathComponent] forKey:@"fileName"];
                [bodyDic setObject:uploadFileVo.strID forKey:@"fileId"];
                strFileID = uploadFileVo.strID;
            }
        }
        
        if(sendChatVo.strStreamContent == nil || sendChatVo.strStreamContent.length == 0)
        {
            sendChatVo.strStreamContent = @"";
        }
        
        if (sendChatVo.strTeamID)
        {
            [bodyDic setObject:sendChatVo.strTeamID forKey:@"toTeamId"];
        }
        if (sendChatVo.strTeamNodeID)
        {
            [bodyDic setObject:sendChatVo.strTeamNodeID forKey:@"to"];
        }
        
        [bodyDic setObject:[NSString stringWithFormat:@"%i",sendChatVo.nContentType] forKey:@"type"];
        [bodyDic setObject:sendChatVo.strStreamContent forKey:@"content"];
        
        VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSendGroupChatURL]];
        [networkFramework startRequestToChatServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
            ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
            if (error)
            {
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = error.localizedDescription;
            }
            else
            {
                retInfo.bSuccess = YES;
                retInfo.data = strFileID;
            }
            resultBlock(retInfo);
        }];
    };
    
    //附件上传
    if (sendChatVo.nContentType == 1 || sendChatVo.nContentType == 2 || sendChatVo.nContentType == 3)
    {
        VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
        [networkFrameworkFile uploadBatchFileToServer:@[sendChatVo.strFilePath] result:^(NSArray *aryResult, NSError *error) {
            if (error)
            {
                ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = error.localizedDescription;
                resultBlock(retInfo);
            }
            else
            {
                UploadFileVo *uploadFileVo = aryResult[0];
                postJSONBlock(uploadFileVo);
            }
        }];
    }
    else
    {
        postJSONBlock(nil);
    }
}

//6.通过ID获取聊天记录(群聊)
+ (void)getGroupChatContentByCId:(NSString*)strChatContentID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getGroupChatConByCIdURL],strChatContentID];
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:strURL];
    [framework startRequestToChatServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            NSMutableArray *aryChatContent = [ServerProvider getChatListByJSONArray:@[responseObject] andType:2];
            if (aryChatContent.count>0)
            {
                retInfo.data = [aryChatContent objectAtIndex:0];
            }
        }
        resultBlock(retInfo);
    }];
}

//7.历史群聊记录
+ (void)getGroupHistoryChatList:(ChatObjectVo*)chatObjectVo andStartDateTime:(long long)nStartDateTime andPageNum:(NSInteger)nPageNum result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (chatObjectVo.strGroupID)
    {
        [bodyDic setObject:chatObjectVo.strGroupID forKey:@"refId"];
    }
    if (chatObjectVo.strGroupNodeID)
    {
        [bodyDic setObject:chatObjectVo.strGroupNodeID forKey:@"id"];
    }
    if (nPageNum != 1)
    {
        [bodyDic setObject:[NSNumber numberWithLongLong:nStartDateTime] forKey:@"startDate"];
    }
    [bodyDic setObject:[NSNumber numberWithInteger:nPageNum] forKey:@"pageNum"];
    [bodyDic setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getGroupHistoryChatURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            long long nQueryDateTime = 0;
            NSMutableArray *aryChatContent = [ServerProvider getChatListByJSONArray:(NSArray*)responseObject andType:2];
            if (nPageNum == 1 && aryChatContent.count>0)
            {
                ChatContentVo *chatContentVo = [aryChatContent objectAtIndex:(aryChatContent.count-1)];
                nQueryDateTime = chatContentVo.nChatTime;
            }
            retInfo.data = aryChatContent;
            retInfo.data2 = [NSNumber numberWithLongLong:nQueryDateTime];
        }
        resultBlock(retInfo);
    }];
}

//8.创建讨论组或者邀请加入
+ (void)createOrUpdateChatDiscussion:(NSMutableArray*)aryMemberList andChatObject:(ChatObjectVo*)chatObjectVo result:(ResultBlock)resultBlock
{
    NSMutableArray *aryTempMember = [NSMutableArray array];
    for (int i=0; i<aryMemberList.count; i++)
    {
        ChatObjectVo *chatObjectVo = [aryMemberList objectAtIndex:i];
        NSDictionary *dicMember = nil;
        if (chatObjectVo.nType == 1)
        {
            //用户
            dicMember = @{@"type":@"U",@"refId":chatObjectVo.strVestID};
        }
        else
        {
            //群组
            dicMember = @{@"type":@"G",@"refId":chatObjectVo.strGroupID,@"orgId":[Common getCurrentUserVo].strCompanyID};
        }
        [aryTempMember addObject:dicMember];
    }
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:aryTempMember forKey:@"members"];
    if (chatObjectVo != nil && chatObjectVo.strGroupNodeID != nil && chatObjectVo.bDiscussion)
    {
        //修改讨论组，邀请人加入(其他的均为创建，包括用户和群组)
        [bodyDic setObject:chatObjectVo.strGroupNodeID forKey:@"id"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCreateOrUpdateChatDiscussionURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            GroupVo *groupVo = nil;
            groupVo = [[GroupVo alloc]init];
            id refId = [responseObject objectForKey:@"refId"];
            if (refId == [NSNull null] || refId == nil)
            {
                groupVo.strGroupID = @"";
            }
            else
            {
                groupVo.strGroupID = [refId stringValue];
            }
            groupVo.strGroupNodeID = [Common checkStrValue:[responseObject objectForKey:@"_id"]];
            groupVo.strGroupName = [Common checkStrValue:[responseObject objectForKey:@"name"]];
            groupVo.strGroupImage = [ServerURL getWholeURL:[Common checkStrValue:[responseObject objectForKey:@"profilePhoto"]]];
            
            id founderRefId = [responseObject objectForKey:@"founderRefId"];
            if (founderRefId == [NSNull null] || founderRefId == nil)
            {
                groupVo.strCreatorID = @"";
            }
            else
            {
                groupVo.strCreatorID = [founderRefId stringValue];
            }
            groupVo.strCreatorName = [Common checkStrValue:[responseObject objectForKey:@"founder"]];
            
            groupVo.aryMemberVo = [NSMutableArray array];
            NSMutableArray *aryMember =  [responseObject objectForKey:@"members"];
            if (aryMember != nil)
            {
                for (int i=0; i<aryMember.count; i++)
                {
                    NSDictionary *dicMember = [aryMember objectAtIndex:i];
                    UserVo *userVo = [[UserVo alloc]init];
                    id refId = [dicMember objectForKey:@"refId"];
                    if (refId == [NSNull null] || refId == nil)
                    {
                        userVo.strUserID = @"";
                    }
                    else
                    {
                        userVo.strUserID = [refId stringValue];
                    }
                    userVo.strUserNodeID = [Common checkStrValue:[responseObject objectForKey:@"_id"]];
                    userVo.strUserName = [Common checkStrValue:[responseObject objectForKey:@"nickName"]];
                    userVo.strHeadImageURL = [ServerURL getWholeURL:[Common checkStrValue:[responseObject objectForKey:@"profilePhoto"]]];
                    [groupVo.aryMemberVo addObject:userVo];
                }
            }
            
            retInfo.data = groupVo;
        }
        resultBlock(retInfo);
    }];
}

//9.获取聊天信息(个人)
+ (void)getChatSingleInfo:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    if (chatObject.strVestID)
    {
        [dicBody setObject:chatObject.strVestID forKey:@"refId"];
    }
    if (chatObject.strVestNodeID)
    {
        [dicBody setObject:chatObject.strVestNodeID forKey:@"id"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getChatSingleInfoURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSDictionary *responseDic = responseObject;
            ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
            chatObjectVo.strVestID = chatObject.strVestID;
            chatObjectVo.strVestNodeID = [Common checkStrValue:[responseDic objectForKey:@"_id"]];
            chatObjectVo.nType = 1;
            
            chatObjectVo.strNAME = [Common checkStrValue:[responseDic objectForKey:@"nickName"]];
            chatObjectVo.strIMGURL = [ServerURL getWholeURL:[Common checkStrValue:[responseDic objectForKey:@"profilePhoto"]]];
            
            id enablePush = [responseDic objectForKey:@"enablePush"];
            if (enablePush == [NSNull null] || enablePush == nil)
            {
                chatObjectVo.bEnablePush = NO;
            }
            else
            {
                chatObjectVo.bEnablePush = [enablePush boolValue];
            }
            
            id stick = [responseDic objectForKey:@"stick"];
            if (stick == [NSNull null] || stick == nil)
            {
                chatObjectVo.bTopMsg = NO;
            }
            else
            {
                chatObjectVo.bTopMsg = [stick boolValue];
            }
            
            chatObjectVo.aryMember = [NSMutableArray array];
            UserVo *userVo = [[UserVo alloc]init];
            userVo.strUserID = chatObjectVo.strVestID;
            userVo.strUserNodeID = chatObjectVo.strVestNodeID;
            userVo.strUserName = chatObjectVo.strNAME;
            userVo.strHeadImageURL = chatObjectVo.strIMGURL;
            [chatObjectVo.aryMember addObject:userVo];
            
            retInfo.data = chatObjectVo;
        }
        resultBlock(retInfo);
    }];
}

//10.获取聊天信息(聊天组)
+ (void)getChatGroupInfo:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    if (chatObject.strGroupID)
    {
        [dicBody setObject:chatObject.strGroupID forKey:@"refId"];
    }
    if (chatObject.strGroupNodeID)
    {
        [dicBody setObject:chatObject.strGroupNodeID forKey:@"id"];
    }
    
    [dicBody setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getChatGroupInfoURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSDictionary *responseDic = responseObject;
            
            ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
            chatObjectVo.strGroupID = [[responseDic objectForKey:@"refId"]stringValue];
            chatObjectVo.strGroupNodeID = [Common checkStrValue:[responseDic objectForKey:@"_id"]];
            chatObjectVo.strGroupName = [Common checkStrValue:[responseDic objectForKey:@"name"]];
            chatObjectVo.nType = 2;
            
            id founderRefId = [responseDic objectForKey:@"founderRefId"];
            if (founderRefId == [NSNull null] || founderRefId == nil)
            {
                chatObjectVo.strVestID = @"";
            }
            else
            {
                chatObjectVo.strVestID = [founderRefId stringValue];
            }
            
            chatObjectVo.strVestNodeID = [Common checkStrValue:[responseDic objectForKey:@"founder"]];
            chatObjectVo.strIMGURL = [ServerURL getWholeURL:[Common checkStrValue:[responseDic objectForKey:@"profilePhoto"]]];
            
            id isDiscussion = [responseDic objectForKey:@"isDiscussion"];
            if (isDiscussion == [NSNull null] || isDiscussion == nil)
            {
                chatObjectVo.bDiscussion = NO;
            }
            else
            {
                chatObjectVo.bDiscussion = [isDiscussion boolValue];
            }
            
            id unnamed = [responseDic objectForKey:@"unnamed"];
            if (unnamed == [NSNull null] || unnamed == nil)
            {
                chatObjectVo.bUnnaming = NO;
            }
            else
            {
                chatObjectVo.bUnnaming = [unnamed boolValue];
            }
            
            id enablePush = [responseDic objectForKey:@"enablePush"];
            if (enablePush == [NSNull null] || enablePush == nil)
            {
                chatObjectVo.bEnablePush = NO;
            }
            else
            {
                chatObjectVo.bEnablePush = [enablePush boolValue];
            }
            
            id stick = [responseDic objectForKey:@"stick"];
            if (stick == [NSNull null] || stick == nil)
            {
                chatObjectVo.bTopMsg = NO;
            }
            else
            {
                chatObjectVo.bTopMsg = [stick boolValue];
            }
            
            chatObjectVo.aryMember = [NSMutableArray array];
            NSMutableArray *aryMember =  [responseDic objectForKey:@"members"];
            if (aryMember != nil)
            {
                for (int i=0; i<aryMember.count; i++)
                {
                    NSDictionary *dicMember = [aryMember objectAtIndex:i];
                    UserVo *userVo = [[UserVo alloc]init];
                    id refId = [dicMember objectForKey:@"refId"];
                    if (refId == [NSNull null] || refId == nil)
                    {
                        userVo.strUserID = @"";
                    }
                    else
                    {
                        userVo.strUserID = [refId stringValue];
                    }
                    
                    userVo.bCanNotCheck = YES;
                    userVo.strUserNodeID = [Common checkStrValue:[dicMember objectForKey:@"_id"]];
                    userVo.strUserName = [Common checkStrValue:[dicMember objectForKey:@"nickName"]];
                    userVo.strHeadImageURL = [ServerURL getWholeURL:[Common checkStrValue:[dicMember objectForKey:@"profilePhoto"]]];
                    
                    //get pinyin
                    NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:userVo.strUserName];
                    if(aryPinyin!=nil && aryPinyin.count>0)
                    {
                        userVo.strQP = [aryPinyin objectAtIndex:0];
                        if (aryPinyin.count>1)
                        {
                            userVo.strJP = [aryPinyin objectAtIndex:1];
                        }
                    }
                    
                    if ([chatObjectVo.strVestID isEqualToString:userVo.strUserID])
                    {
                        //群主，则插入第一位
                        userVo.bGroupFounder = YES;
                        [chatObjectVo.aryMember insertObject:userVo atIndex:0];
                    }
                    else
                    {
                        userVo.bGroupFounder = NO;
                        [chatObjectVo.aryMember addObject:userVo];
                    }
                    
                }
            }
            
            retInfo.data = chatObjectVo;
        }
        resultBlock(retInfo);
    }];
}

//11.清除聊天历史记录
+ (void)clearChatHistory:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    if (chatObject.nType == 1)
    {
        //私聊
        [dicBody setObject:@"U" forKey:@"type"];
        
        if (chatObject.strVestID)
        {
            [dicBody setObject:chatObject.strVestID forKey:@"refId"];
        }
        if (chatObject.strVestNodeID)
        {
            [dicBody setObject:chatObject.strVestNodeID forKey:@"id"];
        }
    }
    else
    {
        //群聊
        [dicBody setObject:@"G" forKey:@"type"];
        [dicBody setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
        
        if (chatObject.strGroupID)
        {
            [dicBody setObject:chatObject.strGroupID forKey:@"refId"];
        }
        if (chatObject.strGroupNodeID)
        {
            [dicBody setObject:chatObject.strGroupNodeID forKey:@"id"];
        }
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getClearChatRecordURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//12.消息推送关闭和开启
+ (void)setPushSwitch:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    if (chatObject.nType == 1)
    {
        //私聊
        [dicBody setObject:@"U" forKey:@"type"];
        
        if (chatObject.strVestID)
        {
            [dicBody setObject:chatObject.strVestID forKey:@"refId"];
        }
        if (chatObject.strVestNodeID)
        {
            [dicBody setObject:chatObject.strVestNodeID forKey:@"id"];
        }
    }
    else
    {
        //群聊
        [dicBody setObject:@"G" forKey:@"type"];
        [dicBody setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
        
        if (chatObject.strGroupID)
        {
            [dicBody setObject:chatObject.strGroupID forKey:@"refId"];
        }
        if (chatObject.strGroupNodeID)
        {
            [dicBody setObject:chatObject.strGroupNodeID forKey:@"id"];
        }
    }
    
    if (chatObject.bEnablePush)
    {
        //加入黑名单(关闭推送)
        [dicBody setObject:@"add" forKey:@"set"];
    }
    else
    {
        //启用推送
        [dicBody setObject:@"remove" forKey:@"set"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSetPushSwitchURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//13.置顶接口
+ (void)setTopChat:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    if (chatObject.nType == 1)
    {
        //私聊
        [dicBody setObject:@"U" forKey:@"type"];
        
        if (chatObject.strVestID)
        {
            [dicBody setObject:chatObject.strVestID forKey:@"refId"];
        }
        if (chatObject.strVestNodeID)
        {
            [dicBody setObject:chatObject.strVestNodeID forKey:@"id"];
        }
    }
    else
    {
        //群聊
        [dicBody setObject:@"G" forKey:@"type"];
        [dicBody setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
        
        if (chatObject.strGroupID)
        {
            [dicBody setObject:chatObject.strGroupID forKey:@"refId"];
        }
        if (chatObject.strGroupNodeID)
        {
            [dicBody setObject:chatObject.strGroupNodeID forKey:@"id"];
        }
    }
    
    if (chatObject.bTopMsg)
    {
        //移除top
        [dicBody setObject:@"remove" forKey:@"set"];
    }
    else
    {
        //增加top
        [dicBody setObject:@"add" forKey:@"set"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSetTopChatURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//14.从讨论组中踢人
+ (void)deleteChatGroupMember:(NSString*)strMemberID andGroupNodeID:(NSString*)strGroupNodeID result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:strMemberID forKey:@"refId"];//成员ID
    [dicBody setObject:strGroupNodeID forKey:@"id"];//讨论组的id
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getDeleteChatGroupMemberURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//15.自己退出讨论组
+ (void)selfExitChatGroup:(NSString*)strGroupNodeID result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:strGroupNodeID forKey:@"id"];//讨论组的id
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSelfExitChatGroupURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//16.获取自己加入的讨论组
+ (void)getJoinedChatGroupList:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getJoinedGroupChatListURL]];
    [networkFramework startRequestToChatServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            
            NSMutableArray *aryGroup = [NSMutableArray array];
            NSArray *aryResponseData = (NSArray*)responseObject;
            if([aryResponseData isKindOfClass:[NSArray class]])
            {
                for (NSDictionary *dicGroup in aryResponseData)
                {
                    GroupVo *groupVo = [[GroupVo alloc]init];
                    groupVo.strGroupName = [Common checkStrValue:dicGroup[@"name"]];
                    groupVo.strGroupNodeID = [Common checkStrValue:dicGroup[@"_id"]];
                    groupVo.strGroupImage = [Common checkStrValue:dicGroup[@"profilePhoto"]];
                    [aryGroup addObject:groupVo];
                }
            }
            
            retInfo.bSuccess = YES;
            retInfo.data = aryGroup;
        }
        resultBlock(retInfo);
    }];
}

//17.删除指定的历史会话
+ (void)deleteChatSingleSession:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    if (chatObject.nType == 1)
    {
        //私聊
        [dicBody setObject:chatObject.strVestNodeID forKey:@"id"];//node id
        [dicBody setObject:[NSNumber numberWithBool:NO] forKey:@"isGroup"];
    }
    else
    {
        //群聊
        [dicBody setObject:chatObject.strGroupNodeID forKey:@"id"];//node id
        [dicBody setObject:[NSNumber numberWithBool:YES] forKey:@"isGroup"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getDeleteChatSessionByIDURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//18.讨论组重命名
+ (void)renameChatDiscussion:(ChatObjectVo*)chatObject andNewName:(NSString*)strNewName result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:chatObject.strGroupNodeID forKey:@"id"];//discussion node id
    [dicBody setObject:strNewName forKey:@"name"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getRenameChatDiscussionURL]];
    [networkFramework startRequestToChatServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
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

//以流的形式上传文件
+ (void)uploadAttachment:(NSString *)path result:(ResultBlock)resultBlock
{
    NSString *strFileUploadURL = [ServerURL getUploadFileURL];
    strFileUploadURL = [strFileUploadURL stringByAppendingFormat:@"?fn=%@",[Common getFileNameFromPath:path]];
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strFileUploadURL];
    [networkFramework uploadSingleFileWithBinary:path result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            retInfo.data = responseObject;
        }
        resultBlock(retInfo);
    }];
}

//评论操作/////////////////////////////////////////////////////////
//按照页码分页获取评论列表
+ (void)getCommentList:(NSString*)strArticleID andPageNum:(int)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strArticleID forKey:@"blogId"];
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInt:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getBlogCommentListByPageURL]];
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
            
            NSArray *aryCommentList = [responseObject objectForKey:@"content"];
            if (aryCommentList != nil)
            {
                retInfo.data  = [ServerProvider getCommentListByJSONArray:aryCommentList];
            }
        }
        resultBlock(retInfo);
    }];
}

//按照endCommentId分页获取评论列表,【bMidData：YES 查询评论中间数据（用于评论提醒跳转）,NO：正常的按照endId查询】
+ (void)getCommentList:(NSString*)strArticleID type:(NSString *)strType endCommentId:(NSString *)strEndCommentID midData:(BOOL)bMidData pageNumber:(NSInteger)page result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    if (bMidData)
    {
        [tempBodyDic setObject:@0 forKey:@"pageNumber"];
    }
    else
    {
        [tempBodyDic setObject:@1 forKey:@"pageNumber"];
    }
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    if (strEndCommentID.length>0)
    {
//#warning .................... 6.3
//        [bodyDic setObject:strEndCommentID forKey:@"endCommentId"];
    }
    
    NSString *strURL;
    if ([strType isEqualToString:@"activity"])
    {
        //活动评论
        [tempBodyDic setObject:@(page) forKey:@"pageNumber"];
        [bodyDic removeAllObjects];
        [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
        [bodyDic setObject:strArticleID forKey:@"activityId"];
        
        strURL = [ServerURL getActivityCommentListByPageURL];
    }
    else if ([strType isEqualToString:@"answer"])
    {
        //回答评论
        [tempBodyDic setObject:@(page) forKey:@"pageNumber"];
        [bodyDic removeAllObjects];
        [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
        [bodyDic setObject:strArticleID forKey:@"answerId"];
        
        strURL = [ServerURL getAnswerCommentListByPageURL];
    }
    else
    {
        //分享评论
        [tempBodyDic setObject:@(page) forKey:@"pageNumber"];
        [bodyDic setObject:strArticleID forKey:@"blogId"];
        strURL = [ServerURL getBlogCommentListByPageURL];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
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
            
            NSArray *aryCommentJSON = [responseObject objectForKey:@"content"];
            if (aryCommentJSON != nil)
            {
                retInfo.data  = [ServerProvider getCommentListByJSONArray:aryCommentJSON];
            }
            
            //最后一页
            id lastPage = responseObject[@"lastPage"];
            retInfo.data2 = lastPage;
        }
        resultBlock(retInfo);
    }];
}

//增加评论 strSourceID:源ID nType:【1针对消息 2.针对消息评论,非空】
+ (void)addComment:(NSString *)strSourceID  blogId:(NSString *)strBlogID content:(NSString*)strContent type:(NSString *)strType result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    NSString *strURL;
    if ([strType isEqualToString:@"activity"])
    {
        //活动评论
        if(strSourceID != nil) {
            [bodyDic setObject:strSourceID forKey:@"refId"];
        }
        [bodyDic setObject:strBlogID forKey:@"activityId"];
        [bodyDic setObject:strContent forKey:@"content"];
        strURL = [ServerURL getActivityCreateCommentURL];
    }
    else if ([strType isEqualToString:@"answer"])
    {
        //回答评论
        if(strSourceID != nil) {
            [bodyDic setObject:strSourceID forKey:@"parentId"];
        }
        [bodyDic setObject:strBlogID forKey:@"answerId"];
        [bodyDic setObject:strContent forKey:@"commentText"];
        strURL = [ServerURL getAnswerCreateCommentURL];
    }
    else
    {
        //分享评论
        if(strSourceID != nil) {
            [bodyDic setObject:strSourceID forKey:@"parentId"];
        }
        [bodyDic setObject:strBlogID forKey:@"blogId"];
        [bodyDic setObject:strContent forKey:@"commentHtml"];
        strURL = [ServerURL getCreateComment];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
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
            retInfo.data  = [ServerProvider getCommentListByJSONArray:@[responseObject]];
        }
        resultBlock(retInfo);
    }];
}

//删除评论
+ (void)deleteComment:(NSString *)strSourceID type:(NSString *)strType result:(ResultBlock)resultBlock
{
    NSString *strURL;
    if ([strType isEqualToString:@"activity"])
    {
        //活动
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDeleteActivityCommentURL],strSourceID];
    }
    else if ([strType isEqualToString:@"answer"])
    {
        //回答
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDeleteAnswerCommentURL],strSourceID];
    }
    else
    {
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDeleteComment],strSourceID];
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
        }
        resultBlock(retInfo);
    }];
}

//赞分享评论
+ (void)praiseComment:(NSString *)strID type:(NSString *)strType result:(ResultBlock)resultBlock
{
    NSString *strURL;
    if ([strType isEqualToString:@"activity"])
    {
        //活动
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getPraiseActivityCommentURL],strID];
    }
    else if ([strType isEqualToString:@"answer"])
    {
        //回答
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getAnswerCommentMentionURL],strID];
    }
    else
    {
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getPraiseShareCommentURL],strID];
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
            
            NSString *strJSONKey;
            if ([strType isEqualToString:@"answer"]) {
                strJSONKey = @"mentionId";
            } else {
                strJSONKey = @"id";
            }
                
            id paiserID = [responseObject objectForKey:strJSONKey];
            if (paiserID == [NSNull null]|| paiserID == nil) {
                paiserID = nil;
            } else {
                paiserID = [paiserID stringValue];
            }
            retInfo.data = paiserID;
        }
        resultBlock(retInfo);
    }];
}

//分享相关////////////////////////////////////////////////////////////////////////
//分享列表(所有、某个人)
+ (void)getShareBlog:(NSString*)strBlogID andType:(int)nType content:(NSString*)strContent create:(NSString *)createBy result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    if (strBlogID != nil && strBlogID.length>0)
    {
        [bodyDic setObject:strBlogID forKey:@"id"];
    }
    if (strContent != nil && strContent.length>0)
    {
        [bodyDic setObject:strContent forKey:@"streamContent"];
    }
    if (createBy != nil && createBy.length > 0)
    {
        [bodyDic setObject:createBy forKey:@"createBy"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getShareBlog]];
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
            NSArray *aryBlogList = [responseObject objectForKey:@"content"];
            if (aryBlogList != nil)
            {
                retInfo.data  = [ServerProvider getBlogListByJSONArray:aryBlogList];
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

//查询按时间线的全部分享、问答、投票(不传type,查询所有)
+ (void)getShareListByType:(NSString *)strType search:(NSString *)strSearchText tag:(NSArray*)aryTag page:(NSInteger)nPage modelId:(NSString *)modelId result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    if (strType != nil && strType.length > 0)
    {
        [bodyDic setObject:strType forKey:@"type"];
    }
    
    if (strSearchText != nil && strSearchText.length > 0)
    {
        if (![strSearchText isEqualToString:@"9810"]){
        [bodyDic setObject:strSearchText forKey:@"queryName"];
        }
    }
    
    if (aryTag != nil)
    {
        NSMutableArray *aryTagIDList = [NSMutableArray array];
        for (TagVo *tagVo in aryTag)
        {
            [aryTagIDList addObject:tagVo.strID];
        }
        [bodyDic setObject:aryTagIDList forKey:@"tagIdList"];
    }
//    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
//    [bodyDic setObject:@"0" forKey:@"endBlogId"];
//    [bodyDic setObject:@{@"pageNumber":@(currentPage),@"pageSize":@"10"} forKey:@"pageInfo"];
//    if (_dataTP != DataTypeAll) {
//        [bodyDic setObject:@[modelId] forKey:@"tagIdList"];
//    }

    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    if (modelId.length != 0 && modelId != nil && ![modelId isEqualToString:@"0"]) {
        [bodyDic setObject:@[modelId] forKey:@"tagIdList"];
    }
    
    VNetworkFramework *networkFramework ;
    if ([strSearchText isEqualToString:@"9810"]){
       networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getHomeListshare]];
    }else{
        [bodyDic setObject:@"0" forKey:@"endBlogId"];
        networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getBlogListByTypeURL]];
    }

    [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
//#warning ..................首页全部数据查询接口 缺少（integral）参数
            retInfo.bSuccess = YES;
            NSArray *aryBlogList = [responseObject objectForKey:@"content"];
            if (aryBlogList != nil)
            {
                retInfo.data  = [ServerProvider getBlogListByJSONArray:aryBlogList];
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

//查询我关注的人的分享列表
+ (void)getAttentionShareList:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getAttentionShareListURL]];
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
            NSArray *aryBlogList = [responseObject objectForKey:@"content"];
            if (aryBlogList != nil)
            {
                retInfo.data  = [ServerProvider getBlogListByJSONArray:aryBlogList];
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

//赞过的分享列表(所有、某个人)
+ (void)getPraiseShareBlog:(NSInteger)nPage create:(NSString *)createBy result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    if (createBy != nil && createBy.length > 0)
    {
        [bodyDic setObject:createBy forKey:@"userId"];
    }
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getPraiseShareBlogURL]];
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
            NSArray *aryBlogList = [responseObject objectForKey:@"content"];
            if (aryBlogList != nil)
            {
                retInfo.data  = [ServerProvider getBlogListByJSONArray:aryBlogList];
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

//获取置顶帖列表
+ (void)getTopShareList:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getTopShareListURL]];
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
            retInfo.data  = [ServerProvider getBlogListByJSONArray:responseObject];
        }
        resultBlock(retInfo);
    }];
}

//单个分享详情(分享、问答、投票)
+ (void)getShareDetailBlog:(NSString*)strBlogID type:(NSString *)strType result:(ResultBlock)resultBlock
{
    NSString *strURL;
    if ([strType isEqualToString:@"qa"])
    {
        //问答
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getQuestDetailURL],strBlogID];
    }
    else
    {
        
        //        NSString *strFontSize = isBigFont()?@"B":@"S";
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getShareDetailBlog],strBlogID];
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
            
            NSMutableArray *aryBlogList;
            if ([strType isEqualToString:@"qa"])
            {
                aryBlogList = [ServerProvider getQAListByJSONArray:@[responseObject]];
            }
            else
            {
                aryBlogList = [ServerProvider getBlogListByJSONArray:@[responseObject]];
            }
            
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

//赞分享
+ (void)praiseBlog:(NSString *)strTeamId type:(NSString *)strType result:(ResultBlock)resultBlock
{
    NSString *strURL;
    if([strType isEqualToString:@"activity"])
    {
        //活动
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getActivityPraiseActionURL],strTeamId];
    }
    else if ([strType isEqualToString:@"answer"])
    {
        //回答
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getAnswerPaiserURL],strTeamId];
    }
    else
    {
        //其他分享
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getSharePaiserBlog],strTeamId];
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
            
            id paiserID;
            if ([strType isEqualToString:@"answer"]) {
                paiserID = [responseObject objectForKey:@"mentionId"];
            } else {
                paiserID = [responseObject objectForKey:@"id"];
            }
            
            if (paiserID == [NSNull null]|| paiserID == nil)
            {
                paiserID = @"";
            }
            else
            {
                paiserID = [paiserID stringValue];
            }
            retInfo.data = paiserID;
        }
        resultBlock(retInfo);
    }];
}

//发分享
+ (void)publishShare:(PublishVo *)publishVo result:(ResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //处理线程同步
        dispatch_group_t group = dispatch_group_create();
        
        //发送JSON数据
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        retInfo.bSuccess = YES;
        
        //批量上传图片
        if(publishVo.imgList != nil && publishVo.imgList.count > 0)
        {
            dispatch_group_enter(group);
            VNetworkFramework *networkImage = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
            [networkImage uploadBatchFileToServer:publishVo.imgList result:^(NSArray *aryResult, NSError *error) {
                if (error)
                {
                    retInfo.bSuccess = NO;
                    retInfo.strErrorMsg = error.localizedDescription;
                }
                else
                {
                    //将富文本替换正文内容
                    if (aryResult.count == publishVo.aryAttriRange.count)
                    {
                        for (long i=publishVo.aryAttriRange.count-1; i>=0; i--)
                        {
                            //替换为富文本
                            UploadFileVo *uploadFileVo = aryResult[i];
                            NSRange range;
                            [[publishVo.aryAttriRange objectAtIndex:i] getValue:&range];
                            [publishVo.attriContent replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:[BusinessCommon getHtmlImgByImageURL:uploadFileVo]]];
                        }
                        publishVo.streamContent = [NSString stringWithFormat:@"%@ <br /> ",publishVo.attriContent.mutableString];
                    }
                    else
                    {
                        retInfo.bSuccess = NO;
                        retInfo.strErrorMsg = @"图片上传失败，请稍后再试";
                    }
                }
                dispatch_group_leave(group);
            }];
        }
        
        //上传视频
        if (publishVo.strVideoPath)
        {
            dispatch_group_enter(group);
            VNetworkFramework *networkVideo = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
            [networkVideo uploadBatchFileToServer:@[publishVo.strVideoPath] result:^(NSArray *aryResult, NSError *error) {
                if (error)
                {
                    retInfo.bSuccess = NO;
                    retInfo.strErrorMsg = error.localizedDescription;
                    resultBlock(retInfo);
                }
                else
                {
                    NSMutableArray *aryVideoList = [NSMutableArray array];
                    for (UploadFileVo *uploadFileVo in aryResult)
                    {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:uploadFileVo.strID forKey:@"id"];
                        [aryVideoList addObject:dic];
                    }
                    [bodyDic setObject:aryVideoList forKey:@"videoList"];
                }
                dispatch_group_leave(group);
            }];
        }
        
        //上传投票图片
        if (publishVo.voteVo != nil)
        {
            for (VoteOptionVo *voteOptionVo in publishVo.voteVo.aryVoteOption)
            {
                if (voteOptionVo.strImage)
                {
                    dispatch_group_enter(group);
                    VNetworkFramework *networkVoteImage = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
                    [networkVoteImage uploadBatchFileToServer:@[voteOptionVo.strImage] result:^(NSArray *aryResult, NSError *error) {
                        if (error)
                        {
                            retInfo.bSuccess = NO;
                            retInfo.strErrorMsg = error.localizedDescription;
                        }
                        else
                        {
                            UploadFileVo *uploadFileVo = aryResult[0];
                            voteOptionVo.strImage = uploadFileVo.strURL;
                        }
                        dispatch_group_leave(group);
                    }];
                }
            }
            
            //等待照片上传完成
            dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
            
            NSMutableDictionary *dicVote = [NSMutableDictionary dictionary];
            [dicVote setObject:[NSNumber numberWithInteger:publishVo.voteVo.nVoteType] forKey:@"voteType"];
            
            if(publishVo.voteVo.nVoteType == 1)
            {
                //多选，设置最少选项以及最多选项
                [dicVote setObject:[NSNumber numberWithInteger:publishVo.voteVo.nMinOption] forKey:@"minItem"];
                [dicVote setObject:[NSNumber numberWithInteger:publishVo.voteVo.nMaxOption] forKey:@"maxItem"];
            }
            
            NSMutableArray *aryVoteOption = [NSMutableArray array];
            for (int i=0; i<publishVo.voteVo.aryVoteOption.count; i++)
            {
                VoteOptionVo *voteOptionVo = [publishVo.voteVo.aryVoteOption objectAtIndex:i];
                NSDictionary *dicVoteOption = nil;
                if (voteOptionVo.strImage)
                {
                    //container vote image
                    dicVoteOption = @{@"content":voteOptionVo.strOptionName,@"imageUrl":voteOptionVo.strImage};
                }
                else
                {
                    dicVoteOption = @{@"content":voteOptionVo.strOptionName};
                }
                [aryVoteOption addObject:dicVoteOption];
            }
            [dicVote setObject:aryVoteOption forKey:@"voteOptionList"];
            
            //vote object
            [bodyDic setObject:dicVote forKey:@"vote"];
            
            [bodyDic setObject:@4 forKey:@"isSignup"];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (!retInfo.bSuccess)
            {
                resultBlock(retInfo);
                return;
            }
            
            [bodyDic setObject:publishVo.aryTag forKey:@"tagIdList"];
            
            if (publishVo.aryAT != nil && publishVo.aryAT.count > 0)
            {
                [bodyDic setObject:publishVo.aryAT forKey:@"atUserIdList"];
            }
            [bodyDic setObject:publishVo.aryTag forKey:@"tagIdList"];
            
            [bodyDic setObject:publishVo.streamTitle forKey:@"titleName"];
            //"\n"替换为"<div style=\"line-height: 0;\"></div>"放在服务器端完成
            [bodyDic setObject:publishVo.streamContent forKey:@"streamContent"];
            
            [bodyDic setObject:[NSString stringWithFormat:@"%d",publishVo.streamComefrom] forKey:@"streamComefrom"];
            FaceModel *model = [FaceModel sharedManager];
            if (model.ISnO) {
                [bodyDic setObject:@"0" forKey:@"isDraft"];

            }else{
                [bodyDic setObject:@"2" forKey:@"isDraft"];

            }
//            [bodyDic setObject:[NSString stringWithFormat:@"%d",publishVo.isDraft ] forKey:@"isDraft"];
            
            //分享超链接
            if(publishVo.strShareLink != nil && publishVo.strShareLink.length>0)
            {
                [bodyDic setObject:publishVo.strShareLink forKey:@"thirdLink"];
            }
            
            VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getPublishShare]];
            [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
                if (error)
                {
                    retInfo.bSuccess = NO;
                    retInfo.strErrorMsg = error.localizedDescription;
                }
                else
                {
                    //发分享获得积分
                    retInfo.bSuccess = YES;
                    NSNumber *numIntegral;
                    NSDictionary *dicJSON = responseObject;
                    id lastIntegral = [dicJSON objectForKey:@"integral"];
                    if (lastIntegral == [NSNull null] || lastIntegral == nil)
                    {
                        numIntegral = [NSNumber numberWithDouble:0.0f];
                    }
                    else
                    {
                        numIntegral = lastIntegral;
                    }
                    retInfo.data = numIntegral;
                }
                resultBlock(retInfo);
            }];
        });
    });
}

//删除分享(只能删除属于自己的分享)
+ (void)deleteShareArticle:(NSString *)strShareID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDeleteShareArticleURL],strShareID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//标签/////////////////////////////////////////////////////////
//查询表情列表(P:个人标签; O:公司标签，默认P)
+ (void)getTagVoListByType:(NSString*)strType result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getTagVoListByTypeURL],strType];
    
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
            
            NSMutableArray *aryTagList = [NSMutableArray array];
            NSArray *aryJSONTagList =[responseObject objectForKey:@"content"];
            if (aryJSONTagList != nil && (id) aryJSONTagList != [NSNull null])
            {
                for (NSDictionary *dicTagVo in aryJSONTagList)
                {
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
                    [aryTagList addObject:tagVo];
                }
            }
            retInfo.data = aryTagList;
        }
        resultBlock(retInfo);
    }];
}

//消息打标签(如果标签ID为1，则是给消息加星标)
+ (void)addTagToMessage:(NSString *)strMessageID andTagsID:(NSString*)strTagsID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@/%@",[ServerURL getAddTagToMessageURL],strMessageID,strTagsID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//消息移除标签(如果标签ID为1，则是给消息移除星标)
+ (void)removeTagFromMessage:(NSString *)strMessageID andTagsID:(NSString*)strTagsID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@/%@",[ServerURL getRemoveTagFromMessageURL],strMessageID,strTagsID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//相册相关////////////////////////////////////////////////////////////////////////
//创建相册
+ (void)createAlbumFolder:(NSString *)name andType:(int)nType andTeamID:(NSString *)teamID andRemark:(NSString *)remark result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:name forKey:@"folderName"];
    [bodyDic setObject:[NSString stringWithFormat:@"%i",nType] forKey:@"folderType"];
    //群组相册需填写teamId
    if (nType == 2)
    {
        [bodyDic setObject:teamID forKey:@"teamId"];
    }
    [bodyDic setObject:remark forKey:@"remark"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCreateAlbumFolderURL]];
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
        }
        resultBlock(retInfo);
    }];
}
//删除相册
+ (void)removeAlbumFolder:(NSString*)strFolderID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getRemoveAlbumFolderURL],strFolderID];
    
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
        }
        resultBlock(retInfo);
    }];
}
//我的相册
+ (void)getMyAlbumInfo:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getMyAlbumFolderInfoURL]];
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
            
            NSArray *array = [responseObject objectForKey:@"folders"];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in array)
            {
                AlbumInfoVO *albumInfo       = [[AlbumInfoVO alloc] init];
                albumInfo.albumFolderID      = [[dic objectForKey:@"id"]stringValue];
                albumInfo.albumFolderName    = [dic objectForKey:@"folderName"];
                albumInfo.nAlbumFolderType   = [[dic objectForKey:@"folderType"] intValue];
                albumInfo.albumFolderRemark  = [dic objectForKey:@"remark"];
                albumInfo.bIsDefault         = [[dic objectForKey:@"isDefault"] boolValue];
                albumInfo.albumFolderCreator = [dic objectForKey:@"createBy"];
                albumInfo.albumGroupID       = [dic objectForKey:@"teamId"];
                albumInfo.albumCreateDate    = [dic objectForKey:@"createDate"];
                albumInfo.albumImageList     = [dic objectForKey:@"imageList"];
                albumInfo.strAlbumImage      = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"imageFolderCover"]]];
                [dataArray addObject:albumInfo];
            }
            
            retInfo.data = dataArray;
        }
        resultBlock(retInfo);
    }];
}
//查寻某个人的相册
+ (void)getAlbumInfoByID:(NSString*)strUserID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getMyAlbumFolderInfoURL],strUserID];
    
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
            
            NSArray *array = [responseObject objectForKey:@"folders"];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in array)
            {
                AlbumInfoVO *albumInfo       = [[AlbumInfoVO alloc] init];
                albumInfo.albumFolderID      = [[dic objectForKey:@"id"]stringValue];
                albumInfo.albumFolderName    = [dic objectForKey:@"folderName"];
                albumInfo.nAlbumFolderType   = [[dic objectForKey:@"folderType"] intValue];
                albumInfo.albumFolderRemark  = [dic objectForKey:@"remark"];
                albumInfo.bIsDefault         = [[dic objectForKey:@"isDefault"] boolValue];
                albumInfo.albumFolderCreator = [dic objectForKey:@"createBy"];
                albumInfo.albumGroupID       = [dic objectForKey:@"teamId"];
                albumInfo.albumCreateDate    = [dic objectForKey:@"createDate"];
                albumInfo.albumImageList     = [dic objectForKey:@"imageList"];
                albumInfo.strAlbumImage      = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"imageFolderCover"]]];
                [dataArray addObject:albumInfo];
            }
            
            retInfo.data = dataArray;
        }
        resultBlock(retInfo);
    }];
}
//系统的相册
+ (void)getPublicAlbumInfo:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@"1" forKey:@"folderType"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getPublicAlbumFolderInfoURL]];
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
            
            NSArray *array = [responseObject objectForKey:@"folders"];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in array)
            {
                AlbumInfoVO *albumInfo       = [[AlbumInfoVO alloc] init];
                albumInfo.albumFolderID      = [[dic objectForKey:@"id"]stringValue];
                albumInfo.albumFolderName    = [dic objectForKey:@"folderName"];
                albumInfo.nAlbumFolderType   = [[dic objectForKey:@"folderType"] intValue];
                albumInfo.albumFolderRemark  = [dic objectForKey:@"remark"];
                albumInfo.bIsDefault         = [[dic objectForKey:@"isDefault"] boolValue];
                albumInfo.albumFolderCreator = [dic objectForKey:@"createBy"];
                albumInfo.albumGroupID       = [dic objectForKey:@"teamId"];
                albumInfo.albumCreateDate    = [dic objectForKey:@"createDate"];
                albumInfo.albumImageList     = [dic objectForKey:@"imageList"];
                albumInfo.strAlbumImage      = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"imageFolderCover"]]];
                [dataArray addObject:albumInfo];
            }
            
            retInfo.data = dataArray;
        }
        resultBlock(retInfo);
    }];
}
//获取单个相册图片
+ (void)getImageFolderFromID:(NSString*)strFolderID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getImageFolderFromIDURL],strFolderID];
    
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
            
            AlbumImageVO *albumImageVO   = [[AlbumImageVO alloc] init];
            NSDictionary *folderInfoDic  = [responseObject objectForKey:@"imageFolder"];
            //folder info
            AlbumInfoVO *albumInfo       = [[AlbumInfoVO alloc] init];
            albumInfo.albumFolderID      = [[folderInfoDic objectForKey:@"id"]stringValue];
            albumInfo.albumFolderName    = [folderInfoDic objectForKey:@"folderName"];
            albumInfo.nAlbumFolderType   = [[folderInfoDic objectForKey:@"folderType"] intValue];
            albumInfo.albumFolderRemark  = [folderInfoDic objectForKey:@"remark"];
            albumInfo.bIsDefault         = [[folderInfoDic objectForKey:@"isDefault"] boolValue];
            albumInfo.albumFolderCreator = [folderInfoDic objectForKey:@"createBy"];
            albumInfo.albumGroupID       = [folderInfoDic objectForKey:@"teamId"];
            albumInfo.albumCreateDate    = [folderInfoDic objectForKey:@"createDate"];
            albumImageVO.albumInfo = albumInfo;
            
            //folder image list
            NSArray *array = [folderInfoDic objectForKey:@"imageList"];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in array)
            {
                AlbumImageInfoVO *albumImgInfo       = [[AlbumImageInfoVO alloc] init];
                albumImgInfo.imageID        = [[dic objectForKey:@"id"]stringValue];
                albumImgInfo.imageName      = [dic objectForKey:@"name"];
                albumImgInfo.imageType      = [dic objectForKey:@"type"];
                id commentCount = [dic objectForKey:@"commentCount"];
                if (commentCount == nil || commentCount == [NSNull null])
                {
                    albumImgInfo.nImgCommentCnt = 0;
                }
                else
                {
                    albumImgInfo.nImgCommentCnt = [commentCount intValue];
                }
                
                id praiseCount = [dic objectForKey:@"praiseCount"];
                if (praiseCount == nil || praiseCount == [NSNull null])
                {
                    albumImgInfo.nImgPraiseCnt = 0;
                }
                else
                {
                    albumImgInfo.nImgPraiseCnt = [praiseCount intValue];
                }
                albumImgInfo.imageCreator   = [dic objectForKey:@"createId"];
                albumImgInfo.imageCreateDate= [dic objectForKey:@"createDate"];
                albumImgInfo.imageMinUrl    = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"minUri"]]];
                albumImgInfo.imageMidUrl    = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"midUri"]]];
                albumImgInfo.imageMaxUrl    = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"maxUri"]]];
                albumImgInfo.imageRemark    = [dic objectForKey:@"remark"];
                [dataArray addObject:albumImgInfo];
            }
            albumImageVO.imageList = dataArray;
            
            albumImageVO.userID = [responseObject objectForKey:@"userId"];
            
            retInfo.data = albumImageVO;
        }
        resultBlock(retInfo);
    }];
}
//给相册批量添加图片
+ (void)addImagesIntoFolder:(NSMutableArray *)aryImagePath forFolder:(NSString*)strFolderID result:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
    [networkFrameworkFile uploadBatchFileToServer:aryImagePath result:^(NSArray *aryResult, NSError *error) {
        if (error)
        {
            ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
            resultBlock(retInfo);
        }
        else
        {
            NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
            [bodyDic setObject:strFolderID forKey:@"folderId"];
            NSMutableString *strIDs = [NSMutableString string];
            int nFlag = 0;
            for (UploadFileVo *uploadFileVo in aryResult)
            {
                if (nFlag == 0)
                {
                    //first
                    [strIDs appendFormat:@"%@",uploadFileVo.strID];
                    nFlag ++;
                }
                else
                {
                    [strIDs appendFormat:@",%@",uploadFileVo.strID];
                }
            }
            [bodyDic setObject:strIDs forKey:@"imageIds"];
            
            VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getAddImagesIntoFolderURL]];
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
                }
                resultBlock(retInfo);
            }];
        }
    }];
}

///////////////////////////////////////////////////////////////////////////
//问题(最新和我的)
+ (void)getQuestList:(NSString*)strBlogID createBy:(NSString*)strUserID content:(NSString*)strContent result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    if (strBlogID != nil || strBlogID.length>0)
    {
        [bodyDic setObject:strBlogID forKey:@"id"];
    }
    if (strContent != nil || strContent.length>0)
    {
        [bodyDic setObject:strContent forKey:@"questionContent"];
    }
    if (strUserID != nil || strUserID.length>0)
    {
        [bodyDic setObject:strUserID forKey:@"createBy"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getQuestListURL]];
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
            
            BlogVo *blogVo = nil;
            NSMutableArray *shareBlogArray =  [responseObject objectForKey:@"content"];
            NSMutableArray *aryBlogList = [NSMutableArray array];
            if ([shareBlogArray isKindOfClass:[NSMutableArray class]] && shareBlogArray.count > 0)
            {
                for (NSDictionary *dic in shareBlogArray)
                {
                    blogVo = [[BlogVo alloc]init];
                    id blogID = [dic objectForKey:@"id"];
                    if (blogID == [NSNull null]|| blogID == nil)
                    {
                        blogVo.streamId = @"";
                    }
                    else
                    {
                        blogVo.streamId = [blogID stringValue];
                    }
                    blogVo.strTitle = [Common checkStrValue:[dic objectForKey:@"titleName"]];
                    blogVo.strContent = [Common checkStrValue:[dic objectForKey:@"questionContent"]];
                    blogVo.strText = [Common checkStrValue:[dic objectForKey:@"questionText"]];
                    id Comefrom = [dic objectForKey:@"questionComefrom"];
                    if (Comefrom == [NSNull null]|| Comefrom == nil)
                    {
                        blogVo.nComefrom = 0;
                    }
                    else
                    {
                        blogVo.nComefrom = [Comefrom intValue];
                    }
                    id orgId = [dic objectForKey:@"orgId"];
                    if (orgId == [NSNull null]|| orgId == nil)
                    {
                        blogVo.orgId = @"";
                    }
                    else
                    {
                        blogVo.orgId = [orgId stringValue];
                    }
                    id isSolution = [dic objectForKey:@"isSolution"];
                    if (isSolution == [NSNull null]|| isSolution == nil)
                    {
                        blogVo.isSolution = 0;
                    }
                    else
                    {
                        blogVo.isSolution = [isSolution intValue];
                    }
                    blogVo.vestImg = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"userImgUrl"]]];
                    blogVo.strCreateDate = [Common checkStrValue:[dic objectForKey:@"createDate"]];
                    blogVo.strUpdateDate = [Common checkStrValue:[dic objectForKey:@"updateDate"]];
                    id strCreateBy = [dic objectForKey:@"createBy"];
                    if (strCreateBy == [NSNull null]|| strCreateBy == nil)
                    {
                        blogVo.strCreateBy = @"";
                    }
                    else
                    {
                        blogVo.strCreateBy = [strCreateBy stringValue];
                    }
                    
                    //勋章
                    id badge = [dic objectForKey:@"userBadge"];
                    if (badge == [NSNull null]|| badge == nil)
                    {
                        blogVo.nBadge = 0;
                    }
                    else
                    {
                        blogVo.nBadge = [badge integerValue];
                    }
                    //积分
                    id integral = [dic objectForKey:@"userIntegral"];
                    if (integral == [NSNull null]|| integral == nil)
                    {
                        blogVo.fIntegral = 0;
                    }
                    else
                    {
                        blogVo.fIntegral = [integral doubleValue];
                    }
                    
                    id strUpdateBy = [dic objectForKey:@"updateBy"];
                    if (strUpdateBy == [NSNull null]|| strUpdateBy == nil)
                    {
                        blogVo.strUpdateBy = @"";
                    }
                    else
                    {
                        blogVo.strUpdateBy = [strUpdateBy stringValue];
                    }
                    blogVo.strCreateByName = [Common checkStrValue:[dic objectForKey:@"userNickname"]];//createName
                    blogVo.strUpdateByName = [Common checkStrValue:[dic objectForKey:@"updateName"]];
                    id praiseCount = [dic objectForKey:@"praiseCount"];
                    if (praiseCount == [NSNull null]|| praiseCount == nil)
                    {
                        blogVo.nPraiseCount = 0;
                    }
                    else
                    {
                        blogVo.nPraiseCount = [praiseCount intValue];
                    }
                    id nCommentCount = [dic objectForKey:@"answerCount"];
                    if (nCommentCount == [NSNull null]|| nCommentCount == nil)
                    {
                        blogVo.nCommentCount = 0;
                    }
                    else
                    {
                        blogVo.nCommentCount = [nCommentCount intValue];
                    }
                    
                    blogVo.strStartTime = [Common checkStrValue:[dic objectForKey:@"startDate"]];
                    blogVo.strEndTime = [Common checkStrValue:[dic objectForKey:@"endDate"]];
                    id delFlag = [dic objectForKey:@"delFlag"];
                    if (delFlag == [NSNull null]|| delFlag == nil)
                    {
                        blogVo.nDelFlag = 0;
                    }
                    else
                    {
                        blogVo.nDelFlag = [delFlag intValue];
                    }
                    id isDraft = [dic objectForKey:@"isDraft"];
                    if (isDraft == [NSNull null]|| isDraft == nil)
                    {
                        blogVo.isDraft = 0;
                    }
                    else
                    {
                        blogVo.isDraft = [isDraft intValue];
                    }
                    [aryBlogList addObject:blogVo];
                }
            }
            retInfo.data = aryBlogList;
        }
        resultBlock(retInfo);
    }];
}

//问题的回答列表
+ (void)getAnswerList:(NSString*)strQuestionID nPage:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strQuestionID forKey:@"questionId"];
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getAnswerListURL]];
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
            
            NSArray *aryAnswerJSON = [responseObject objectForKey:@"content"];
            if (aryAnswerJSON != nil)
            {
                retInfo.data  = [ServerProvider getAnswerListByJSONArray:aryAnswerJSON];
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

//删除答案
+ (void)deleteAnswer:(NSString *)strSourceID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getAnswerDeleteURL],strSourceID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//删除问题
+ (void)deleteQusetion:(NSString *)strSourceID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getQuestDeleteURL],strSourceID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//赞问答
+ (void)paiserAnswer:(NSString *)strTeamId result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getAnswerPaiserURL],strTeamId];
    
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
            
            //change by fjz
            id paiserID = [responseObject objectForKey:@"mentionId"];
            if (paiserID == [NSNull null]|| paiserID == nil)
            {
                paiserID = nil;
            }
            else
            {
                paiserID = [paiserID stringValue];
            }
            retInfo.data = paiserID;
        }
        resultBlock(retInfo);
    }];
}

//邀请回答
+ (void)askUser:(NSString *)strTeamId andUser:(NSMutableArray *)userArr result:(ResultBlock)resultBlock
{
    NSMutableDictionary *BodyDic = [[NSMutableDictionary alloc]init];
    [BodyDic setObject:strTeamId forKey:@"id"];
    if (userArr.count == 0)
    {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        retInfo.bSuccess = NO;
        retInfo.strErrorMsg = @"请选择邀请的人";
        resultBlock(retInfo);
        return;
    }
    else
    {
        NSMutableString *str = [[NSMutableString alloc] init];
        for (int i=0; i<userArr.count; i++)
        {
            UserVo *userVo = [userArr objectAtIndex:i];
            [str appendString:userVo.strUserID];
            if (i != userArr.count - 1)
            {
                [str appendString:@","];
            }
        }
        [BodyDic setObject:str forKey:@"askUsers"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getAskUserURL]];
    [networkFramework startRequestToServer:@"POST" parameter:BodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            id paiserID = [responseObject objectForKey:@"id"];
            if (paiserID == [NSNull null]|| paiserID == nil)
            {
                paiserID = @"";
            }
            else
            {
                paiserID = [paiserID stringValue];
            }
            retInfo.data = paiserID;
        }
        resultBlock(retInfo);
    }];
}

//添加答案
+ (void)addAnswer:(PublishVo*)publishVo result:(ResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //处理线程同步
        dispatch_group_t group = dispatch_group_create();
        
        //发送JSON数据
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        retInfo.bSuccess = YES;
        
        //批量上传图片
        if(publishVo.imgList != nil && publishVo.imgList.count > 0)
        {
            dispatch_group_enter(group);
            VNetworkFramework *networkImage = [[VNetworkFramework alloc]initWithURLString:[ServerURL getFormUploadFileURL]];
            [networkImage uploadBatchFileToServer:publishVo.imgList result:^(NSArray *aryResult, NSError *error) {
                if (error)
                {
                    retInfo.bSuccess = NO;
                    retInfo.strErrorMsg = error.localizedDescription;
                }
                else
                {
                    //将富文本替换正文内容
                    if (aryResult.count == publishVo.aryAttriRange.count)
                    {
                        for (long i=publishVo.aryAttriRange.count-1; i>=0; i--)
                        {
                            //替换为富文本
                            UploadFileVo *uploadFileVo = aryResult[i];
                            NSRange range;
                            [[publishVo.aryAttriRange objectAtIndex:i] getValue:&range];
                            [publishVo.attriContent replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:[BusinessCommon getHtmlImgByImageURL:uploadFileVo]]];
                        }
                        publishVo.streamContent = [NSString stringWithFormat:@"%@ <br /> ",publishVo.attriContent.mutableString];
                    }
                    else
                    {
                        retInfo.bSuccess = NO;
                        retInfo.strErrorMsg = @"图片上传失败，请稍后再试";
                    }
                }
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (!retInfo.bSuccess)
            {
                resultBlock(retInfo);
                return;
            }
            
            [bodyDic setObject:publishVo.strRefID forKey:@"questionId"];
            [bodyDic setObject:publishVo.streamContent forKey:@"answerHtml"];
            
            VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCreateAnswerURL]];
            [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
                if (error)
                {
                    retInfo.bSuccess = NO;
                    retInfo.strErrorMsg = error.localizedDescription;
                }
                else
                {
                    retInfo.bSuccess = YES;
                    NSArray *aryAnswer;
                    if (responseObject[@"answer"]){
                         aryAnswer = [ServerProvider getAnswerListByJSONArray:@[responseObject[@"answer"]]];
                    }
                    if (aryAnswer.count>0)
                    {
                        retInfo.data = aryAnswer[0];
                    }
                }
                resultBlock(retInfo);
            }];
        });
    });
}

//添加问题
+ (void)addQuest:(PublishVo *)publishVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:publishVo.streamTitle forKey:@"titleName"];
    [bodyDic setObject:publishVo.streamContent forKey:@"questionContent"];
    [bodyDic setObject:[NSString stringWithFormat:@"%d",publishVo.streamComefrom] forKey:@"questionComefrom"];
    [bodyDic setObject:[NSString stringWithFormat:@"%d",publishVo.isDraft ] forKey:@"isDraft"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCreateQuestURL]];
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
        }
        resultBlock(retInfo);
    }];
}

//获取赞列表(strType => "blog"：分享；"vote": 投票；"qa":问答；"answer":回答；)
+ (void)getPraiseList:(NSString*)strRefID type:(NSString *)strType page:(NSInteger)nPage result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strRefID forKey:@"id"];
    
    NSString *strURL;
    if ([strType isEqualToString:@"answer"])
    {
        strURL = [ServerURL getAnswerPraiseListURL];
    }
    else if ([strType isEqualToString:@"activity"])
    {
        strURL = [ServerURL getActivityPraiseListURL];
    }
    else
    {
        strURL = [ServerURL getSharePraiseListURL];
    }
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
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
            
            NSArray *aryPraiseJSON = [responseObject objectForKey:@"content"];
            if (aryPraiseJSON != nil)
            {
                retInfo.data  = [ServerProvider getPraiseListByJSONArray:aryPraiseJSON];
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

//收藏/////////////////////////////////////////////////////////////////
//增加收藏
+ (void)addCollection:(NSString *)strResourceID andType:(NSString*)strBlogType result:(ResultBlock)resultBlock
{
    NSString *strType;
    if ([strBlogType isEqualToString:@"qa"])
    {
        strType = @"2";
    }
    else
    {
        strType = @"1";
    }
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:strResourceID forKey:@"refId"];
    [dicBody setObject:strType forKey:@"refType"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getAddCollectionURL]];
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

//取消收藏
+ (void)cancelCollection:(NSString *)strResourceID andType:(NSString*)strBlogType result:(ResultBlock)resultBlock
{
    NSString *strType;
    if ([strBlogType isEqualToString:@"qa"])
    {
        strType = @"2";
    }
    else
    {
        strType = @"1";
    }
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@/%@",[ServerURL getCancelCollectionURL],strType,strResourceID];
    
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
        }
        resultBlock(retInfo);
    }];
}

//收藏的分享列表
+ (void)getCollectionBlog:(NSInteger)nPageNum create:(NSString *)strCreateBy result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nPageNum] forKey:@"pageNumber"];
    [dicPageInfo setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    [bodyDic setObject:strCreateBy forKey:@"userId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCollectionBlogURL]];
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
            NSArray *aryBlogList = [responseObject objectForKey:@"content"];
            if (aryBlogList != nil)
            {
                retInfo.data  = [ServerProvider getBlogListByJSONArray:aryBlogList];
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

//收藏的问题列表
+ (void)getCollectionQuestion:(NSInteger)nPageNum result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSNumber numberWithInteger:nPageNum] forKey:@"pageNumber"];
    [dicPageInfo setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCollectionQuestionURL]];
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
            
            BlogVo *blogVo = nil;
            NSMutableArray *shareBlogArray =  [responseObject objectForKey:@"content"];
            NSMutableArray *aryBlogList = [NSMutableArray array];
            if ([shareBlogArray isKindOfClass:[NSMutableArray class]] && shareBlogArray.count > 0)
            {
                for (NSDictionary *dic in shareBlogArray)
                {
                    blogVo = [[BlogVo alloc]init];
                    id blogID = [dic objectForKey:@"id"];
                    if (blogID == [NSNull null]|| blogID == nil)
                    {
                        blogVo.streamId = @"";
                    }
                    else
                    {
                        blogVo.streamId = [blogID stringValue];
                    }
                    blogVo.strTitle = [Common checkStrValue:[dic objectForKey:@"titleName"]];
                    blogVo.strContent = [Common checkStrValue:[dic objectForKey:@"questionContent"]];
                    blogVo.strText = [Common checkStrValue:[dic objectForKey:@"questionText"]];
                    id Comefrom = [dic objectForKey:@"questionComefrom"];
                    if (Comefrom == [NSNull null]|| Comefrom == nil)
                    {
                        blogVo.nComefrom = 0;
                    }
                    else
                    {
                        blogVo.nComefrom = [Comefrom intValue];
                    }
                    id orgId = [dic objectForKey:@"orgId"];
                    if (orgId == [NSNull null]|| orgId == nil)
                    {
                        blogVo.orgId = @"";
                    }
                    else
                    {
                        blogVo.orgId = [orgId stringValue];
                    }
                    id isSolution = [dic objectForKey:@"isSolution"];
                    if (isSolution == [NSNull null]|| isSolution == nil)
                    {
                        blogVo.isSolution = 0;
                    }
                    else
                    {
                        blogVo.isSolution = [isSolution intValue];
                    }
                    blogVo.vestImg = [ServerURL getWholeURL:[Common checkStrValue:[dic objectForKey:@"userImgUrl"]]];
                    blogVo.strCreateDate = [Common checkStrValue:[dic objectForKey:@"createDate"]];
                    blogVo.strUpdateDate = [Common checkStrValue:[dic objectForKey:@"updateDate"]];
                    id strCreateBy = [dic objectForKey:@"createBy"];
                    if (strCreateBy == [NSNull null]|| strCreateBy == nil)
                    {
                        blogVo.strCreateBy = @"";
                    }
                    else
                    {
                        blogVo.strCreateBy = [strCreateBy stringValue];
                    }
                    id strUpdateBy = [dic objectForKey:@"updateBy"];
                    if (strUpdateBy == [NSNull null]|| strUpdateBy == nil)
                    {
                        blogVo.strUpdateBy = @"";
                    }
                    else
                    {
                        blogVo.strUpdateBy = [strUpdateBy stringValue];
                    }
                    blogVo.strCreateByName = [Common checkStrValue:[dic objectForKey:@"userNickname"]];//createName
                    blogVo.strUpdateByName = [Common checkStrValue:[dic objectForKey:@"updateName"]];
                    id praiseCount = [dic objectForKey:@"praiseCount"];
                    if (praiseCount == [NSNull null]|| praiseCount == nil)
                    {
                        blogVo.nPraiseCount = 0;
                    }
                    else
                    {
                        blogVo.nPraiseCount = [praiseCount intValue];
                    }
                    id nCommentCount = [dic objectForKey:@"answerCount"];
                    if (nCommentCount == [NSNull null]|| nCommentCount == nil)
                    {
                        blogVo.nCommentCount = 0;
                    }
                    else
                    {
                        blogVo.nCommentCount = [nCommentCount intValue];
                    }
                    
                    blogVo.strStartTime = [Common checkStrValue:[dic objectForKey:@"startDate"]];
                    blogVo.strEndTime = [Common checkStrValue:[dic objectForKey:@"endDate"]];
                    id delFlag = [dic objectForKey:@"delFlag"];
                    if (delFlag == [NSNull null]|| delFlag == nil)
                    {
                        blogVo.nDelFlag = 0;
                    }
                    else
                    {
                        blogVo.nDelFlag = [delFlag intValue];
                    }
                    id isDraft = [dic objectForKey:@"isDraft"];
                    if (isDraft == [NSNull null]|| isDraft == nil)
                    {
                        blogVo.isDraft = 0;
                    }
                    else
                    {
                        blogVo.isDraft = [isDraft intValue];
                    }
                    [aryBlogList addObject:blogVo];
                }
            }
            retInfo.data = aryBlogList;
        }
        resultBlock(retInfo);
    }];
}

//会议签到/////////////////////////////////////////////////////////////////
+ (void)signInConferenceWithQRCode:(NSString *)strURLSuffix result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@", [ServerURL getServerURL], strURLSuffix];
    
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
        }
        resultBlock(retInfo);
    }];
}

//测试饮料机
+ (void)testQRCode:(NSString *)strURLSuffix result:(ResultBlock)resultBlock
{
    NSString *strURL = strURLSuffix;
    
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
            
            NSDictionary *dicTip = responseObject;
            retInfo.data = dicTip[@"orderNo"];
        }
        resultBlock(retInfo);
    }];
}

//抽奖/////////////////////////////////////////////////////////////////
+ (void)drawLotteryAction:(NSString*)strLotteryID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getDrawLotteryActionURL],strLotteryID];
    
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
            
            LotteryOptionVo *lotteryOptionVo = [[LotteryOptionVo alloc]init];
            
            NSDictionary *responseDic = responseObject;
            id lotteryID = [responseDic objectForKey:@"id"];
            if (lotteryID == nil || lotteryID == [NSNull null])
            {
                lotteryOptionVo.strLotteryOptionID = @"";
            }
            else
            {
                lotteryOptionVo.strLotteryOptionID = [lotteryID stringValue];
            }
            
            lotteryOptionVo.strLotteryName = [responseDic objectForKey:@"content"];
            
            id numberPeople = [responseDic objectForKey:@"numberPeople"];
            if (numberPeople == nil || numberPeople == [NSNull null])
            {
                lotteryOptionVo.nLotteryNum = 0;
            }
            else
            {
                lotteryOptionVo.nLotteryNum = [numberPeople integerValue];
            }
            
            id surplus = [responseDic objectForKey:@"surplus"];
            if (surplus == nil || surplus == [NSNull null])
            {
                lotteryOptionVo.nLotteryLeftNum = 0;
            }
            else
            {
                lotteryOptionVo.nLotteryLeftNum = [surplus integerValue];
            }
            
            lotteryOptionVo.strLotteryImgUrl = [Common checkStrValue:[responseDic objectForKey:@"downloadImageUri"]];
            if (lotteryOptionVo.strLotteryImgUrl.length > 0)
            {
                lotteryOptionVo.strLotteryImgUrl = [ServerURL getWholeURL:lotteryOptionVo.strLotteryImgUrl];
            }
            
            lotteryOptionVo.strWinLotteryName = [Common checkStrValue:[responseDic objectForKey:@"userNames"]];
            
            retInfo.data = lotteryOptionVo;
        }
        resultBlock(retInfo);
    }];
}

//会议报名
+ (void)signupMeeting:(UserVo*)userVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:userVo.strMeetingID forKey:@"meetingId"];
    [dicBody setObject:userVo.strUserName forKey:@"memberName"];
    [dicBody setObject:[NSNumber numberWithInteger:userVo.gender] forKey:@"gender"];
    [dicBody setObject:userVo.strPhoneNumber forKey:@"phoneNumber"];
    [dicBody setObject:userVo.strEmail forKey:@"email"];
    [dicBody setObject:userVo.strDepartmentId forKey:@"departmentId"];
    
    //自定义字段（都是非必填的）
    if (userVo.aryCustomField != nil && userVo.aryCustomField.count>0)
    {
        NSMutableArray *aryField = [NSMutableArray array];
        for (int i=0; i<userVo.aryCustomField.count; i++)
        {
            FieldVo *fieldVo = userVo.aryCustomField[i];
            NSDictionary *dicField= @{@"id":fieldVo.strID,@"diyValue":fieldVo.strValue};
            [aryField addObject:dicField];
        }
        [dicBody setObject:aryField forKey:@"fieldList"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSignupMeetingURL]];
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

/////////////////////////////////////////////////////////////////////////////////
//获取信息分享快照(分享、消息、问答)
+ (void)getShareInformation:(NSString*)strResID andResType:(ShareResType)resType andAnswerID:(NSString*)strAnswerID result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strResID forKey:@"targetId"];
    
    NSString *strResType = nil;
    if (resType == ShareResMsgType)
    {
        strResType = @"S";
    }
    else if (resType == ShareResAnswerType)
    {
        strResType = @"Q";
        if (strAnswerID.length > 0)
        {
            [bodyDic setObject:strAnswerID forKey:@"answerId"];
        }
    }
    else if (resType == ShareResActivityType)
    {
        strResType = @"A";
    }
    else
    {
        strResType = @"B";
    }
    [bodyDic setObject:strResType forKey:@"targetType"];
    
    if (resType == ShareResQAType)
    {
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getShareInfoURL]];
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
            
            ShareInfoVo *shareInfoVo = [[ShareInfoVo alloc]init];
            shareInfoVo.strResID = strResID;//资源ID
            
            NSString *strLink = [Common checkStrValue:[responseObject objectForKey:@"link"]];
            NSRange range = [strLink rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
            if (range.length==0)
            {
                //需要追加前缀
                shareInfoVo.strLinkURL = [ServerURL getWholeURL:strLink];
            }
            else
            {
                shareInfoVo.strLinkURL = strLink;
            }
            
            shareInfoVo.strImageURL = [Common checkStrValue:[responseObject objectForKey:@"picture"]];
            shareInfoVo.strTitle = [Common checkStrValue:[responseObject objectForKey:@"title"]];
            shareInfoVo.strContent = [Common checkStrValue:[responseObject objectForKey:@"snapDes"]];
            
            retInfo.data = shareInfoVo;
        }
        resultBlock(retInfo);
    }];
}

//问卷调查///////////////////////////////////////////////////////////////////////////////
//1.问卷基本说明查看
+(void)getQuestionSurvey:(NSString*)strSurveyID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getQuestionSurveyURL],strSurveyID];
    
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
            
            QuestionSurveyVo *questionSurveyVo = [[QuestionSurveyVo alloc]init];
            
            NSDictionary *dicSurvey = responseObject;
            id surveyId = [dicSurvey objectForKey:@"id"];
            if (surveyId == [NSNull null]|| surveyId == nil)
            {
                questionSurveyVo.strID = @"";
            }
            else
            {
                questionSurveyVo.strID = [surveyId stringValue];
            }
            
            questionSurveyVo.strName = [Common checkStrValue:[dicSurvey objectForKey:@"tableName"]];
            questionSurveyVo.strDesc = [Common checkStrValue:[dicSurvey objectForKey:@"tableDesc"]];
            
            id optionLimit = [dicSurvey objectForKey:@"optionLimit"];
            if (optionLimit == [NSNull null]|| optionLimit == nil)
            {
                questionSurveyVo.nSelectLimited = 3;
            }
            else
            {
                questionSurveyVo.nSelectLimited = [optionLimit integerValue];
            }
            
            questionSurveyVo.strState = [Common checkStrValue:[dicSurvey objectForKey:@"tableType"]];
            
            retInfo.data = questionSurveyVo;
        }
        resultBlock(retInfo);
    }];
}

//2.问卷所有题目列表
+(void)getQuestionList:(NSString*)strSurveyID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getQuestionListURL],strSurveyID];
    
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
            
            NSMutableArray *aryQuestionList = [NSMutableArray array];
            NSArray *aryJSONQuestion = responseObject;
            for (NSDictionary *dicQuestion in aryJSONQuestion)
            {
                QuestionVo *questionVo = [[QuestionVo alloc]init];
                
                id questionId = [dicQuestion objectForKey:@"id"];
                if (questionId == [NSNull null]|| questionId == nil)
                {
                    questionVo.strID = @"";
                }
                else
                {
                    questionVo.strID = [questionId stringValue];
                }
                
                questionVo.strName = [Common checkStrValue:[dicQuestion objectForKey:@"name"]];
                questionVo.strDesc = [Common checkStrValue:[dicQuestion objectForKey:@"fieldDesc"]];
                
                id multiple = [dicQuestion objectForKey:@"multiple"];
                if (multiple == [NSNull null]|| multiple == nil)
                {
                    questionVo.nMultiple = 0;
                }
                else
                {
                    questionVo.nMultiple = [multiple integerValue];
                }
                
                id association = [dicQuestion objectForKey:@"association"];
                if (association == [NSNull null]|| association == nil)
                {
                    questionVo.nAssociation = 0;
                }
                else
                {
                    questionVo.nAssociation = [association integerValue];
                }
                
                //选项列表
                questionVo.aryOption = [NSMutableArray array];
                NSArray *aryJSONOption = [dicQuestion objectForKey:@"optionList"];
                for (NSDictionary *dicOption in aryJSONOption)
                {
                    QOptionVo *qOptionVo = [[QOptionVo alloc]init];
                    id optionId = [dicOption objectForKey:@"key"];
                    if (optionId == [NSNull null]|| optionId == nil)
                    {
                        qOptionVo.strID = @"";
                    }
                    else
                    {
                        qOptionVo.strID = [optionId stringValue];
                    }
                    
                    qOptionVo.strName = [Common checkStrValue:[dicOption objectForKey:@"value"]];
                    qOptionVo.bChecked = NO;//默认没有选择该项
                    
                    [questionVo.aryOption addObject:qOptionVo];
                }
                
                [aryQuestionList addObject:questionVo];
            }
            retInfo.data = aryQuestionList;
        }
        resultBlock(retInfo);
    }];
}

//3.问卷整体提交
+(void)commitSurvey:(NSString*)strSurveyID andAnswer:(NSMutableArray*)aryQuestion result:(ResultBlock)resultBlock
{
    NSMutableArray *aryBody = [[NSMutableArray alloc] init];
    for (QuestionVo *questionVo in aryQuestion)
    {
        NSMutableDictionary *dicQuestion = [[NSMutableDictionary alloc] init];
        //question id
        [dicQuestion setObject:questionVo.strID forKey:@"id"];
        
        //question answer option list
        NSMutableArray *aryOption = [[NSMutableArray alloc] init];
        for (QOptionVo *qOptionVo in questionVo.aryOption)
        {
            if (qOptionVo.bChecked)
            {
                NSMutableDictionary *dicOption = [[NSMutableDictionary alloc] init];
                [dicOption setObject:qOptionVo.strID forKey:@"key"];
                [dicOption setObject:qOptionVo.strName forKey:@"value"];
                [aryOption addObject:dicOption];
            }
        }
        [dicQuestion setObject:aryOption forKey:@"optionList"];
        
        [aryBody addObject:dicQuestion];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[NSString stringWithFormat:@"%@/%@",[ServerURL getCommitSurveyURL],strSurveyID]];
    [networkFramework startRequestToServer:@"POST" parameter:aryBody result:^(id responseObject, NSError *error) {
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

//合理化建议表单/////////////////////////////////////////////////////////////////////////////
//1.提交建议
+ (void)commitSuggestion:(SuggestionVo*)suggestionVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    [dicBody setObject:suggestionVo.strName forKey:@"applyMan"];
    [dicBody setObject:suggestionVo.strSuggestionName forKey:@"applySuggestSubject"];
    [dicBody setObject:suggestionVo.strTypeKey forKey:@"applySuggestItem"];
    [dicBody setObject:suggestionVo.strProblemDes forKey:@"applyProblem"];
    [dicBody setObject:suggestionVo.strImproveDes forKey:@"applyImprove"];
    [dicBody setObject:suggestionVo.strDepartmentID forKey:@"departmentId"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCommitSuggestionURL]];
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
            
            suggestionVo.strID = [responseObject objectForKey:@"id"];
            retInfo.data = suggestionVo;
        }
        resultBlock(retInfo);
    }];
}

//2.建议列表+搜索功能
+ (void)getSuggestionList:(NSString*)strSearchText deparment:(NSString*)strDeparmentID
                   status:(NSString*)strStatus relate:(NSString*)strRelate page:(NSInteger)nPage
                 pageSize:(NSInteger)nSize result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPage setObject:[NSNumber numberWithInteger:nSize] forKey:@"pageSize"];
    [dicBody setObject:dicPage forKey:@"pageInfo"];
    
    //分公司查找
    if(![strDeparmentID isEqualToString:@"0"])
    {
        [dicBody setObject:strDeparmentID forKey:@"departmentId"];
    }
    
    //状态查找
    if(![strStatus isEqualToString:@"0"])
    {
        [dicBody setObject:strStatus forKey:@"status"];
    }
    
    //相关筛选（已提交、已办、待办）
    if(![strRelate isEqualToString:@"0"])
    {
        if([strRelate isEqualToString:@"C"])
        {
            //已提交
            [dicBody setObject:[Common getCurrentUserVo].strUserID forKey:@"createBy"];
        }
        else
        {
            [dicBody setObject:strRelate forKey:@"mySuggestion"];
        }
    }
    
    //搜索内容
    if(strSearchText != nil && strSearchText.length>0)
    {
        [dicBody setObject:strSearchText forKey:@"queryName"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getSuggestionListURL]];
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
            
            NSMutableArray *arySuggestionList = [NSMutableArray array];
            NSArray *aryJSONSuggestion = [responseObject objectForKey:@"content"];
            for (NSDictionary *dicSuggestion in aryJSONSuggestion)
            {
                SuggestionVo *suggestionVo = [[SuggestionVo alloc]init];
                
                id suggestionId = [dicSuggestion objectForKey:@"id"];
                if (suggestionId == [NSNull null]|| suggestionId == nil)
                {
                    suggestionVo.strID = @"";
                }
                else
                {
                    suggestionVo.strID = [suggestionId stringValue];
                }
                
                //版本号
                id version = [dicSuggestion objectForKey:@"version"];
                if (version == [NSNull null]|| version == nil)
                {
                    suggestionVo.nDBVersion = 1;
                }
                else
                {
                    suggestionVo.nDBVersion = [version integerValue];
                }
                
                id createBy = [dicSuggestion objectForKey:@"createBy"];
                if (createBy == [NSNull null]|| createBy == nil)
                {
                    suggestionVo.strApplyID = @"";
                }
                else
                {
                    suggestionVo.strApplyID = [createBy stringValue];
                }
                
                suggestionVo.strName = [Common checkStrValue:[dicSuggestion objectForKey:@"applyMan"]];
                suggestionVo.strSuggestionName = [Common checkStrValue:[dicSuggestion objectForKey:@"applySuggestSubject"]];
                suggestionVo.strProblemDes = [Common checkStrValue:[dicSuggestion objectForKey:@"applyProblem"]];
                
                id departmentId = [dicSuggestion objectForKey:@"departmentId"];
                if (departmentId == [NSNull null]|| departmentId == nil)
                {
                    suggestionVo.strDepartmentID = @"";
                }
                else
                {
                    suggestionVo.strDepartmentID = [departmentId stringValue];
                }
                
                suggestionVo.strDepartmentName = [Common checkStrValue:[dicSuggestion objectForKey:@"departmentName"]];
                suggestionVo.strSuggestionNo = [Common checkStrValue:[dicSuggestion objectForKey:@"serialNo"]];
                suggestionVo.strDate = [Common checkStrValue:[dicSuggestion objectForKey:@"createDate"]];
                
                //状态
                id status = [dicSuggestion objectForKey:@"status"];
                if (status == [NSNull null]|| status == nil)
                {
                    suggestionVo.nStatus = 0;
                }
                else
                {
                    suggestionVo.nStatus = [status integerValue];
                }
                
                suggestionVo.strStatusName = [Common checkStrValue:[dicSuggestion objectForKey:@"statusName"]];
                
                //获奖状态
                id rewardStatus = [dicSuggestion objectForKey:@"rewardStatus"];
                if (rewardStatus == [NSNull null]|| rewardStatus == nil)
                {
                    suggestionVo.nRewardStatus = 0;
                }
                else
                {
                    suggestionVo.nRewardStatus = [rewardStatus integerValue];
                }
                
                suggestionVo.strRewardStatusName = [Common checkStrValue:[dicSuggestion objectForKey:@"rewardStatusName"]];
                
                //子公司评奖
                suggestionVo.strSubRewardKey = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentOpinion"]];
                suggestionVo.strSubRewardValue = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentOpinionValue"]];
                suggestionVo.strReportHeadOfficeKey = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentReport"]];
                suggestionVo.strReportHeadOfficeValue = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentReportValue"]];
                
                //总公司评奖
                suggestionVo.strHeadRewardKey = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationCommitteeOpinion"]];
                suggestionVo.strHeadRewardValue = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationCommitteeOpinionValue"]];
                suggestionVo.strHeadRewardSituation = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationReward"]];
                
                [arySuggestionList addObject:suggestionVo];
            }
            retInfo.data = arySuggestionList;
            
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

//3.基础数据加载
+ (void)getSuggestionBaseDataList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getSuggestionBaseDataListURL]];
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
            
            NSDictionary *jsonResult = responseObject;
            SuggestionBaseVo *suggestionBaseVo = [[SuggestionBaseVo alloc]init];
            id departmentId = [jsonResult objectForKey:@"departmentId"];
            if (departmentId == [NSNull null]|| departmentId == nil)
            {
                suggestionBaseVo.strDepartmentID = @"";
            }
            else
            {
                suggestionBaseVo.strDepartmentID = [departmentId stringValue];
            }
            
            suggestionBaseVo.strDepartmentName = [Common checkStrValue:[jsonResult objectForKey:@"departmentName"]];
            
            //建议项目类别
            suggestionBaseVo.arySuggestionType = [NSMutableArray array];
            NSArray *applySuggestItemList = [jsonResult objectForKey:@"applySuggestItemList"];
            for (NSDictionary *dicJSON in applySuggestItemList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.arySuggestionType addObject:keyValueVo];
            }
            
            //初评建议选项
            suggestionBaseVo.aryAssessOpinion = [NSMutableArray array];
            NSArray *assessOpinionList = [jsonResult objectForKey:@"assessOpinionList"];
            for (NSDictionary *dicJSON in assessOpinionList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryAssessOpinion addObject:keyValueVo];
            }
            
            //建议实施部门
            suggestionBaseVo.aryAssessImplementItem = [NSMutableArray array];
            NSArray *assessImplementItemList = [jsonResult objectForKey:@"assessImplementItemList"];
            for (NSDictionary *dicJSON in assessImplementItemList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryAssessImplementItem addObject:keyValueVo];
            }
            
            //本公司审核人意见
            suggestionBaseVo.aryAssessReviewerOpinion = [NSMutableArray array];
            NSArray *assessReviewerOpinionList = [jsonResult objectForKey:@"assessReviewerOpinionList"];
            for (NSDictionary *dicJSON in assessReviewerOpinionList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryAssessReviewerOpinion addObject:keyValueVo];
            }
            
            //子公司评奖
            suggestionBaseVo.aryEvaluationDepartmentOpinion = [NSMutableArray array];
            NSArray *evaluationDepartmentOpinionList = [jsonResult objectForKey:@"evaluationDepartmentOpinionList"];
            for (NSDictionary *dicJSON in evaluationDepartmentOpinionList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryEvaluationDepartmentOpinion addObject:keyValueVo];
            }
            
            //本公司推荐上报总公司评奖意见
            suggestionBaseVo.aryEvaluationDepartmentReport = [NSMutableArray array];
            NSArray *evaluationDepartmentReportList = [jsonResult objectForKey:@"evaluationDepartmentReportList"];
            for (NSDictionary *dicJSON in evaluationDepartmentReportList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryEvaluationDepartmentReport addObject:keyValueVo];
            }
            
            //工作小组评审意见
            suggestionBaseVo.aryEvaluationGroupOpinion = [NSMutableArray array];
            NSArray *evaluationGroupOpinionList = [jsonResult objectForKey:@"evaluationGroupOpinionList"];
            for (NSDictionary *dicJSON in evaluationGroupOpinionList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryEvaluationGroupOpinion addObject:keyValueVo];
            }
            
            //评审委员会意见
            suggestionBaseVo.aryEvaluationCommitteeOpinion = [NSMutableArray array];
            NSArray *evaluationCommitteeOpinionList = [jsonResult objectForKey:@"evaluationCommitteeOpinionList"];
            for (NSDictionary *dicJSON in evaluationCommitteeOpinionList)
            {
                KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"optionKey"]];
                keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"optionValue"]];
                [suggestionBaseVo.aryEvaluationCommitteeOpinion addObject:keyValueVo];
            }
            
            retInfo.data = suggestionBaseVo;
        }
        resultBlock(retInfo);
    }];
}

//4.合理化建议详情
+ (void)getSuggestionDetail:(NSString*)strSuggestionID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getSuggestionDetailURL],strSuggestionID];
    
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
            
            NSDictionary *dicSuggestion = responseObject;
            SuggestionVo *suggestionVo = [[SuggestionVo alloc]init];
            
            id suggestionId = [dicSuggestion objectForKey:@"id"];
            if (suggestionId == [NSNull null]|| suggestionId == nil)
            {
                suggestionVo.strID = @"";
            }
            else
            {
                suggestionVo.strID = [suggestionId stringValue];
            }
            
            //版本号
            id version = [dicSuggestion objectForKey:@"version"];
            if (version == [NSNull null]|| version == nil)
            {
                suggestionVo.nDBVersion = 1;
            }
            else
            {
                suggestionVo.nDBVersion = [version integerValue];
            }
            
            id createBy = [dicSuggestion objectForKey:@"createBy"];
            if (createBy == [NSNull null]|| createBy == nil)
            {
                suggestionVo.strApplyID = @"";
            }
            else
            {
                suggestionVo.strApplyID = [createBy stringValue];
            }
            
            suggestionVo.strName = [Common checkStrValue:[dicSuggestion objectForKey:@"applyMan"]];
            suggestionVo.strSuggestionName = [Common checkStrValue:[dicSuggestion objectForKey:@"applySuggestSubject"]];
            
            //分公司
            id departmentId = [dicSuggestion objectForKey:@"departmentId"];
            if (departmentId == [NSNull null]|| departmentId == nil)
            {
                suggestionVo.strDepartmentID = @"";
            }
            else
            {
                suggestionVo.strDepartmentID = [departmentId stringValue];
            }
            suggestionVo.strDepartmentName = [Common checkStrValue:[dicSuggestion objectForKey:@"departmentName"]];
            
            //建议类别
            suggestionVo.strTypeKey = [Common checkStrValue:[dicSuggestion objectForKey:@"applySuggestItem"]];
            suggestionVo.strTypeValue = [Common checkStrValue:[dicSuggestion objectForKey:@"applySuggestItemValue"]];
            
            suggestionVo.strSuggestionNo = [Common checkStrValue:[dicSuggestion objectForKey:@"serialNo"]];
            suggestionVo.strDate = [Common checkStrValue:[dicSuggestion objectForKey:@"createDate"]];
            
            //目前存在的问题
            suggestionVo.strProblemDes = [Common checkStrValue:[dicSuggestion objectForKey:@"applyProblem"]];
            
            //解决方案
            suggestionVo.strImproveDes = [Common checkStrValue:[dicSuggestion objectForKey:@"applyImprove"]];
            
            //状态
            id status = [dicSuggestion objectForKey:@"status"];
            if (status == [NSNull null]|| status == nil)
            {
                suggestionVo.nStatus = 0;
            }
            else
            {
                suggestionVo.nStatus = [status integerValue];
            }
            
            suggestionVo.strStatusName = [Common checkStrValue:[dicSuggestion objectForKey:@"statusName"]];
            
            //获奖状态
            id rewardStatus = [dicSuggestion objectForKey:@"rewardStatus"];
            if (rewardStatus == [NSNull null]|| rewardStatus == nil)
            {
                suggestionVo.nRewardStatus = 0;
            }
            else
            {
                suggestionVo.nRewardStatus = [rewardStatus integerValue];
            }
            
            suggestionVo.strRewardStatusName = [Common checkStrValue:[dicSuggestion objectForKey:@"rewardStatusName"]];
            
            //初评结果
            suggestionVo.strEvaluationKey = [Common checkStrValue:[dicSuggestion objectForKey:@"assessOpinion"]];
            suggestionVo.strEvaluationValue = [Common checkStrValue:[dicSuggestion objectForKey:@"assessOpinionValue"]];
            suggestionVo.strEvaluationSuggestion = [Common checkStrValue:[dicSuggestion objectForKey:@"assessQc"]];
            id reviewUserId = [dicSuggestion objectForKey:@"reviewUserId"];
            if (reviewUserId == [NSNull null]|| reviewUserId == nil)
            {
                suggestionVo.strReviewID = 0;
            }
            else
            {
                suggestionVo.strReviewID = [reviewUserId stringValue];
            }
            suggestionVo.strReviewName = [Common checkStrValue:[dicSuggestion objectForKey:@"reviewUserName"]];
            
            id attentionFlag = [dicSuggestion objectForKey:@"attentionFlag"];
            if (attentionFlag == [NSNull null]|| attentionFlag == nil)
            {
                suggestionVo.nReportAttention = 0;
            }
            else
            {
                suggestionVo.nReportAttention = [attentionFlag integerValue];
            }
            
            //审核结果
            suggestionVo.strReviewKey = [Common checkStrValue:[dicSuggestion objectForKey:@"assessImplementItem"]];
            suggestionVo.strReviewValue = [Common checkStrValue:[dicSuggestion objectForKey:@"assessImplementItemValue"]];
            suggestionVo.strReviewRemark = [Common checkStrValue:[dicSuggestion objectForKey:@"assessReviewerOpinion"]];
            
            //实施结果
            suggestionVo.strImplementTeam = [Common checkStrValue:[dicSuggestion objectForKey:@"implementTeam"]];
            suggestionVo.strImplementSituation = [Common checkStrValue:[dicSuggestion objectForKey:@"implementDesc"]];
            
            //验证结果
            suggestionVo.strVerifySituaion = [Common checkStrValue:[dicSuggestion objectForKey:@"implementVerify"]];
            suggestionVo.strExtendSituation = [Common checkStrValue:[dicSuggestion objectForKey:@"implementPromotion"]];
            //数字类型
            id implementCost = [dicSuggestion objectForKey:@"implementCost"];
            if (implementCost == nil || implementCost  == [NSNull null])
            {
                suggestionVo.strImplementCost = @"";
            }
            else
            {
                suggestionVo.strImplementCost = [implementCost stringValue];
            }
            
            id implementBenefit = [dicSuggestion objectForKey:@"implementBenefit"];
            if (implementBenefit == nil || implementBenefit  == [NSNull null])
            {
                suggestionVo.strSavingCost = @"";
            }
            else
            {
                suggestionVo.strSavingCost = [implementBenefit stringValue];
            }
            
            //子公司评奖
            suggestionVo.strSubRewardKey = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentOpinion"]];
            suggestionVo.strSubRewardValue = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentOpinionValue"]];
            suggestionVo.strReportHeadOfficeKey = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentReport"]];
            suggestionVo.strReportHeadOfficeValue = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationDepartmentReportValue"]];
            
            //总公司评奖
            suggestionVo.strHeadRewardKey = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationCommitteeOpinion"]];
            suggestionVo.strHeadRewardValue = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationCommitteeOpinionValue"]];
            suggestionVo.strHeadRewardSituation = [Common checkStrValue:[dicSuggestion objectForKey:@"evaluationReward"]];
            
            retInfo.data = suggestionVo;
        }
        resultBlock(retInfo);
    }];
}

//5.提交审批
+ (void)commitSuggestionReview:(SuggestionVo*)suggestionVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:suggestionVo.strID forKey:@"id"];
    [dicBody setObject:[NSNumber numberWithInteger:suggestionVo.nDBVersion] forKey:@"version"];
    
    if(suggestionVo.nCommitStatus == 0)
    {
        //0-修改合理化建议
        [dicBody setObject:@1 forKey:@"status"];
        
        [dicBody setObject:suggestionVo.strName forKey:@"applyMan"];
        [dicBody setObject:suggestionVo.strSuggestionName forKey:@"applySuggestSubject"];
        [dicBody setObject:suggestionVo.strTypeKey forKey:@"applySuggestItem"];
        [dicBody setObject:suggestionVo.strProblemDes forKey:@"applyProblem"];
        [dicBody setObject:suggestionVo.strImproveDes forKey:@"applyImprove"];
        [dicBody setObject:suggestionVo.strDepartmentID forKey:@"departmentId"];
    }
    else if(suggestionVo.nCommitStatus == 1)
    {
        //1-提交初评
        [dicBody setObject:@2 forKey:@"status"];
        [dicBody setObject:suggestionVo.strEvaluationKey forKey:@"assessOpinion"];
        if(suggestionVo.strEvaluationSuggestion != nil)
        {
            [dicBody setObject:suggestionVo.strEvaluationSuggestion forKey:@"assessQc"];
        }
        if(suggestionVo.strReviewID != nil)
        {
            [dicBody setObject:suggestionVo.strReviewID forKey:@"reviewUserId"];
        }
        [dicBody setObject:[NSNumber numberWithInteger:suggestionVo.nReportAttention] forKey:@"attentionFlag"];
    }
    else if(suggestionVo.nCommitStatus == 2)
    {
        //2-提交审核
        [dicBody setObject:@4 forKey:@"status"];
        [dicBody setObject:suggestionVo.strReviewKey forKey:@"assessImplementItem"];
        if(suggestionVo.strReviewRemark != nil)
        {
            [dicBody setObject:suggestionVo.strReviewRemark forKey:@"assessReviewerOpinion"];
        }
    }
    else if(suggestionVo.nCommitStatus == 3)
    {
        //3-提交实施
        [dicBody setObject:@8 forKey:@"status"];
        [dicBody setObject:suggestionVo.strImplementTeam forKey:@"implementTeam"];
        [dicBody setObject:suggestionVo.strImplementSituation forKey:@"implementDesc"];
    }
    else if(suggestionVo.nCommitStatus == 4)
    {
        //4-提交验证
        [dicBody setObject:@9 forKey:@"status"];
        [dicBody setObject:suggestionVo.strVerifySituaion forKey:@"implementVerify"];
        [dicBody setObject:suggestionVo.strExtendSituation forKey:@"implementPromotion"];
        [dicBody setObject:suggestionVo.strImplementCost forKey:@"implementCost"];
        [dicBody setObject:suggestionVo.strSavingCost forKey:@"implementBenefit"];
    }
    else if(suggestionVo.nCommitStatus == 5)
    {
        //5-提交子公司评奖
        [dicBody setObject:@10 forKey:@"status"];
        [dicBody setObject:suggestionVo.strSubRewardKey forKey:@"evaluationDepartmentOpinion"];
    }
    else if(suggestionVo.nCommitStatus == 6)
    {
        //6-提交总公司评奖
        [dicBody setObject:@11 forKey:@"status"];
        [dicBody setObject:suggestionVo.strHeadRewardKey forKey:@"evaluationCommitteeOpinion"];
        [dicBody setObject:suggestionVo.strHeadRewardSituation forKey:@"evaluationReward"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getCommitSuggestionReviewURL]];
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

//6.子公司选人(通过真实姓名)
+ (void)getCompanyUserByTrueName:(NSString*)strTrueName result:(ResultBlock)resultBlock
{
    
    NSString *strURL = [NSString stringWithFormat:@"%@?term=%@",[ServerURL getCompanyUserByTrueNameURL],strTrueName];
    
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
            
            NSMutableArray *aryUser = [NSMutableArray array];
            NSArray *aryJSONUser = responseObject;
            if ([aryJSONUser isKindOfClass:[NSArray class]] && aryJSONUser.count>0)
            {
                for (NSDictionary *dicUser in aryJSONUser)
                {
                    UserVo *userVo = [[UserVo alloc]init];
                    
                    id userID = [dicUser objectForKey:@"id"];
                    if (userID == [NSNull null]|| userID == nil)
                    {
                        userVo.strUserID = @"";
                    }
                    else
                    {
                        userVo.strUserID = [userID stringValue];
                    }
                    
                    userVo.strRealName = [Common checkStrValue:[dicUser objectForKey:@"value"]];
                    userVo.strUserName = [Common checkStrValue:[dicUser objectForKey:@"aliasName"]];//别名
                    userVo.strHeadImageURL = [Common checkStrValue:[dicUser objectForKey:@"imageUrl"]];
                    userVo.strDepartmentName = [Common checkStrValue:[dicUser objectForKey:@"orgName"]];//子公司名字
                    
                    [aryUser addObject:userVo];
                }
            }
            retInfo.data = aryUser;
        }
        resultBlock(retInfo);
    }];
}

//积分相关/////////////////////////////////////////////////////////////////////////////
//用户积分流水记录(nType:0:收入积分,1：支出积分,2：版主积分)
+ (void)getIntegrationList:(NSInteger)nPage type:(NSInteger)nType result:(ResultBlock)resultBlock
{
    NSString *strType;
    if (nType == 0)
    {
        strType = @"I";
    }
    else if (nType == 1)
    {
        strType = @"O";
    }
    else
    {
        strType = @"M";
    }
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:strType forKey:@"queryType"];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPage setObject:@10 forKey:@"pageSize"];
    [dicBody setObject:dicPage forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getIntegrationListURL]];
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
            
            NSMutableArray *aryIntegration = [NSMutableArray array];
            
            NSDictionary *dicResponse = (NSDictionary*)responseObject;
            id content = [dicResponse objectForKey:@"content"];
            if (content != [NSNull null] && content != nil)
            {
                NSArray *aryResponse = (NSArray*)content;
                for (NSDictionary *dicJSON in aryResponse)
                {
                    IntegrationDetailVo *detailVo = [[IntegrationDetailVo alloc]init];
                    id integrationId = [dicJSON objectForKey:@"id"];
                    if (integrationId == [NSNull null]|| integrationId == nil)
                    {
                        detailVo.strID = @"";
                    }
                    else
                    {
                        detailVo.strID = [integrationId stringValue];
                    }
                    
                    id sender = [dicJSON objectForKey:@"sender"];
                    if (sender == [NSNull null]|| sender == nil)
                    {
                        detailVo.strFromID = @"";
                    }
                    else
                    {
                        detailVo.strFromID = [sender stringValue];
                    }
                    detailVo.strFromName = [Common checkStrValue:[dicJSON objectForKey:@"senderName"]];
                    detailVo.strDateTime = [Common checkStrValue:[dicJSON objectForKey:@"createDate"]];
                    detailVo.strFromType = [Common checkStrValue:[dicJSON objectForKey:@"integralSource"]];
                    
                    detailVo.strTitle = [Common checkStrValue:[dicJSON objectForKey:@"refTitle"]];
                    
                    id integral = [dicJSON objectForKey:@"integral"];
                    if (integral == [NSNull null]|| integral == nil)
                    {
                        detailVo.fNum = 0.0f;
                    }
                    else
                    {
                        detailVo.fNum = [integral doubleValue];
                    }
                    
                    detailVo.strIntegralType = [Common checkStrValue:[dicJSON objectForKey:@"integralType"]];
                    detailVo.strIntegralTypeName = [Common checkStrValue:[dicJSON objectForKey:@"integralTypeName"]];
                    
                    [aryIntegration addObject:detailVo];
                }
            }
            
            retInfo.data = aryIntegration;
            
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

//用户每日签到
+ (void)signInByDay:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getSignInByDayURL]];
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
            
            NSDictionary *dicJSON = (NSDictionary *)responseObject;
            
            //本次签到获得积分
            NSNumber *numIntegral;
            id lastIntegral = [dicJSON objectForKey:@"lastIntegral"];
            if (lastIntegral == [NSNull null] || lastIntegral == nil)
            {
                numIntegral = [NSNumber numberWithDouble:0.0f];
            }
            else
            {
                numIntegral = lastIntegral;
            }
            retInfo.data = numIntegral;
            
            //当前总积分
            NSNumber *numSumIntegral;
            id currentIntegral = [dicJSON objectForKey:@"currentIntegral"];
            if (currentIntegral == [NSNull null] || currentIntegral == nil)
            {
                numSumIntegral = [NSNumber numberWithDouble:0.0f];
            }
            else
            {
                numSumIntegral = currentIntegral;
            }
            retInfo.data2 = numSumIntegral;
        }
        resultBlock(retInfo);
    }];
}

//打赏
+ (void)integrationOperation:(NSString*)strReceiverID intergral:(NSString*)strNum
                      blogId:(NSString*)strRefID remark:(NSString*)strDesc result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    if (strReceiverID != nil && strReceiverID.length > 0)
    {
        [dicBody setObject:strReceiverID forKey:@"receiver"];
    }
    
    [dicBody setObject:strNum forKey:@"integral"];
    
    if (strRefID != nil && strRefID.length > 0)
    {
        [dicBody setObject:strRefID forKey:@"refId"];
    }
    
    if (strDesc != nil && strDesc.length > 0)
    {
        [dicBody setObject:strDesc forKey:@"remark"];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getIntegrationOperationURL]];
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

//分享第三方平台奖励积分
+ (void)getIntegralByShareToThird:(NSString*)strShareID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getIntegralByShareToThirdURL],strShareID];
    
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
            
            NSNumber *numIntegral;
            NSDictionary *dicJSON = (NSDictionary *)responseObject;
            id lastIntegral = [dicJSON objectForKey:@"integral"];
            if (lastIntegral == [NSNull null] || lastIntegral == nil)
            {
                numIntegral = [NSNumber numberWithInteger:0];
            }
            else
            {
                numIntegral = lastIntegral;
            }
            retInfo.data = numIntegral;
        }
        resultBlock(retInfo);
    }];
}

//排行榜///////////////////////////////////////////////////////////////////////////
//热点人物排行榜(24小时内增长积分最多用户)
+ (void)getHotUserList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getHotUserListURL]];
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
            
            NSMutableArray *aryUser = [NSMutableArray array];
            NSArray *aryJSONUserList = responseObject;
            if (aryJSONUserList.count>0)
            {
                aryUser = [self getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryUser;
        }
        resultBlock(retInfo);
    }];
}

//本人积分排名(前20+self+后10)
+ (void)getSelfRankUserList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getSelfRankUserListURL]];
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
            
            NSMutableArray *aryUser = [NSMutableArray array];
            NSArray *aryJSONUserList = responseObject;
            if (aryJSONUserList.count>0)
            {
                aryUser = [self getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryUser;
        }
        resultBlock(retInfo);
    }];
}

//积分总排行(前10)
+ (void)getIntegrationSort:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getIntegrationSortURL]];
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
            
            NSMutableArray *aryMemberList = nil;
            NSArray *aryJSONUserList = (NSArray*)responseObject;
            if (aryJSONUserList != nil && aryJSONUserList.count>0)
            {
                aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
            }
            retInfo.data = aryMemberList;
        }
        resultBlock(retInfo);
    }];
}

//热门帖子
+ (void)getHotShareList:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@"1" forKey:@"hotFlag"];
    
    NSMutableDictionary *tempBodyDic = [[NSMutableDictionary alloc] init];
    [tempBodyDic setObject:@1 forKey:@"pageNumber"];
    [tempBodyDic setObject:@"10" forKey:@"pageSize"];
    [bodyDic setObject:tempBodyDic forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getShareListByTypeAndTagURL]];
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
            
            NSMutableArray *aryShare = nil;
            
            NSArray *aryActivityList = [responseObject objectForKey:@"content"];
            if (aryActivityList != nil)
            {
                aryShare  = [ServerProvider getBlogListByJSONArray:aryActivityList];
                retInfo.data = aryShare;
            }
        }
        resultBlock(retInfo);
    }];
}

//公司排名
+ (void)getCompanyRankingList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getCompanyRankingListURL]];
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
            
            NSArray *aryJSON = responseObject;
            NSMutableArray *aryData = [NSMutableArray array];
            if([aryJSON isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *dicJSON in aryJSON)
                {
                    CompanyRankingVo *rankingVo = [[CompanyRankingVo alloc]init];
                    id companyID = [dicJSON objectForKey:@"id"];
                    if (companyID == [NSNull null]|| companyID == nil)
                    {
                        rankingVo.strID = @"";
                    }
                    else
                    {
                        rankingVo.strID = [companyID stringValue];
                    }
                    
                    rankingVo.strName = [Common checkStrValue:[dicJSON objectForKey:@"departmentName"]];
                    
                    id sum = [dicJSON objectForKey:@"sum"];
                    if (sum == [NSNull null]|| sum == nil)
                    {
                        rankingVo.fSum = 0;
                    }
                    else
                    {
                        rankingVo.fSum = [sum doubleValue];
                    }
                    
                    id avg = [dicJSON objectForKey:@"avg"];
                    if (avg == [NSNull null]|| avg == nil)
                    {
                        rankingVo.fAvg = 0;
                    }
                    else
                    {
                        rankingVo.fAvg = [avg doubleValue];
                    }
                    
                    [aryData addObject:rankingVo];
                }
                
            }
            retInfo.data = aryData;
        }
        resultBlock(retInfo);
    }];
}

//通用字典/////////////////////////////////////////////////////////////////////////////
+ (void)getDictionaryConfigData:(NSString *)strType result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",[ServerURL getDictionaryConfigDataURL],strType];
    
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
            
            NSArray *aryJSON = responseObject;
            NSMutableArray *aryData = [NSMutableArray array];
            if([aryJSON isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *dicJSON in aryJSON)
                {
                    KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
                    keyValueVo.strKey = [Common checkStrValue:[dicJSON objectForKey:@"key"]];
                    keyValueVo.strValue = [Common checkStrValue:[dicJSON objectForKey:@"value"]];
                    
                    [aryData addObject:keyValueVo];
                }
            }
            retInfo.data = aryData;
        }
        resultBlock(retInfo);
    }];
}

@end
