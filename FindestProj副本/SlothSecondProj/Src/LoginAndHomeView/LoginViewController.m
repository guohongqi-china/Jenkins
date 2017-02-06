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
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Common.h"
#import "SQLiteDBOperator.h"
#import "ServerURL.h"
#import "FaceModel.h"
#import "ChatCountDao.h"
#import "UserVo.h"
#import "GroupAndUserDao.h"
#import "BusinessCommon.h"
#import "Constants+OC.h"
#import "MBProgressHUD.h"
#import "CommitButtonView.h"
#import "RegisterPhoneViewController.h"
#import "MobAnalytics.h"
#import "FindestProj-Swift.h"

@interface LoginViewController ()
{
    CommitButtonView *commitButtonView;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTip;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;

@end

@implementation LoginViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_JPUSH_BROADCAST object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    FaceModel *model = [FaceModel sharedManager];
//    model.ISnO = NO;
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
    //注册广播推送
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jpushBroadcast:) name:NOTIFY_JPUSH_BROADCAST object:nil];
    
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.bFirstAppear)
    {
        if (self.txtPhone.text.length > 0)
        {
            [self.txtPwd becomeFirstResponder];
        }
        else
        {
            [self.txtPhone becomeFirstResponder];
        }
    }
}

- (void)setRightDrawerView:(BOOL)bValue
{
    
}

//广播通知，进入到分享列表
-(void)jpushBroadcast:(NSNotification*)notification
{
    NSDictionary *dicJPushUserInfo = [notification object];
    
    int nNotifyType = -1;
    id objType = [dicJPushUserInfo valueForKey:@"type"];
    if (objType != nil && objType != [NSNull null])
    {
        nNotifyType = [objType intValue];
    }
    
    if (nNotifyType == 6 || nNotifyType == 13)
    {
        id refId = [dicJPushUserInfo valueForKey:@"refId"];
        if (refId != nil && refId != [NSNull null])
        {
            //广播或者@指定分享
//            ShareDetailOldViewController *shareDetailViewController = [[ShareDetailOldViewController alloc]init];
//            BlogVo *blogVo = [[BlogVo alloc]init];
//            blogVo.streamId = [refId stringValue];
//            shareDetailViewController.m_originalBlogVo = blogVo;
//            [self.navigationController pushViewController:shareDetailViewController animated:YES];
        }
        else
        {
            //广播不指定分享
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
}

#pragma mark - Init data
//初始化用户登录数据
- (void)initData
{
    self.loginUserDao = [[LoginUserDao alloc] init];
    LoginUserVo *loginUserVo = [self.loginUserDao getLastLoginUser];
    if(loginUserVo != nil)
    {
        self.txtPhone.text = loginUserVo.strUserAccount;
    }
    
    //清理临时目录（临时图片、临时语音文件）
    [Utils clearTempPath];
}

//初始化视图
- (void)initView
{
    self.isNeedBackItem = NO;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    leftItem.tintColor = COLOR(112, 84, 81, 1.0);
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self setTitleImage:[UIImage imageNamed:@"nav_logo"]];
    self.lblTip.text = [NSString stringWithFormat:@"登录%@。",Constants.strAppName];
    
    @weakify(self)
    commitButtonView = [[CommitButtonView alloc]initWithLeftTitle:@"忘记密码？" right:@"登录" action:^(UIButton *sender) {
        @strongify(self)
        if(sender.tag == 1)
        {
            //登录
            [self loginAction];
        }
        else
        {
            //忘记密码
            RegisterPhoneViewController *registerPhoneViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterPhoneViewController"];
            registerPhoneViewController.viewType = RegisterPhoneResetPwdType;
            [self.navigationController pushViewController:registerPhoneViewController animated:YES];
        }
    }];
    [self.view addSubview:commitButtonView];
    
    [commitButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(0);
        make.height.equalTo(44.5);
    }];
    
    [self checkTextFieldValue];
}

