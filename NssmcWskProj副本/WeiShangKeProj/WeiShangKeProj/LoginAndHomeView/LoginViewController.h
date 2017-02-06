//
//  LoginViewController.h
//  Sloth
//
//  Created by Ann Yao on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "LoginUserDao.h"
#import "LoginUserVo.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "MMNavigationController.h"
#import "LoginUserDao.h"
#import "EAIntroView.h"
#import "EAIntroPage.h"

@interface LoginViewController : UIViewController<UIAlertViewDelegate,MBProgressHUDDelegate,UITextFieldDelegate,EAIntroDelegate>
{
    MBProgressHUD *HUD;//等待进度条
}

@property (nonatomic, strong) UIImageView *imgViewBK;

@property (nonatomic, strong) UILabel *lblAppName;

@property (nonatomic, strong) UIView *viewMiddleInput;
@property (nonatomic, strong) UIImageView *imgViewNameIcon;
@property (nonatomic, strong) UITextField *loginName;               //登录名称
@property (nonatomic, strong) UIImageView *imgViewPwdIcon;
@property (nonatomic, strong) UITextField *loginPwd;                //登陆密码

@property (nonatomic, strong) UIView *viewLineH1;//水平线1
@property (nonatomic, strong) UIView *viewLineV1;//垂直线1

@property (nonatomic, strong) UIButton *btnLogin;
@property (nonatomic, strong) UIButton *btnRegainPwd;//找回密码

@property (nonatomic, strong) LoginUserVo *currLoginUserVo;         //当前登录用户信息
@property (nonatomic, strong) NSNotification *notifyJPushInfo;

@property (nonatomic, strong) NSString *strLoginName;
@property (nonatomic, strong) NSString *strLoginPwd;

@property (nonatomic)BOOL bRememberPwd;                   //是否记住密码
@property (nonatomic, strong) LoginUserDao *loginUserDao;

@end
