//
//  BusinessCommon.m
//  Sloth
//
//  Created by 焱 孙 on 13-7-3.
//
//

#import "BusinessCommon.h"
#import "GroupAndUserDao.h"
#import "JPushService.h"
#import "ServerURL.h"
#import "ScheduleJoinStateVo.h"
#import "ReceiverVo.h"
#import "UserVo.h"
#import "AttachmentVo.h"
#import "TagVo.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "RewardAnimationView.h"
#import "FullScreenWebViewController.h"
#import "BlogVo.h"
#import "ActivityDetailOldViewController.h"
#import "DocViewController.h"
#import "RotateNavigationController.h"
#import "NotifyTypeVo.h"
#import <AudioToolbox/AudioServices.h>
#import "NotifyListViewController.h"
#import "ShareDetailViewController.h"
#import "UserProfileViewController.h"
#import "FootballLotteryViewController.h"
#import "AppConfig.h"

static BOOL g_bRunningUpdate		= NO;
__strong static NSMutableArray *g_aryReportUserInfo = nil;         //举报用户信息

@implementation BusinessCommon

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
    NSString *strOrgID = [Common getCurrentUserVo].strCompanyID;
    NSSet *setTag = [NSSet set];
    
#if defined(Development_Config)             //开发、测试环境
    if (strOrgID.length > 0 && ![strOrgID isEqualToString:@"0"]) {
       setTag = [[NSSet alloc]initWithObjects:[NSString stringWithFormat:@"test_%@",strOrgID], nil];//用于给整个公司推送分享通知
    }
    NSString *strAlias = [NSString stringWithFormat:@"test_%@",[Common getCurrentUserVo].strUserID];
    
#elif defined(Production_Config)            //正式环境
    if (strOrgID.length > 0 && ![strOrgID isEqualToString:@"0"]) {
        setTag = [[NSSet alloc]initWithObjects:strOrgID, nil];//用于给整个公司推送分享通知
    }
    NSString *strAlias = [Common getCurrentUserVo].strUserID;//正式环境
    
#endif
    
    [JPUSHService setTags:setTag alias:strAlias callbackSelector:nil object:nil];
}

+(void)clearJPUSHAliasAndTags
{
    [JPUSHService setTags:[NSSet set] alias:@"" callbackSelector:nil object:nil];
}

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

+ (void)updateServerGroupAndUserData:(void(^)(void))finished
{
    //1.已经有线程在更新，则退出
    if ([BusinessCommon getRunningUpdateState])
    {
        return;
    }
    [BusinessCommon setRunningUpdateState:YES];
    
    //2.update group and user data
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    //a:更新群组表
    [groupAndUserDao updateGroupTable:^{
        //更新用户表
        [groupAndUserDao updateUserTable:^{
            [BusinessCommon setRunningUpdateState:NO];
            //向其他第一时间需要用户列表或群组列表数据的视图发送更新成功通知
            dispatch_async(dispatch_get_main_queue(),^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SyncServerDataSuccess" object:nil];
                if (finished)
                {
                    finished();
                }
            });
        }];
    }];
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
            strResult = @"收件人：";
        }
        else if ([strType isEqualToString:@"C"])
        {
            strResult = @"抄　送：";
        }
        else if ([strType isEqualToString:@"B"])
        {
            strResult = @"密　送：";
        }
        
        for (int i=0; i<aryReceiverList.count; i++)
        {
            ReceiverVo *receiverVo = [aryReceiverList objectAtIndex:i];
            if (i == 0)
            {
                strResult = [strResult stringByAppendingFormat:@"%@",receiverVo.strName];
            }
            else
            {
                strResult = [strResult stringByAppendingFormat:@"\r\n　　　　%@",receiverVo.strName];
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
        [strRet appendString:@"附　件："];
    }
    
    for (int i=0;i<aryAttachmentList.count;i++)
    {
        AttachmentVo *attachmentVo = [aryAttachmentList objectAtIndex:i];
        if (i == 0)
        {
            [strRet appendFormat:@"%@",attachmentVo.strAttachmentName];
        }
        else
        {
            [strRet appendFormat:@"\r\n　　　　%@",attachmentVo.strAttachmentName];
        }
    }
    return strRet;
}

