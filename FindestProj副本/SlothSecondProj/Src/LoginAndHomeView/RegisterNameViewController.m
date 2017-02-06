//
//  RegisterNameViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RegisterNameViewController.h"
#import "CommitButtonView.h"
#import "EXTScope.h"
#import "RegisterCompanyViewController.h"
#import "FindestProj-Swift.h"

@interface RegisterNameViewController ()
{
    CommitButtonView *commitButtonView;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewValidate;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintIconH;

@end

@implementation RegisterNameViewController

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
        [self.txtName becomeFirstResponder];
    }
}

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)initView
{
    self.isNeedBackItem = NO;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    leftItem.tintColor = COLOR(112, 84, 81, 1.0);
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self setTitleImage:[UIImage imageNamed:@"nav_logo"]];
    
    @weakify(self)
    commitButtonView = [[CommitButtonView alloc]initWithLeftTitle:nil right:@"下一步" action:^(UIButton *sender) {
        @strongify(self)
        [self.txtName resignFirstResponder];
        RegisterAccountViewController *registerAccountViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterAccountViewController"];
        UserVo *registerVo = [[UserVo alloc] init];
        registerVo.strUserName = self.txtName.text;
        registerVo.strRealName = self.txtName.text;
        registerAccountViewController.registerVo = registerVo;
        [self.navigationController pushViewController:registerAccountViewController animated:YES];
        
        //        RegisterCompanyViewController *registerCompanyViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterCompanyViewController"];
        //        UserVo *registerVo = [[UserVo alloc] init];
        //        registerVo.strUserName = self.txtName.text;
        //        registerVo.strRealName = self.txtName.text;
        //        registerCompanyViewController.registerVo = registerVo;
        //        [self.navigationController pushViewController:registerCompanyViewController animated:YES];
    }];
    [self.view addSubview:commitButtonView];
    
    [commitButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(0);
        make.height.equalTo(44.5);
    }];
}

- (void)backButtonClicked
{
    [self.txtName resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
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
