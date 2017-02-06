//
//  AppDelegate.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-1-21.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerProvider.h"
#import "NotifyVo.h"
#import "FirstStartViewController.h"
#import "HomeViewController.h"

#define kNormalStart        0           //点击应用图标启动
#define kNotifyStart        1           //点击系统推送通知启动
#define kEnterForeground    2           //点击任务栏应用图标激活
#define kInAPP              3           //应用程序处于激活状态



@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FirstStartViewController *firstStartViewController;
@property (weak, nonatomic) HomeViewController *homeViewController;     //为了提醒跳转
@property (assign, nonatomic) int nStartModal;
@property (strong, nonatomic) NSDictionary *dicJPushUserInfo;       //推送通知信息
@property (strong, nonatomic) NSMutableArray *aryAlertView;
@property (strong, nonatomic) UIImage *imgBK;

@property (assign, nonatomic) CurrentPageName currentPageName;
@property (assign, nonatomic) id currentViewController;
@property (strong, nonatomic) NSArray *aryFace;//表情数据

@property (strong, nonatomic) NSString *strURLSchemeParameter;  //URLScheme参数

+ (AppDelegate*)getSlothAppDelegate;

@end
