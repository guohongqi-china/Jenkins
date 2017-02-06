//
//  ServerProvider.m
//  Sloth
//
//  Created by Ann Yao on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServerProvider.h"
#import "DNENetworkFramework.h"
#import "Utils.h"
#import "shareModel.h"
#import "Common.h"
#import "shareModel.h"
#import "ServerURL.h"
#import "CommentVo.h"
#import "NotifyVo.h"
#import "ServerURL.h"
#import "VoteOptionVo.h"
#import "TopicVo.h"
#import "PageClassVo.h"
#import "SendChatVo.h"
#import "ChineseToPinyin.h"
#import "ChatContentVo.h"
#import "PublishVo.h"
#import "UserVo.h"
#import "ScheduleJoinStateVo.h"
#import "AttachmentVo.h"
#import "TransferInfoVo.h"
#import "KeyValueVo.h"
#import "TagVo.h"
#import "ReceiverVo.h"
#import "BlogVo.h"
#import "AnswerVo.h"
#import "UploadFileVo.h"
#import "PraiseVo.h"
#import "LanguageManage.h"
#import "AnnouncementVo.h"
#import "ShareInfoVo.h"
#import "ActivityProjectVo.h"
#import "QuestionSurveyVo.h"
#import "QuestionVo.h"
#import "LotteryOptionVo.h"
#import "FieldVo.h"
#import "CustomerVo.h"
#import "FAQVo.h"
#import "TicketTypeVo.h"
#import "TicketTraceVo.h"

#define BODY_NULL @"获取数据失败"

@implementation ServerProvider

+ (NSMutableArray*)getUserListByJSONArray:(NSArray*)aryUserList
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
        
        userVo.strLoginAccount = [Common checkStrValue:[dicUserInfo objectForKey:@"userLoginName"]];
        
        userVo.strPhoneNumber = [Common checkStrValue:[dicUserInfo objectForKey:@"phoneNumber"]];
        
        id companyId = [dicUserInfo objectForKey:@"companyId"];
        if (companyId == [NSNull null]|| companyId == nil)
        {
            userVo.strCompanyID = @"0";
        }
        else
        {
            userVo.strCompanyID = [companyId stringValue];
        }
        
        userVo.strRealName = [Common checkStrValue:[dicUserInfo objectForKey:@"aliasName"]];
        userVo.strEmployeeNum = [Common checkStrValue:[dicUserInfo objectForKey:@"employeeNum"]];
        userVo.strEmail = [Common checkStrValue:[dicUserInfo objectForKey:@"email"]];
        userVo.strFirstLetter = [[Common checkStrValue:[dicUserInfo objectForKey:@"firstLetter"]] uppercaseString];
        
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
        
        userVo.strPartImageURL = [Common checkStrValue:[dicUserInfo objectForKey:@"headimgurl"]];
        userVo.strHeadImageURL = [ServerURL getWholeURL:userVo.strPartImageURL];
        
        //get pinyin
        NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:userVo.strRealName];
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

