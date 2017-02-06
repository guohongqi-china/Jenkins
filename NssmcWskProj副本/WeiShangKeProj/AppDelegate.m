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
#import "CustomNavigationController.h"
#import "UserVo.h"
#import "MBProgressHUD+GHQ.h"
#import "LanguageManage.h"
#import <AFNetworking.h>
#import "SessionDetailViewController.h"
#import "ServerURL.h"
#import "WorkOrderDetailsViewControll.h"
#import "WorkOrderDetailsViewControll.h"
#import <AdSupport/ASIdentifierManager.h>
#import "AddRecordViewController.h"
#define kJPushNotify    1001
#define kJPushChat      1002
#define kJPushGroupChat      1003
#define kJPushBroadcast     1004
#define kWSNotify    1005

/**
 * 菱信工单：jPFSKo8XEIT7dkcnsfIuCGLQ8RNErrfe 
 * Old：j5ozabmh4BXpIpazy5e45VQIcBY1cFEz
 */
#define kKey @"jPFSKo8XEIT7dkcnsfIuCGLQ8RNErrfe"


#import "shareModel.h"
@interface AppDelegate ()<BMKLocationServiceDelegate,UIAlertViewDelegate>
{
    shareModel *model;
    BOOL flag;
    BOOL isOr;
    NSInteger number;
}
@property(nonatomic,strong)AFNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, strong) BMKMapManager *mapManager;/** <#注释#> */

@end
@implementation AppDelegate
- (BMKMapManager *)mapManager{
    if (!_mapManager) {
        _mapManager = [[BMKMapManager alloc]init];
        // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
        BOOL ret = [_mapManager start:kKey generalDelegate:nil];
        if (!ret) {
            NSLog(@"manager start failed!");
        }else
        {
            NSLog(@"成功");
        }
        
    }
    return _mapManager;
    
}
/**
 *  新日铁bunId：com.visionet.inhouse.NssmcProjkk
 *   com.visionet.inhouse.LiaotianProj
 */
- (void)notification{
    isOr = YES;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
    [self mapManager];
    number = 0;

    //创建网络监控对象
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    flag = NO;
    isOr = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notification) name:@"tongzhi" object:nil];
    //设置监听
    [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"2G,3G,4G...的网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi的网络");
                break;
            default:
                break;
        }
    }];
    
    //开始监听网络状况.
    [_reachabilityManager startMonitoring];
    
    // Override point for customization after application launch.
    self.bRespondsToViewWillAppear = YES;
    
    self.bChatJPUSH = NO;
    self.nStartModal = kNormalStart;
    //init global value
    [Common initGlobalValue];
    _currentPageName = OtherPage;
    
    //初始化表情数据
    [self initFaceData];
    
    self.aryAlertView = [[NSMutableArray alloc]init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initDefault];
    
    //初始化语言设置
    [LanguageManage initLanguageSetting];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.loginViewController = [[LoginViewController alloc] init];
        CustomNavigationController *loginNavController = [[CustomNavigationController alloc] initWithRootViewController:_loginViewController];
        loginNavController.navigationBarHidden = YES;
        _loginViewController.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.window.rootViewController = loginNavController;
    }
    
    [self.window makeKeyAndVisible];
    
    
    
