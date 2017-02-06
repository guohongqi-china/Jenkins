//
//  ChangePasswordViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-4-8.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
@class TheCountdownButton;
@interface ChangePasswordViewController : QNavigationViewController<UITextFieldDelegate>

//必填项//////////////////////////////////////////////////////////
@property(nonatomic,strong)UILabel *lblMustCompleteOption;
@property(nonatomic,strong)UIImageView *imgViewTopBK;

//账号
@property(nonatomic,strong)UILabel *lblAccount;
@property(nonatomic,strong)UITextField *txtAccount;

//验证码
@property(nonatomic,strong)UILabel *lblIdentifyingCode;
@property(nonatomic,strong)UITextField *txtIdentifyingCode;
@property(nonatomic,strong)TheCountdownButton *btnCode;

//重置密码
@property(nonatomic,strong)UILabel *lblPwd;
@property(nonatomic,strong)UITextField *txtPwd;

//重复密码
@property(nonatomic,strong)UILabel *lblRepeatPwd;
@property(nonatomic,strong)UITextField *txtRepeatPwd;

//找回按钮//////////////////////////////////////////////////////////
@property(nonatomic,strong)UIButton *btnChangePwd;

@end
