//
//  AppDelegate.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-1-21.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatCountDao.h"
#import "JPUSHService.h"
#import "UIImage+UIImageScale.h"
#import "CommonNavigationController.h"
#import "UserVo.h"
#import "ChatListViewController.h"
#import "ShareDetailViewController.h"
#import "SkinManage.h"
#import "ServerURL.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"
#import "MobAnalytics.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "ShareListViewController.h"
#import "FaceModel.h"
#import <AFNetworking.h>
#import "VNetworkFramework.h"
#import "MBProgressHUD+GHQ.h"
#define kJPushNotify        1001
#define kJPushChat          1002
#define kJPushGroupChat     1003
#define kJPushBroadcast     1004
#define kJPushOther         1005
@interface AppDelegate ()
{
    NSString *strID33;
}
@end
@implementation AppDelegate
static NSString *appKey = @"XXXX";
static NSInteger indexll = 0;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
       // Override point for customization after application launch.
    self.nStartModal = kNormalStart;
    //init global value
    [Common initGlobalValue];
    _currentPageName = OtherPage;
    
    //初始化环境
    [self initDefault];
    
    //初始化表情数据
    [self initFaceData];
    
    //初始化皮肤设置
    [SkinManage initSkinSetting];
    
    self.aryAlertView = [[NSMutableArray alloc]init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.firstStartViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil] instantiateViewControllerWithIdentifier:@"FirstStartViewController"];
        CommonNavigationController *loginNavController = [[CommonNavigationController alloc] initWithRootViewController:self.firstStartViewController];
        self.firstStartViewController.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.window.rootViewController = loginNavController;
    }
    
    [self.window makeKeyAndVisible];
    
    //init JPush
    [self initJPushWithOptions:launchOptions];
    
    //init ShareSDK
    [self initShareSDK];
   
    
    //    [MobAnalytics setEncryptEnabled:YES];
//    [MobAnalytics startWithAppkey:appKey reportPolicy:BATCH];
//    application.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Required
//    indexll += 1;
    NSLog(@"hhhhttttttttttttttttttttttttttttttt%@",deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
//    if (deviceToken == nil) {
//        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//
//    }else{
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:indexll];
//    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"================接收不到消息%@",error);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //JPUSH
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(nilSymbol) userInfo:nil repeats:YES];
    
    [JPUSHService resetBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //JPUSH

    indexll = 0;
    NSLog(@"进入前台%ld",(long)indexll);

//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
    _nStartModal = kEnterForeground;//进入到激活状态
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler
{
    
        indexll += 1;
    NSLog(@"oooooooooooooooooooooo========%ld",(long)indexll);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:indexll];
       strID33 = userInfo[@"blogId"];
    if (!strID33) {
        strID33 = userInfo[@"refId"];
    }

    //处理推送信息
    [self networkDidReceiveMessage:userInfo];
    
    NSLog(@"极光推送userInfo基本信息%@",userInfo);
  
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //orgId
    NSString *strQuery = url.query;
    DLog(@"--url.query:%@",strQuery);
    NSRange range = [strQuery rangeOfString:@"orgId=" options:NSCaseInsensitiveSearch];
    if (range.length > 0) {
        self.strURLSchemeParameter = [strQuery substringFromIndex:range.location+range.length];
        
        if (self.strURLSchemeParameter.length > 0) {
            if ([Common getCurrentUserVo].strUserID.length > 0) {
                //已经登录
                [[NSNotificationCenter defaultCenter] postNotificationName:@"URLSchemeEnterForeground" object:nil];
            }
        }
    }
    
    return YES;
}

+ (AppDelegate*)getSlothAppDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

//////////////////////////////////////////////////////////////////////
-(void)initJPushWithOptions:(NSDictionary *)launchOptions
{
    //判断程序是不是由推送服务完成的
    if (launchOptions)
    {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey)
        {
            //点击系统推送通知启动
            _nStartModal = kNotifyStart;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

        }
        else
        {
            //点击应用图标启动
            _nStartModal = kNormalStart;
        }
    }
    else
    {
        //点击应用图标启动
        _nStartModal = kNormalStart;
    }
    
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        //categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    }
    else
    {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
    }
    
    // 测试环境极光推送key========45211d3e02d5a50f84fdd353
    // 正式环境极光推送key========79aa2226041e67cf38b1540b
    [JPUSHService setupWithOption:launchOptions appKey:@"45211d3e02d5a50f84fdd353" channel:@"Publish channel" apsForProduction:YES];
    
    //关闭日志信息