//将工单JSON转换为对象数组
+ (NSMutableArray*)getTagListByJSONArray:(NSArray*)aryJSON
{
    if (![aryJSON isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryTagList = [NSMutableArray array];
    for (NSDictionary *dicData in aryJSON)
    {
        TagVo *tagVo = [[TagVo alloc]init];
        id tagId = [dicData objectForKey:@"id"];
        if (tagId == [NSNull null])
        {
            tagVo.strID = @"";
        }
        else
        {
            tagVo.strID = [tagId stringValue];
        }
        
        tagVo.strTagName = [Common checkStrValue:[dicData objectForKey:@"tagName"]];
        
        //get pinyin
        NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:tagVo.strTagName];
        if(aryPinyin!=nil && aryPinyin.count>0)
        {
            tagVo.strQP = [aryPinyin objectAtIndex:0];
            if (aryPinyin.count>1)
            {
                tagVo.strJP = [aryPinyin objectAtIndex:1];
            }
        }

        [aryTagList addObject:tagVo];
    }
    return aryTagList;
}

//将工单跟踪记录JSON转换为对象数组
+ (NSMutableArray*)getTicketRecordByJSONArray:(NSArray*)aryJSON
{
    if (![aryJSON isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryRecordList = [NSMutableArray array];
    for (NSDictionary *dicData in aryJSON)
    {
        TicketTraceVo *ticketTraceVo = [[TicketTraceVo alloc]init];
        id ticketId = [dicData objectForKey:@"id"];
        if (ticketId == [NSNull null])
        {
            ticketTraceVo.strID = @"";
        }
        else
        {
            ticketTraceVo.strID = [ticketId stringValue];
        }
        
        ticketTraceVo.strContent = [Common checkStrValue:[dicData objectForKey:@"trackContent"]];
        
        ticketTraceVo.strDateTime = [Common checkStrValue:[dicData objectForKey:@"createDate"]];
        
        [aryRecordList addObject:ticketTraceVo];
    }
    return aryRecordList;
}

//将工单JSON转换为对象数组
+ (NSMutableArray*)getTicketListByJSONArray:(NSArray*)aryJSON
{
    if (![aryJSON isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryTicketList = [NSMutableArray array];
    for (NSDictionary *dicTicket in aryJSON)
    {
        TicketVo *ticketVo = [[TicketVo alloc]init];
        id ticketId = [dicTicket objectForKey:@"id"];
        if (ticketId == [NSNull null])
        {
            ticketVo.strID = @"";
        }
        else
        {
            ticketVo.strID = [ticketId stringValue];
        }
        
        ticketVo.strTicketNum = [Common checkStrValue:[dicTicket objectForKey:@"orderNumber"]];
        
        id customerId = [dicTicket objectForKey:@"customerId"];
        if (customerId == [NSNull null])
        {
            ticketVo.strCustomerID = @"";
        }
        else
        {
            ticketVo.strCustomerID = [customerId stringValue];
        }
        
        ticketVo.strCustomerName = [Common checkStrValue:[dicTicket objectForKey:@"customerName"]];
        
        id kefuId = [dicTicket objectForKey:@"kefuId"];
        if (kefuId == [NSNull null])
        {
            ticketVo.strKefuID = @"";
        }
        else
        {
            ticketVo.strKefuID = [kefuId stringValue];
        }
        
        ticketVo.strTitle = [Common checkStrValue:[dicTicket objectForKey:@"orderTitle"]];
        
        id orderType = [dicTicket objectForKey:@"orderType"];
        if (orderType == [NSNull null])
        {
            ticketVo.strTypeID = @"";
        }
        else
        {
            ticketVo.strTypeID = [orderType stringValue];
        }
        ticketVo.strTypeName = [Common checkStrValue:[dicTicket objectForKey:@"orderTypeName"]];
        
        id talkId = [dicTicket objectForKey:@"talkId"];
        if (talkId == [NSNull null])
        {
            ticketVo.strSessionID = @"";
        }
        else
        {
            ticketVo.strSessionID = [talkId stringValue];
        }
        
//        id status = [dicTicket objectForKey:@"status"];
//        if (status == [NSNull null])
//        {
//            ticketVo.nStatus = 1;
//        }
//        else
//        {
//            ticketVo.nStatus = [status integerValue];
//        }
        
        
        id trackRecordVoList = [dicTicket objectForKey:@"trackRecordVoList"];
        if (trackRecordVoList != nil &&  trackRecordVoList != [NSNull null] && [trackRecordVoList isKindOfClass:[NSArray class]])
        {
            ticketVo.aryTrace = [ServerProvider getTicketRecordByJSONArray:trackRecordVoList];
        }
        
        //tag
        id tagList = [dicTicket objectForKey:@"tagList"];
        if (tagList != nil &&  tagList != [NSNull null])
        {
            ticketVo.aryTag = [ServerProvider getTagListByJSONArray:tagList];
        }
        
        //接口新字段///////////////////////////////////////////////////////////////////////
        //价格估算
        ticketVo.strEvaluatePrice = [Common checkStrValue:[dicTicket objectForKey:@"priceEstimation"]];
        
        //难易度
        ticketVo.strDifficultyLevel = [Common checkStrValue:[dicTicket objectForKey:@"difficulty"]];
        
        //明细内容
        ticketVo.strContent = [Common checkStrValue:[dicTicket objectForKey:@"content"]];
        
        //故障分类
        ticketVo.classification = [Common checkStrValue:[dicTicket objectForKey:@"classification"]];
        
        //状态
        ticketVo.strStatus = [Common checkStrValue:[dicTicket objectForKey:@"detailStatus"]];
        
        //时间
        id updateTime = [dicTicket objectForKey:@"updateTime"];
        if (updateTime != [NSNull null] && updateTime != nil)
        {
            ticketVo.strDateTime = [Common getDateTimeStringFromTimeStamp:[updateTime unsignedLongLongValue]];
        }
        else
        {
            ticketVo.strDateTime = @"";
        }
        
        //客户ID
        ticketVo.strCustomerID = [Common checkStrValue:[dicTicket objectForKey:@"guestId"]];
        
        //客户姓名
        ticketVo.strCustomerName = [Common checkStrValue:[dicTicket objectForKey:@"guestName"]];
        
        
        [aryTicketList addObject:ticketVo];
    }
    return aryTicketList;
}

//将会话JSON转换为对象数组
+ (NSMutableArray*)getSessionListByJSONArray:(NSArray*)arySessionJSONList
{
    NSMutableArray *arySessionList = [NSMutableArray array];
    for (NSDictionary *dicSession in arySessionJSONList)
    {
        ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
        chatObjectVo.nType = 1;
        
        //会话ID
        id talkId = [dicSession objectForKey:@"id"];
        if (talkId == [NSNull null] || talkId == nil)
        {
            chatObjectVo.strID = @"";
        }
        else
        {
            chatObjectVo.strID = [talkId stringValue];
        }
        
        //状态
        id status = [dicSession objectForKey:@"status"];
        if (status == [NSNull null] || status == nil)
        {
            chatObjectVo.nSessionStatus = -2;
        }
        else
        {
            chatObjectVo.nSessionStatus = [status integerValue];
        }
        
        //会话分类
        id talkType = [dicSession objectForKey:@"talkType"];
        if (talkType == [NSNull null] || talkType == nil)
        {
            chatObjectVo.nSessionType = 0;
        }
        else
        {
            chatObjectVo.nSessionType = [talkType integerValue];
        }
        
        //优先级
        id priorityId = [dicSession objectForKey:@"priorityId"];
        if (priorityId == [NSNull null] || priorityId == nil)
        {
            chatObjectVo.nPriorityID = 0;
        }
        else
        {
            chatObjectVo.nPriorityID = [priorityId integerValue];
        }
        
        //优先级描述
        chatObjectVo.strPriorityDesc = [Common checkStrValue:[dicSession objectForKey:@"priorityDesc"]];
        
        //客户ID
        id customerId = [dicSession objectForKey:@"customerId"];
        if (customerId == [NSNull null] || customerId == nil)
        {
            chatObjectVo.strCustomerID = @"";
        }
        else
        {
            chatObjectVo.strCustomerID = [customerId stringValue];
        }
        
        //客户编号
        chatObjectVo.strCustomerCode = [Common checkStrValue:[dicSession objectForKey:@"customerNumber"]];
        
        //客户名称
        chatObjectVo.strCustomerNickName = [Common checkStrValue:[dicSession objectForKey:@"customerNickname"]];
        
        //该客户信息是否完善过
        id customerVip = [dicSession objectForKey:@"customerVip"];
        if (customerVip == [NSNull null] || customerVip == nil)
        {
            chatObjectVo.bCustomerVip = NO;
        }
        else
        {
            chatObjectVo.bCustomerVip = [customerVip boolValue];
        }
        
        //最新消息的ID
        id newMessageId = [dicSession objectForKey:@"newMessageId"];
        if (newMessageId == [NSNull null] || newMessageId == nil)
        {
            chatObjectVo.strLastChatID = @"";
        }
        else
        {
            chatObjectVo.strLastChatID = [newMessageId stringValue];
        }
        
        //最新消息的内容
        chatObjectVo.strLastChatCon = [Common checkStrValue:[dicSession objectForKey:@"newMessageContent"]];
        
        //最新消息的时间
        chatObjectVo.strLastChatTime = [Common checkStrValue:[dicSession objectForKey:@"newMessageDateStr"]];
        
        //最新消息的来源
        id talkOrigin = [dicSession objectForKey:@"talkOrigin"];
        if (talkOrigin == [NSNull null] || talkOrigin == nil)
        {
            chatObjectVo.nLastChatFrom = 0;
        }
        else
        {
            chatObjectVo.nLastChatFrom = [talkOrigin integerValue];
        }
        
        //经度
        id newLocationx = [dicSession objectForKey:@"newLocationx"];
        if (newLocationx == [NSNull null] || newLocationx == nil)
        {
            chatObjectVo.fLongitude = 0;
        }
        else
        {
            chatObjectVo.fLongitude = [newLocationx doubleValue];
        }
        
        //纬度
        id newLocationy = [dicSession objectForKey:@"newLocationy"];
        if (newLocationy == [NSNull null] || newLocationy == nil)
        {
            chatObjectVo.fLatitude = 0;
        }
        else
        {
            chatObjectVo.fLatitude = [newLocationy doubleValue];
        }
        
        //当前客服ID
        id kefuId = [dicSession objectForKey:@"kefuId"];
        if (kefuId == [NSNull null] || kefuId == nil)
        {
            chatObjectVo.strCurrKefuID = @"";
        }
        else
        {
            chatObjectVo.strCurrKefuID = [kefuId stringValue];
        }
        
        //当前客服Name
        chatObjectVo.strCurrKefuName = [Common checkStrValue:[dicSession objectForKey:@"kefuName"]];
        
        //来自转交客服ID
        id transferFromId = [dicSession objectForKey:@"transferFromId"];
        if (transferFromId == [NSNull null] || transferFromId == nil)
        {
            chatObjectVo.strTransferFromID = @"";
        }
        else
        {
            chatObjectVo.strTransferFromID = [transferFromId stringValue];
        }
        
        //公司ID
        id companyId = [dicSession objectForKey:@"companyId"];
        if (companyId == [NSNull null] || companyId == nil)
        {
            chatObjectVo.strCompanyID = @"";
        }
        else
        {
            chatObjectVo.strCompanyID = [companyId stringValue];
        }
        
        //第一次回复时间，即当客服人员第一次回复消息的时间
        chatObjectVo.strFirstReplyDate = [Common checkStrValue:[dicSession objectForKey:@"firstReplyDateFormat"]];
        
        //最后回复时间
        chatObjectVo.strLastResponseDate = [Common checkStrValue:[dicSession objectForKey:@"lastResponseDateFormat"]];
        
        //关闭会话时间
        chatObjectVo.strCloseDate = [Common checkStrValue:[dicSession objectForKey:@"closeDateFormat"]];
        
        //到会话暂停/结束为止，客服回复总数量
        id replyTotalNum = [dicSession objectForKey:@"replyTotalNum"];
        if (replyTotalNum == [NSNull null] || replyTotalNum == nil)
        {
            chatObjectVo.nReplyTotalNum = 0;
        }
        else
        {
            chatObjectVo.nReplyTotalNum = [replyTotalNum integerValue];
        }
        
        //消息标签名
        chatObjectVo.strTagNames = [Common checkStrValue:[dicSession objectForKey:@"tagNames"]];
        
        //上次读过最后的消息ID
        id lastReadMessageId = [dicSession objectForKey:@"lastReadMessageId"];
        if (lastReadMessageId == [NSNull null] || lastReadMessageId == nil)
        {
            chatObjectVo.strLastReadMessageID = @"";
        }
        else
        {
            chatObjectVo.strLastReadMessageID = [lastReadMessageId stringValue];
        }
        
        [arySessionList addObject:chatObjectVo];
    }
    
    return arySessionList;
}

//获取某个具体会话的聊天记录
+ (NSMutableArray*)getSessionDetailByJSONArray:(NSArray*)aryChatJSONList
{
    NSMutableArray *aryChatContent = [NSMutableArray array];
    for (NSDictionary *dicContent in aryChatJSONList)
    {
        ChatContentVo *chatContentVo = [[ChatContentVo alloc]init];
        
        //消息id
        id messageId = [dicContent objectForKey:@"id"];
        if (messageId == [NSNull null] || messageId == nil)
        {
            chatContentVo.strID = @"";
        }
        else
        {
            chatContentVo.strID = [messageId stringValue];
        }
        
        //消息的来源
        id messageOrigin = [dicContent objectForKey:@"messageOrigin"];
        if (messageOrigin == [NSNull null] || messageOrigin == nil)
        {
            chatContentVo.nChatFrom = 0;
        }
        else
        {
            chatContentVo.nChatFrom = [messageOrigin integerValue];
        }
        
        //发送人类型
        id senderType = [dicContent objectForKey:@"senderType"];
        if (senderType == [NSNull null] || senderType == nil)
        {
            chatContentVo.nSenderType = 2;//null 则默认客服发布
        }
        else
        {
            chatContentVo.nSenderType = [senderType integerValue];
        }
        
        //会话ID
        id talkId = [dicContent objectForKey:@"talkId"];
        if (talkId == [NSNull null] || talkId == nil)
        {
            chatContentVo.strSessionID = @"";
        }
        else
        {
            chatContentVo.strSessionID = [talkId stringValue];
        }
        
        //消息链接
        NSString *strMessageURL = [Common checkStrValue:[dicContent objectForKey:@"messageUrl"]];
        if([strMessageURL hasPrefix:@"http"])
        {
            chatContentVo.strChatURL = strMessageURL;
        }
        else
        {
            chatContentVo.strChatURL = [ServerURL getWholeURL:strMessageURL];
        }

        //标签集合
        
        //经度
        id locationx = [dicContent objectForKey:@"locationx"];
        if (locationx == [NSNull null] || locationx == nil)
        {
            chatContentVo.fLongitude = 0;
        }
        else
        {
            chatContentVo.fLongitude = [locationx doubleValue];
        }
        
        //纬度
        id locationy = [dicContent objectForKey:@"locationy"];
        if (locationy == [NSNull null] || locationy == nil)
        {
            chatContentVo.fLatitude = 0;
        }
        else
        {
            chatContentVo.fLatitude = [locationy doubleValue];
        }
        
        //客服ID
        id kefuId = [dicContent objectForKey:@"kefuId"];
        if (kefuId == [NSNull null] || kefuId == nil)
        {
            chatContentVo.strCurrKefuID = @"";
        }
        else
        {
            chatContentVo.strCurrKefuID = [kefuId stringValue];
        }
        
        //客服Name
        chatContentVo.strCurrKefuName = [Common checkStrValue:[dicContent objectForKey:@"kefuName"]];
        
        //客户ID
        id customerId = [dicContent objectForKey:@"customerId"];
        if (customerId == [NSNull null] || customerId == nil)
        {
            chatContentVo.strCustomerID = @"";
        }
        else
        {
            chatContentVo.strCustomerID = [customerId stringValue];
        }
        
        //客户名称
        chatContentVo.strCustomerNickName = [Common checkStrValue:[dicContent objectForKey:@"customerNickname"]];
        
        //客户账户	微信号、邮箱等
        chatContentVo.strCustomerAccount = [Common checkStrValue:[dicContent objectForKey:@"sourceAccount"]];
        
        //公司ID
        id companyId = [dicContent objectForKey:@"companyId"];
        if (companyId == [NSNull null] || companyId == nil)
        {
            chatContentVo.strCompanyID = @"";
        }
        else
        {
            chatContentVo.strCompanyID = [companyId stringValue];
        }
//        
        chatContentVo.strHeadImg = [Common checkStrValue:[dicContent objectForKey:@"avatar"]];
        chatContentVo.strHeadImg = [ServerURL getWholeURL:chatContentVo.strHeadImg];
        
        chatContentVo.strChatTime = [Common checkStrValue:[dicContent objectForKey:@"createDateStr"]];
        
        chatContentVo.strContent = [Common checkStrValue:[dicContent objectForKey:@"messageContent"]];
        chatContentVo.strContent = [Common replaceLineBreak:chatContentVo.strContent];
        
        chatContentVo.strChatType = [Common checkStrValue:[dicContent objectForKey:@"messageType"]];
        
        //消息类型(文本/图片)	text image document video audio location
        //0:文本(text)  1:图片(image)  2:语音(voice)  3:视频(video) 4:音频(audio) 5:位置(location) 6:链接(link)
        //chatContentVo.strChatType = @"image";
        if ([chatContentVo.strChatType isEqualToString:@"text"])
        {
            //文本
            chatContentVo.nContentType = 0;
        }
        else if ([chatContentVo.strChatType isEqualToString:@"image"])
        {
            //图片
            chatContentVo.nContentType = 1;
            
            chatContentVo.strImgURL = chatContentVo.strChatURL;
            chatContentVo.strSmallImgURL = chatContentVo.strImgURL;
        }
        else if ([chatContentVo.strChatType isEqualToString:@"voice"])
        {
            //语音
            chatContentVo.nContentType = 2;
            chatContentVo.bAudioPlaying = NO;
            chatContentVo.strFileURL = chatContentVo.strChatURL;
        }
        else if ([chatContentVo.strChatType isEqualToString:@"video"] || [chatContentVo.strChatType isEqualToString:@"shortvideo"])
        {
            //视频
            chatContentVo.nContentType = 3;
            chatContentVo.strFileURL = chatContentVo.strChatURL;
        }
        else if ([chatContentVo.strChatType isEqualToString:@"audio"])
        {
            //音频
            chatContentVo.nContentType = 4;
            chatContentVo.bAudioPlaying = NO;
            chatContentVo.strFileURL = chatContentVo.strChatURL;
        }
        else if ([chatContentVo.strChatType isEqualToString:@"location"])
        {
            //地理位置
            chatContentVo.nContentType = 5;
        }
        else if ([chatContentVo.strChatType isEqualToString:@"link"])
        {
            //链接
            chatContentVo.nContentType = 6;
        }
        else
        {
            chatContentVo.nContentType = 0;
        }
        
        [aryChatContent addObject:chatContentVo];
    }
    
    //倒序操作
    [aryChatContent sortUsingComparator:^NSComparisonResult(__strong ChatContentVo* obj1,__strong ChatContentVo* obj2){
        NSString *str1=obj1.strChatTime;
        NSString *str2=obj2.strChatTime;
        return [str1 compare:str2];
    }];
    
    return aryChatContent;
}

//将客户JSON转换为对象数组
+(NSMutableArray*)getCustomerListByJSONArray:(NSArray*)aryCustomerJSONList
{
    if (![aryCustomerJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryCustomerList = [NSMutableArray array];
    for (NSDictionary *dicCustomer in aryCustomerJSONList)
    {
        CustomerVo *model = [[CustomerVo alloc]init];
        [model setValuesForKeysWithDictionary:dicCustomer];
            [aryCustomerList addObject:model];

//        CustomerVo *customerVo = [[CustomerVo alloc]init];
//        id customerId = [dicCustomer objectForKey:@"id"];
//        if (customerId == [NSNull null])
//        {
//            customerVo.strID = @"";
//        }
//        else
//        {
//            customerVo.strID = [customerId stringValue];
//        }
//        
//        customerVo.strName = [Common checkStrValue:[dicCustomer objectForKey:@"customerName"]];
//        customerVo.strHeadImageURL = [Common checkStrValue:[dicCustomer objectForKey:@"headimgurl"]];
//        customerVo.strEmail = [Common checkStrValue:[dicCustomer objectForKey:@"email"]];
//        customerVo.strCode = [Common checkStrValue:[dicCustomer objectForKey:@"customerNumber"]];
//        customerVo.strPhone = [Common checkStrValue:[dicCustomer objectForKey:@"phoneNumber"]];
//        customerVo.strRemark = [Common checkStrValue:[dicCustomer objectForKey:@"remark"]];
//        
//        customerVo.chatObjectVo = nil;
//        id talk = [dicCustomer objectForKey:@"talk"];
//        if (talk != nil && talk != [NSNull null] )
//        {
//            NSMutableArray *aryTalk = [self getSessionListByJSONArray:@[talk]];
//            if (aryTalk.count>0)
//            {
//                customerVo.chatObjectVo = aryTalk[0];
//            }
//        }
//        
    }
    return aryCustomerList;
}

//将知识库JSON转换为对象数组
+(NSMutableArray*)getFAQListByJSONArray:(NSArray*)aryFAQJSONList
{
    if (![aryFAQJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryFAQList = [NSMutableArray array];
    for (NSDictionary *dicFAQ in aryFAQJSONList)
    {
        FAQVo *faqVo = [[FAQVo alloc]init];
        id faqId = [dicFAQ objectForKey:@"id"];
        if (faqId == [NSNull null])
        {
            faqVo.strID = @"";
        }
        else
        {
            faqVo.strID = [faqId stringValue];
        }
        
        faqVo.strTitle = [Common checkStrValue:[dicFAQ objectForKey:@"question"]];
        faqVo.strTextContent = [Common checkStrValue:[dicFAQ objectForKey:@"textContent"]];
        faqVo.strPicUrl = [Common checkStrValue:[dicFAQ objectForKey:@"picUrl"]];
        if (![faqVo.strPicUrl hasPrefix:@"http"])
        {
            faqVo.strPicUrl = [ServerURL getWholeURL:faqVo.strPicUrl];
        }
        
        faqVo.strJumpUrl = [Common checkStrValue:[dicFAQ objectForKey:@"jumpUrl"]];

        [aryFAQList addObject:faqVo];
    }
    return aryFAQList;
}

///////////////////////////////////////////////////////////////////////////////////////
//登录到REST server(获取程序版本信息)
+ (ServerReturnInfo*)loginToRestServer:(NSString*)strLoginPhone andPwd:(NSString*)strPwd
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    retInfo.bSuccess = NO;
    
    if (strLoginPhone == nil || strPwd == nil)
    {
        return retInfo;
    }
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strLoginPhone forKey:@"username"];
    [bodyDic setObject:strPwd forKey:@"password"];
    [bodyDic setObject:@"ios" forKey:@"client_flag"];
    [bodyDic setObject:[Common getDevicePlatform] forKey:@"model"];
    //国际化语言
//    if ([[LanguageManage getCurrLanguage] isEqualToString:@"zh-Hans"])
//    {
        [bodyDic setObject:@"zh" forKey:@"locale"];
//    }
//    else
//    {
//        [bodyDic setObject:@"en" forKey:@"locale"];
//    }
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getLoginToRESTServerURL]];
    [framework loginToRestServer:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断头信息状态
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                //版本号
                retInfo.data = [Common checkStrValue:[responseDic objectForKey:@"version"]];
                
                //登录用户ID
                retInfo.data2 = [Common checkStrValue:[responseDic objectForKey:@"id"]];
                shareModel *model = [shareModel sharedManager];
                model.remindtick = [responseDic objectForKey:@"remindtick"];
                //app update url
                NSString *strAppUpdateURL = [Common checkStrValue:[responseDic objectForKey:@"iospath"]];
                [ServerURL setVersionUpdateURL:strAppUpdateURL];
                
                [Common setUserPwd:strPwd];
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//设置当前登录语言
+ (ServerReturnInfo*)setLanguage:(NSString*)strLanguage
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strLanguage];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSetLanguageURL]];
    [framework startRequestToServerAndNoSesssion:@"GET" andParameter:strBody];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//手机用户登出
+ (ServerReturnInfo*)logoutAction
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getLogoutActionURL]];
    [framework startRequestToServerAndNoSesssion:@"GET" andParameter:nil];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//修改用户密码
+ (void)editUserPassword:(NSString*)strNewPwd andOldPwd:(NSString*)strOldPwd result:(ResultBlock)resultBlock
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
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

//即时聊天/////////////////////////////////////////////////////////////////////////////////////////////////
//1.【微上客】 - 获取会话列表
+(ServerReturnInfo*)getSessionList:(NSInteger)nStatus page:(NSInteger)nPage from:(NSInteger)nFrom
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPage setObject:[NSNumber numberWithInteger:20] forKey:@"pageSize"];
    [bodyDic setObject:dicPage forKey:@"pageInfo"];
    
    [bodyDic setObject:[NSNumber numberWithInteger:nStatus] forKey:@"status"];
    
    //来源
    if(nFrom != 0)
    {
        //非所有
        [bodyDic setObject:[NSNumber numberWithInteger:nFrom] forKey:@"talkOrigin"];
    }
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getHistoryChatSessionURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSArray *arySessionList = (NSArray*)[jsonResult objectForKey:@"content"];
                retInfo.data = [ServerProvider getSessionListByJSONArray:(NSArray*)arySessionList];
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//2.【微上客】- 历史会话详情
+(ServerReturnInfo*)getSessionDetail:(NSString*)strCustomerID endMessageID:(NSString*)strEndMessageID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    
    //分页数据写死，就是在endMessageId数据之前的第一页
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setObject:[NSNumber numberWithInteger:1] forKey:@"pageNumber"];
    [dicPage setObject:[NSNumber numberWithInteger:15] forKey:@"pageSize"];
    [bodyDic setObject:dicPage forKey:@"pageInfo"];
    
    if (strEndMessageID != nil && strEndMessageID.length > 0)
    {
        [bodyDic setObject:strEndMessageID forKey:@"endMessageId"];
    }
    
    [bodyDic setObject:strCustomerID forKey:@"customerId"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSessionDetailURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSMutableArray *aryChatContent = [ServerProvider getSessionDetailByJSONArray:(NSArray*)jsonResult];
                retInfo.data = aryChatContent;
                
                //end message id
                if (aryChatContent.count>0)
                {
                    ChatContentVo *chatContentVo = aryChatContent[0];
                    retInfo.data2 = chatContentVo.strID;
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//3.【微上客】- 发送消息
+(ServerReturnInfo*)sendSessionMessage:(SendChatVo *)sendChatVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    //1.发送附件(图片1，文件2，语音3)
    if (sendChatVo.nContentType == 1)
    {
        ServerReturnInfo *retInfoAttachment = [ServerProvider uploadAttachment:sendChatVo.strFilePath];
        if (retInfoAttachment.bSuccess)
        {
            UploadFileVo *uploadFileVo = retInfoAttachment.data;
            //原图
            NSString *strURL = [NSString stringWithFormat:@"%@%@",uploadFileVo.strPrefix,uploadFileVo.strURL];
            [bodyDic setObject:[ServerURL getWholeURL:strURL] forKey:@"messageUrl"];
        }
        else
        {
            retInfo.strErrorMsg = @"发送失败";
            return retInfo;
        }
    }
    
    //会话ID
    [bodyDic setObject:sendChatVo.strSessionID forKey:@"talkId"];
    
    //类型(文本/图片)
    if (sendChatVo.nContentType == 0)
    {
        [bodyDic setObject:@"text" forKey:@"messageType"];
    }
    else
    {
        [bodyDic setObject:@"image" forKey:@"messageType"];
    }
    
    //消息内容
    if(sendChatVo.strStreamContent == nil || sendChatVo.strStreamContent.length == 0)
    {
        sendChatVo.strStreamContent = @"";
    }
    [bodyDic setObject:sendChatVo.strStreamContent forKey:@"messageContent"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSendSessionMessageURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
                
                NSDictionary *dicMessageJSON = [responseDic objectForKey:@"message"];
                NSArray *aryMessage = [ServerProvider getSessionDetailByJSONArray:@[dicMessageJSON]];
                if (aryMessage.count>0)
                {
                    retInfo.data = aryMessage[0];
                }
                
                //设置error msg
                NSString *strCode = [DNENetworkFramework getErrorCodeBy:responseDic];
                if (![strCode isEqualToString:SERVER_CODE_SUCCESS])
                {
                    retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
                }
            }
        }
    }
    return retInfo;
}

