//
//  BusinessCommon.m
//  Sloth
//
//  Created by 焱 孙 on 13-7-3.
//
//

#import "BusinessCommon.h"
#import "GroupAndUserDao.h"
#import "JPUSHService.h"
#import "ServerURL.h"
#import "ScheduleJoinStateVo.h"
#import "ReceiverVo.h"
#import "UserVo.h"
#import "AttachmentVo.h"
#import "TagVo.h"
#import "Utils.h"
#import <ShareSDK/ShareSDK.h>

static BOOL g_bRunningUpdate		= NO;
__strong static NSMutableArray *g_aryTicketType = nil;         //缓存工单类型列表

@implementation BusinessCommon

//获取数据更新状态
+ (BOOL)getRunningUpdateState
{
    return g_bRunningUpdate;
}
//设置数据更新状态
+ (void)setRunningUpdateState:(BOOL)bState
{
    g_bRunningUpdate = bState;
}

//获取数据更新状态
+ (NSMutableArray*)getTicketTypeArray
{
    return g_aryTicketType;
}
//设置数据更新状态
+ (void)setTicketTypeArray:(NSMutableArray*)aryType
{
    if(g_aryTicketType != aryType)
    {
        g_aryTicketType = [aryType copy];
    }
}

+(NSString*)getChatImgURLString:(NSString*)strText
{
    NSString *strTemp = @"";
    NSRange range = [strText rangeOfString:@"href='" options:NSCaseInsensitiveSearch];
    if (range.length <= 0) 
    {
        //not search sub string
        strTemp = @"";
    }
    else
    {
        //search sub string success
        strTemp = [strText substringFromIndex:(range.location+6)];
        range = [strTemp rangeOfString:@"'" options:NSCaseInsensitiveSearch];
        if (range.length > 0) 
        {
            strTemp = [strTemp substringToIndex:range.location];
        }
        else
        {
            strTemp = @"";
        }
    }
    return strTemp;
}

+(void)setJPUSHAliasAndTags
{
//    //测试环境
//    NSSet *setTag = [[NSSet alloc]initWithObjects:@"test_1", nil];//用于给整个公司推送分享通知
//    NSString *strAlias = [NSString stringWithFormat:@"test_%@",[Common getCurrentUserVo].strUserID];
    
    //成都环境
//    NSSet *setTag = [[NSSet alloc]initWithObjects:@"chengdu_1", nil];//用于给整个公司推送分享通知
//    NSString *strAlias = [NSString stringWithFormat:@"chengdu_%@",[Common getCurrentUserVo].strUserID];
    
//    //生产环境
//    NSSet *setTag = [[NSSet alloc]initWithObjects:@"1", nil];//[NSSet set]
//    NSString *strAlias = [Common getCurrentUserVo].strUserID;
    
//    [JPUSHService setTags:setTag alias:strAlias callbackSelector:nil object:nil];
}

+(void)clearJPUSHAliasAndTags
{
//    [JPUSHService setTags:[NSSet set] alias:@"" callbackSelector:nil object:nil];
}

+ (void)updateServerGroupAndUserData
{
    //1.已经有线程在更新，则退出
    if ([BusinessCommon getRunningUpdateState])
    {
        return;
    }
    [BusinessCommon setRunningUpdateState:YES];
    
    //2.update group and user data
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    [groupAndUserDao updateGroupTable];
    [groupAndUserDao updateUserTable];
    
    [BusinessCommon setRunningUpdateState:NO];

    //向聊天页面（或者其他第一时间需要用户列表数据的视图）发送更新成功通知，然后那些页面再加载用户数据
    dispatch_async(dispatch_get_global_queue(0,0),^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SyncServerDataSuccess" object:nil];
    });
}

+ (RoleType)getUserRealRole:(NSString*)strSum
{
    NSRange range1 = [strSum rangeOfString:@"admin"];
    if (range1.length > 0)
    {
        //管理员
        return RoleTypeAdmin;
    }
    
    NSRange range2 = [strSum rangeOfString:@"leader"];
    if (range2.length > 0)
    {
        //领导
        return RoleTypeLeader;
    }
    
    NSRange range3 = [strSum rangeOfString:@"assistant"];
    if (range3.length > 0)
    {
        //秘书
        return RoleTypeAssistant;
    }
    
    NSRange range4 = [strSum rangeOfString:@"agency"];
    if (range4.length > 0)
    {
        //代理
        return RoleTypeAgency;
    }
    return RoleTypeOther;
}