//    [JPUSHService setLogOFF];
}

- (void)networkDidReceiveMessage:(NSDictionary *)userInfo
{
    self.dicJPushUserInfo = userInfo;
    if ([Common getCurrentUserVo].strUserID.length == 0)
    {
        //当没有设置MemberID, 默认为点击系统推送通知启动（退出登录，再登录过程）
        _nStartModal = kNotifyStart;
    }
    [self tackleJPUSHMessage];
}

-(void)clearOtherAlertView
{
    if(_aryAlertView.count == 0 )
    {
        return;
    }
    
    for (NSInteger i=(_aryAlertView.count-1); i>=0; i--)
    {
        UIAlertView *temp = (UIAlertView *)[_aryAlertView objectAtIndex:i];
        [temp dismissWithClickedButtonIndex:0 animated:NO];
        [_aryAlertView removeObjectAtIndex:i];
    }
}

-(void)saveUnseeChatNum:(NSDictionary*)dicData
{
    int nNotifyType = -1;
    id objType = [dicData valueForKey:@"type"];
    if (objType != nil && objType != [NSNull null])
    {
        nNotifyType = [objType intValue];
    }
    
    if(nNotifyType == 5)
    {
        //群聊
        id tempID = [dicData valueForKey:@"team"];
        if (tempID != nil && tempID != [NSNull null])
        {
            NSString *strKey = [NSString stringWithFormat:@"group_%@",tempID];
            [ChatCountDao addOneUnseenChatNumByKey:strKey];
        }
    }
    else if(nNotifyType == 0)
    {
        //私聊
        id tempID = [dicData valueForKey:@"uid"];
        if (tempID != nil && tempID != [NSNull null])
        {
            NSString *strKey = [NSString stringWithFormat:@"vest_%@",[tempID stringValue]];
            [ChatCountDao addOneUnseenChatNumByKey:strKey];
        }
    }
}