//4.【微上客】- 移交会话
+ (ServerReturnInfo*)transferSession:(NSString *)strSessionID kefu:(NSString*)strKefuID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@/%@",strSessionID,strKefuID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTransferSessionURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
        DLog(@"ERROR!Reason:%@", [framework dneError]);
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//5.【微上客】- 暂停会话
+ (ServerReturnInfo*)suspendSession:(NSString *)strSessionID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strSessionID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSuspendSessionURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
        DLog(@"ERROR!Reason:%@", [framework dneError]);
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//6.【微上客】- 发送评分
+ (ServerReturnInfo*)sendScoreLink:(NSString *)strSessionID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strSessionID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSendScoreLinkURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
        DLog(@"ERROR!Reason:%@", [framework dneError]);
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//7.【微上客】- 关闭会话
+ (ServerReturnInfo*)closeSession:(NSString *)strSessionID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strSessionID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getCloseSessionURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
        DLog(@"ERROR!Reason:%@", [framework dneError]);
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}
//+ (void)uploadPicData:(NSData *)picdata result:(void (^)(ServerReturnInfo *retInfo))result
//{
//    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
//    [bodyDic setObject:@"ios" forKey:@"client_flag"];
//    
//    [VNetworkFramework uploadPicWithUrl:[ServerURL getActivityListURL] andParams:bodyDic andPicData:picdata result:^(id resultObj) {
//        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
//        retInfo.bSuccess = NO;
//        if ([resultObj isKindOfClass:[NSError class]])
//        {
//            //错误
//            result(retInfo);
//        }
//        else
//        {
//            //成功
//            [Digestion replaceInformPicVoKey];
//            InformPicVo *pic = [InformPicVo objectWithKeyValues:resultObj];
//            
//            retInfo.data5 = pic.msg;
//            
//            retInfo.data2 = pic.minImg;
//            retInfo.data = pic.midImg;
//            retInfo.data4 = pic.img;
//            retInfo.data3 = pic.strCode;
//            retInfo.bSuccess = YES;
//            result(retInfo);
//        }
//    }];
//}

