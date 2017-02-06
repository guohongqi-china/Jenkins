//
//  FirstStartViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "FirstStartViewController.h"
#import "EAIntroView.h"
#import "EAIntroPage.h"
#import "LoginUserDao.h"
#import "Utils.h"
#import "LoginViewController.h"
#import "RegisterNameViewController.h"
#import "CommonNavigationController.h"
#import "UserVo.h"

@interface FirstStartViewController ()<EAIntroDelegate>
{
    EAIntroView *intro;
    UIButton *btnSkipIntro;

    NSString *strName;
    NSString *strPwd;
}

@property (weak, nonatomic) IBOutlet UIView *viewLoading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLogo;        //Logo距离底部的约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLogoH;       //Logo的尺寸
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;      //认真发帖文字的容器底部约束

@end

@implementation FirstStartViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_EXIT_APP object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;
    
    [self initData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(exitAction:) name:NOTIFY_EXIT_APP object:nil];
    
    //显示引导页处理
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strLaunchFlag = [userDefaults stringForKey:@"FIRST_LAUNCH_APP_FLAG"];
    NSString *strAppVersion = [Common getAppVersion];
    
    if (strLaunchFlag == nil)
    {
        //show intro view(第一次安装应用)
        [self showIntroView];
        [Common setFirstEnterAppState:YES];
    }
    else if (![strLaunchFlag isEqualToString:strAppVersion])
    {
        //show intro view(更新后的第一次进入应用，根据版本号判定)
        [self showIntroView];
        [Common setFirstEnterAppState:NO];
    }
    else
    {
        //check auto login
        [self checkAutoLogin];
        [Common setFirstEnterAppState:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//初始化用户登录数据
- (void)initData
{
    //初始化logo的position
    self.constraintLogo.constant = kScreenHeight*0.527;
    [self.view layoutIfNeeded];
    
    [self initAccountAndPwd];
    
    //清理临时目录（临时图片、临时语音文件）
    [Utils clearTempPath];
}

- (void)initAccountAndPwd {
    LoginUserDao *loginUserDao = [[LoginUserDao alloc] init];
    LoginUserVo *loginUserVo = [loginUserDao getLastLoginUser];
    if(loginUserVo != nil)
    {
        strName = loginUserVo.strUserAccount;
        if (loginUserVo.nIsRemember == 1)
        {
            strPwd = loginUserVo.strPwd;
        }
    }
}

//check auto login
- (void)checkAutoLogin
{
    if (strName == nil || strName.length ==0 || strPwd == nil || strPwd.length ==0)
    {
        //1.password is or not memorized
        [self showLoginAndRegisterView];
    }
    else
    {
        //2.auto login
        [LoginViewController commonLoginAction:strName pwd:strPwd controller:self result:^(ServerReturnInfo *retInfo) {
            if (retInfo.bSuccess)
            {
                //登录成功进入home,不做处理
                [self showLoginAndRegisterView];
            }
            else
            {
                //登录失败进入SecondStartViewController
                [self showLoginAndRegisterView];
            }
        }];
    }
}

- (void)showLoginAndRegisterView
{
    [UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //隐藏加载页动画
        self.viewLoading.alpha = 0;
        
        //logo动画
        self.constraintLogo.constant = kScreenHeight-60-35;
        self.constraintLogoH.constant = 35;
        self.constraintBottom.constant = 30;
        [self.view layoutIfNeeded];
        
    } completion:nil];
}

//show introduce view
- (void)showIntroView
{
    [self checkAutoLogin];
    
//    NSMutableArray *aryPageList = [NSMutableArray array];
//    for (int i=1; i<=7; i++)
//    {
//        UIView *viewForPage = [[UIView alloc] initWithFrame:self.view.bounds];
//        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"intro_img%i@2x.jpg",i]]];
//        imgView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        [viewForPage addSubview:imgView];
//        [aryPageList addObject:[EAIntroPage pageWithCustomView:viewForPage]];
//    }
//    
//    intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:aryPageList];
//    intro.backgroundColor = COLOR(75, 103, 107, 1.0);
//    intro.swipeToExit = NO;
//    intro.pageControl.pageIndicatorTintColor = [UIColor orangeColor];
//    intro.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
//    intro.pageControlY = 25;
//    
//    //在最后一页增加“立即体验”功能
//    btnSkipIntro = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnSkipIntro setFrame:CGRectMake(kScreenWidth-107.5-15, kScreenHeight*0.4533, 108, 32.5)];
//    [btnSkipIntro setImage:[UIImage imageNamed:@"btn_intro_skip"] forState:UIControlStateNormal];
//    [btnSkipIntro addTarget:self action:@selector(skipIntroImage) forControlEvents:UIControlEventTouchUpInside];
//    EAIntroPage *viewForPage = aryPageList.lastObject;
//    btnSkipIntro.alpha = 0;
//    [viewForPage.customView addSubview:btnSkipIntro];
//    
//    intro.skipButton = nil;
//    
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.5];
}

-(void)skipIntroImage
{
    [intro skipIntroduction];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if (sender.tag == 1001)
    {
        
        //登录
        LoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"LoginViewController"];
        CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:loginViewController];
        navController.statusBarStyle = UIStatusBarStyleDefault;
        [navController setBarBackgroundImage:[Common getImageWithColor:[UIColor whiteColor]]];
        [self presentViewController:navController animated:YES completion:nil];

       
    }
    else
    {
        //注册
        RegisterNameViewController *registerNameViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterNameViewController"];
        CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:registerNameViewController];
        navController.statusBarStyle = UIStatusBarStyleDefault;
        [navController setBarBackgroundImage:[Common getImageWithColor:[UIColor whiteColor]]];
        //        [navController setBarBackgroundImage:[UIImage imageNamed:@"Default@2x-3guo"]];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

//退出登录，清空数据
-(void)exitAction:(NSNotification *)notification
{
    NSString *strParameter = notification.object;
    if ([strParameter isEqualToString:@"ReLoginNotify"]) {
        //重新登录操作
        [self initAccountAndPwd];
        [self checkAutoLogin];
    } else {
        //退出操作
        [ServerProvider logoutAction:^(ServerReturnInfo *retInfo){}];
        [Common setFirstEnterAppState:NO];
        
        //关掉记住密码
        LoginUserDao *loginUserDao = [[LoginUserDao alloc] init];
        [loginUserDao updateUserRememberPwdState:0 andUserID:[Common getCurrentUserVo].strUserID];
        
        //clear JPush alias
        [BusinessCommon clearJPUSHAliasAndTags];
        
        [AppDelegate getSlothAppDelegate].homeViewController = nil;
        [Common setUserPwd:@""];
        [Common setCurrentUserVo:nil];
        [AppDelegate getSlothAppDelegate].dicJPushUserInfo = nil;
    }
}

#pragma mark - EAIntroDelegate
- (void)swipePage:(NSInteger)nCurrPage
{
    if (nCurrPage == (intro.pages.count-1))
    {
        //最后一页
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            btnSkipIntro.alpha = 1.0;
        } completion:nil];
    }
    else if (nCurrPage < (intro.pages.count-1))
    {
        btnSkipIntro.alpha = 0.0;
    }
}

- (void)introDidFinish
{
    [intro removeFromSuperview];
    [self checkAutoLogin];
}

@end
