//
//  ChangePasswordViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-4-8.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Common.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    [self setTopNavBarTitle:@"找回密码"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat fHeight = NAV_BAR_HEIGHT+10.0;
    
    self.imgViewTopBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 4*41)];
    self.imgViewTopBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.view addSubview:self.imgViewTopBK];
    
    //1.手机号
    self.lblPhoneNum = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 65, 17)];
    self.lblPhoneNum.text = @"手 机 号";
    self.lblPhoneNum.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblPhoneNum.textColor = COLOR(51, 51, 51, 1.0);
    self.lblPhoneNum.textAlignment = NSTextAlignmentCenter;
    self.lblPhoneNum.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lblPhoneNum];
    
    self.txtPhoneNum = [[UITextField alloc]initWithFrame:CGRectMake(90,fHeight+12,kScreenWidth-110,17)];
    self.txtPhoneNum.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtPhoneNum.textColor = COLOR(51, 51, 51, 1.0);
    self.txtPhoneNum.placeholder = @"请输入您的手机号";
    self.txtPhoneNum.delegate = self;
    self.txtPhoneNum.tag = 501;
    self.txtPhoneNum.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.txtPhoneNum];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.view addSubview:viewLine];
    fHeight += 41;
    
    //2.验证码
    self.lblIdentifyingCode = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 65, 17)];
    self.lblIdentifyingCode.text = @"验 证 码";
    self.lblIdentifyingCode.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblIdentifyingCode.textColor = COLOR(51, 51, 51, 1.0);
    self.lblIdentifyingCode.textAlignment = NSTextAlignmentCenter;
    self.lblIdentifyingCode.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lblIdentifyingCode];
    
    self.txtIdentifyingCode = [[UITextField alloc]initWithFrame:CGRectMake(90,fHeight+12, 120,17)];
    self.txtIdentifyingCode.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtIdentifyingCode.textColor = COLOR(51, 51, 51, 1.0);
    self.txtIdentifyingCode.placeholder = @"请输入验证码";
    self.txtIdentifyingCode.delegate = self;
    self.txtIdentifyingCode.tag = 505;
    self.txtIdentifyingCode.keyboardType = UIKeyboardTypeNamePhonePad;
    [self.view addSubview:self.txtIdentifyingCode];
    
    self.btnCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnCode.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.btnCode setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Nav_Bar_Color"]] forState:UIControlStateNormal];
    [self.btnCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.btnCode.frame = CGRectMake(kScreenWidth-105, fHeight+5.5, 90, 30);
    [self.btnCode.layer setBorderWidth:1.0];
    [self.btnCode.layer setCornerRadius:3];
    self.btnCode.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnCode.layer setMasksToBounds:YES];
    [self.btnCode addTarget:self action:@selector(getIdentifyingCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnCode];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.view addSubview:viewLine];
    fHeight += 41;
    
    //3.重置密码
    self.lblPwd = [[UILabel alloc]initWithFrame:CGRectMake(20,fHeight+12,65,(17))];
    self.lblPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.lblPwd.textColor = COLOR(51, 51, 51, 1.0);
    self.lblPwd.text = @"重置密码";
    self.lblPwd.textAlignment = NSTextAlignmentRight;
    self.lblPwd.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lblPwd];
    
    self.txtPwd = [[UITextField alloc]initWithFrame:CGRectMake(90, fHeight+12,kScreenWidth-110, (17))];
    self.txtPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.txtPwd.textColor = COLOR(51, 51, 51, 1.0);
    self.txtPwd.secureTextEntry = YES;
    self.txtPwd.placeholder = @"请输入您的密码";
    self.txtPwd.delegate = self;
    self.txtPwd.tag = 502;
    [self.view addSubview:self.txtPwd];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.view addSubview:viewLine];
    fHeight += 41;
    
    //4.重复密码
    self.lblRepeatPwd = [[UILabel alloc]initWithFrame:CGRectMake(20,fHeight+12,65,(17))];
    self.lblRepeatPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.lblRepeatPwd.textColor = COLOR(51, 51, 51, 1.0);
    self.lblRepeatPwd.text = @"重复密码";
    self.lblRepeatPwd.textAlignment = NSTextAlignmentRight;
    self.lblRepeatPwd.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lblRepeatPwd];
    
    self.txtRepeatPwd = [[UITextField alloc]initWithFrame:CGRectMake(90, fHeight+12,kScreenWidth-110, (17))];
    self.txtRepeatPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.txtRepeatPwd.textColor = COLOR(51, 51, 51, 1.0);
    self.txtRepeatPwd.secureTextEntry = YES;
    self.txtRepeatPwd.placeholder = @"请输入您的密码";
    self.txtRepeatPwd.delegate = self;
    self.txtRepeatPwd.tag = 503;
    [self.view addSubview:self.txtRepeatPwd];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.view addSubview:viewLine];
    fHeight += 41;
    
    //4.register button
    self.btnChangePwd = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnChangePwd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnChangePwd.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [self.btnChangePwd setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Nav_Bar_Color"]] forState:UIControlStateNormal];
    [self.btnChangePwd setTitle:@"找回密码" forState:UIControlStateNormal];
    self.btnChangePwd.frame = CGRectMake(40, fHeight+12, kScreenWidth-80, 30);
    [self.btnChangePwd.layer setBorderWidth:1.0];
    [self.btnChangePwd.layer setCornerRadius:3];
    self.btnChangePwd.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnChangePwd.layer setMasksToBounds:YES];
    [self.btnChangePwd addTarget:self action:@selector(doChangePwd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnChangePwd];
}

-(void)getIdentifyingCode
{
    NSString *strPhoneNum = self.txtPhoneNum.text;
    if (strPhoneNum == nil || strPhoneNum.length == 0)
    {
        [Common tipAlert:@"请输入手机号码"];
        return;
    }
    
    [self isHideActivity:NO];
    [ServerProvider sendChangePwdIdentifyingCode:strPhoneNum result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

-(void)doChangePwd
{
    //1.手机号
    NSString *strPhoneNum = self.txtPhoneNum.text;
    if (strPhoneNum == nil || strPhoneNum.length==0)
    {
        [Common tipAlert:@"请输入手机号码"];
        return;
    }
    
    //2.验证码	发送到对应手机
    NSString *strIdentifyCode = self.txtIdentifyingCode.text;
    if (strIdentifyCode == nil || strIdentifyCode.length==0)
    {
        [Common tipAlert:@"请输入验证码"];
        return;
    }

    //3.重置密码 和重复密码
    NSString *strPassword = self.txtPwd.text;
    if (strPassword == nil || strPassword.length==0)
    {
        [Common tipAlert:@"请输入重置密码"];
        return;
    }
    NSString *strRepeatPwd = self.txtRepeatPwd.text;
    if (strRepeatPwd == nil || strRepeatPwd.length==0)
    {
        [Common tipAlert:@"请输入重复密码"];
        return;
    }
    if (![strPassword isEqualToString:strRepeatPwd])
    {
        [Common tipAlert:@"重置密码与重复密码不一致"];
        return;
    }
    
    [self isHideActivity:NO];
    [ServerProvider resetLoginPwd:strPhoneNum andPwd:strPassword andIdentifyingCode:strIdentifyCode result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [Common tipAlert:@"找回密码成功"];
            [self backButtonClicked];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//隐藏键盘
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch*touch =[touches anyObject];
	if(touch.phase==UITouchPhaseBegan)
    {
		//find first response view
		for(UIView*view in[self.view subviews])
        {
			if([view isFirstResponder])
            {
				[view resignFirstResponder];
				break;
			}
		}
	}
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
