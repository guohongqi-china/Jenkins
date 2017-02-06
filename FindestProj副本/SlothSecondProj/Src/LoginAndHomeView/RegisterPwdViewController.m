//
//  RegisterPwdViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RegisterPwdViewController.h"
#import "CommitButtonView.h"
#import "Constants+OC.h"
#import "LoginViewController.h"

@interface RegisterPwdViewController ()
{
    CommitButtonView *commitButtonView;
}

@property (weak, nonatomic) IBOutlet UITextField *txtPwd;

@end

@implementation RegisterPwdViewController

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
        [self.txtPwd becomeFirstResponder];
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
        @strongify(self)
        if (self.txtPwd.text.length == 0)
        {
            [Common bubbleTip:@"密码不可以为空" andView:self.view];
        }
        else
        {
            [self.txtPwd resignFirstResponder];
            self.registerVo.strPassword = self.txtPwd.text;
            [Common showProgressView:@"请稍后..." view:self.view modal:NO];
            [ServerProvider registerUserAction:self.registerVo result:^(ServerReturnInfo *retInfo) {
                [Common hideProgressView:self.view];
                if (retInfo.bSuccess)
                {
                    //注册成功 - 进行登录操作
                    [LoginViewController commonLoginAction:self.registerVo.strLoginAccount pwd:self.registerVo.strPassword controller:self result:^(ServerReturnInfo *retInfo) {
                        if (retInfo.bSuccess)
                        {
                            //登录成功进入home,不做处理
                        }
                        else
                        {
                            //登录失败
                            [Common tipAlert:retInfo.strErrorMsg];
                        }
                    }];
                }
                else
                {
                    //注册失败
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
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
    self.txtPwd.secureTextEntry = !sender.selected;
    
    // Workaround to refresh cursor
    NSString *tmpString = self.txtPwd.text;
    self.txtPwd.text = @" ";
    self.txtPwd.text = tmpString;
}

- (IBAction)textValueChanged:(UITextField *)sender
{
    if (sender.text.length > 0)
    {
        [commitButtonView setRightButtonEnable:YES];
    }
    else
    {
        [commitButtonView setRightButtonEnable:NO];
    }
}

@end
