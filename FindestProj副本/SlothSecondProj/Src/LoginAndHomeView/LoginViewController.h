//
//  LoginViewController.h
//  Sloth
//
//  Created by Ann Yao on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginUserDao.h"
#import "LoginUserVo.h"
#import "CommonViewController.h"

typedef void (^LoginBlock)(ServerReturnInfo *retInfo);

@interface LoginViewController : CommonViewController <UIAlertViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) LoginUserVo *currLoginUserVo;         //当前登录用户信息
@property (nonatomic, strong) LoginUserDao *loginUserDao;

- (void)setRightDrawerView:(BOOL)bValue;
//通用登录方法
+ (void)commonLoginAction:(NSString *)strName pwd:(NSString *)strPwd controller:(UIViewController *)parentController result:(LoginBlock)loginBlock;

@end