//8.【微上客】- 会话状态数量
+ (ServerReturnInfo*)getSessionStatusNum
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSessionStatusNumURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
        DLog(@"ERROR!Reason:%@", [framework dneError]);
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSMutableDictionary *dicStatusNum = [[NSMutableDictionary alloc]init];
                NSArray *aryResponse = (NSArray*)jsonResult;
                for (int i=0; i<aryResponse.count; i++)
                {
                    NSDictionary *dicStatus = [aryResponse objectAtIndex:i];
                    
                    NSString *strKey = @"";
                    id status = [dicStatus objectForKey:@"status"];
                    if (status == [NSNull null])
                    {
                        strKey = @" ";
                    }
                    else 
                    {
                        strKey = [status stringValue];
                    }
                    
                    NSNumber *num;
                    id count = [dicStatus objectForKey:@"count"];
                    if (count == [NSNull null])
                    {
                        num = @0;
                    }
                    else
                    {
                        num = count;
                    }
                    
                    [dicStatusNum setObject:num forKey:strKey];
                }
                
                retInfo.data = dicStatusNum;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//19.获取私聊天里面的所有图片
+(ServerReturnInfo*)getSingleChatImageList:(NSString*)strOtherVestId
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strOtherVestId forKey:@"refId"];
    [bodyDic setObject:@100000 forKey:@"limit"];
    [bodyDic setObject:@1 forKey:@"type"];
    [bodyDic setObject:@"id,filePathUri" forKey:@"requires"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getHistoryChatUserURL]];
    [framework startRequestToChatServer:@"POST" andParameter:bodyDic];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSMutableArray *aryChatContent = [NSMutableArray array];
                NSMutableArray *aryImageURL = [NSMutableArray array];
                NSArray *aryChatJSONList = (NSArray*)jsonResult;
                for (NSDictionary *dicContent in aryChatJSONList)
                {
                    ChatContentVo *chatContentVo = [[ChatContentVo alloc]init];
                    chatContentVo.strCId = [Common checkStrValue:[dicContent objectForKey:@"id"]];
                    
                    //图片
                    chatContentVo.strImgURL = [Common checkStrValue:[dicContent objectForKey:@"filePathUri"]];
                    chatContentVo.strImgURL = [ServerURL getWholeURL:chatContentVo.strImgURL];
                    [aryChatContent addObject:chatContentVo];
                    
                    //URL array
                    NSURL *urlMax = [NSURL URLWithString:chatContentVo.strImgURL];
                    NSURL *urlMin = [NSURL URLWithString:chatContentVo.strImgURL];
                    
                    if (urlMax == nil || urlMin == nil)
                    {
                        continue;
                    }
                    
                    NSArray *ary = @[urlMax,urlMin];
                    [aryImageURL addObject:ary];
                }
                retInfo.data = aryChatContent;
                retInfo.data2 = aryImageURL;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//20.获取群聊天里面的所有图片
+(ServerReturnInfo*)getGroupChatImageList:(ChatObjectVo*)chatObjectVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (chatObjectVo.strGroupID)
    {
        [bodyDic setObject:chatObjectVo.strGroupID forKey:@"refId"];
    }
    if (chatObjectVo.strGroupNodeID)
    {
        [bodyDic setObject:chatObjectVo.strGroupNodeID forKey:@"id"];
    }
    [bodyDic setObject:[Common getCurrentUserVo].strCompanyID forKey:@"orgId"];
    [bodyDic setObject:@100000 forKey:@"limit"];
    [bodyDic setObject:@1 forKey:@"type"];
    [bodyDic setObject:@"id,filePathUri" forKey:@"requires"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getGroupHistoryChatURL]];
    [framework startRequestToChatServer:@"POST" andParameter:bodyDic];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSMutableArray *aryChatContent = [NSMutableArray array];
                NSMutableArray *aryImageURL = [NSMutableArray array];
                NSArray *aryChatJSONList = (NSArray*)jsonResult;
                for (NSDictionary *dicContent in aryChatJSONList)
                {
                    ChatContentVo *chatContentVo = [[ChatContentVo alloc]init];
                    chatContentVo.strCId = [Common checkStrValue:[dicContent objectForKey:@"id"]];
                    
                    //图片
                    chatContentVo.strImgURL = [Common checkStrValue:[dicContent objectForKey:@"filePathUri"]];
                    chatContentVo.strImgURL = [ServerURL getWholeURL:chatContentVo.strImgURL];
                    [aryChatContent addObject:chatContentVo];
                    
                    //URL array
                    NSURL *urlMax = [NSURL URLWithString:chatContentVo.strImgURL];
                    NSURL *urlMin = [NSURL URLWithString:chatContentVo.strImgURL];
                    
                    if (urlMax == nil || urlMin == nil)
                    {
                        continue;
                    }
                    
                    NSArray *ary = @[urlMax,urlMin];
                    [aryImageURL addObject:ary];
                }
                retInfo.data = aryChatContent;
                retInfo.data2 = aryImageURL;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//群组相关////////////////////////////////////////////////////////////////////////
//创建群组
+ (ServerReturnInfo*)createGroup:(GroupVo *)groupVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
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
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getCreateGroupURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
        DLog(@"ERROR!Reason:%@", [framework dneError]);
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                id teamId = [responseDic objectForKey:@"teamId"];
                if (teamId != nil && teamId != [NSNull null])
                {
                    retInfo.data = [teamId stringValue];
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//修改群组(不能修改创建者)
+ (ServerReturnInfo*)editGroup:(GroupVo*)groupVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
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
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getEditGroupURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//加入群组
+ (ServerReturnInfo*)joinGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTeamId forKey:@"teamId"];
    [bodyDic setObject:strUserID forKey:@"userId"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getJoinGroupURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//退出群组
+ (ServerReturnInfo*)exitGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTeamId forKey:@"teamId"];
    [bodyDic setObject:strUserID forKey:@"userId"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getExitGroupURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//解散(删除)群组
+ (ServerReturnInfo*)dismissGroup:(NSString *)strTeamId
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strTeamId];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getDismissGroupURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//转移群组
+ (ServerReturnInfo*)transferGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTeamId forKey:@"id"];
    [bodyDic setObject:strUserID forKey:@"createId"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTransferGroupURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//获取所有的群组
+ (ServerReturnInfo*)getAllGroupList
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryGroupList = nil;
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getAllGroupListURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                aryGroupList = [NSMutableArray array];
                NSArray *aryJSONGroup = [dicResponse objectForKey:@"list"];
                //一级群组
                for (int i=0; i<aryJSONGroup.count; i++)
                {
                    NSDictionary *dicGroupJSON = (NSDictionary*)[aryJSONGroup objectAtIndex:i];
                    GroupVo *groupVo = [[GroupVo alloc]init];
                    id groupId = [dicGroupJSON objectForKey:@"id"];
                    if (groupId == [NSNull null] || groupId == nil)
                    {
                        groupVo.strGroupID = @"";
                    }
                    else
                    {
                        groupVo.strGroupID = [groupId stringValue];
                    }
                    
                    groupVo.strGroupName = [Common checkStrValue:[dicGroupJSON objectForKey:@"teamName"]];
                    groupVo.strGroupDesc = [Common checkStrValue:[dicGroupJSON objectForKey:@"teamDesc"]];
                    groupVo.strGroupImage = [Common checkStrValue:[dicGroupJSON objectForKey:@"imageUrl"]];
                    
                    id isWrite = [dicGroupJSON objectForKey:@"isWrite"];
                    if (isWrite == nil || isWrite == [NSNull null])
                    {
                        groupVo.nAllowSee = -1;
                    }
                    else
                    {
                        groupVo.nAllowSee = [isWrite intValue];
                    }
                    
                    id isOpen = [dicGroupJSON objectForKey:@"isOpen"];
                    if (isOpen == nil || isOpen == [NSNull null])
                    {
                        groupVo.nAllowJoin = -1;
                    }
                    else
                    {
                        groupVo.nAllowJoin = [isOpen intValue];
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
                    groupVo.strCreatorName = [Common checkStrValue:[dicGroupJSON objectForKey:@"createName"]];
                    
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
//                        //将UserList JSON 存放到DB
//                        SBJsonWriter *writer = [SBJsonWriter new];
//                        [SBJsonWriter initialize];
//                        groupVo.strMemListJSON = [writer stringWithObject:aryMember];
                        groupVo.strMemberNum = [NSString stringWithFormat:@"%lu",(unsigned long)aryMember.count];
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
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//获取群组成员
+ (ServerReturnInfo*)getGroupMemberList:(NSString*)strGroupID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryUserList = nil;
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strGroupID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getGroupMemberListURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSArray *aryResponse = (NSArray*)jsonResult;
                aryUserList = [NSMutableArray array];
                for (int i=0; i<aryResponse.count; i++)
                {
                    NSDictionary *dicUser = (NSDictionary*)[aryResponse objectAtIndex:i];
                    //用户详细信息
                    NSDictionary *dicUserInfo = [dicUser objectForKey:@"userInfo"];
                    
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
                    userVo.strRealName = [dicUserInfo objectForKey:@"userName"];
                    
                    //get pinyin
                    NSArray *aryPinyin = [ChineseToPinyin getQPAndJPFromChiniseString:userVo.strRealName];
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
                    
                    userVo.strPosition = [Common checkStrValue:[dicUserInfo objectForKey:@"title"]];
                    userVo.strHeadImageURL = [ServerURL getWholeURL:[Common checkStrValue:[dicUserInfo objectForKey:@"userImgUrl"]]];
                    [aryUserList addObject:userVo];
                }
                retInfo.data = aryUserList;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//////////////////////////////////////////////////////////////////////////////
//同步成员的操作(获取最近更新通讯录列表)
+(ServerReturnInfo*)syncAllMember:(NSString*)strLastUpdateDateTime
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryMemberList = nil;
    NSString *strUpdateDateTime = nil;
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strLastUpdateDateTime forKey:@"updateDate"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSyncAllMemberURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                strUpdateDateTime = [dicResponse objectForKey:@"lastUpdateDate"];
                NSArray *aryJSONUserList = [dicResponse objectForKey:@"userList"];
                if (aryJSONUserList != nil && aryJSONUserList.count>0)
                {
                    aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    retInfo.data = aryMemberList;
    retInfo.data2 = strUpdateDateTime;
    return retInfo;
}

//查询用户详情
+ (ServerReturnInfo*)getUserDetail:(NSString*)strUserID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    UserVo *userVo = nil;
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strUserID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getUserDetailURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                NSDictionary *dicUserInfo =  responseDic;
                if ([dicUserInfo isKindOfClass:[NSDictionary class]])
                {
                    NSMutableArray *aryUserList = [self getUserListByJSONArray:@[dicUserInfo]];
                    if (aryUserList.count>0)
                    {
                        userVo = [aryUserList objectAtIndex:0];
                    }
                    retInfo.data = userVo;
                    retInfo.bSuccess = YES;
                }
            }
        }
    }
    return retInfo;
}