//获取约会成员
+(NSString*)getScheduleMemberByType:(int)nType andArray:(NSMutableArray*)aryMemList
{
    NSString *strMemStr = @"";
    for (int i=0;i<aryMemList.count;i++)
    {
        ScheduleJoinStateVo *scheduleMemVo = [aryMemList objectAtIndex:i];
        if(scheduleMemVo.nReply == nType)
        {
            if (strMemStr.length == 0)
            {
                strMemStr = [strMemStr stringByAppendingString:scheduleMemVo.strUserName];
            }
            else
            {
                strMemStr = [strMemStr stringByAppendingFormat:@",%@",scheduleMemVo.strUserName];
            }
        }
    }
    return strMemStr;
}

+(NSString*)getImageNameByMessageState:(int)nState
{
    NSString *strImgName = @"";
    if (nState == 0)
    {
        //已读邮件
    }
    else if (nState == 1)
    {
        //未读邮件
        strImgName = @"email_unread";
    }
    else if (nState == 2)
    {
        //再次编辑后未读邮件
        strImgName = @"email_unread_afterEdited";
    }
    else if (nState == 3)
    {
        //已转发或已回复的邮件
        strImgName = @"email_forward_reply";
    }
    return strImgName;
}

+(NSString*)getReceiverListString:(NSMutableArray*)aryReceiverList andType:(NSString*)strType
{
    NSString *strResult = @"";
    if (aryReceiverList.count>0)
    {
        if ([strType isEqualToString:@"T"])
        {
            strResult = [NSString stringWithFormat:@"%@：",[Common localStr:@"Msg_Receiver" value:@"收件人"]];
        }
        else if ([strType isEqualToString:@"C"])
        {
            strResult = [NSString stringWithFormat:@"%@：",[Common localStr:@"Msg_CC" value:@"抄　送"]];
        }
        else if ([strType isEqualToString:@"B"])
        {
            strResult = [NSString stringWithFormat:@"%@：",[Common localStr:@"Msg_BC" value:@"密　送"]];
        }
        
        for (int i=0; i<aryReceiverList.count; i++)
        {
            ReceiverVo *receiverVo = [aryReceiverList objectAtIndex:i];
            if (i == 0)
            {
                strResult = [strResult stringByAppendingFormat:@"\t%@",receiverVo.strName];
            }
            else
            {
                strResult = [strResult stringByAppendingFormat:@"\r\n\t\t%@",receiverVo.strName];
            }
        }
    }
    return strResult;
}

+(NSString*)getAttachmentListString:(NSMutableArray*)aryAttachmentList
{
    NSMutableString *strRet = [NSMutableString string];
    if (aryAttachmentList.count>0)
    {
        [strRet appendFormat:@"%@：",[Common localStr:@"Msg_Attachments" value:@"附　件"]];
    }
    
    for (int i=0;i<aryAttachmentList.count;i++)
    {
        AttachmentVo *attachmentVo = [aryAttachmentList objectAtIndex:i];
        if (i == 0)
        {
            [strRet appendFormat:@"\t%@",attachmentVo.strAttachmentName];
        }
        else
        {
            [strRet appendFormat:@"\r\n\t\t\t\t%@",attachmentVo.strAttachmentName];
        }
    }
    return strRet;
}

//更新应用图片（加载页图片和登录页面图片），在子线程运行
+(void)updateAppImageAction:(NSArray*)aryImageList
{
    //1.目录是否存在,不存在则创建（图片存放在：Documents/AppImage/）
    NSString *strPath = [[Utils documentsDirectory] stringByAppendingPathComponent:@"AppImage"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strPath];
    if (!fileExists)
    {
        //not exist,then create
        [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES  attributes:nil error:nil];
    }
    
    //2.检查每个文件是否存在，不存在逐个下载
    for (NSString *strURL in aryImageList)
    {
        //a:检查文件是否存在
        NSString *strImageName = [strURL lastPathComponent];
        NSString *strImagePath = [strPath stringByAppendingPathComponent:strImageName];
        BOOL fileExists = [fileManager fileExistsAtPath:strImagePath];
        if (!fileExists)
        {
            //不存在则下载文件
            NSData *dataImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            //将文件写入到 "Documents/AppImage/" 目录中
            [dataImage writeToFile:strImagePath atomically:YES];
        }
    }
}

