//
//  ResetPwdViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "CommitButtonView.h"
#import "Constants+OC.h"

@interface ResetPwdViewController ()
{
    CommitButtonView *commitButtonView;
}

@property (weak, nonatomic) IBOutlet UITextField *txtNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtAgainPwd;

@end

@implementation ResetPwdViewController

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
        [self.txtNewPwd becomeFirstResponder];
    }
}

- (void)initView
{
    [self setTitleImage:[UIImage imageNamed:@"nav_logo"]];
    self.isNeedBackItem = NO;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(backForePage)];
    leftItem.tintColor = THEME_COLOR;
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    commitButtonView = [[CommitButtonView alloc]initWithLeftTitle:nil right:@"完成" action:^(UIButton *sender) {
        @strongify(self);
        
        //重置密码 和重复密码
        NSString *strPassword = self.txtNewPwd.text;
        if (strPassword == nil || strPassword.length==0)
        {
            [Common tipAlert:@"请输入新密码"];
            return;
        }
        NSString *strRepeatPwd = self.txtAgainPwd.text;
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
        
        [self.txtNewPwd resignFirstResponder];
        [self.txtAgainPwd resignFirstResponder];
        
        [Common showProgressView:@"请稍后..." view:self.view modal:NO];
        [ServerProvider resetLoginPwd:self.registerVo.strPhoneNumber andPwd:strPassword andIdentifyingCode:self.registerVo.strIdentifyCode result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                //返回到登录页面
                [Common tipAlert:@"找回密码成功"];
                [self.navigationController popToRootViewControllerAnimated:YES];
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

- (IBAction)buttonAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.txtNewPwd.secureTextEntry = !sender.selected;
    self.txtAgainPwd.secureTextEntry = !sender.selected;
    
    // Workaround to refresh cursor
    NSString *tmpString = self.txtNewPwd.text;
    self.txtNewPwd.text = @" ";
    self.txtNewPwd.text = tmpString;
    
    // Workaround to refresh cursor
    tmpString = self.txtAgainPwd.text;
    self.txtAgainPwd.text = @" ";
    self.txtAgainPwd.text = tmpString;
}

- (IBAction)textValueChanged:(UITextField *)sender
{
    if (self.txtNewPwd.text.length > 0 && self.txtAgainPwd.text.length > 0)
    {
        [commitButtonView setRightButtonEnable:YES];
    }
    else
    {
        [commitButtonView setRightButtonEnable:NO];
    }
}

@end
