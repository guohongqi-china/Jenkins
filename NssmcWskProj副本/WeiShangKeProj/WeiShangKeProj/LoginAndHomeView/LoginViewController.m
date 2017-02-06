//
//  LoginViewController.m
//  Sloth
//
//  Created by Ann Yao on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "Utils.h"
#import "ServerProvider.h"
#import "AppDelegate.h"
#import "Common.h"
#import "SQLiteDBOperator.h"
#import "ServerURL.h"
#import "ChatCountDao.h"
#import "JPUSHService.h"
#import "UserVo.h"
#import "LeftMenuViewController.h"
#import "VersionControlDao.h"
#import "GroupAndUserDao.h"
#import "RegisterAndEditViewController.h"
#import "ChangePasswordViewController.h"
#import "LanguageManage.h"
#import "MainSearchViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "LocationService.h"
#import "LocationManage.h"
#import "EXTScope.h"
#import "UIViewExt.h"
#import "Common.h"
#import "RegisterData.h"
#import "shareModel.h"

@interface LoginViewController ()
{
    NSTimer *timerLocation;
    
    shareModel *model;
    
    UIImageView *imgViewRemember;
    UIButton *btnRememberPwd;
    UIButton *btnRegister;
}
@property (nonatomic, strong) shareModel * modell;/** <#注释#> */

@end

@implementation LoginViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginOutMsg" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SwitchRoleTypeOperation1" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_LANGUAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_JPUSH_BROADCAST object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fd_prefersNavigationBarHidden = YES;
    self.fd_interactivePopDisabled = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearData) name:@"LoginOutMsg" object:nil];
    //仅仅是为了刷新页面而重新进入系统（语言、皮肤）
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reenterHomeView:) name:@"JumpToHomeView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshLanguage) name:NOTIFY_REFRESH_LANGUAGE object:nil];
    
    [self initView];
    [self initData];
    
    //check auto login
    [self checkAutoLogin];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
//    //显示引导页处理
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    id firstLaunchFlag = [userDefaults objectForKey:@"FIRST_LAUNCH_APP_FLAG"];
//    if (firstLaunchFlag == [NSNull null] || firstLaunchFlag == nil)
//    {
//        //show intro view
//        [userDefaults setObject:@"FIRST_LAUNCH_APP_FLAG" forKey:@"FIRST_LAUNCH_APP_FLAG"];
//        [self showIntroView];
//    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}

//退出登录，清空数据
-(void)clearData
{
    //调用登出接口
    dispatch_async(dispatch_get_global_queue(0,0),^{
    	[ServerProvider logoutAction];
    });
    
    //是否保留密码
    if (!self.bRememberPwd)
    {
        self.loginPwd.text = @"";
    }
    
    [self stopTimerLocation];
    //clear JPush alias
    [BusinessCommon clearJPUSHAliasAndTags];
    
    [Common setUserPwd:@""];
    [Common setCurrentUserVo:nil];
    [Common setChatSessionID:@""];
}

//重新进入主界面
-(void)reenterHomeView:(NSNotification*)notification
{
    NSString *strFromPage = @"";
    NSDictionary *dicValue = [notification object];
    if (dicValue != nil)
    {
        strFromPage = [dicValue objectForKey:@"fromView"];
    }
    
    [Common setFirstEnterAppState:NO];
    [self jumpToHomeView:NO];
    
    if ([strFromPage isEqualToString:@"LanguageViewController"])
    {
        //跳转到设置页面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchViewWithKey" object:@"Menu_Setting"];
    }
}

