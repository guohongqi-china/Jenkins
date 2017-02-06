//
//  EditPasswordViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-18.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "EditPasswordViewController.h"
#import "Utils.h"
#import "UIViewExt.h"
#import "RecordModel.h"
@interface EditPasswordViewController ()

@property (nonatomic, strong) RecordModel *RDModel;/** <#注释#> */
@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmNewPwd;

@end

@implementation EditPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (RecordModel *)RDModel{
    if (!_RDModel) {
        _RDModel = [[RecordModel alloc]initWith:self voiceView:self.view];
    }
    return _RDModel;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}


- (IBAction)Down:(UIButton *)sender {
    
    [self.RDModel recordStart];
    
}

- (IBAction)Up:(UIButton *)sender {
    [self.RDModel recordStop];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:@"修改密码"];
    
    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(showSideMenu)];
    [self setLeftBarButton:btnBack];
    
    //notice num view
    NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
    [self.view addSubview:noticeNumView];
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
}

- (IBAction)doCompleteModifyPwd
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
    [self isHideActivity:NO];
    [ServerProvider editUserPassword:strNewPwd andOldPwd:strCurrPwd result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            //刷新视图
            [Common setUserPwd:strNewPwd];
            [Common tipAlert:@"密码修改成功"];
            [self isHideActivity:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