//推送提醒相关//////////////////////////////////////////////////////////
//处理JPUSH
-(void)tackleJPUSHMessage
{
    //clear badge number
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
    
    //使用APNS的格式（不使用JPUSH格式,没有title字段），{aps:{alert:"test";sound:"default;};ct:0;type:0;uid:2;}
    NSDictionary *dicAPS = [self.dicJPushUserInfo valueForKey:@"aps"];
    NSString *content = [dicAPS valueForKey:@"alert"];
    DLog(@"--%@",dicAPS);
    
    if(self.dicJPushUserInfo != nil)
    {
        //获取通知类型
        int nNotifyType = -1;
        id objType = [self.dicJPushUserInfo valueForKey:@"type"];
        if (objType != nil && objType != [NSNull null])
        {
            nNotifyType = [objType intValue];
        }

        if (nNotifyType == 0 || nNotifyType == 5)
        {
            //私聊:type=0,群聊:type=5
            //即时聊天-----------------------------------------------------------------
            //a:存储未查看的聊天数
            [self saveUnseeChatNum:self.dicJPushUserInfo];
            
            //三种状态(kInAPP,kEnterForeground,kNormalStart)
            if (self.currentPageName == ChatListPage)
            {
                //处于聊天人列表界面
                [[NSNotificationCenter defaultCenter] postNotificationName:JPUSH_REFRESH_CHATLIST object:nil];
            }
            else if (self.currentPageName == ChatContentPage)
            {
                //处于聊天界面
                [[NSNotificationCenter defaultCenter] postNotificationName:JPUSH_REFRESH_CHATCONTENT object:self.dicJPushUserInfo];
            }
            else
            {
                //other page
                [self clearOtherAlertView];
                
                UIAlertView *alertViewTemp =[[UIAlertView alloc] initWithTitle:@"聊天" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
                if (nNotifyType == 0)
                {
                    //私聊
                    alertViewTemp.tag = kJPushChat;
                }
                else
                {
                    //群聊
                    alertViewTemp.tag = kJPushGroupChat;
                }
                [alertViewTemp show];
                [self.aryAlertView addObject:alertViewTemp];
            }
            
            _nStartModal = kInAPP;
            
            //update tab bottom notice num
            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:self.dicJPushUserInfo];
        }
        else if (nNotifyType == 6 || nNotifyType == 13 || nNotifyType == 15)
        {
            //6:广播推送、13:@推送、15 消息群组
            //当前用户不为空，则说明已经登录，广播后要回到分享主界面
            if ([Common getCurrentUserVo] != nil)
            {
                if (_nStartModal == kNotifyStart || _nStartModal == kEnterForeground)
                {
                    NSLog(@"378=================");

                    //点击通知栏启动或唤醒应用
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_JPUSH_ENTER_APP object:self.dicJPushUserInfo];
                 UIAlertView   *alertViewTemp =[[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
                    alertViewTemp.tag = 56;
                    [alertViewTemp show];
                }
                else
                {
                    //在应用内收到通知
                    [self clearOtherAlertView];
                    
                    UIAlertView *alertViewTemp;
                    id refId = [self.dicJPushUserInfo valueForKey:@"refId"];
                    if(nNotifyType == 15)
                    {
                        NSLog(@"392=================");

                        alertViewTemp =[[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
                        alertViewTemp.tag = kJPushNotify;
                    }
//                        else if (nNotifyType == 13){
//                        alertViewTemp =[[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
//                        alertViewTemp.tag = 13;
//
//                    }
                    else if (refId != nil && refId != [NSNull null])
                    {
                        NSLog(@"402=================");

                        alertViewTemp =[[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
                        alertViewTemp.tag = kJPushBroadcast;
                    }
                    else
                    {
                        NSLog(@"408=================");
                        alertViewTemp =[[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        alertViewTemp.tag = kJPushBroadcast;
                    }
                    
                    [alertViewTemp show];
                    [self.aryAlertView addObject:alertViewTemp];
                }
            }
            _nStartModal = kInAPP;
        }
        else
        {
            
            [self clearOtherAlertView];
            
//            UIAlertView *alertViewTemp =[[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            alertViewTemp.tag = kJPushOther;
//            [alertViewTemp show];
//            [self.aryAlertView addObject:alertViewTemp];
            _nStartModal = kInAPP;
            
            ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc]init];
            BlogVo *blogVo = [[BlogVo alloc]init];
            blogVo.streamId = strID33;
            shareDetailViewController.m_originalBlogVo = blogVo;
            [self.homeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
                }
    }
}

//UIActionSheet delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kJPushBroadcast)
    {
        NSLog(@"453========================");

        if (buttonIndex==1)
        {
            //广播-进入分享详情(在应用内收到通知)
            id refId = [self.dicJPushUserInfo valueForKey:@"refId"];
            if (refId != nil && refId != [NSNull null])
            {
                NSLog(@"453========================");
                NSLog(@"111111111111111111111%@",refId);
//                ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc]init];
//                BlogVo *blogVo = [[BlogVo alloc]init];
//                blogVo.streamId = [NSString stringWithFormat:@"%@",refId];
//                NSLog(@"refId========================%@",refId);
//
//                shareDetailViewController.m_originalBlogVo = blogVo;
//                NSLog(@"push========================%@",blogVo);
//
                MessageViewController *MControl = [[UIStoryboard storyboardWithName:@"HomeModule" bundle:nil]instantiateViewControllerWithIdentifier:@"MessageViewController"];
//                MControl.homeViewController = self.homeViewController;
                
                [self.homeViewController.navigationController pushViewController:MControl animated:YES];
//
//                self.homeViewController.mainTabType = TabItemType3;
//                [self.homeViewController setTabItemStyle:self.homeViewController.btnItem3];
//
//                [self.homeViewController switchViewController];
                /*
                 self.itemThirdViewController = [[UIStoryboard storyboardWithName:@"HomeModule" bundle:nil]instantiateViewControllerWithIdentifier:@"MessageViewController"];
                 self.itemThirdViewController.homeViewController = self;
                 self.itemThirdNavigationController = [[CommonNavigationController alloc]initWithRootViewController:self.itemThirdViewController];
                 
                 [self.view addSubview:self.itemThirdNavigationController.view];
                 self.itemThirdViewController.tableViewMenu.scrollsToTop = YES;
                 
                 [self.itemThirdViewController updateNoticeNum:YES];

                */
            }
        }
    }
    if (alertView.tag == 56)
    {
        if (buttonIndex==1)
        {
            //广播-进入分享详情(在应用内收到通知)
            id refId = [self.dicJPushUserInfo valueForKey:@"refId"];
            if (refId != nil && refId != [NSNull null])
            {
                NSLog(@"453========================");
//                NSLog(@"111111111111111111111%@",refId);
//                ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc]init];
//                BlogVo *blogVo = [[BlogVo alloc]init];
//                blogVo.streamId = [NSString stringWithFormat:@"%@",refId];
//                NSLog(@"refId========================%@",refId);
//                
//                shareDetailViewController.m_originalBlogVo = blogVo;
//                NSLog(@"push========================%@",blogVo);
//                
//                [self.homeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
//                self.homeViewController.mainTabType = TabItemType3;
//                [self.homeViewController setTabItemStyle:self.homeViewController.btnItem3];
//                [self.homeViewController switchViewController];
                MessageViewController *MControl = [[UIStoryboard storyboardWithName:@"HomeModule" bundle:nil]instantiateViewControllerWithIdentifier:@"MessageViewController"];
                [self.homeViewController.navigationController pushViewController:MControl animated:YES];

            }
        }
    }

    else if (alertView.tag == kJPushChat)
    {
        if (buttonIndex==1)
        {
            //即时聊天-私聊
            ChatListViewController *chatListViewController = [[ChatListViewController alloc] init];
            chatListViewController.nEnterType = 1;
            [self.homeViewController.navigationController pushViewController:chatListViewController animated:NO];
        }
    }
    else if (alertView.tag == kJPushGroupChat)
    {
        if (buttonIndex==1)
        {
            //即时聊天-群聊
            ChatListViewController *chatListViewController = [[ChatListViewController alloc] init];
            chatListViewController.nEnterType = 1;
            [self.homeViewController.navigationController pushViewController:chatListViewController animated:NO];
        }
    }
    else if (alertView.tag == kJPushNotify)
    {
        if (buttonIndex==1)
        {
            //提醒列表
            NSInteger nNotifyType = -1;
            id objType = [self.dicJPushUserInfo valueForKey:@"type"];
            if (objType != nil && objType != [NSNull null])
            {
                nNotifyType = [objType integerValue];
            }
            
            [BusinessCommon jumpToNotifyListByJPUSH:nNotifyType viewController:self.homeViewController];
        }
    }
    else if (alertView.tag == kJPushOther)
    {
        if (buttonIndex==1)
        {
            //...
        }
    }
}

//////////////////////////////////////////////////////////////////////
//初始化ShareSDK
-(void)initShareSDK
{
    [ShareSDK registerApp:@"24610a1cf1bc"];
    
    //添加新浪微博应用 注册网址 http://open.weibo.com
    [ShareSDK connectSinaWeiboWithAppKey:@"2358557042"
                               appSecret:@"0ac14e726bca7a8a90e03863cd145f74"
                             redirectUri:@"http://www.sina.com.cn/"];
    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
    [ShareSDK  connectSinaWeiboWithAppKey:@"2358557042"
                                appSecret:@"0ac14e726bca7a8a90e03863cd145f74"
                              redirectUri:@"http://www.sina.com.cn/"//回调网址
                              weiboSDKCls:[WeiboSDK class]];
    
    //添加微信应用(share_sdk:wx6dd7a9b94f3dd72a)
    [ShareSDK connectWeChatWithAppId:@"wxeb78e5c444fca95d" wechatCls:[WXApi class]];
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    //连接邮件
    [ShareSDK connectMail];
}

//初始化表情数据
-(void)initFaceData
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"SlothFace" ofType:@"plist"];
    self.aryFace  = [[NSArray alloc] initWithContentsOfFile:path];
    FaceModel *arr = [FaceModel sharedManager];
    arr.modelArr = [NSMutableArray array];
    for (NSDictionary *dic in [[NSArray alloc] initWithContentsOfFile:path]) {
        FaceModel *model = [[FaceModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [arr.modelArr addObject:model];
    }
    
}

-(void)initDefault
{
    //初始化字体大小
    NSString *strdefaultTypeFace  = [[NSUserDefaults standardUserDefaults] objectForKey:@"FontSize"];
    if (strdefaultTypeFace != nil)
    {
        g_fFontScale = [strdefaultTypeFace doubleValue];
    }
    
    //微信名片高德定位功能(iOS8)
    if(iOSPlatform >= 8)
    {
        CLLocationManager* location = [CLLocationManager new];
        [location requestAlwaysAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    //清理SDImageCache
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
}

@end