///////////////////////////////////////////////////////////////////////////////////
//分享第三方平台 aryShareType:分享类型（微信、微博、...）
+ (void)shareContentToThirdPlatform:(UIViewController*)vcContainer shareVo:(ShareInfoVo*)shareInfoVo shareList:(NSArray*)aryShareType
{
    if (shareInfoVo.strImageURL != nil && shareInfoVo.strImageURL.length>0)
    {
        //分享图片（不阻塞主线程）
        [MBProgressHUD showHUDAddedTo:vcContainer.view animated:YES];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:shareInfoVo.strImageURL] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                if (image && finished)
                {
                    shareInfoVo.imgData = image;
                }
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [MBProgressHUD hideHUDForView:vcContainer.view animated:YES];
                    //当图片加载失败也要分享出去
                    [BusinessCommon showShareActionSheet:vcContainer andShareVo:shareInfoVo shareList:aryShareType];
                });
            }];
        });
    }
    else
    {
        //no picture
        [BusinessCommon showShareActionSheet:vcContainer andShareVo:shareInfoVo shareList:aryShareType];
    }
}

//显示分享
+ (void)showShareActionSheet:(UIViewController*)vcContainer andShareVo:(ShareInfoVo*)shareInfoVo shareList:(NSArray*)aryShareType
{
    NSArray *shareList = nil;
    if (aryShareType == nil)
    {
        //默认分享类型
        shareList = [ShareSDK getShareListWithType:
                     ShareTypeWeixiSession,
                     ShareTypeWeixiTimeline,
                     ShareTypeSinaWeibo,
                     ShareTypeSMS,
                     ShareTypeMail,
                     nil];
    }
    else
    {
        shareList = aryShareType;
    }
    
    //加入分享的图片
    id<ISSCAttachment> shareImage;
    if (shareInfoVo.imgData != nil)
    {
        shareImage = [ShareSDK pngImageWithImage:shareInfoVo.imgData];
    }
    else
    {
        shareImage = [ShareSDK pngImageWithImage:[[UIImage imageNamed:@"icon_120"] roundedWithSize:CGSizeMake(120,120)]];
    }
    
    //将分享出去的文字限定为50，不截断表情
    if(shareInfoVo.strContent.length>60)
    {
        NSRange range = [shareInfoVo.strContent rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 50)];
        if (range.length < shareInfoVo.strContent.length)
        {
            shareInfoVo.strContent = [NSString stringWithFormat:@"%@...",[shareInfoVo.strContent substringWithRange:range]];
        }
    }
    
    __block id<ISSContent> publishContent = [ShareSDK content:shareInfoVo.strContent
                                               defaultContent:@""
                                                        image:shareImage
                                                        title:shareInfoVo.strTitle
                                                          url:shareInfoVo.strLinkURL
                                                  description:nil
                                                    mediaType:SSPublishContentMediaTypeNews];
    
    //定制新浪微博分享内容(在编辑界面显示的是shareInfoVo.strContent，不能编辑strSinaContent)
    NSString *strSinaContent = [NSString stringWithFormat:@"%@　-　%@ %@",shareInfoVo.strTitle,shareInfoVo.strContent,shareInfoVo.strLinkURL];
    [publishContent addSinaWeiboUnitWithContent:strSinaContent image:shareImage];
    
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
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    DLog(@"分享成功");
                                    //分享第三方平台成功后增加积分（由后台控制积分逻辑）
                                    [ServerProvider getIntegralByShareToThird:shareInfoVo.strResID result:^(ServerReturnInfo *retInfo) {
                                        if (retInfo.bSuccess)
                                        {
                                            //                                            NSInteger nIntegral = [retInfo.data integerValue];
                                            //                                            [BusinessCommon addAnimation:nIntegral andView:vcContainer.view];
                                        }
                                    }];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    DLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                }
                            }];
}

+ (NSString*)getLeagueTypeName:(NSInteger)nType
{
    NSString *strName = @"";
    if(nType == 1)
    {
        strName = @"意甲";
    }
    else if(nType == 2)
    {
        strName = @"西甲";
    }
    else if(nType == 3)
    {
        strName = @"德甲";
    }
    else if(nType == 4)
    {
        strName = @"英超";
    }
    else if(nType == 5)
    {
        strName = @"法甲";
    }
    else if(nType == 6)
    {
        strName = @"中超";
    }
    else if(nType == 7)
    {
        strName = @"欧洲杯";
    }
    return strName;
}

