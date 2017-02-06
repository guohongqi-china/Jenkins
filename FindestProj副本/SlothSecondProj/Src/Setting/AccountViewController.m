//
//  AccountViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AccountViewController.h"
#import "EditPasswordViewController.h"
#import "UserVo.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnEditPassword;
@property (weak, nonatomic) IBOutlet UIView *viewContainerView;
@property (weak, nonatomic) IBOutlet UILabel *accountLoginLab;

@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *pwdLab;
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)initView
{
    self.title = @"账号和密码";
    
    
    self.viewContainerView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.accountLoginLab.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblAccount.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.passwordView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];;
    self.passwordView.layer.borderColor = [UIColor clearColor].CGColor;
    self.pwdLab.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    self.accessoryImageView.image= [SkinManage imageNamed:@"table_accessory"];;
    
    NSMutableString *strAccount = [[NSMutableString alloc]initWithString:[Common getCurrentUserVo].strLoginAccount];
    //    if (strAccount.length>=11)
    //    {
    //        [strAccount deleteCharactersInRange:NSMakeRange(3, 4)];
    //        [strAccount insertString:@"****" atIndex:3];
    //    }
    _lblAccount.text = strAccount;
    
    [_btnEditPassword setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editPassword:(UIButton *)sender
{
    EditPasswordViewController *editPasswordViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"EditPasswordViewController"];
    [self.navigationController pushViewController:editPasswordViewController animated:YES];
}

@end