//登录验证
- (void)loginAction
{
    [MobAnalytics event:@"loginButton"];

    NSString *strLoginName = self.txtPhone.text;
    NSString *strLoginPwd = self.txtPwd.text;
    [Common showProgressView:@"登录中..." view:self.view modal:YES];
    [LoginViewController commonLoginAction:strLoginName pwd:strLoginPwd controller:self result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)backButtonClicked
{
    [self.txtPhone resignFirstResponder];
    [self.txtPwd resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//通用登录方法
+ (void)commonLoginAction:(NSString *)strName pwd:(NSString *)strPwd controller:(UIViewController *)parentController result:(LoginBlock)loginBlock
{
    [ServerProvider loginToRestServer:strName andPwd:strPwd result:^(ServerReturnInfo *retInfo) {
        ServerReturnInfo *retInfoLogin = [[ServerReturnInfo alloc]init];
        retInfoLogin.bSuccess = NO;
        if (!retInfo.bSuccess)
        {
            //如果是自动登录，判断是否有超过7天没有登录，则清空密码，重新输入密码登录
            NSString *strErrorMsg = retInfo.strErrorMsg;
            if (strErrorMsg == nil)
            {
                strErrorMsg = @"登录失败，请重试";
            }
            
            retInfoLogin.strErrorMsg = strErrorMsg;
            loginBlock(retInfoLogin);
        }
        else
        {
            //第二次请求，获取登录用户信息以及版本相关
            [ServerProvider getUserDetail:retInfo.data2 result:^(ServerReturnInfo *retUserInfo) {
                if (retInfo.bSuccess)
                {
                    //判断登录用户是否存在
                    UserVo *userVo = (UserVo*)retUserInfo.data;
                    [Common setCurrentUserVo:userVo];//保存当前登录用户信息
                    LoginUserDao *loginUserDao = [[LoginUserDao alloc]init];
                    LoginUserVo *user = [loginUserDao getUserByID:userVo.strUserID];
                    if (user == nil)
                    {
                        //增加登录用户信息
                        user = [[LoginUserVo alloc] init];
                        user.strUserID = userVo.strUserID;
                        user.strUserAccount = strName;
                        user.strPwd = strPwd;
                        user.strEmail = userVo.strEmail;
                        user.strLastLoginTime = [Utils getCurrentDateString];
                        user.nIsRemember = 1;
                        [loginUserDao insertUser:user];
                        
                        //切换用户，清理缓存数据
                        GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                        [groupAndUserDao clearAllBufferDBData];
                    }
                    else
                    {
                        //已存在 更新部分信息
                        user.strUserID = userVo.strUserID;
                        user.strUserAccount = strName;
                        user.strPwd = strPwd;
                        user.strEmail = userVo.strEmail;
                        user.strLastLoginTime = [Utils getCurrentDateString];
                        user.nIsRemember = 1;
                        [loginUserDao updateUser:user];
                    }
                    
                    //关掉键盘（当有AlertView出现时会有键盘）
                    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                    
                    //微企统计分析
                    [MobAnalytics bindUID:strName];
                    
                    //初始化聊天未看数量
                    [ChatCountDao initChatParaSetting];
                    
                    //注册推送
                    [BusinessCommon setJPUSHAliasAndTags];
                    
                    //set value
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:[Common getAppVersion] forKey:@"FIRST_LAUNCH_APP_FLAG"];
                    
                    if ([AppDelegate getSlothAppDelegate].dicJPushUserInfo != nil)
                    {
                        //用于广播消息
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_JPUSH_BROADCAST object:[AppDelegate getSlothAppDelegate].dicJPushUserInfo];
                    }
                    
                    retInfoLogin.bSuccess = YES;
                    loginBlock(retInfoLogin);
                    
                    //进入主界面
                    [LoginViewController enterHomeViewController:parentController];
                }
                else
                {
                    retInfoLogin.strErrorMsg = retInfo.strErrorMsg;
                    loginBlock(retInfoLogin);
                }
            }];
        }
    }];
}

+ (void)enterHomeViewController:(UIViewController *)parentController
{
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    [AppDelegate getSlothAppDelegate].homeViewController = homeViewController;
    [parentController.navigationController pushViewController:homeViewController animated:YES];
}

- (void)checkTextFieldValue {
    if (self.txtPhone.text.length > 0 && self.txtPwd.text.length > 0)
    {
        [commitButtonView setRightButtonEnable:YES];
    }
    else
    {
        [commitButtonView setRightButtonEnable:NO];
    }
}

- (IBAction)textValueChanged:(UITextField *)sender
{
    [self checkTextFieldValue];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtPwd)
    {
        [self loginAction];
    }
    [textField resignFirstResponder];
    return YES;
}

@end