//积分相关/////////////////////////////////////////////////////////////////////////////////
//获取头像背景色andSuffix:命名后缀
+ (UIImage*)getHeaderBKImageByIntegral:(double)fNum andSuffix:(NSString*)strSuffix
{
    NSMutableString *strName = [[NSMutableString alloc]init];
    UIImage *image;
    if (fNum<300)
    {
        //白色头像框 0-300
        [strName appendString:@"header_bk1"];
    }
    else if (fNum<1500)
    {
        //绿色头像框 300-1500
        [strName appendString:@"header_bk2"];
    }
    else if (fNum<3000)
    {
        //蓝色头像框 1500-3000
        [strName appendString:@"header_bk3"];
    }
    else if (fNum<8000)
    {
        //紫色头像框 3000-8000
        [strName appendString:@"header_bk4"];
    }
    else if (fNum<20000)
    {
        //橙色头像框 8000-20000
        [strName appendString:@"header_bk5"];
    }
    else if (fNum<40000)
    {
        //红色头像框 20000-40000
        [strName appendString:@"header_bk6"];
    }
    else if (fNum<80000)
    {
        //象牙白头像框 40000-80000
        [strName appendString:@"header_bk7"];
    }
    else if (fNum<150000)
    {
        //樱花粉头像框 80000-150000
        [strName appendString:@"header_bk8"];
    }
    else
    {
        //金色头像框 150000-???
        [strName appendString:@"header_bk9"];
    }
    
    //加载特定后缀的框图
    [strName appendString:strSuffix];
    image = [UIImage imageNamed:strName];
    
    return image;
}

//获取该积分下的等级信息
+ (IntegralInfoVo *)getIntegralInfo:(double)fNum
{
    IntegralInfoVo *infoVo = [[IntegralInfoVo alloc]init];
    
    NSArray *aryIntegral = @[@500,@2000,@10000,@30000,@80000,@150000,@300000,@500000,@1000000];
    
    if (fNum<((NSNumber *)aryIntegral[0]).doubleValue)
    {
        infoVo.fMinIntegral = 0;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[0]).doubleValue;
        infoVo.strLevelName = @"滑板车";
        infoVo.strLevelImage = @"inte_1";
    }
    else if (fNum<((NSNumber *)aryIntegral[1]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[0]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[1]).doubleValue;
        infoVo.strLevelName = @"自行车";
        infoVo.strLevelImage = @"inte_2";
    }
    else if (fNum<((NSNumber *)aryIntegral[2]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[1]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[2]).doubleValue;
        infoVo.strLevelName = @"电动车";
        infoVo.strLevelImage = @"inte_3";
    }
    else if (fNum<((NSNumber *)aryIntegral[3]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[2]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[3]).doubleValue;
        infoVo.strLevelName = @"摩托车";
        infoVo.strLevelImage = @"inte_4";
    }
    else if (fNum<((NSNumber *)aryIntegral[4]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[3]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[4]).doubleValue;
        infoVo.strLevelName = @"轿车";
        infoVo.strLevelImage = @"inte_5";
    }
    else if (fNum<((NSNumber *)aryIntegral[5]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[4]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[5]).doubleValue;
        infoVo.strLevelName = @"跑车";
        infoVo.strLevelImage = @"inte_6";
    }
    else if (fNum<((NSNumber *)aryIntegral[6]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[5]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[6]).doubleValue;
        infoVo.strLevelName = @"赛车";
        infoVo.strLevelImage = @"inte_7";
    }
    else if (fNum<((NSNumber *)aryIntegral[7]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[6]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[7]).doubleValue;
        infoVo.strLevelName = @"直升机";
        infoVo.strLevelImage = @"inte_8";
    }
    else if (fNum<((NSNumber *)aryIntegral[8]).doubleValue)
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[7]).doubleValue;
        infoVo.fMaxIntegral = ((NSNumber *)aryIntegral[8]).doubleValue;
        infoVo.strLevelName = @"喷气飞机";
        infoVo.strLevelImage = @"inte_9";
    }
    else
    {
        infoVo.fMinIntegral = ((NSNumber *)aryIntegral[8]).doubleValue;
        infoVo.fMaxIntegral = CGFLOAT_MAX;
        infoVo.strLevelName = @"火箭";
        infoVo.strLevelImage = @"inte_10";
        infoVo.bTopLevel = YES;
    }
    
    return infoVo;
}

+ (UIImage*)getBadgeImage:(NSInteger)nBadge
{
    UIImage *image;
    if (nBadge == 1)
    {
        //版主
        image = [UIImage imageNamed:@"badge_moderator"];
    }
    else if (nBadge == 2)
    {
        //跑鞋
        image = [UIImage imageNamed:@"badge_running_shoes"];
    }
    else if (nBadge == 3)
    {
        //达人
        image = [UIImage imageNamed:@"badge_top_man"];
    }
    else if (nBadge == 4)
    {
        //BOSS
        image = [UIImage imageNamed:@"badge_boss"];
    }
    else if (nBadge == 5)
    {
        //慈善
        image = [UIImage imageNamed:@"badge_charity"];
    }
    else if (nBadge == 6)
    {
        //智汇写手
        image = [UIImage imageNamed:@"badge_writer"];
    }
    else if (nBadge == 7)
    {
        //美食达人
        image = [UIImage imageNamed:@"badge_food"];
    }
    else if (nBadge == 8)
    {
        //积分王
        image = [UIImage imageNamed:@"badge_integral_king"];
    }
    else if (nBadge == 9)
    {
        //昨日积分增长第一名
        image = [UIImage imageNamed:@"badge_yesterday_king"];
    }
    else
    {
        //普通用户
        image = [Common getImageWithColor:[UIColor clearColor]];
    }
    return image;
}

