//
//  AppDelegate.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-1-21.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "ServerProvider.h"
#import "NotifyVo.h"
#import "ChatContentVo.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

#define kNormalStart        0           //点击应用图标启动
#define kNotifyStart        1           //点击系统推送通知启动
#define kEnterForeground    2           //点击任务栏应用图标激活
#define kInAPP              3           //应用程序处于激活状态

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (assign, nonatomic) int nStartModal;
@property (strong, nonatomic) NSDictionary *dicJPushUserInfo; //推送通知信息
@property (strong, nonatomic) NSMutableArray *aryAlertView;
@property (strong, nonatomic) UIImage *imgBK;

//自定义启动图片
@property (strong, nonatomic) UIImageView *imgViewLoading;

@property (assign, nonatomic) CurrentPageName currentPageName;
@property (assign, nonatomic) id currentViewController;
@property (strong, nonatomic) NSArray *aryFace;//表情数据

@property (strong, nonatomic) ChatObjectVo *chatObjectVo;


//是否有新的聊天推送，用于切换tab的时候刷新聊天列表
@property (assign, nonatomic) BOOL bChatJPUSH;
@property (assign, nonatomic) BOOL bRespondsToViewWillAppear;//用于防止返回后bottom tab 的显示

+ (AppDelegate*)getSlothAppDelegate;

@end
