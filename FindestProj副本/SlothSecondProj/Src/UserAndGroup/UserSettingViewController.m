//
//  UserSettingViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/5.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserSettingViewController.h"
#import "UserSettingCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UserVo.h"
#import "UserEditViewController.h"
#import "UserEditVo.h"
#import "EditUserHeaderViewController.h"

@interface UserSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryUserSection;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewUserInfo;

@end

@implementation UserSettingViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshUserDetail" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"个人资料设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableViewUserInfo.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewUserInfo.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:@"RefreshUserDetail" object:nil];
}

- (void)initData
{
    aryUserSection = [NSMutableArray array];
    
    UserVo *userVo = [Common getCurrentUserVo];
    
    NSMutableArray *aryFirst = [NSMutableArray array];
    UserEditVo *menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"headerImage";
    menuVo.strTitle = @"头像";
    menuVo.strValue = userVo.strHeadImageURL;
    [aryFirst addObject:menuVo];
    [aryUserSection addObject:aryFirst];
    
    NSMutableArray *arySecond = [NSMutableArray array];
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"userName";
    menuVo.strTitle = @"昵称";
    menuVo.strValue = userVo.strUserName;
    menuVo.bRequired = YES;
    menuVo.nMaxLength = 20;
    [arySecond addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"trueName";
    menuVo.strTitle = @"姓名";
    menuVo.strValue = userVo.strRealName;
    menuVo.bRequired = YES;
    menuVo.nMaxLength = 20;
    [arySecond addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"phoneNumber";
    menuVo.strTitle = @"手机";
    menuVo.strValue = userVo.strPhoneNumber;
    menuVo.bRequired = YES;
    [arySecond addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"departmentId";   //公司ID
    menuVo.strTitle = @"公司";
    menuVo.strValue = userVo.strDepartmentName;
    menuVo.strValueID = userVo.strDepartmentId;
    [arySecond addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"title";
    menuVo.strTitle = @"职务";
    menuVo.strValue = userVo.strPosition;
    menuVo.nMaxLength = 20;
    [arySecond addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"signature";
    menuVo.strTitle = @"签名";
    menuVo.strValue = userVo.strSignature;
    menuVo.nMaxLength = 30;
    [arySecond addObject:menuVo];
    [aryUserSection addObject:arySecond];
    
    NSMutableArray *aryThird = [NSMutableArray array];
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"gender";
    menuVo.strTitle = @"性别";
    [aryThird addObject:menuVo];
    if (userVo.gender == 0)
    {
        menuVo.strValue = @"女";
        menuVo.strValueID = @"0";
    }
    else if (userVo.gender == 1)
    {
        menuVo.strValue = @"男";
        menuVo.strValueID = @"1";
    }
    else
    {
        menuVo.strValue = @"";
        menuVo.strValueID = @"2";
    }
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"birthday";
    menuVo.strTitle = @"生日";
    menuVo.strValue = userVo.strBirthday;
    [aryThird addObject:menuVo];
    [aryUserSection addObject:aryThird];
    
    NSMutableArray *aryFourth = [NSMutableArray array];
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"qq";
    menuVo.strTitle = @"QQ";
    menuVo.strValue = userVo.strQQ;
    [aryFourth addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strKey = @"email";
    menuVo.strTitle = @"邮箱";
    menuVo.strValue = userVo.strEmail;
    [aryFourth addObject:menuVo];
    
//    menuVo = [[UserEditVo alloc]init];
//    menuVo.strKey = @"deliveryAddrss";
//    menuVo.strTitle = @"我的收货地址";
//    menuVo.strValue = nil;
//    [aryFourth addObject:menuVo];
    [aryUserSection addObject:aryFourth];
}

- (void)refreshUserInfo
{
    [self.tableViewUserInfo reloadData];
}

- (void)configureCell:(UserSettingCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    UserEditVo *menuVo = aryUserSection[indexPath.section][indexPath.row];
    [cell setEntity:menuVo];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryUserSection.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryUserSection[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSettingCell" forIndexPath:indexPath];
    //cell.selectedBackgroundView.backgroundColor = COLOR(220, 220, 220, 0.5);
    UserEditVo *menuVo = aryUserSection[indexPath.section][indexPath.row];
    cell.entity = menuVo;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"UserSettingCell" cacheByIndexPath:indexPath configuration:^(UserSettingCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserEditVo *menuVo = aryUserSection[indexPath.section][indexPath.row];
    
    if([menuVo.strKey isEqualToString:@"headerImage"])
    {
        EditUserHeaderViewController *editUserHeaderViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"EditUserHeaderViewController"];
        editUserHeaderViewController.menuVo = menuVo;
        [self.navigationController pushViewController:editUserHeaderViewController animated:YES];
    }
    else if([menuVo.strKey isEqualToString:@"deliveryAddrss"])
    {
        
    }
    else
    {
        UserEditViewController *userEditViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UserEditViewController"];
        userEditViewController.menuVo = menuVo;
        [self.navigationController pushViewController:userEditViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    CGFloat fHeight = CGFLOAT_MIN;
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return 15;
}

@end