//修改用户密码
+ (ServerReturnInfo*)editUserPassword:(NSString*)strUserID andNewPwd:(NSString*)strNewPwd andOldPwd:(NSString*)strOldPwd
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strUserID forKey:@"id"];
    [bodyDic setObject:strNewPwd forKey:@"plainPassword"];
    [bodyDic setObject:strOldPwd forKey:@"password"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getEditUserPasswordURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//修改用户详情
+ (ServerReturnInfo*)editUserInfo:(UserVo*)userVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    NSString *strImageID = @"";
    //1.头像附件
    if (userVo.bHasHeadImg)
    {
        ServerReturnInfo *retInfoAttachment = [ServerProvider uploadAttachment:userVo.strHeadImgPath];
        if (retInfoAttachment.bSuccess)
        {
            UploadFileVo *uploadFileVo = retInfoAttachment.data;
            strImageID = uploadFileVo.strID;
        }
        else
        {
            retInfo.strErrorMsg = @"上传用户头像失败";
            return retInfo;
        }
    }
    
    //发送JSON数据
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strSignature] forKey:@"selfIntroduction"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strPhoneNumber] forKey:@"phoneNumber"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.gender] forKey:@"sex"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strBirthday] forKey:@"birthday"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strEmail] forKey:@"email"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.nickName ] forKey:@"aliasName"];
    
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strSeniority] forKey:@"workingYears"];
    
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strCompanyName] forKey:@"company"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strRealName ] forKey:@"name"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strEducation] forKey:@"education"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strNation] forKey:@"nation"];
     [bodyDic setObject:[ServerProvider JudgeStrIsEmpty:userVo.strHouseHold] forKey:@"householdRegister"];
    [bodyDic setObject:[ServerProvider JudgeStrIsEmpty: userVo.strSchool] forKey:@"graduationSchool"];
    [bodyDic setObject:@"houzhengming3" forKey:@"userLoginName"];
    
//    
//    
//    
//    
//    
////    [bodyDic setObject:userVo.strAddress forKey:@"address"];
////    [bodyDic setObject:userVo.strReceiveMessage forKey:@"receiveMessage"];//是否接收推送消息
//    
//    if (userVo.bHasHeadImg)
//    {
//        [bodyDic setObject:strImageID forKey:@"imageId"];
//    }
//    NSDictionary *bodyDic = @{@"userLoginName":@"houzhengming3",@"plainPassword":@"123456",@"phoneNumber":@"155651223",@"aliasName":@"NS6",@"name":@"测试6",@"education":@"本科",@"workingYears":@"4",@"company":@"公司1",@"selfIntroduction":@"介绍6",@"email":@"houzm1@visionet.com.cn"};
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//  [manager POST:[ServerURL getEditUserInfoURL] parameters:bodyDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//      NSLog(@"%@",responseObject);
//      
//  } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//      NSLog(@"%@",error);
//      
//  }];
//    AFHTTPRequestOperationManager *manager11 = [AFHTTPRequestOperationManager manager];
//    manager11.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager11 POST:@"http://vn-functional.chinacloudapp.cn/wsk-ns/api/mobile/user/update" parameters:bodyDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        NSLog(@"%@",responseObject);
//
//    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//
//    }];
    
    
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getEditUserInfoURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}
+ (NSString *)JudgeStrIsEmpty:(NSString *)string{
    if (string.length == 0 || string == nil || string == NULL) {
        return @" ";
    }
    return string;
}

//我关注的用户列表
+(ServerReturnInfo*)getMyAttentionUserList:(int)nPage
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryMemberList = nil;
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:[NSString stringWithFormat:@"%i",nPage] forKey:@"pageNumber"];
    [dicPageInfo setObject:@10 forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getMyAttentionUserListURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                NSArray *aryJSONUserList = [dicResponse objectForKey:@"content"];
                if (aryJSONUserList != nil && aryJSONUserList.count>0)
                {
                    aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    retInfo.data = aryMemberList;
    return retInfo;
}

//我关注的所有用户列表（不分页）
+(ServerReturnInfo*)getAllMyAttentionUserList
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryMemberList = nil;
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:@"1" forKey:@"pageNumber"];
    [dicPageInfo setObject:@1000000 forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getMyAttentionUserListURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                NSArray *aryJSONUserList = [dicResponse objectForKey:@"content"];
                if (aryJSONUserList != nil && aryJSONUserList.count>0)
                {
                    aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    retInfo.data = aryMemberList;
    return retInfo;
}

//获取积分排行前30的用户
+(ServerReturnInfo*)getIntegrationSort
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryMemberList = nil;
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getIntegrationSortURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSArray *aryJSONUserList = (NSArray*)jsonResult;
                if (aryJSONUserList != nil && aryJSONUserList.count>0)
                {
                    aryMemberList = [self getUserListByJSONArray:aryJSONUserList];
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    retInfo.data = aryMemberList;
    return retInfo;
}

//增加或取消关注(bAttention:YES 增加关注,NO 取消关注)
+ (ServerReturnInfo*)attentionUserAction:(BOOL)bAttention andOtherUserID:(NSString*)strUserID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strUserID];
    
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
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:strURL];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}
+ (ServerReturnInfo*)toGetTheCompanyName
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    NSString *strURL =[ServerURL getToGetTheCompanyName];
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:strURL];
    
    [framework startRequestToServer:@"POST" andParameter:@{}];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                NSMutableArray *arycomNameList = [NSMutableArray array];
                NSArray *aryJSONCustomer = [responseDic objectForKey:@"content"];
                if (aryJSONCustomer != nil && aryJSONCustomer.count>0)
                {
                    arycomNameList = [self getCustomerListByJSONArray:aryJSONCustomer];
                }
                retInfo.data = arycomNameList;
                
                //获取数据总数（用于停止刷新）
                id totalElements = [responseDic objectForKey:@"totalElements"];
                if (totalElements != [NSNull null] && totalElements != nil)
                {
                    retInfo.data2 = totalElements;
                }
                else
                {
                    retInfo.data2 = nil;
                }
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}
//发送用于获取激活的验证码
+ (ServerReturnInfo*)sendIdentifyingCode:(NSString *)strPhoneNum
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strURL =[ServerURL getSendIdentifyingCodeURL];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:strURL];

    [framework startRequestToServer:@"POST" andParameter:@{@"email":strPhoneNum,@"emailType":@"1"}];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
                retInfo.data2 = responseDic[@"code"];
                retInfo.data = responseDic[@"msg"];
            }
        }
    }
    return retInfo;
}
+ (void)startFormData:(NSString *)urlString parms:(NSDictionary *)bodDic result:(void (^)(ServerReturnInfo *retInfo))result{
    //    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://api.map.baidu.com/geodata/v3/poi/create" parameters:dic error:nil];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:bodDic error:nil];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        
        if (error) {
            NSLog(@"Error: %@", error);
            retInfo.bSuccess = NO;
            retInfo.data = responseObject;
            retInfo.data2 = response;
            return;
        }
        retInfo.bSuccess = YES;
        retInfo.data = responseObject;
        retInfo.data2 = response;
        result(retInfo);
        NSLog(@"%@ %@", response, responseObject);
        
    }];
    [dataTask resume];
    
    
}

//激活
+ (ServerReturnInfo*)registerUserAction:(UserVo*)userVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:userVo.strLoginAccount forKey:@"userLoginName"];
    [bodyDic setObject:userVo.strPassword forKey:@"plainPassword"];
    [bodyDic setObject:userVo.strEmail forKey:@"email"];
    [bodyDic setObject:userVo.aliasName forKey:@"nickName"];
    [bodyDic setObject:userVo.strPhoneNumber forKey:@"phoneNumber"];
    [bodyDic setObject:userVo.strRealName forKey:@"name"];
    [bodyDic setObject:userVo.strIdentifyCode forKey:@"emailCode"];
    [bodyDic setObject:userVo.strEducation forKey:@"education"];
    [bodyDic setObject:userVo.strCompanyName forKey:@"company"];
    [bodyDic setObject:userVo.strCompanyID forKey:@"companyId"];
    [bodyDic setObject:userVo.strSeniority forKey:@"workingYears"];
    [bodyDic setObject:userVo.strSignature forKey:@"selfIntroduction"];
    if (![shareModel sharedManager].isHe) {
        [bodyDic setObject:[NSString stringWithFormat:@"%f,%f",[shareModel sharedManager].longitude,[shareModel sharedManager].latitude] forKey:@"lastCoordinate"];

    }
        if (userVo.gender==0)
    {
        [bodyDic setObject:@"女" forKey:@"sex"];
    }else
    {
        [bodyDic setObject:@"男" forKey:@"sex"];
    }
    
    if (userVo.strBirthday != nil && userVo.strBirthday.length > 0)
    {
        [bodyDic setObject:userVo.strBirthday forKey:@"birthday"];
    }
    
    if (userVo.strNation != nil && userVo.strNation.length > 0)
    {
        [bodyDic setObject:userVo.strNation forKey:@"nation"];
    }
    if (userVo.strHouseHold != nil && userVo.strHouseHold.length > 0)
    {
        [bodyDic setObject:userVo.strHouseHold forKey:@"householdRegister"];
    }
    if (userVo.strSchool != nil && userVo.strSchool.length > 0)
    {
        [bodyDic setObject:userVo.strSchool forKey:@"graduationSchool"];
    }
