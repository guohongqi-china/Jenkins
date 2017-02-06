//
//  RegisterCodeViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RegisterCodeViewController.h"
#import "CommitButtonView.h"
#import "RegisterPwdViewController.h"
#import "ResetPwdViewController.h"
#import "Constants+OC.h"

@interface RegisterCodeViewController ()<UITextFieldDelegate>
{
    CommitButtonView *commitButtonView;
    
    NSTimer *_timer;
    NSUInteger nSecond;
}

@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UILabel *lblNum1;
@property (weak, nonatomic) IBOutlet UILabel *lblNum2;
@property (weak, nonatomic) IBOutlet UILabel *lblNum3;
@property (weak, nonatomic) IBOutlet UILabel *lblNum4;
@property (weak, nonatomic) IBOutlet UILabel *lblNum5;
@property (weak, nonatomic) IBOutlet UILabel *lblNum6;
@property (weak, nonatomic) IBOutlet UIButton *btnResendCode;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblCodeTip;

@end

@implementation RegisterCodeViewController

- (void)dealloc
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.bFirstAppear)
    {
        [self.txtCode becomeFirstResponder];
        [self sendPhoneCode];
    }
}

- (void)initView
{
    [self setTitleImage:[UIImage imageNamed:@"nav_logo"]];
    self.isNeedBackItem = NO;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(backForePage)];
    leftItem.tintColor = THEME_COLOR;
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
    [_viewContainer addGestureRecognizer:recognizer];
    
    self.lblCodeTip.text = [NSString stringWithFormat:@"短信验证码已发送至 %@",self.registerVo.strPhoneNumber];
    
    @weakify(self)
    commitButtonView = [[CommitButtonView alloc]initWithLeftTitle:nil right:@"下一步" action:^(UIButton *sender) {
        @strongify(self)
        //验证码的有效性
        [Common showProgressView:@"请稍后..." view:self.view modal:NO];
        NSString *strCode = [NSString stringWithFormat:@"%@%@%@%@%@%@",self.lblNum1.text,self.lblNum2.text,self.lblNum3.text,self.lblNum4.text,self.lblNum5.text,self.lblNum6.text];
        
        [ServerProvider validatePhoneAndCode:self.registerVo.strPhoneNumber code:strCode result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            //重置密码页面
            if(retInfo.bSuccess)
            {
                if (self.viewType == RegisterCodeRegisterType)
                {
                    //注册密码页面
                    RegisterPwdViewController *registerPwdViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterPwdViewController"];
                    self.registerVo.strIdentifyCode = strCode;
                    registerPwdViewController.registerVo = self.registerVo;
                    [self.navigationController pushViewController:registerPwdViewController animated:YES];
                }
                else
                {
                    //重置密码页面
                    ResetPwdViewController *resetPwdViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"ResetPwdViewController"];
                    self.registerVo.strIdentifyCode = strCode;
                    resetPwdViewController.registerVo = self.registerVo;
                    [self.navigationController pushViewController:resetPwdViewController animated:YES];
                }
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
        
    }];
    [self.view addSubview:commitButtonView];
    
    [commitButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(0);
        make.height.equalTo(44.5);
    }];
}

- (void)tapBackground
{
    [self.txtCode becomeFirstResponder];
}

//设置获取验证码间隔时间
- (void)setValidateIntervalTime
{
    //设置按钮不可用
    self.btnResendCode.enabled = NO;
    [self.btnResendCode setTitle:@"60秒后 重新发送验证码" forState:UIControlStateDisabled];
    
    //设置倒计时
    nSecond = 60;
    if(_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateValidateButton) userInfo:nil repeats:YES];
}

- (void)updateValidateButton
{
    if (nSecond <=0)
    {
        [_timer invalidate];
        _timer = nil;
        
        [self.btnResendCode setTitle:@"重新发送验证码" forState:UIControlStateNormal];
        self.btnResendCode.enabled = YES;
    }
    else
    {
        [self.btnResendCode setTitle:[NSString stringWithFormat:@"%lu秒后 重新发送验证码",(unsigned long)nSecond] forState:UIControlStateDisabled];
        nSecond --;
    }
}

- (IBAction)textValueChanged:(UITextField *)sender
{
    if (sender.text.length == 6)
    {
        [commitButtonView setRightButtonEnable:YES];
    }
    else
    {
        [commitButtonView setRightButtonEnable:NO];
    }
}

- (IBAction)buttonAction:(UIButton *)sender
{
    [self setValidateIntervalTime];
    [self sendPhoneCode];
}

//发送验证码
-(void)sendPhoneCode
{
    [Common showProgressView:@"请稍后..." view:self.view modal:NO];
    [ServerProvider sendIdentifyingCode:self.registerVo.strPhoneNumber result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [self setValidateIntervalTime];
            [Common bubbleTip:@"验证码已发送" andView:self.view];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([toBeString length] > 6 && string.length > 0)
    {
        return NO;
    }
    else
    {
        UILabel *lblTemp = [self valueForKey:[NSString stringWithFormat:@"_lblNum%lu",(unsigned long)range.location+1]];
        lblTemp.text = string;
    }
    return YES;
}

@end