//显示分享
+ (void)showShareActionSheet:(UIViewController*)vcContainer andShareVo:(ShareInfoVo*)shareInfoVo
{
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          ShareTypeWeixiTimeline,
                          ShareTypeSinaWeibo,
                          ShareTypeSMS,
                          ShareTypeMail,
                          nil];
    
    //加入分享的图片
    id<ISSCAttachment> shareImage;
    if (shareInfoVo.strImageURL != nil && shareInfoVo.strImageURL.length>0)
    {
        shareImage = [ShareSDK imageWithUrl:shareInfoVo.strImageURL];
    }
    else
    {
        shareImage = [ShareSDK pngImageWithImage:[UIImage imageNamed:@"icon_120"]];
    }
    
    __block id<ISSContent> publishContent = [ShareSDK content:shareInfoVo.strContent
                                               defaultContent:@""
                                                        image:shareImage
                                                        title:shareInfoVo.strTitle
                                                          url:shareInfoVo.strLinkURL
                                                  description:nil
                                                    mediaType:SSPublishContentMediaTypeNews];
    
    __block id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"分享内容"               //分享视图标题
                                                                      oneKeyShareList:nil                   //一键分享菜单
                                                                       qqButtonHidden:YES                    //QQ分享按钮是否隐藏
                                                                wxSessionButtonHidden:NO                   //微信好友分享按钮是否隐藏
                                                               wxTimelineButtonHidden:NO                 //微信朋友圈分享按钮是否隐藏
                                                                 showKeyboardOnAppear:YES                  //是否显示键盘
                                                                    shareViewDelegate:(id<ISSShareViewDelegate>)vcContainer                            //分享视图委托
                                                                  friendsViewDelegate:nil                          //好友视图委托
                                                                picViewerViewDelegate:nil];                    //图片浏览视图委托
    
    //定义容器，可以自定义导航按钮和背景颜色
    id<ISSContainer> container = [ShareSDK container];
    [container setIPhoneContainerWithViewController:vcContainer];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if(state == SSResponseStateBegan)
                                {
                                    if (type == ShareTypeSinaWeibo)
                                    {
                                        //对于分享到新浪微博，加上链接（微信平台不用）
                                        publishContent.content = [NSString stringWithFormat:@"%@ %@",shareInfoVo.strContent,shareInfoVo.strLinkURL];
                                    }
                                }
                                else
                                {
                                    if (state == SSPublishContentStateSuccess)
                                    {
                                        NSLog(@"分享成功");
                                    }
                                    else if (state == SSResponseStateFail)
                                    {
                                        NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                    }
                                }
                            }];
}

//【1:微信 2:新浪微博 3:腾讯微博 4:易信 5:邮件 6:短信 7:新浪@我的 8:知新 9:系统内web聊天】
+(NSString*)getSessionHeadBySource:(NSInteger)nSource
{
    NSString *strIconName;
    if(nSource == 1)
    {
       strIconName = @"head_weixin";
    }
    else if(nSource == 2)
    {
        strIconName = @"head_sina";
    }
    else if(nSource == 4)
    {
        strIconName = @"head_yixin";
    }
    else if(nSource == 5)
    {
        strIconName = @"head_email";
    }
    else if(nSource == 6)
    {
        strIconName = @"head_sms";
    }
    else if(nSource == 7)
    {
        strIconName = @"head_sina";
    }
    else if(nSource == 8)
    {
        strIconName = @"head_sina";
    }
    else if(nSource == 9 || nSource == 11)
    {
        strIconName = @"head_browser";
    }
    else
    {
        strIconName = @"head_default";
    }
    return strIconName;
}


@end