//    NSDictionary *dic = @{
//                          @"userLoginName":userVo.strLoginAccount,
//                          @"email":userVo.strEmail,
//                          @"name":@"hongqi",
//                          @"emailCode":userVo.strIdentifyCode,
//                          @"plainPassword":@"qqqqqq",
//                          @"aliasName":@"账上",
//                          @"phoneNumber":userVo.strPhoneNumber,@"education":@"本科",@"workingYears":@"3",@"selfIntroduction":@"12312312",
//                          @"company":userVo.strCompanyName,@"companyId":userVo.strCompanyID};
//    VNetworkFramework *SERVER = [[VNetworkFramework alloc]initWithURLString:[ServerURL getRegisterUserURL]];
//    [SERVER startRequestToServer:@"POST" parameter:dic result:^(id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"%@",error);
//        }else{
//            NSLog(@"===========%@",dic);
//            NSLog(@"%@",responseObject);
//        }
//    }];
//    
//    NSLog(@"字典一%@ -------------字典二%@",dic,bodyDic);
//    NSLog(@"%d",(dic == bodyDic));
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getRegisterUserURL]];
    [framework startRequestToServerAndNoSesssion:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//发送用于获取找回密码的验证码
+ (ServerReturnInfo*)sendChangePwdIdentifyingCode:(NSString *)strPhoneNum
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
//    NSString *strURL = [NSString stringWithFormat:@"%@",[ServerURL getSendIdentifyingCodeURL]];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSendIdentifyingCodeURL]];
    
    [framework startRequestToServerAndNoSesssion:@"POST" andParameter:@{@"email":strPhoneNum,@"emailType":@"2"}];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
                retInfo.data = responseDic[@"msg"];
                retInfo.data2 = responseDic[@"code"];
            }
        }
    }
    return retInfo;
}

//重置登录密码
+ (ServerReturnInfo*)resetLoginPwd:(NSString*)strLoginName andPwd:(NSString*)strPwd andIdentifyingCode:(NSString*)strCode
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strLoginName forKey:@"email"];
    [bodyDic setObject:strPwd forKey:@"plainPassword"];
    [bodyDic setObject:strCode forKey:@"emailCode"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getChangePasswordURL]];
    [framework startRequestToServerAndNoSesssion:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//通知提醒/////////////////////////////////////////////////////////
//1.所有提醒分类数量
+ (ServerReturnInfo*)getAllNotifyTypeUnreadNum
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    NSMutableArray *aryNotifyTypeNum = [NSMutableArray array];
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getNoticeNumURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                if ([responseDic isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dicNotifyNum = responseDic;
                    //0.消息总数
                    id allRemindCount = [dicNotifyNum objectForKey:@"allRemindCount"];
                    if (allRemindCount == [NSNull null] || allRemindCount == nil)
                    {
                        [aryNotifyTypeNum addObject:@"0"];
                    }
                    else
                    {
                        [aryNotifyTypeNum addObject:[allRemindCount stringValue]];
                    }
                    
                    //1.我的提醒数量
                    id MYSELF = [dicNotifyNum objectForKey:@"MYSELF"];
                    if (MYSELF == [NSNull null] || MYSELF == nil)
                    {
                        [aryNotifyTypeNum addObject:@"0"];
                    }
                    else
                    {
                        [aryNotifyTypeNum addObject:[MYSELF stringValue]];
                    }
                    
                    //2.群组提醒数量
                    id TEAM = [dicNotifyNum objectForKey:@"TEAM"];
                    if (TEAM == nil || TEAM == [NSNull null])
                    {
                        [aryNotifyTypeNum addObject:@"0"];
                    }
                    else
                    {
                        [aryNotifyTypeNum addObject:[TEAM stringValue]];
                    }
                    
                    //3.未读消息数量
                    id unreadNum = [dicNotifyNum objectForKey:@"unreadNum"];
                    if (unreadNum == nil || (id)unreadNum == [NSNull null])
                    {
                        [aryNotifyTypeNum addObject:@"0"];
                    }
                    else
                    {
                        [aryNotifyTypeNum addObject:[unreadNum stringValue]];
                    }
                }
                
                retInfo.data = aryNotifyTypeNum;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//2.我的提醒列表
+ (ServerReturnInfo*)getMyNotifyList:(int)nPageNum
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryNotifyList = [NSMutableArray array];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:[NSString stringWithFormat:@"%i",nPageNum] forKey:@"page"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getMyNotifyListURL]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSDictionary *dicResponse = (NSDictionary*)jsonResult;
                id content = [dicResponse objectForKey:@"content"];
                if (content != [NSNull null] && content != nil)
                {
                    NSArray *aryResponse = (NSArray*)content;
                    for (int i=0; i<aryResponse.count; i++)
                    {
                        NSDictionary *dicNotify = (NSDictionary*)[aryResponse objectAtIndex:i];
                        NotifyVo *notifyVo = [[NotifyVo alloc]init];
                        notifyVo.strID = [[dicNotify objectForKey:@"id"]stringValue];
                        
                        id sendId = [dicNotify objectForKey:@"sendId"];
                        if (sendId == [NSNull null])
                        {
                            notifyVo.strFromUserID = @"";
                        }
                        else
                        {
                            notifyVo.strFromUserID = [sendId stringValue];
                        }
                        
                        id strRefID = [dicNotify objectForKey:@"refId"];
                        if (strRefID == [NSNull null])
                        {
                            notifyVo.strRefID = @"";
                        }
                        else
                        {
                            notifyVo.strRefID = [strRefID stringValue];
                        }
                        notifyVo.strFromUserName = [Common checkStrValue:[dicNotify objectForKey:@"userNickname"]];//sendName
                        notifyVo.strDescription = [Common checkStrValue:[dicNotify objectForKey:@"description"]];
                        notifyVo.strAssistContent = [Common checkStrValue:[dicNotify objectForKey:@"assistContent"]];
                        notifyVo.strLinkHtml = [Common checkStrValue:[dicNotify objectForKey:@"linkHtml"]];
                        notifyVo.strUserImgUrl = [ServerURL getWholeURL:[Common checkStrValue:[Common checkStrValue:[dicNotify objectForKey:@"userImgUrl"]]]];
                        notifyVo.strCreateDate = [Common checkStrValue:[dicNotify objectForKey:@"createDate"]];
                        notifyVo.strTitleID = [Common checkStrValue:[dicNotify objectForKey:@"titleId"]];
                        
                        id type = [dicNotify objectForKey:@"type"];
                        if (type == [NSNull null])
                        {
                            notifyVo.notifyMainType = -1;
                        }
                        else
                        {
                            notifyVo.notifyMainType = [type intValue];
                        }
                        
                        id subclass = [dicNotify objectForKey:@"subclass"];
                        if (subclass == [NSNull null])
                        {
                            notifyVo.notifySubType = -1;
                        }
                        else
                        {
                            notifyVo.notifySubType = [subclass intValue];
                        }
                        
                        id unread = [dicNotify objectForKey:@"unread"];
                        if (unread == [NSNull null])
                        {
                            notifyVo.nReadState = -1;
                        }
                        else
                        {
                            notifyVo.nReadState = [unread intValue];
                        }
                        
                        [aryNotifyList addObject:notifyVo];
                    }
                }
                
                retInfo.data = aryNotifyList;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//3.群组提醒列表
+ (ServerReturnInfo*)getGroupNotifyList:(int)nPageNum
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    NSMutableArray *aryNotifyList = [NSMutableArray array];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:[NSString stringWithFormat:@"%i",nPageNum] forKey:@"page"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getGroupNotifyListURL]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSDictionary *dicResponse = (NSDictionary*)jsonResult;
                id content = [dicResponse objectForKey:@"content"];
                if (content != [NSNull null] && content != nil)
                {
                    NSArray *aryResponse = (NSArray*)content;
                    for (int i=0; i<aryResponse.count; i++)
                    {
                        NSDictionary *dicNotify = (NSDictionary*)[aryResponse objectAtIndex:i];
                        NotifyVo *notifyVo = [[NotifyVo alloc]init];
                        notifyVo.strID = [[dicNotify objectForKey:@"id"]stringValue];
                        
                        id sendId = [dicNotify objectForKey:@"sendId"];
                        if (sendId == [NSNull null])
                        {
                            notifyVo.strFromUserID = @"";
                        }
                        else
                        {
                            notifyVo.strFromUserID = [sendId stringValue];
                        }
                        
                        notifyVo.strFromUserName = [Common checkStrValue:[dicNotify objectForKey:@"sendName"]];
                        notifyVo.strDescription = [Common checkStrValue:[dicNotify objectForKey:@"description"]];
                        notifyVo.strAssistContent = [Common checkStrValue:[dicNotify objectForKey:@"assistContent"]];
                        notifyVo.strLinkHtml = [Common checkStrValue:[dicNotify objectForKey:@"linkHtml"]];
                        notifyVo.strUserImgUrl = [ServerURL getWholeURL:[Common checkStrValue:[dicNotify objectForKey:@"userImgUrl"]]];
                        notifyVo.strCreateDate = [Common checkStrValue:[dicNotify objectForKey:@"createDate"]];
                        
                        id type = [dicNotify objectForKey:@"type"];
                        if (type == [NSNull null])
                        {
                            notifyVo.notifyMainType = -1;
                        }
                        else
                        {
                            notifyVo.notifyMainType = [type intValue];
                        }
                        
                        id subclass = [dicNotify objectForKey:@"subclass"];
                        if (subclass == [NSNull null])
                        {
                            notifyVo.notifySubType = -1;
                        }
                        else
                        {
                            notifyVo.notifySubType = [subclass intValue];
                        }
                        
                        id unread = [dicNotify objectForKey:@"unread"];
                        if (unread == [NSNull null])
                        {
                            notifyVo.nReadState = -1;
                        }
                        else
                        {
                            notifyVo.nReadState = [unread intValue];
                        }
                        
                        id strRefID = [dicNotify objectForKey:@"refId"];
                        if (strRefID == [NSNull null])
                        {
                            notifyVo.strRefID = @"";
                        }
                        else
                        {
                            notifyVo.strRefID = [strRefID stringValue];
                        }
                        [aryNotifyList addObject:notifyVo];
                    }
                }
                retInfo.data = aryNotifyList;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//5.设置某一类型的消息为已读