//    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    /**
     *  b8c98dd79bc8d0aa0d48bf0c    243
     *  26187b66fe0fc29baaa1d036
     *  cdbbc45c1f5a44c999810046
     */
    [JPUSHService setupWithOption:launchOptions appKey:@"cdbbc45c1f5a44c999810046"
                          channel:@"xinritie"
                 apsForProduction:YES
            advertisingIdentifier:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    
    
//    //init JPush
//    [self initJPushWithOptions:launchOptions];
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
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //处理推送信息
//    [self networkDidReceiveMessage:userInfo];
    
    // Required
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    isBackgroud = YES;
    //JPUSH
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
        // 当申请的后台运行时间已经结束（过期），就会调用这个block
        
        // 赶紧结束任务
        [application endBackgroundTask:task];
    }];
    flag = NO;


}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //JPUSH
    isBackgroud = NO;
    number = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
    _nStartModal = kEnterForeground;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler
{
    //处理推送信息
//    [self networkDidReceiveMessage:userInfo];
    NSLog(@"userInfo%@",userInfo);
    if (flag && isOr ) {
//        [MBProgressHUD showMessage:@"请添加记录" toView:nil];
        
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HadReceiveNotification" object:nil];
 
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    number += 1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    flag = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    }
    else
    {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
    }
#else
    //categories 必须为nil
    [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
#endif
    // Required
    [JPUSHService setupWithOption:launchOptions];
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
    self.bChatJPUSH = YES;
    
    int nNotifyType = -1;
    id objType = [dicData valueForKey:@"type"];
    if (objType != nil && objType != [NSNull null])
    {
        nNotifyType = [objType intValue];
    }
    
    if(nNotifyType == 1)
    {
        //客服与客户:1
        id talkId = [dicData valueForKey:@"talkId"];
        id talkStatus = [dicData valueForKey:@"status"];
        if (talkId != nil && talkId != [NSNull null] && talkStatus != nil && talkStatus != [NSNull null])
        {
            NSString *strKey = [NSString stringWithFormat:@"session_%@",[talkId stringValue]];
            NSString *strStatus = [ChatCountDao getSessionKeyByStatus:[talkStatus integerValue]];
            [ChatCountDao addOneUnseenChatNumByKey:strKey status:strStatus];
        }
    }
}

//推送提醒相关//////////////////////////////////////////////////////////
//处理JPUSH
-(void)tackleJPUSHMessage
{
    //clear badge number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //使用APNS的格式（不使用JPUSH格式,没有title字段），{aps:{alert:"test";sound:"default;};ct:0;type:0;uid:2;}
    if(self.dicJPushUserInfo != nil)
    {
        DLog(@"JPUSH:%@",self.dicJPushUserInfo);
        
        //获取推送类型
        int nNotifyType = -1;
        id objType = [self.dicJPushUserInfo valueForKey:@"type"];
        if (objType != nil && objType != [NSNull null])
        {
            nNotifyType = [objType intValue];
        }
        
        //客服与客户:1
        if (nNotifyType == 1)
        {
            //a:存储未查看的聊天数
            [self saveUnseeChatNum:self.dicJPushUserInfo];
            
            //b:刷新或者跳转操作【三种状态(kInAPP,kEnterForeground,kNormalStart)】
            if (self.currentPageName == SessionListPage)
            {
                //处于聊天人列表界面
                [[NSNotificationCenter defaultCenter] postNotificationName:JPUSH_REFRESH_CHATLIST object:self.dicJPushUserInfo];
            }
            else if (self.currentPageName == SessionContentPage)
            {
                //处于聊天界面
                [[NSNotificationCenter defaultCenter] postNotificationName:JPUSH_REFRESH_CHATCONTENT object:self.dicJPushUserInfo];
            }
            else
            {
                //other page
            }
            _nStartModal = kInAPP;
            
            //更新左边菜单顶部提醒数字
            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
        }
    }
}

//UIActionSheet delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kWSNotify)
    {
        if (buttonIndex==1)
        {
            //WS推送，查看消息
            if(self.chatObjectVo != nil)
            {
                SessionDetailViewController *sessionDetailViewController = [[SessionDetailViewController alloc] init];
                sessionDetailViewController.m_chatObjectVo = self.chatObjectVo;
                sessionDetailViewController.refreshSessionBlock = nil;
                [self.loginViewController.navigationController pushViewController:sessionDetailViewController animated:YES];
            }
        }
    }else{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

//初始化表情数据
-(void)initFaceData
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"SlothFace" ofType:@"plist"];
    self.aryFace  = [[NSArray alloc] initWithContentsOfFile:path];
}

//初始化百度地图
- (void)initBaiduMapSDK
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"7CVxGq4h0NPWk4xyqbecwyY0" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

//应用初始化配置
-(void)initDefault
{
    //Server URL setting
    [ServerURL initServerURL];
    
//    // 初始化Bugly SDK
//    [self initBuglySDK];
    
    //百度定位功能(iOS8)
    if(iOSPlatform >= 8)
    {
        CLLocationManager* location = [CLLocationManager new];
        [location requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
    }
}

#pragma BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [alertView dismissWithClickedButtonIndex:0 animated:YES];
//}

// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    // 这里真实需要处理交互的地方
    // 获取通知所带的数据
    NSString *notMess = [notification.userInfo objectForKey:@"key"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息提醒"
                                                    message:notMess
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.delegate = self;
    if (!isBackgroud){
    [alert show];
    }
    // 更新显示的徽章个数
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge--;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    
    // 在不需要再推送时，可以取消推送
}


@end
