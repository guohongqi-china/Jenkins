//
//  RegisterPhoneViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RegisterPhoneViewController.h"
#import "CommitButtonView.h"
#import "RegisterCodeViewController.h"
#import "Constants+OC.h"

@interface RegisterPhoneViewController ()
{
    CommitButtonView *commitButtonView;
}

@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewValidate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintIconH;

@end

@implementation RegisterPhoneViewController

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
        [self.txtPhone becomeFirstResponder];
    }
}

- (void)initView
{
    if (self.viewType == RegisterPhoneRegisterType)
    {
        [self setTitleImage:[UIImage imageNamed:@"nav_logo"]];
    }
    else
    {
        [self setTitle:@"重置密码"];
        [self setTitleColor:COLOR(41, 47, 51, 1.0)];
    }
    
    self.isNeedBackItem = NO;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(backForePage)];
    leftItem.tintColor = THEME_COLOR;
    self.navigationItem.leftBarButtonItem = leftItem;
    
    @weakify(self)
    commitButtonView = [[CommitButtonView alloc]initWithLeftTitle:nil right:@"下一步" action:^(UIButton *sender) {
        @strongify(self)
        [Common showProgressView:@"请稍后..." view:self.view modal:NO];
        [ServerProvider checkPhone:self.txtPhone.text result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            [self.txtPhone resignFirstResponder];
            
            if(retInfo.bSuccess)
            {
                if(self.registerVo == nil)
                {
                    self.registerVo = [[UserVo alloc]init];
                }
                    
                RegisterCodeViewController *registerCodeViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterCodeViewController"];
                self.registerVo.strPhoneNumber = self.txtPhone.text;
                self.registerVo.strLoginAccount = self.txtPhone.text;
                registerCodeViewController.registerVo = self.registerVo;
                
                //手机号不存在
                if ([retInfo.data isEqualToString:@"true"])
                {
                    if (self.viewType == RegisterCodeRegisterType)
                    {
                        //注册
                        registerCodeViewController.viewType = RegisterCodeRegisterType;
                        [self.navigationController pushViewController:registerCodeViewController animated:YES];
                    }
                    else
                    {
                        //找回密码
                        [Common bubbleTip:@"手机号不存在" andView:self.view];
                    }
                }
                else//手机号存在
                {
                    if (self.viewType == RegisterCodeRegisterType)
                    {
                        //注册
                        [Common bubbleTip:@"手机号存在" andView:self.view];
                    }
                    else
                    {
                        //找回密码
                        registerCodeViewController.viewType = RegisterCodeResetPwdType;
                        [self.navigationController pushViewController:registerCodeViewController animated:YES];
                    }
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

- (IBAction)textValueChanged:(UITextField *)sender
{
    if (sender.text.length > 0)
    {
        [commitButtonView setRightButtonEnable:YES];
        
        if (self.imgViewValidate.alpha < 0.0001)//浮点数
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.imgViewValidate.alpha = 1.0;
                self.constraintIconH.constant = 20;
                [self.view layoutIfNeeded];
            }];
        }
    }
    else
    {
        [commitButtonView setRightButtonEnable:NO];
        
        if (self.imgViewValidate.alpha > 0.0001)//浮点数
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.imgViewValidate.alpha = 0;
                self.constraintIconH.constant = 10;
                [self.view layoutIfNeeded];
            }];
        }
    }
}

@end