#pragma mark - Init data
//初始化视图
- (void)initView
{
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    CGFloat fHeight = kStatusBarHeight-20;
    
    //背景图片
    self.imgViewBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.imgViewBK.image = [Common getImageWithColor:THEME_COLOR];
    [self.view addSubview:self.imgViewBK];
    
    fHeight += 40;
    //appname label
    self.lblAppName = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 60)];
    self.lblAppName.text = @"用户登录";
    self.lblAppName.font = [UIFont fontWithName:@"Helvetica" size:22];
    self.lblAppName.textColor = [UIColor whiteColor];
    self.lblAppName.textAlignment = NSTextAlignmentCenter;
    self.lblAppName.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lblAppName];
    fHeight += 60;
    
    //middle view
    self.viewMiddleInput = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 104.5)];
    self.viewMiddleInput.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.viewMiddleInput];
    fHeight += 104.5;
    
    //name icon
    self.imgViewNameIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 13.5, 25, 25)];
    self.imgViewNameIcon.image = [UIImage imageNamed:@"login_name_icon"];
    [self.viewMiddleInput addSubview:self.imgViewNameIcon];
    
    //账号输入框
    self.loginName = [[UITextField alloc] initWithFrame:CGRectMake(35, 0, kScreenWidth-35, 52)];
    _loginName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _loginName.placeholder = @" 用户名";
    _loginName.returnKeyType = UIReturnKeyNext;
    _loginName.keyboardType = UIKeyboardTypeEmailAddress;
    _loginName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _loginName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _loginName.font = [UIFont systemFontOfSize:17];
    _loginName.backgroundColor = [UIColor whiteColor];
    _loginName.delegate = self;
    [self.viewMiddleInput addSubview:_loginName];
    
    //水平 line
    self.viewLineH1 = [[UIView alloc]initWithFrame:CGRectMake(0, 52, kScreenWidth, 0.5)];
    self.viewLineH1.backgroundColor = COLOR(179, 179, 179, 1.0);
    [self.viewMiddleInput addSubview:self.viewLineH1];
    
    //pwd icon
    self.imgViewPwdIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 52.5+13.5, 25, 25)];
    self.imgViewPwdIcon.image = [UIImage imageNamed:@"login_pwd_icon"];
    [self.viewMiddleInput addSubview:self.imgViewPwdIcon];
    
    //密码输入框
    self.loginPwd = [[UITextField alloc] initWithFrame:CGRectMake(35, 52.5, kScreenWidth-35-82, 52)];
    _loginPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _loginPwd.placeholder = @" 密码";
    _loginPwd.returnKeyType = UIReturnKeyDone;
    _loginPwd.keyboardType = UIKeyboardTypeASCIICapable;
    _loginPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _loginPwd.clearButtonMode = UITextFieldViewModeWhileEditing;
    _loginPwd.secureTextEntry = YES;
    _loginPwd.font = [UIFont systemFontOfSize:17];
    _loginPwd.delegate = self;
    [self.viewMiddleInput addSubview:_loginPwd];
    
    //垂直线
    self.viewLineV1 = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth-82, 52.5+8, 1, 36)];
    self.viewLineV1.backgroundColor = COLOR(179, 179, 179, 1.0);
    [self.viewMiddleInput addSubview:self.viewLineV1];
    
    //找回密码
    self.btnRegainPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnRegainPwd.tag = 1002;
    self.btnRegainPwd.frame = CGRectMake(kScreenWidth-81, 52.5, 81, 52);
    [self.btnRegainPwd setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [self.btnRegainPwd setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnRegainPwd.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [self.btnRegainPwd setTitle:@"重置密码" forState:UIControlStateNormal];
    [self.btnRegainPwd addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewMiddleInput addSubview:self.btnRegainPwd];
    
    //登录按钮
    self.btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnLogin.frame = CGRectMake(0, fHeight, kScreenWidth, 53);
    [self.btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnLogin setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnLogin.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [self.btnLogin setTitle:[Common localStr:@"Login_Action" value:@"点击登录"] forState:UIControlStateNormal];
    [self.btnLogin setBackgroundImage:[Common getImageWithColor:COLOR(26, 107, 88, 1.0)] forState:UIControlStateNormal];
    [self.btnLogin addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnLogin];
    
    //记住密码
    imgViewRemember = [[UIImageView alloc]initWithFrame:CGRectMake(15,self.btnLogin.bottom+11, 21, 21)];
    imgViewRemember.image = [UIImage imageNamed:@"btn_not_remember_pwd"];
    [self.view addSubview:imgViewRemember];
    
    btnRememberPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRememberPwd.frame = CGRectMake(15, self.btnLogin.bottom+10, 95, 25);
    [btnRememberPwd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRememberPwd setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnRememberPwd.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    [btnRememberPwd setTitle:@"记住密码" forState:UIControlStateNormal];
    [btnRememberPwd addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [Common getStringSize:btnRememberPwd.titleLabel.text font:btnRememberPwd.titleLabel.font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:btnRememberPwd.titleLabel.lineBreakMode];
    btnRememberPwd.titleEdgeInsets = UIEdgeInsetsMake(0, -(btnRememberPwd.frame.size.width-size.width)+50, 0, 0);
    [self.view addSubview:btnRememberPwd];

    
    //注册
    btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake((kScreenWidth-65-10), self.btnLogin.bottom+10, 65, 25);
    [btnRegister setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [btnRegister setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnRegister.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    [btnRegister setTitle:@"　 注册" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRegister];
}

//初始化用户登录数据
- (void)initData
{
    self.bRememberPwd = NO;
    self.loginUserDao = [[LoginUserDao alloc] init];
    LoginUserVo *loginUserVo = [self.loginUserDao getLastLoginUser];
    if(loginUserVo != nil)
    {
        self.loginName.text = loginUserVo.strUserAccount;
        if (loginUserVo.nIsRemember == 1)
        {
            self.loginPwd.text = loginUserVo.strPwd;
            self.bRememberPwd = YES;
            imgViewRemember.image = [UIImage imageNamed:@"btn_remember_pwd"];
        }
    }
    
    //清理临时目录（临时图片、临时语音文件）
    [Utils clearTempPath];
}

//check auto login
- (void)checkAutoLogin
{       
    NSString *strNameTemp = _loginName.text;
    NSString *strPwdTemp = _loginPwd.text;
    if (strNameTemp == nil ||strNameTemp.length ==0 || strPwdTemp == nil ||strPwdTemp.length ==0) 
    {
        //1.password is or not memorized
        return;
    }
    else
    {
        //2.auto login
        [self login];
    }
}

//登录验证
- (void)login
{
//    //C:跳转到主界面
//    [self jumpToHomeView:YES];
//    return;
   
   
    self.strLoginName = _loginName.text;
    self.strLoginPwd = _loginPwd.text;
//    _modell = [shareModel sharedManager];

    if (self.strLoginName == nil || self.strLoginName.length==0)
    {
        [Common tipAlert:[Common localStr:@"Login_AccountEmpty" value:@"用户名不能为空"]];
    }
    else if(self.strLoginPwd == nil || self.strLoginPwd.length==0 )
    {
        [Common tipAlert:[Common localStr:@"Login_PwdEmpty" value:@"密码不能为空"]];
    }
    else
    {
        //隐藏键盘
        [_loginName resignFirstResponder];
        [_loginPwd resignFirstResponder];
        
        //网络判断
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.center = CGPointMake(HUD.center.x, HUD.center.y-53);
        HUD.delegate = self;
        [self.view addSubview:HUD];
        
        [HUD showWhileExecuting:@selector(loginTask) onTarget:self withObject:nil animated:YES];
    }
}

- (void)loginTask
{
//                     self.modell = [shareModel sharedManager];

    ServerReturnInfo *retInfo = [ServerProvider loginToRestServer:self.strLoginName andPwd:self.strLoginPwd];
    if (!retInfo.bSuccess) 
    {
        //如果是自动登录，判断是否有超过7天没有登录，则清空密码，重新输入密码登录
        NSString *strErrorMsg = retInfo.strErrorMsg;
        if (strErrorMsg == nil)
        {
            strErrorMsg = [Common localStr:@"Login_FailureTip" value:@"登录失败，请重试"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [Common tipAlert:strErrorMsg];
        });
    } 
    else 
    {
        //第二次请求，获取登录用户信息以及版本相关
        ServerReturnInfo *retUserInfo = [ServerProvider getUserDetail:retInfo.data2];
        if (retUserInfo.bSuccess) 
        {
            //判断登录用户是否存在
            UserVo *userVo = (UserVo*)retUserInfo.data;
            [Common setCurrentUserVo:userVo];//保存当前登录用户信息
            [[NSUserDefaults standardUserDefaults]setObject:userVo.strUserID forKey:@"userID"];
            LoginUserVo *user = [self.loginUserDao getUserByID:userVo.strUserID];
            if (user == nil) 
            {
                //增加登录用户信息
                user = [[LoginUserVo alloc] init];
                user.strUserID = userVo.strUserID;
                user.strUserAccount = _loginName.text;
                user.strPwd = _loginPwd.text;
                user.strEmail = userVo.strEmail;
                user.strLastLoginTime = [Utils getCurrentDateString];
                user.nIsRemember = self.bRememberPwd?1:0;
                [self.loginUserDao insertUser:user];
                
                //切换用户，清理缓存数据
                GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                [groupAndUserDao clearAllBufferDBData];
            } 
            else 
            {
                //已存在 更新部分信息
                user.strUserID = userVo.strUserID;
                user.strUserAccount = _loginName.text;
                user.strPwd = _loginPwd.text;
                user.strEmail = userVo.strEmail;
                user.strLastLoginTime = [Utils getCurrentDateString];
                user.nIsRemember = self.bRememberPwd?1:0;
                [self.loginUserDao updateUser:user];
            }

            dispatch_async(dispatch_get_main_queue(), ^{

                NSString *DeviceName = @"";

//                DeviceName = [DeviceName substringToIndex:8];
                NSString *phoneAndAlis = [NSString stringWithFormat:@"%@%@",DeviceName,[Common getCurrentUserVo].strUserID];  // 设备的唯一标识
                NSLog(@"我我我我我我我我我我我我我我我%@",[NSString stringWithFormat:@"%@",phoneAndAlis]);
                [JPUSHService setTags:[NSSet set] alias:[NSString stringWithFormat:@"%@",phoneAndAlis] callbackSelector:nil object:nil]; // @"EB457286" 测试的设备标识
                
                //初始化聊天未看数量
                [ChatCountDao initChatParaSetting];
//                //更新本地化语言到后台
//                [LanguageManage updateLanguageToServer];
                
                //如果是切换公司登录，查看是否缓存了其他公司数据，有则清空缓存数据
                VersionControlDao *versionControlDao = [[VersionControlDao alloc]init];
                if ([versionControlDao checkBufferOtherCompanyData])
                {
                    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                    [groupAndUserDao clearAllBufferDBData];
                }
                
                //A:重新获得新数据
                self.currLoginUserVo = [self.loginUserDao getLastLoginUser];
                
                //B:注册推送
                [BusinessCommon setJPUSHAliasAndTags];
                
                //C:跳转到主界面
                [self jumpToHomeView:YES];
                
                //D:启动定位操作
                [self startTimerLocation];

                

            });
        }
    }
}

//跳转到主界面
- (void)jumpToHomeView:(BOOL)animated
{
    LeftMenuViewController *leftMenuViewController = [[LeftMenuViewController alloc] init];
    leftMenuViewController.mainSearchViewController = [[MainSearchViewController alloc] init];
    
    UIViewController *leftSideDrawerViewController = leftMenuViewController;
    UIViewController *centerViewController = leftMenuViewController.mainSearchViewController;
    
    UINavigationController * navigationController = [[MMNavigationController alloc] initWithRootViewController:centerViewController];
    navigationController.navigationBarHidden = YES;
    
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:leftSideDrawerViewController rightDrawerViewController:nil];

    [drawerController setRestorationIdentifier:@"MMDrawer"];
    [drawerController setMaximumLeftDrawerWidth:DRAWER_LEFT_WIDTH];
    drawerController.showsShadow = NO;
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];

    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block;
        block = [[MMExampleDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
        if(block)
        {
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    [self.navigationController pushViewController:drawerController animated:animated];
}

//按钮action
- (void)buttonAction:(UIButton*)sender
{
    if (sender == self.btnLogin)
    {
        //登录
        [self login];
    }
    else if (sender == btnRememberPwd)
    {
        //记住密码
        self.bRememberPwd = !self.bRememberPwd;
        if(self.bRememberPwd)
        {
            imgViewRemember.image = [UIImage imageNamed:@"btn_remember_pwd"];
        }
        else
        {
            imgViewRemember.image = [UIImage imageNamed:@"btn_not_remember_pwd"];
        }
    }
    else if(sender == self.btnRegainPwd)
    {
        //找回密码
        ChangePasswordViewController *changePasswordViewController = [[ChangePasswordViewController alloc]init];
        [self.navigationController pushViewController:changePasswordViewController animated:YES];
    }
    else if (sender == btnRegister)
    {
            model = [shareModel sharedManager];
            model.locationBool = shareModelLocationNo;
            [model shareModelStartToLocation];
        //注册
        RegisterAndEditViewController *registerViewController = [[RegisterAndEditViewController alloc]initWithNibName:@"RegisterAndEditViewController" bundle:nil];
        registerViewController.viewType = RegisterUserType;//EditUserType RegisterUserType;
        [self.navigationController pushViewController:registerViewController animated:YES];
    }
}

//定时定位操作//////////////////////////////////////////////////////////////////////////////////////////////
- (void)startTimerLocation
{
    timerLocation = [NSTimer timerWithTimeInterval:3600 target:self selector:@selector(locationAction) userInfo:nil repeats:YES];
    [timerLocation fire];
}

- (void)stopTimerLocation
{
    [timerLocation invalidate];
    timerLocation = nil;
}

- (void)locationAction
{
    //TODO:如果是工作时间以外则不上传时间 ???????
    LocationManage *locationManage = [LocationManage sharedLocationManage];
    [locationManage startLocation:^(BMKUserLocation *userLocation) {
        if (userLocation)
        {
            //发送定位信息到服务器
            [LocationService uploadLocation:userLocation.location result:^(ServerReturnInfo *retInfo) {
            
            }];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.loginName)
    {
        [self.loginPwd becomeFirstResponder];
    } 
    else if (textField == self.loginPwd)
    {
        [self login];
    }
    //[textField resignFirstResponder];
    return YES;
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud 
{
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark - UIAlertViewDelegate


-(void)doJPushFirst:(NSNotification *)notification
{
    self.notifyJPushInfo = notification;
}

//隐藏键盘
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch*touch =[touches anyObject];
	if(touch.phase==UITouchPhaseBegan)
    {
		//find first response view
		for(UIView *view in [self.viewMiddleInput subviews])
        {
			if([view isFirstResponder])
            {
				[view resignFirstResponder];
				break;
			}
		}
	}
}

//show introduce view
- (void)showIntroView
{
    NSMutableArray *aryPageList = [NSMutableArray array];
    for (int i=0; i<6; i++)
    {
        UIView *viewForPage = [[UIView alloc] initWithFrame:self.view.bounds];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"intro_img%i",i+1]]];
        imgView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [viewForPage addSubview:imgView];
        [aryPageList addObject:[EAIntroPage pageWithCustomView:viewForPage]];
    }
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:aryPageList];
    intro.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    intro.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    intro.pageControlY = 25;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(220, kScreenHeight-40, 100, 40)];
    [btn setTitle:@"Skip" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    intro.skipButton = btn;
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.5];
}

#pragma mark - EAIntroDelegate
- (void)introDidFinish
{

}

- (void)refreshLanguage
{
//    self.lblAppName.text = [Common localStr:@"Setting_About_Title" value:@"知新 2"];
//    
//    self.loginName.placeholder = [Common localStr:@"Login_Account" value:@"账号"];
//    self.loginPwd.placeholder = [Common localStr:@"Login_Pwd" value:@"密码"];
//    [self.logoButton setTitle:[Common localStr:@"Login_Action" value:@"登 录"] forState:UIControlStateNormal];
//    [self.btnRememberPwd setTitle:[Common localStr:@"Login_RememberPwd" value:@"记住密码"] forState:UIControlStateNormal];
//    CGSize size = [Common getStringSize:self.btnRememberPwd.titleLabel.text font:self.btnRememberPwd.titleLabel.font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:self.btnRememberPwd.titleLabel.lineBreakMode];
//    self.btnRememberPwd.titleEdgeInsets = UIEdgeInsetsMake(0, -(self.btnRememberPwd.frame.size.width-size.width)+45, 0, 0);
//    
//    [self.btnRegister setTitle:[Common localStr:@"Login_Activation" value:@"激　活"] forState:UIControlStateNormal];
//    [self.btnRegainPwd setTitle:[Common localStr:@"Login_RegainPwd" value:@"找回密码?"] forState:UIControlStateNormal];
//    self.lblFoot.text = [NSString stringWithFormat:@"CopyRight © 2012-2014 %@",[Common localStr:@"Login_CopyRight" value:@"知新 版权所有"]];
}

@end