//动画
+ (void)addAnimation:(double)fIntegral sum:(double)fSumIntegral view:(UIView*)viewContainer
{
    //有积分，则显示变更
    if (fIntegral > 0)
    {
        //大于0，显示变化积分
        RewardAnimationView *animationView = [[RewardAnimationView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) integral:fIntegral total:fSumIntegral];
        [viewContainer addSubview:animationView];
        
        animationView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            animationView.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            double delayInSeconds = 2.0;
            __block RewardAnimationView* bself = animationView;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [bself closeRewardView];
            });
        }];
    }
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - 检查URL跳转到分享详情还是WebView界面
+ (void)checkShareURLJump:(NSString *)strURL parent:(UIViewController*)viewController
{
    if(strURL != nil && strURL.length>0)
    {
        //1.应用内部分享超链接
        NSString *strModelURL = @"#/articles/show/";//public/index.html#/articles/show/
        NSRange range = [strURL rangeOfString:strModelURL options:NSCaseInsensitiveSearch];
        if (range.length > 0)
        {
            //taozhihui 分享
            NSRange range1 = [strURL rangeOfString:@"/show/" options:NSCaseInsensitiveSearch];
            NSString *strBlogID = [strURL substringFromIndex:range1.location+6];

            ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
            BlogVo *blogVo = [[BlogVo alloc]init];
            blogVo.streamId = strBlogID;
            shareDetailViewController.m_originalBlogVo = blogVo;
            [viewController.navigationController pushViewController:shareDetailViewController animated:YES];
            return;
        }
        
        //2.@某人超链接
        NSString *strAtModelURL = @"#/me/";//public/index.html#/me/
        range = [strURL rangeOfString:strAtModelURL options:NSCaseInsensitiveSearch];
        if(range.length>0)
        {
            NSString *strUserID = [strURL substringFromIndex:range.location+range.length];
            if(strUserID != nil && strUserID.length>0)
            {
                //注：这个strUserID会带上前缀0，导致进入个人中心判断错误
                NSInteger nUserID = strUserID.integerValue;
                strUserID = [NSString stringWithFormat:@"%li",(unsigned long)nUserID];
                
                UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
                userProfileViewController.strUserID = strUserID;
                [viewController.navigationController pushViewController:userProfileViewController animated:YES];
            }
            else
            {
                [Common bubbleTip:@"用户不存在" andView:viewController.view];
            }
            return;
        }
        
        //3.活动超链接
        NSString *strActivityModelURL = @"#/events/detail/";
        range = [strURL rangeOfString:strActivityModelURL options:NSCaseInsensitiveSearch];
        if(range.length>0)
        {
            NSRange range1 = [strURL rangeOfString:@"/detail/" options:NSCaseInsensitiveSearch];
            NSString *strActivityID = [strURL substringFromIndex:range1.location+8];
            
            ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
            BlogVo *blogVo = [[BlogVo alloc]init];
            blogVo.strBlogType = @"activity";
            blogVo.streamId = strActivityID;
            shareDetailViewController.m_originalBlogVo = blogVo;
            [viewController.navigationController pushViewController:shareDetailViewController animated:YES];
            return;
        }
        
        //5.竞猜跳转超链接
        range = [strURL rangeOfString:GuessingJumpLink options:NSCaseInsensitiveSearch];
        if(range.length>0)
        {
            UIStoryboard *footballSB = [UIStoryboard storyboardWithName:@"FootballModule" bundle:nil];
            FootballLotteryViewController *footballLotteryVC = [footballSB instantiateViewControllerWithIdentifier:@"FootballLotteryViewController"];
            [viewController.navigationController pushViewController:footballLotteryVC animated:YES];
            return;
        }
        
        
        
        //4.其他超链接
        FullScreenWebViewController *fullScreenWebViewController = [[FullScreenWebViewController alloc]init];
        fullScreenWebViewController.urlFile = [NSURL URLWithString:strURL];
        [viewController.navigationController pushViewController:fullScreenWebViewController animated:YES];
        
    }
}