+ (ServerReturnInfo*)setNotifyTypeToRead:(int)nType
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%i",nType];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSetNotifyTypeToReadURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//设置某一条的消息为已读
+ (ServerReturnInfo*)setTheNoticeToRead:(NSString*)strNoticeID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strNoticeID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSetTheNoticeToReadURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//6.设置所有的消息为已读
+ (ServerReturnInfo*)setAllNotifyToRead
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSetAllNotifyToReadURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//上传附件
+ (ServerReturnInfo*)uploadAttachment:(NSString *)path
{
    ServerReturnInfo *returnInfo = [[ServerReturnInfo alloc] init];
    returnInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    NSDictionary *dicResult = [framework uploadFileToServer:path];
    
    if (dicResult == nil)
    {
        returnInfo.strErrorMsg = [Common localStr:@"Common_Attachment_Failure" value:@"上传附件失败！"];
    }
    else
    {
        UploadFileVo *uplaodFileVo = [[UploadFileVo alloc]init];
        uplaodFileVo.strID = [Common checkStrValue:[dicResult objectForKey:@"msg"]];
        uplaodFileVo.strPrefix = [Common checkStrValue:[dicResult objectForKey:@"prefix"]];
        uplaodFileVo.strFileType = [Common checkStrValue:[dicResult objectForKey:@"sign"]];
        if ([uplaodFileVo.strFileType isEqualToString:@"image"])
        {
            //上传图片
            //a:原图
            uplaodFileVo.strURL = [Common checkStrValue:[dicResult objectForKey:@"img"]];
            
            //b:中图
            uplaodFileVo.strMidURL = [Common checkStrValue:[dicResult objectForKey:@"img-mid"]];
            
            //c:小图
            uplaodFileVo.strMinURL = [Common checkStrValue:[dicResult objectForKey:@"img-min"]];
        }
        else if ([uplaodFileVo.strFileType isEqualToString:@"document"])
        {
            uplaodFileVo.strURL = [Common checkStrValue:[dicResult objectForKey:@"filePath"]];
        }
        else
        {
            uplaodFileVo.strURL = [Common checkStrValue:[dicResult objectForKey:@"img"]];
        }
        returnInfo.bSuccess = YES;
        returnInfo.data = uplaodFileVo;
    }
    return returnInfo;
}

//标签/////////////////////////////////////////////////////////
//查询标签列表(M：消息标签；U：特殊标签 ；F：FAQ标签；W：工单标签)
+(ServerReturnInfo *)getTagVoListByType:(NSString*)strType
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strType forKey:@"tagType"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTagVoListByTypeURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                retInfo.data = [ServerProvider getTagListByJSONArray:jsonResult];
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//客服模块/////////////////////////////////////////////////////////
+(ServerReturnInfo*)getAllOnLineKefu
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getAllOnLineKefuURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                retInfo.data = [self getUserListByJSONArray:jsonResult];
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//客户模块/////////////////////////////////////////////////////////
//1.客户列表
+(ServerReturnInfo*)getCustomerList:(NSString*)strSearchText page:(NSInteger)nPage pageSize:(NSInteger)nSize
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPage setObject:[NSNumber numberWithInteger:nSize] forKey:@"pageSize"];
    [dicBody setObject:dicPage forKey:@"pageInfo"];
    
    if (strSearchText != nil && strSearchText.length>0)
    {
        [dicBody setObject:strSearchText forKey:@"queryName"];
    }
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getCustomerList]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                NSMutableArray *aryMemberList = [NSMutableArray array];
                NSArray *aryJSONCustomer = [dicResponse objectForKey:@"content"];
                if (aryJSONCustomer != nil && aryJSONCustomer.count>0)
                {
                    aryMemberList = [self getCustomerListByJSONArray:aryJSONCustomer];
                }
                retInfo.data = aryMemberList;
                
                //获取数据总数（用于停止刷新）
                id totalElements = [dicResponse objectForKey:@"totalElements"];
                if (totalElements != [NSNull null] && totalElements != nil)
                {
                    retInfo.data2 = totalElements;
                }
                else
                {
                    retInfo.data2 = nil;
                }
                
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//2.客户详情
+ (ServerReturnInfo*)getCustomerDetail:(NSString*)strID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getCustomerDetailURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                CustomerVo *customerVo = nil;
                if ([responseDic isKindOfClass:[NSDictionary class]])
                {
                    NSMutableArray *aryCustomerList = [self getCustomerListByJSONArray:@[responseDic]];
                    if (aryCustomerList.count>0)
                    {
                        customerVo = [aryCustomerList objectAtIndex:0];
                    }
                    retInfo.data = customerVo;
                    retInfo.bSuccess = YES;
                }
            }
        }
    }
    return retInfo;
}

//3.更新客户信息
+ (ServerReturnInfo*)updateCustomer:(CustomerVo*)customerVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    [dicBody setObject:customerVo.strID forKey:@"id"];
    [dicBody setObject:customerVo.strName forKey:@"customerName"];
    [dicBody setObject:customerVo.strCode forKey:@"customerNumber"];
    [dicBody setObject:customerVo.strPhone forKey:@"phoneNumber"];
    [dicBody setObject:customerVo.strEmail forKey:@"email"];
    [dicBody setObject:customerVo.strHeadImageURL forKey:@"headimgurl"];
    [dicBody setObject:customerVo.strRemark forKey:@"remark"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getUpdateCustomerURL]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//知识库模块/////////////////////////////////////////////////////////
+(ServerReturnInfo*)getFAQList:(NSString*)strSearchText page:(NSInteger)nPage pageSize:(NSInteger)nPageSize
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setObject:[NSNumber numberWithInteger:nPage] forKey:@"pageNumber"];
    [dicPage setObject:[NSNumber numberWithInteger:nPageSize] forKey:@"pageSize"];
    [dicBody setObject:dicPage forKey:@"pageInfo"];
    
    if (strSearchText != nil && strSearchText.length>0)
    {
        [dicBody setObject:strSearchText forKey:@"content"];
    }
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getFAQListURL]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                NSMutableArray *aryFAQList = [NSMutableArray array];
                NSArray *aryJSONFAQ = [dicResponse objectForKey:@"content"];
                if (aryJSONFAQ != nil && aryJSONFAQ.count>0)
                {
                    aryFAQList = [self getFAQListByJSONArray:aryJSONFAQ];
                }
                retInfo.data = aryFAQList;
                
                //获取数据总数（用于停止刷新）
                id totalElements = [dicResponse objectForKey:@"totalElements"];
                if (totalElements != [NSNull null] && totalElements != nil)
                {
                    retInfo.data2 = totalElements;
                }
                else
                {
                    retInfo.data2 = nil;
                }
                
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//知识库 - 发送富文本
+(ServerReturnInfo*)sendRichFAQ:(NSString *)strFAQID customerID:(NSString*)strCustomerID sessionID:(NSString*)strSessionID orign:(NSString*)strChatFrom
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@/%@/%@/%@",strFAQID,strCustomerID,strSessionID,strChatFrom];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSendRichFAQ]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *responseDic = [framework getResponseDic];
        if(responseDic == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
            }
            else
            {
                retInfo.bSuccess = YES;
                
                NSDictionary *dicMessageJSON = [responseDic objectForKey:@"message"];
                NSArray *aryMessage = [ServerProvider getSessionDetailByJSONArray:@[dicMessageJSON]];
                if (aryMessage.count>0)
                {
                    retInfo.data = aryMessage[0];
                }
                
                //设置error msg
                NSString *strCode = [DNENetworkFramework getErrorCodeBy:responseDic];
                if (![strCode isEqualToString:SERVER_CODE_SUCCESS])
                {
                    retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:responseDic];
                }
            }
        }
    }
    return retInfo;
}
+ (ServerReturnInfo *)getTicketTypeGetArray:(NSString *)malfunctionId detailId:(NSString *)detailId{
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
     retInfo.bSuccess = NO;
//    NSDictionary *dicBody = @{@"malfunctionId":malfunctionId,@"detailId":detailId,@"no":@"3",@"detailContent":@"detailContent",@"result":@"result",@"updateUserCd":@"606",@"percentage":@"64"};

        NSDictionary *dicBody = @{@"malfunctionId":malfunctionId,@"detailId":detailId,@"pageNo":@"1",@"lines":@"20"};

     [framework setURL:[ServerURL getWODeatilArray]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSArray *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                
                NSLog(@"%@",dicResponse);
                retInfo.data = dicResponse;
                
                retInfo.bSuccess = YES;
            }
        }
    }
    
    
    return retInfo;

}
+ (void)uploadPicData:(NSData *)picdata result:(void (^)(ServerReturnInfo *retInfo))result
{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@"ios" forKey:@"client_flag"];
    
    [DNENetworkFramework uploadPicWithUrl:[ServerURL setRecordImageURL] andParams:bodyDic andPicData:picdata result:^(id resultObj) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        retInfo.bSuccess = NO;
        if ([resultObj isKindOfClass:[NSError class]])
        {
            //错误
            result(retInfo);
        }
        else
        {
            //成功
        
            InformPicVo *pic = [InformPicVo objectWithKeyValues:resultObj];
            
            retInfo.data5 = pic.msg;
            
            retInfo.data2 = pic.minImg;
            retInfo.data = pic.midImg;
            retInfo.data4 = pic.img;
            retInfo.data3 = pic.strCode;
            retInfo.bSuccess = YES;
            result(retInfo);
        }
    }];
}
+ (ServerReturnInfo *)uploadPicData:(NSData *)picdata params:(NSDictionary *)dictionary{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@"ios" forKey:@"client_flag"];
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
     retInfo.bSuccess = NO;
           NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH-ss-mm"];
            NSString *dateString = [formatter stringFromDate:date];
             NSString *urlString = [[ServerURL setRecordImageURL] stringByAppendingString:[dateString stringByAppendingString:@".png"]];
    [DNENetworkFramework uploadPicWithUrl:urlString andParams:bodyDic andPicData:picdata result:^(id resultObj) {
        
        
        if ([resultObj isKindOfClass:[NSError class]])
        {
            //错误
            retInfo.strErrorMsg = ERROR_TO_SERVER;

        }
        else
        {
            //成功
//            [Digestion replaceInformPicVoKey];
//            InformPicVo *pic = [InformPicVo objectWithKeyValues:resultObj];
//            
//            retInfo.data5 = pic.msg;
//            
//            retInfo.data2 = pic.minImg;
//            retInfo.data = pic.midImg;
//            retInfo.data4 = pic.img;
//            retInfo.data3 = pic.strCode;
            retInfo.bSuccess = YES;
//            result(retInfo);
        }
    }];
    return retInfo;
}

+ (ServerReturnInfo *)setTicketTypeListRecord:(NSString *)malfunctionId detailId:(NSString *)detailId  percentage:(NSString *)percentage detailContent:(NSString *)detailContent no:(NSString *)no  updateUserCd:(NSString *)updateUserCd guestId:(NSString *)guestId{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    if (!percentage) {
        percentage = @"0";
    }
    NSDictionary *dic = @{@"malfunctionId":malfunctionId,@"detailId":detailId,@"detailContent":detailContent,@"percentage":percentage,@"no":no,@"result":@"result",@"updateUserCd":updateUserCd};
    
    NSMutableDictionary *dicBody = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    
    
    
    [framework setURL:[ServerURL setRecordURL]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSArray *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                
                NSLog(@"%@",dicResponse);
                retInfo.data = dicResponse;
                
                retInfo.bSuccess = YES;
            }
        }
    }
    
    
    return retInfo;

}
+ (BOOL)isNullToString:(id)string
    {
        if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"])
        {
            return YES;
            
            
        }else
        {
            
            return NO;
        }
    }

