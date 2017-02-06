//
//  EditPasswordViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "EditPasswordViewController.h"
#import "UserVo.h"

@interface EditPasswordViewController ()<UITextFieldDelegate>
{
    UIBarButtonItem *btnNavRight;
}

@property (weak, nonatomic) IBOutlet UIView *viewContainerView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *containerSep1;
@property (weak, nonatomic) IBOutlet UIView *containerSep2;
@property(nonatomic,weak) IBOutlet UILabel *lblCurrentPwd;
@property(nonatomic,weak) IBOutlet UITextField *txtCurrentPwd;

@property(nonatomic,weak) IBOutlet UILabel *lblNewPwd;
@property(nonatomic,weak) IBOutlet UITextField *txtNewPwd;

@property(nonatomic,weak) IBOutlet UILabel *lblConfirmNewPwd;
@property(nonatomic,weak) IBOutlet UITextField *txtConfirmNewPwd;


@end

@implementation EditPasswordViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewContainerView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.containerView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.containerView.layer.borderColor = [UIColor clearColor].CGColor;
    self.containerSep1.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.containerSep2.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    
    self.txtCurrentPwd.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.txtNewPwd.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.txtConfirmNewPwd.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    
    self.lblCurrentPwd.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.lblNewPwd.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.lblConfirmNewPwd.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    
    
    self.title = @"修改密码";
    
    //right button
    btnNavRight = [self rightBtnItemWithTitle:@"完成"];
    btnNavRight.enabled = NO;
    self.navigationItem.rightBarButtonItem = btnNavRight;
    
    self.txtCurrentPwd.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"当前密码" attributes:@{NSForegroundColorAttributeName:COLOR(221, 208, 204, 1.0)}];
    self.txtNewPwd.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"新密码" attributes:@{NSForegroundColorAttributeName:COLOR(221, 208, 204, 1.0)}];
    self.txtConfirmNewPwd.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"确认密码" attributes:@{NSForegroundColorAttributeName:COLOR(221, 208, 204, 1.0)}];
}

//修改密码
-(void)righBarClick
{
    //当前密码
    NSString *strCurrPwd = self.txtCurrentPwd.text;
    if (strCurrPwd.length == 0)
    {
        [Common tipAlert:@"当前密码不能为空"];
        return;
    }
    else
    {
        //当前密码验证
        if (![strCurrPwd isEqualToString:[Common getUserPwd]])
        {
            [Common tipAlert:@"当前密码不正确"];
            return;
        }
    }
    
    //新密码
    NSString *strNewPwd = self.txtNewPwd.text;
    if (strNewPwd.length == 0)
    {
        [Common tipAlert:@"新密码不能为空"];
        return;
    }
    
    //确认密码
    NSString *strConfirmNewPwd = self.txtConfirmNewPwd.text;
    if (strConfirmNewPwd.length == 0)
    {
        [Common tipAlert:@"确认密码不能为空"];
        return;
    }
    
    //验证新密码和确认密码是否一致
    if (![strNewPwd isEqualToString:strConfirmNewPwd])
    {
        [Common tipAlert:@"新密码与确认密码不一致"];
        return;
    }
    
    //修改密码
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider editUserPassword:[Common getCurrentUserVo].strUserID andNewPwd:strNewPwd andOldPwd:strCurrPwd result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            //刷新视图
            [Common setUserPwd:strNewPwd];
            [Common tipAlert:@"密码修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (IBAction)doValueChanged:(UITextField*)sender
{
    if (self.txtCurrentPwd.text.length == 0 || self.txtNewPwd.text.length == 0 || self.txtConfirmNewPwd.text.length == 0)
    {
        btnNavRight.enabled = NO;
    }
    else
    {
        btnNavRight.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtCurrentPwd)
    {
        [self.txtNewPwd becomeFirstResponder];
    }
    else if(textField == self.txtNewPwd)
    {
        [self.txtConfirmNewPwd becomeFirstResponder];
    }
    else
    {
        [self righBarClick];
    }
    
    return YES;
}

@end
