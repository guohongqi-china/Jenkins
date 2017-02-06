//
//  PersonalViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/30.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "PersonalViewController.h"
#import "MenuViewCell.h"
#import "UserVo.h"
#import "UIImageView+WebCache.h"
#import "HomeViewController.h"
#import "SettingViewController.h"
#import "UserProfileViewController.h"
#import "SuggestionListViewController.h"
#import "IntegrationViewController.h"
#import "ActivityListViewController.h"
#import "MyJobListViewController.h"
#import "IntegralInfoVo.h"
#import "CardWebViewController.h"
#import "FindestProj-Swift.h"
#import "AuditViewController.h"
#import "FaceModel.h"
@interface PersonalViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryMenuSection;
    UserVo *userVo;
}

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLevel;
@property (weak, nonatomic) IBOutlet UIView *viewTopLine;
@property (weak, nonatomic) IBOutlet UIView *viewBottomLine;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnTapBK;

@end

@implementation PersonalViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshUserDetail" object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    UIWindow *win = [UIApplication sharedApplication].windows.lastObject;
    win.backgroundColor = [UIColor clearColor];
    [super viewWillAppear:animated];
        self.navigationController.navigationBar.translucent = NO;
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
    self.title = @"个人";
    self.isNeedBackItem = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:@"RefreshUserDetail" object:nil];
    
    userVo = [Common getCurrentUserVo];
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    _imgViewIndicator.image = [SkinManage imageNamed:@"table_accessory"];
    
    _lblName.text = userVo.strUserName;
    _lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:userVo.fIntegrationCount].strLevelImage];
    [_btnTapBK setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Table_Selected_Color"]] forState:UIControlStateHighlighted];
    
    _viewHeader.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    _viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _viewBottomLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewMenu.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.tableViewMenu.scrollsToTop = NO;
    
    [self.tableViewMenu registerNib:[UINib nibWithNibName:@"MenuViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MenuViewCell"];
}

- (void)initData
{
    aryMenuSection = [NSMutableArray array];
    
    NSMutableArray *arySecond = [NSMutableArray array];
    MenuVo *menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"Personal2";
    menuVo.strName = @"我的积分";
    menuVo.strImageName = @"menu_integral";
    [arySecond addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"Personal3";
    menuVo.strName = @"我的活动";
    menuVo.strImageName = @"menu_order";
    [arySecond addObject:menuVo];
    [aryMenuSection addObject:arySecond];
    
    NSMutableArray *aryFourth = [NSMutableArray array];
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"Personal5";
    menuVo.strName = @"夜间模式";
    menuVo.strImageName = @"menu_night";
    [aryFourth addObject:menuVo];
    
//    menuVo = [[MenuVo alloc]init];
//    menuVo.strID = @"Personal4";
//    menuVo.strName = @"圈子";
//    menuVo.strImageName = @"menu_group";//menu_group
//    [aryFourth addObject:menuVo];
    FaceModel *model = [FaceModel sharedManager];
    if (model.ISnO) {
        menuVo = [[MenuVo alloc]init];
        menuVo.strID = @"Personal7";
        menuVo.strName = @"审核";
        menuVo.strImageName = @"menu_learning";//menu_group
        [aryFourth addObject:menuVo];
    }
 
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"Personal6";
    menuVo.strName = @"设置";
    menuVo.strImageName = @"menu_setting";
    [aryFourth addObject:menuVo];
    [aryMenuSection addObject:aryFourth];
    
    [self.tableViewMenu reloadData];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.translucent = NO;
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeViewController hideBottomTabBar:NO];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)refreshSkin
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setTitleColor:[SkinManage colorNamed:@"Nav_Bar_Title_Color"]];
        [self.navigationController.navigationBar setBarTintColor:[SkinManage colorNamed:@"Theme_Color"]];
        
        _imgViewIndicator.image = [SkinManage imageNamed:@"table_accessory"];
        _lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        [_btnTapBK setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Table_Selected_Color"]] forState:UIControlStateHighlighted];
        
        _viewHeader.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        _viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        _viewBottomLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        
        self.tableViewMenu.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        self.tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    } completion:^(BOOL finished) {
        [self.navigationController.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    }];
}

- (void)refreshUserInfo
{
    userVo = [Common getCurrentUserVo];
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    _lblName.text = userVo.strUserName;
}

- (IBAction)buttonAction:(UIButton *)sender
{
    UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
    userProfileViewController.strUserID = [Common getCurrentUserVo].strUserID;
    [self.homeViewController hideBottomTabBar:YES];
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryMenuSection.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryMenuSection[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuViewCell" forIndexPath:indexPath];
    MenuVo *menuVo = aryMenuSection[indexPath.section][indexPath.row];
    cell.entity = menuVo;
    
    if ([menuVo.strID isEqualToString:@"Personal5"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuVo *menuVo = aryMenuSection[indexPath.section][indexPath.row];
    if([menuVo.strID isEqualToString:@"Personal0"])
    {
        MyJobListViewController *myJobListViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyJobListViewController"];
        myJobListViewController.jobListPageType = MyJobListPageType;
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:myJobListViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"Personal1"])
    {
        CardWebViewController *cardWebVC = [[CardWebViewController alloc]init];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:cardWebVC animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"Personal2"])
    {
        IntegrationViewController *integrationViewController = [[UIStoryboard storyboardWithName:@"IntegrationModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IntegrationViewController"];
        [self.homeViewController hideBottomTabBar:YES];
        MenuVo *menuVo = [[MenuVo alloc]init];
        menuVo.strName = @"我的积分";
        menuVo.strImageName = @"integral_home";
        [self.navigationController pushViewController:integrationViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"Personal3"])
    {
        [MobAnalytics event:@"activityEntry" attributes:@{@"type":@"order"}];
        
        //我的活动
        ActivityListViewController *activityListViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        activityListViewController.activityListType = ActivityListOrderType;
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:activityListViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"Personal7"])
    {
        //审核
        AuditViewController *communityViewController = [[AuditViewController alloc]initWithNibName:@"AuditViewController" bundle:nil];
        [self.homeViewController hideBottomTabBar:YES];
        communityViewController.perSONcONTROLER = self;
        [self.navigationController pushViewController:communityViewController animated:YES];
    }

    else if([menuVo.strID isEqualToString:@"Personal4"])
    {
        //我的圈子
        CommunityViewController *communityViewController = [[UIStoryboard storyboardWithName:@"CommunityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CommunityViewController"];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:communityViewController animated:YES];
    }
    else if ([menuVo.strID isEqualToString:@"Personal6"])
    {
        //设置
        SettingViewController *settingViewController = [[UIStoryboard storyboardWithName:@"PersonalModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SettingViewController"];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:settingViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