//播放小视频
+ (void)presentVideoViewController:(NSURL *)urlVideo controller:(UIViewController*)parentController
{
    DocViewController *docViewController = [[DocViewController alloc]init];
    docViewController.urlFile = urlVideo;
    
    RotateNavigationController *rotateNavigationController = [[RotateNavigationController alloc]initWithRootViewController:docViewController];
    rotateNavigationController.navigationBarHidden = YES;
    
    [parentController presentViewController:rotateNavigationController animated:YES completion:nil];
}

//跳转到提醒列表
+ (void)jumpToNotifyListByJPUSH:(NSInteger)nMainType viewController:(UIViewController*)viewControllerParent
{
    //提醒列表
    NotifyTypeVo *notifyTypeVo = [[NotifyTypeVo alloc]init];
    notifyTypeVo.notifyMainType = nMainType;
    
    switch (nMainType) {
        case 11:
            notifyTypeVo.strNotifyTypeName = @"通知";
            break;
            
        case 12:
            notifyTypeVo.strNotifyTypeName = @"评论";
            break;
            
        case 14:
            notifyTypeVo.strNotifyTypeName = @"打赏";
            break;
            
        case 15:
            notifyTypeVo.strNotifyTypeName = @"私信";
            break;
            
        default:
            return;
    }
    
    NotifyListViewController *notifyListViewController = [[UIStoryboard storyboardWithName:@"NotifyModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NotifyListViewController"];
    notifyListViewController.nNotifyMainType = nMainType;
    [viewControllerParent.navigationController pushViewController:notifyListViewController animated:YES];
}

//根据图片路径生成Img标签
+ (NSString *)getHtmlImgByImageURL:(UploadFileVo *)uploadFileVo
{
    NSString *strImgMid = [NSString stringWithFormat:@"%@%@",uploadFileVo.strDomain,uploadFileVo.strMidURL];
    NSString *strImgMax = [NSString stringWithFormat:@"%@%@",uploadFileVo.strDomain,uploadFileVo.strURL];
    
    NSMutableString *strHtml = [[NSMutableString alloc]initWithFormat:@" <img data-img-id=\"%@\" ",uploadFileVo.strID];
    [strHtml appendFormat:@" src=\"%@\" ",strImgMid];
    [strHtml appendFormat:@" img-max=\"%@\" ",strImgMax];
    [strHtml appendString:@" style=\"max-width:100%;padding:0px;\" /> "];
    return strHtml;
}

+ (NSString *)getCollectionNumByInt:(NSInteger)nNum
{
    if (nNum <10000)
    {
        return [NSString stringWithFormat:@"%li",(unsigned long)nNum];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1f万",nNum/10000.0];
    }
}

+ (NSString *)getMonthDayWeekStringByDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *compts = [calendar components:unitFlags fromDate:date];//当前时间
    
    return [NSString stringWithFormat:@"%li月%li日 周%@",(long)compts.month,(long)compts.day,[BusinessCommon getWeekStringByInteger:compts.weekday]];
}

+ (NSString *)getWeekStringByInteger:(NSInteger)nWeekday
{
    NSString *strWeek;
    switch (nWeekday) {
        case 1:
            strWeek = @"日";
            break;
        case 2:
            strWeek = @"一";
            break;
        case 3:
            strWeek = @"二";
            break;
        case 4:
            strWeek = @"三";
            break;
        case 5:
            strWeek = @"四";
            break;
        case 6:
            strWeek = @"五";
            break;
        case 7:
            strWeek = @"六";
            break;
        default:
            strWeek = [NSString stringWithFormat:@"%li",(long)nWeekday];
            break;
    }
    return strWeek;
}

//播放开场音乐
+ (void)playingOpeningMusic
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"opening_music" ofType:@"m4a"];
    SystemSoundID soundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundID);
    AudioServicesPlaySystemSound(soundID);
}

///////////////////////////////////////////////////////////////////////////////////
//获取举报人所需信息列表
+ (void)getReportUserInfoList:(UIView *)view result:(void(^)(NSMutableArray *aryReportInfo))resultBlock
{
    if(g_aryReportUserInfo == nil)
    {
        [Common showProgressView:nil view:view modal:NO];
        [ServerProvider getDictionaryConfigData:@"REPORT_REASON" result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:view];
            if (retInfo.bSuccess)
            {
                g_aryReportUserInfo = [NSMutableArray array];
                [g_aryReportUserInfo addObjectsFromArray:retInfo.data];
                resultBlock(g_aryReportUserInfo);
            }
            else
            {
                resultBlock(nil);
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else
    {
        resultBlock(g_aryReportUserInfo);
    }
}

@end
