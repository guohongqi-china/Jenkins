//
//  VerifyJobViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "VerifyJobViewController.h"
#import "CheXiangService.h"
#import "UserProfileViewController.h"

@interface VerifyJobViewController ()<UITextFieldDelegate>
{
    UIBarButtonItem *btnNavRight;
    NSString *strRepeadUserID;
}

@property (weak, nonatomic) IBOutlet UILabel *lblVerifyTip;
@property (weak, nonatomic) IBOutlet UIView *viewFieldContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIView *viewLine;

@end

@implementation VerifyJobViewController

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
    [self.txtNumber becomeFirstResponder];
}

- (void)initView
{
    self.title = self.jobVo.strName;
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.isNeedBackItem = NO;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    leftItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //right button
    btnNavRight = [self rightBtnItemWithTitle:@"完成"];
    btnNavRight.enabled = NO;
    self.navigationItem.rightBarButtonItem = btnNavRight;
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"*工号"];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"metting_Tite_Precolor"] range:NSMakeRange(0, 1)];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"]  range:NSMakeRange(1, 2)];
    self.lblNumber.attributedText = attriString;
    
    attriString = [[NSMutableAttributedString alloc]initWithString:@"*密码"];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"metting_Tite_Precolor"] range:NSMakeRange(0, 1)];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"]range:NSMakeRange(1, 2)];
    self.lblPassword.attributedText = attriString;
    
    
    
    
    
    
    
    
    self.lblVerifyTip.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.txtNumber.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    self.txtPassword.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    _viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
}

- (void)backButtonClicked
{
    [self.txtNumber resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)righBarClick
{
    if(self.txtNumber.text.length == 0)
    {
        [Common tipAlert:@"请输入工号"];
    }
    else if(self.txtPassword.text.length == 0)
    {
        [Common tipAlert:@"请输入密码"];
    }
    else
    {
        [Common showProgressView:nil view:self.view modal:NO];
        [CheXiangService loginToCheXiangServer:self.txtNumber.text pwd:self.txtPassword.text result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                //再次验证操作
                NSString *strRepeatUserID = retInfo.data2;
                if(strRepeatUserID.length > 0)
                {
                    //若被别人绑定则提示
                    strRepeadUserID = retInfo.data2;
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"是否需要查看绑定该工号的用户信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
                    alertView.tag = 1001;
                    [alertView show];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:^{
                        NSDictionary *dicParam = @{@"ChexiangAccount":retInfo.data,@"MyWorkbenchURL":retInfo.data3,@"JobId":self.jobVo.strID};
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"CheXiangVerifyJobNotification" object:dicParam];
                    }];
                }
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)tapBackground
{
    [self.txtNumber resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (IBAction)doValueChanged:(UITextField*)sender
{
    if (self.txtNumber.text.length == 0 || self.txtPassword.text.length == 0)
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
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        //提示被别人绑定信息
        if(buttonIndex == 1)
        {
            UserProfileViewController *userProfileViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
            userProfileViewController.strUserID = strRepeadUserID;
            [self.navigationController pushViewController:userProfileViewController animated:YES];
        }
    }
}
@end
