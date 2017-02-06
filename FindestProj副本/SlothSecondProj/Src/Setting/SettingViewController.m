//
//  SettingViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewCell.h"
#import "MenuVo.h"
#import "UserSettingViewController.h"
#import "AccountViewController.h"
#import "PrivacySettingViewController.h"
#import "UserShieldListViewController.h"
#import "AboutViewController.h"
#import "SDImageCache.h"
#import "PushSettingViewController.h"
#import "FindestProj-Swift.h"

@interface SettingViewController ()<SettingViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *arySetting;
}

@property (weak, nonatomic) IBOutlet UIButton *btnExit;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSetting;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [self setTitle:@"设置"];
    
    [self.btnExit setBackgroundImage:[Common getImageWithColor:COLOR(54,103,177, 1.0)] forState:UIControlStateNormal];
    self.bottomView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewSetting.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewSetting.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [_tableViewSetting registerNib:[UINib nibWithNibName:@"SettingViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SettingViewCell"];
    
    [self.tableViewSetting reloadData];
}

- (void)initData
{
    arySetting = [NSMutableArray array];
    
    NSMutableArray *aryFirst = [NSMutableArray array];
    MenuVo *menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"personal";
    menuVo.strName = @"个人资料设置";
    [aryFirst addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"shield";
    menuVo.strName = @"已屏蔽的人";
    [aryFirst addObject:menuVo];
    [arySetting addObject:aryFirst];
    
    NSMutableArray *arySecond = [NSMutableArray array];
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"password";
    menuVo.strName = @"账号和密码";
    [arySecond addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"privacy";
    menuVo.strName = @"隐私";
    [arySecond addObject:menuVo];
    [arySetting addObject:arySecond];
    
    NSMutableArray *aryThird = [NSMutableArray array];
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"push";
    menuVo.strName = @"推送消息设置";
    [aryThird addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"audio";
    menuVo.strName = @"内置音效";
    NSNumber *numStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"InnerAudioStatus"];
    if (numStatus == nil || numStatus.integerValue == 1) {
        menuVo.bBoolValue = YES;
    } else {
        menuVo.bBoolValue = NO;
    }
    [aryThird addObject:menuVo];
    [arySetting addObject:aryThird];
    
    NSMutableArray *aryFourth = [NSMutableArray array];
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"clear";
    menuVo.strName = @"清除缓存";
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    menuVo.strRemark = [Common getFileSizeFormatString:[imageCache getSize]];
    [aryFourth addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"about";
//    menuVo.strName = [NSString stringWithFormat:@"关于%@",Constants.strAppName];
    menuVo.strName = @"关于博睿";
    menuVo.strRemark = [NSString stringWithFormat:@"v%@",[Common getAppVersion]];
    [aryFourth addObject:menuVo];
    [arySetting addObject:aryFourth];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要退出当前账号？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定退出", nil];
    [alertView show];
}

#pragma mark - SettingViewDelegate
- (void)switchControlChanged:(MenuVo *)entity state:(BOOL)bOn {
    //设置内置音效
    [[NSUserDefaults standardUserDefaults] setObject:(bOn?@1:@0) forKey:@"InnerAudioStatus"];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //退出当前账号
        [self.navigationController popViewControllerAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_BACKTOHOME object:nil];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //清除SDImageCache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearDisk];
        
        //清除浏览器cache
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [NSURLCache sharedURLCache].diskCapacity = 0;
        
        MenuVo *menuVo = arySetting[3][0];
        menuVo.strRemark = [Common getFileSizeFormatString:0];
        [self.tableViewSetting reloadData];
        
        [Common bubbleTip:@"清除成功" andView:self.view];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arySetting.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = arySetting[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    MenuVo *menuVo = arySetting[indexPath.section][indexPath.row];
    cell.entity = menuVo;
    
    if ([menuVo.strID isEqualToString:@"audio"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MenuVo *menuVo = arySetting[indexPath.section][indexPath.row];
    if ([menuVo.strID isEqualToString:@"personal"])
    {
        UserSettingViewController *userEditViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UserSettingViewController"];
        [self.navigationController pushViewController:userEditViewController animated:YES];
    }
    else if ([menuVo.strID isEqualToString:@"shield"])
    {
        UserShieldListViewController *userShieldListViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UserShieldListViewController"];
        [self.navigationController pushViewController:userShieldListViewController animated:YES];
    }
    else if ([menuVo.strID isEqualToString:@"password"])
    {
        AccountViewController *accountViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AccountViewController"];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
    else if ([menuVo.strID isEqualToString:@"privacy"])
    {
        PrivacySettingViewController *privacySettingViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PrivacySettingViewController"];
        [self.navigationController pushViewController:privacySettingViewController animated:YES];
    }
    else if ([menuVo.strID isEqualToString:@"push"])
    {
        PushSettingViewController *pushSettingViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PushSettingViewController"];
        [self.navigationController pushViewController:pushSettingViewController animated:YES];
    }
    else if ([menuVo.strID isEqualToString:@"clear"])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"确定清除%@本地的缓存数据？",Constants.strAppName]
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"清除缓存"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
    else if ([menuVo.strID isEqualToString:@"about"])
    {
        AboutViewController *aboutViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    CGFloat fHeight = 15;
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return CGFLOAT_MIN;
}

@end
