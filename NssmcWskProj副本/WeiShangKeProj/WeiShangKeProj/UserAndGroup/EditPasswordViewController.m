//
//  EditPasswordViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-18.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "EditPasswordViewController.h"
#import "Utils.h"

@interface EditPasswordViewController ()

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
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:[Common localStr:@"UserGroup_ChangePwd" value:@"修改密码"]];
    UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Done" value:@"完成"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doCompleteModifyPwd)];
    [self setRightBarButton:addTeamItem];
    
    CGFloat fHeight = NAV_BAR_HEIGHT;
    //1.bk
    self.imgViewBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight+10, kScreenWidth, 3*41)];
    self.imgViewBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:105 topCapHeight:22];
    [self.view addSubview:self.imgViewBK];
    
    //当前密码
    fHeight += 10;
    self.lblCurrentPwd = [[UILabel alloc]initWithFrame:CGRectMake(15,fHeight+12,(100),(17))];
    self.lblCurrentPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.lblCurrentPwd.textColor = COLOR(19, 19, 19, 1.0);
    self.lblCurrentPwd.text = [Common localStr:@"UserGroup_OldPassword" value:@"当前密码"];
    self.lblCurrentPwd.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblCurrentPwd];
    
    self.txtCurrentPwd = [[UITextField alloc]initWithFrame:CGRectMake(30+(68)+20, fHeight+12, 270-(68)-20, (17))];
    self.txtCurrentPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.txtCurrentPwd.textColor = COLOR(19, 19, 19, 1.0);
    self.txtCurrentPwd.secureTextEntry = YES;
    self.txtCurrentPwd.placeholder = [Common localStr:@"UserGroup_OldPassword" value:@"当前密码"];
    self.txtCurrentPwd.delegate = self;
    [self.view addSubview:self.txtCurrentPwd];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+(42), kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.view addSubview:viewLine];
    
    fHeight += (43);
    
    //新密码
    self.lblNewPwd = [[UILabel alloc]initWithFrame:CGRectMake(15,fHeight+12,(100),(17))];
    self.lblNewPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.lblNewPwd.textColor = COLOR(19, 19, 19, 1.0);
    self.lblNewPwd.text = [Common localStr:@"UserGroup_NewPassword" value:@"新 密 码"];
    self.lblNewPwd.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblNewPwd];
    
    self.txtNewPwd = [[UITextField alloc]initWithFrame:CGRectMake(30+(68)+20, fHeight+12, 270-(68)-20, (17))];
    self.txtNewPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.txtNewPwd.textColor = COLOR(19, 19, 19, 1.0);
    self.txtNewPwd.secureTextEntry = YES;
    self.txtNewPwd.placeholder = [Common localStr:@"UserGroup_NewPassword" value:@"新 密 码"];
    self.txtNewPwd.delegate = self;
    [self.view addSubview:self.txtNewPwd];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+(42), kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.view addSubview:viewLine];
    
    fHeight += (43);
    
    //确认密码
    self.lblConfirmNewPwd = [[UILabel alloc]initWithFrame:CGRectMake(15,fHeight+12,(100),(17))];
    self.lblConfirmNewPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.lblConfirmNewPwd.textColor = COLOR(19, 19, 19, 1.0);
    self.lblConfirmNewPwd.text = [Common localStr:@"UserGroup_ConfirmPassword" value:@"确认密码"];
    self.lblConfirmNewPwd.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblConfirmNewPwd];
    
    self.txtConfirmNewPwd = [[UITextField alloc]initWithFrame:CGRectMake(30+(68)+20, fHeight+12, 270-(68)-20, (17))];
    self.txtConfirmNewPwd.font = [UIFont fontWithName:APP_FONT_NAME size:(16)];
    self.txtConfirmNewPwd.textColor = COLOR(19, 19, 19, 1.0);
    self.txtConfirmNewPwd.secureTextEntry = YES;
    self.txtConfirmNewPwd.placeholder = [Common localStr:@"UserGroup_ConfirmPassword" value:@"确认密码"];
    self.txtConfirmNewPwd.delegate = self;
    [self.view addSubview:self.txtConfirmNewPwd];
}

//修改密码
-(void)doCompleteModifyPwd
{
    //当前密码
    NSString *strCurrPwd = self.txtCurrentPwd.text;
    if (strCurrPwd.length == 0)
    {
        [Common tipAlert:[Common localStr:@"UserGroup_OldPasswordEmpty" value:@"当前密码不能为空"]];
        return;
    }
    else
    {
        //当前密码验证
        if (![strCurrPwd isEqualToString:[Common getUserPwd]])
        {
            [Common tipAlert:[Common localStr:@"UserGroup_OldPasswordError" value:@"当前密码不正确"]];
            return;
        }
    }
    
    //新密码
    NSString *strNewPwd = self.txtNewPwd.text;
    if (strNewPwd.length == 0)
    {
        [Common tipAlert:[Common localStr:@"UserGroup_NewPwdEmpty" value:@"新密码不能为空"]];
        return;
    }
    
    //确认密码
    NSString *strConfirmNewPwd = self.txtConfirmNewPwd.text;
    if (strConfirmNewPwd.length == 0)
    {
        [Common tipAlert:[Common localStr:@"UserGroup_ConfirmPwdEmpty" value:@"确认密码不能为空"]];
        return;
    }
    
    //验证新密码和确认密码是否一致
    if (![strNewPwd isEqualToString:strConfirmNewPwd])
    {
        [Common tipAlert:[Common localStr:@"UserGroup_PwdDiff" value:@"新密码与确认密码不一致"]];
        return;
    }
    
    //获取群组详情
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider editUserPassword:self.strUserID andNewPwd:strNewPwd andOldPwd:strCurrPwd];
    	if (retInfo.bSuccess)
    	{
        	dispatch_async(dispatch_get_main_queue(), ^{
                [Common setUserPwd:strNewPwd];
                [Common tipAlert:[Common localStr:@"UserGroup_ChangePwdSuccess" value:@"密码修改成功"]];
                [self isHideActivity:YES];
                [self.navigationController popViewControllerAnimated:YES];
        	});
    	}
    	else
    	{
        	dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:retInfo.strErrorMsg];
                [self isHideActivity:YES];
        	});
    	}
    });
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