+ (ServerReturnInfo *)setTicketTypeListDetail:(NSString *)malfunctionId detailId:(NSString *)detailId detailStatus:(NSString *)detailStatus percentage:(NSString *)percentage judgement:(NSString *)judgement boolJudge:(BOOL)isHe guestId:(NSString *)guestId model:(TijiaoModel *)model PINCD:(NSString *)pinCd{
    if (guestId==nil) {
                    guestId = @" ";
    }
    if ([ServerProvider isNullToString:pinCd]) {
        pinCd = @"";
    }
    NSDictionary *dic1 = @{@"malfunctionId":malfunctionId,@"detailId":detailId,@"detailStatus":detailStatus,@"percentage":percentage,@"judgement":judgement,@"guestId":guestId,@"pinCd":pinCd};
    
    NSDictionary *dic2 = @{@"malfunctionId":malfunctionId,@"detailId":detailId,@"no":model.no,@"detailContent":@"完成",@"percentage":percentage,@"result":@"result",@"updateUserCd":[Common getCurrentUserVo].strUserID,@"guestId":guestId};
    
    NSMutableDictionary *dicBody = [NSMutableDictionary dictionaryWithDictionary:@{@"finishData":dic1,@"recordLast":dic2}];

    
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
//    NSDictionary *dic = @{@"malfunctionId":malfunctionId,@"detailId":detailId,@"detailStatus":detailStatus,@"percentage":percentage,@"judgement":judgement};
//    NSMutableDictionary *dicBody = [NSMutableDictionary dictionaryWithDictionary:dic];
//    if (isHe) {
//        if (guestId==nil) {
//            guestId = @" ";
//        }
//        [dicBody setObject:guestId forKey:@"guestId"];
//    }

    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
   
    
    
    [framework setURL:[ServerURL  commentWork]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSArray *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                
                NSLog(@"%@",dicResponse);
                retInfo.data = dicResponse;
                
                retInfo.bSuccess = YES;
            }
        }
    }
    
    
    return retInfo;

}
+ (ServerReturnInfo *)getTicketTypeListDetail:(NSString *)malfunctionId detailId:(NSString *)detailId boolIS:(BOOL)isAttachment{
     DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:malfunctionId forKey:@"malfunctionId"];
    [dicBody setObject:detailId forKey:@"detailId"];
    if (isAttachment) {
        [dicBody setObject:@"02" forKey:@"type"];
         [framework setURL:[ServerURL getWOImage]];
    }else{
        
         [framework setURL:[ServerURL getWODEDetailUR]];
    }
    
   
   
    [framework startRequestToServer:@"POST" andParameter:dicBody];

    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSArray *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
   
                NSLog(@"%@",dicResponse);
                retInfo.data = dicResponse;
                
                retInfo.bSuccess = YES;
            }
        }
    }

    
    return retInfo;
}
+ (ServerReturnInfo *)getTicketList:(NSString *)strSearch page:(NSInteger)nPage pageSize:(NSInteger)nSize status:(NSString *)strStatus type:(NSString *)strType difficulty:(NSString *)strDifficulty title:(NSString *)title
//工单模块/////////////////////////////////////////////////////////

{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:[NSString stringWithFormat:@"%li",(unsigned long)nPage] forKey:@"pageNo"];
    [dicBody setObject:[NSString stringWithFormat:@"%li",(unsigned long)nSize] forKey:@"lines"];
    if ([title isEqualToString:@"未解决工单"]) {
        [dicBody setObject:@"0" forKey:@"detailStatus"];
    }
    if ([title isEqualToString:@"已解决工单"]) {
         [dicBody setObject:@"1" forKey:@"detailStatus"];
    }
//    if ([title isEqualToString:@"可抢工单"]) {
//        [dicBody setObject:@"01" forKey:@"orderType"];
//    }
    
    //检索内容
    if (strSearch.length>0)
    {
        [dicBody setObject:strSearch forKey:@"searchContent"];
    }
    
    //难易度
    if (strDifficulty.length > 0)
    {
        [dicBody setObject:strDifficulty forKey:@"difficulty"];
    }
    
    //故障分类
    if (strType.length > 0)
    {
        [dicBody setObject:strType forKey:@"classification"];
    }
    
    //对应状态
    if (strStatus.length > 0)
    {
        [dicBody setObject:strStatus forKey:@"detailStatus"];
    }
    
    //工程师ID
    [dicBody setObject:[Common getCurrentUserVo].strUserID forKey:@"engId"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTicketListURL]];
    [framework startRequestToServer:@"POST" andParameter:dicBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSArray *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                
//                NSMutableArray *aryList;
                NSLog(@"%@",dicResponse);
                retInfo.data = dicResponse;
//                NSArray *aryJSON = [dicResponse objectForKey:@"content"];
//                if (aryJSON != nil && aryJSON.count>0)
//                {
//                    aryList = [self getTicketListByJSONArray:aryJSON];
//                }
//                retInfo.data = aryList;
//                
//                //获取数据总数（用于停止刷新）
//                id totalElements = [dicResponse objectForKey:@"totalElements"];
//                if (totalElements != [NSNull null] && totalElements != nil)
//                {
//                    retInfo.data2 = totalElements;
//                }
//                else
//                {
//                    retInfo.data2 = nil;
//                }
//                
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//查询工单明细
+(ServerReturnInfo*)getTicketDetail:(NSString*)strTicketID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strTicketID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTicketDetailURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                NSMutableArray *aryList = [self getTicketListByJSONArray:@[dicResponse]];
                if (aryList.count>0)
                {
                    retInfo.data = aryList[0];
                    retInfo.bSuccess = YES;
                }
                else
                {
                    retInfo.strErrorMsg = ERROR_TO_SERVER;
                    retInfo.bSuccess = NO;
                }
            }
        }
    }
    return retInfo;
}

//查询工单类型
+(ServerReturnInfo*)getTicketTypeList
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTicketTypeListURL]];
    [framework startRequestToServer:@"GET" andParameter:nil];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        id jsonResult = [framework getResponseDic];
        if(jsonResult == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:jsonResult];
            }
            else
            {
                NSArray *aryJson = jsonResult;
                NSMutableArray *aryType = [NSMutableArray array];
                for (NSDictionary *dicJson in aryJson)
                {
                    TicketTypeVo *ticketTypeVo = [[TicketTypeVo alloc]init];
                    id typeId = [dicJson objectForKey:@"id"];
                    if (typeId == nil && typeId == [NSNull null])
                    {
                        ticketTypeVo.strID = @"";
                    }
                    else
                    {
                        ticketTypeVo.strID = [typeId stringValue];
                    }
                    
                    ticketTypeVo.strName = [Common checkStrValue:[dicJson objectForKey:@"orderType"]];
                    
                    ticketTypeVo.strCompanyID = @"";
                    
                    [aryType addObject:ticketTypeVo];
                }
                retInfo.data = aryType;
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//增加工单跟踪记录
+(ServerReturnInfo*)addTicketRecord:(NSString*)strTicketID record:(NSString*)strContent
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTicketID forKey:@"workOrderId"];
    [bodyDic setObject:strContent forKey:@"trackContent"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getAddTicketRecordURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                retInfo.strErrorMsg = ERROR_TO_SERVER;
                retInfo.bSuccess = NO;
                
                NSDictionary *dicRecord = [dicResponse objectForKey:@"trackRecord"];
                if (dicRecord != nil && [dicRecord isKindOfClass:[NSDictionary class]])
                {
                    NSMutableArray *aryList = [self getTicketRecordByJSONArray:@[dicRecord]];
                    if (aryList.count>0)
                    {
                        retInfo.data = aryList[0];
                        retInfo.bSuccess = YES;
                    }
                }
            }
        }
    }
    return retInfo;
}

//工单转发邮件
+(ServerReturnInfo*)transferTicketToEmail:(NSString*)strTicketID session:(NSString*)strSessionID email:(NSMutableArray*)aryEmail
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:strTicketID forKey:@"workOrderId"];
    [bodyDic setObject:strSessionID forKey:@"talkId"];
    [bodyDic setObject:aryEmail forKey:@"toAddresses"];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getTransferTicketToEmailURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//关闭工单
+(ServerReturnInfo*)closeTicket:(NSString*)strTicketID
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@",strTicketID];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getCloseTicketURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//合并工单
+(ServerReturnInfo*)mergeTicket:(NSString*)strTicketID toTicket:(NSString*)strToTicketId
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSString *strBody = [NSString stringWithFormat:@"/%@/%@",strTicketID,strToTicketId];
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getMergeTicketURL]];
    [framework startRequestToServer:@"GET" andParameter:strBody];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                retInfo.bSuccess = YES;
            }
        }
    }
    return retInfo;
}

//保存工单(增加或修改)
+(ServerReturnInfo*)saveTicket:(TicketVo*)ticketVo
{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
    retInfo.bSuccess = NO;
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (ticketVo.strID == nil || ticketVo.strID.length == 0)
    {
        //增加
        [bodyDic setObject:@"create" forKey:@"updateField"];
    }
    else
    {
        //修改
        [bodyDic setObject:ticketVo.strID forKey:@"id"];
        [bodyDic setObject:@"modify" forKey:@"updateField"];
    }
    
    [bodyDic setObject:ticketVo.strTitle forKey:@"orderTitle"];
    [bodyDic setObject:ticketVo.strContent forKey:@"orderDesc"];
    [bodyDic setObject:ticketVo.strSessionID forKey:@"talkId"];
    
    if (ticketVo.strTypeID != nil && ticketVo.strTypeID.length>0)
    {
        [bodyDic setObject:ticketVo.strTypeID forKey:@"orderType"];
    }
    
    if(ticketVo.aryTag != nil)
    {
        NSMutableArray *aryTagID = [NSMutableArray array];
        for (TagVo *tagVo in ticketVo.aryTag)
        {
            [aryTagID addObject:tagVo.strID];
        }
        [bodyDic setObject:aryTagID forKey:@"tagIdList"];
    }
    
    DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
    [framework setURL:[ServerURL getSaveTicketURL]];
    [framework startRequestToServer:@"POST" andParameter:bodyDic];
    
    if ([framework dneError])
    {
        retInfo.strErrorMsg = ERROR_TO_NETWORK;
    }
    else
    {
        NSDictionary *dicResponse = [framework getResponseDic];
        if(dicResponse == nil)
        {
            retInfo.strErrorMsg = ERROR_TO_SERVER;
        }
        else
        {
            //判断 HTTP 请求状态码
            if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
            {
                retInfo.strErrorMsg = [DNENetworkFramework getErrorMsgBy:dicResponse];
            }
            else
            {
                retInfo.strErrorMsg = ERROR_TO_SERVER;
                retInfo.bSuccess = NO;
                
                NSDictionary *dicTicketVo = [dicResponse objectForKey:@"workOrder"];
                if (dicTicketVo != nil && [dicTicketVo isKindOfClass:[NSDictionary class]])
                {
                    NSMutableArray *aryList = [self getTicketListByJSONArray:@[dicTicketVo]];
                    if (aryList.count>0)
                    {
                        retInfo.data = aryList[0];
                        retInfo.bSuccess = YES;
                    }
                }
            }
        }
    }
    return retInfo;
}

@end
