//
//  DiscoveryViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/30.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "MenuVo.h"
#import "MenuViewCell.h"
#import "HomeViewController.h"
#import "MeetingBookingViewController.h"
#import "TopRangkingManageViewController.h"
#import "BarCodeScanViewController.h"
#import "SuggestionListViewController.h"
#import "FootballLotteryViewController.h"
#import "ActivityHomeViewController.h"
#import "FullScreenWebViewController.h"
#import "FindestProj-Swift.h"

@interface DiscoveryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryMenuSection;
}

@end

@implementation DiscoveryViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
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
    self.title = @"发现";
    self.isNeedBackItem = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    
    self.tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewMenu.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.tableViewMenu.scrollsToTop = NO;
    
    [self.tableViewMenu registerNib:[UINib nibWithNibName:@"MenuViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MenuViewCell"];
}

- (void)initData
{
    aryMenuSection = [NSMutableArray array];
    
    NSMutableArray *aryTop = [NSMutableArray array];
    MenuVo *menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"0";
    menuVo.strName = @"活动";
    menuVo.strImageName = @"menu_activity";
    [aryTop addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"2";
    menuVo.strName = @"排行";
    menuVo.strImageName = @"menu_ranking";
    [aryTop addObject:menuVo];
    [aryMenuSection addObject:aryTop];
    
    NSMutableArray *aryMiddle = [NSMutableArray array];
    aryMiddle = [NSMutableArray array];
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"3";
    menuVo.strName = @"扫一扫";
    menuVo.strImageName = @"menu_scan";
    [aryMiddle addObject:menuVo];
    [aryMenuSection addObject:aryMiddle];
    
    [self.tableViewMenu reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTitleColor:[SkinManage colorNamed:@"Nav_Bar_Title_Color"]];
    [self.navigationController.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeViewController hideBottomTabBar:NO];
}

- (void)refreshSkin
{
    [self setTitleColor:[SkinManage colorNamed:@"Nav_Bar_Title_Color"]];
    [self.navigationController.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    
    self.tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewMenu.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    [self.tableViewMenu reloadData];
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
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MenuVo *menuVo = (aryMenuSection[indexPath.section])[indexPath.row];
    
    if([menuVo.strID isEqualToString:@"0"])
    {
        [MobAnalytics event:@"activityEntry" attributes:@{@"type":@"activity"}];
        
        ActivityHomeViewController *activityHomeViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivityHomeViewController"];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:activityHomeViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"1"])
    {
        FootballLotteryViewController *footballLotteryViewController = [[UIStoryboard storyboardWithName:@"FootballModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FootballLotteryViewController"];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:footballLotteryViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"2"])
    {
        TopRangkingManageViewController *topRangkingManageViewController = [[TopRangkingManageViewController alloc]init];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:topRangkingManageViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"3"])
    {
        BarCodeScanViewController *barCodeScanViewController = [[BarCodeScanViewController alloc]init];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:barCodeScanViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"4"])
    {
        //会议室预订
        MeetingBookingViewController *meetingBookingViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MeetingBookingViewController"];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:meetingBookingViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"6"])
    {
        //合理化建议
        SuggestionListViewController *suggestionListViewController = [[SuggestionListViewController alloc]init];
        suggestionListViewController.suggestionListType = SuggestionListAllType;
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:suggestionListViewController animated:YES];
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
