//
//  LeftMenuViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-13.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "LeftMenuCell.h"
#import "UserVo.h"
#import "ServerURL.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ChatCountDao.h"
#import "BarCodeScanViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "CommonNavigationController.h"

static BOOL bShowLeftMenu = NO;

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BindNoticeNum" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SwitchViewWithKey" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateSessionTipNum" object:nil];
}

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
    self.fd_prefersNavigationBarHidden = YES;
    self.fd_interactivePopDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindNoticeNum) name:@"BindNoticeNum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchViewWithKey:) name:@"SwitchViewWithKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchViewWithKey:) name:@"updateSessionStatusNum" object:nil];
    
    [self initData];
    [self initView];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)initView
{
    CGFloat fHeight = kStatusBarHeight-20;
    //1.bk color
    self.view.backgroundColor = COLOR(31, 31, 31, 1.0);
    
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.scrollViewBody = [[UIScrollView alloc]initWithFrame:rect];
    self.scrollViewBody.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollViewBody.delegate = self;
	self.scrollViewBody.clipsToBounds = YES;
	self.scrollViewBody.scrollEnabled = YES;
	self.scrollViewBody.pagingEnabled = NO;
    self.scrollViewBody.autoresizingMask = NO;
    self.scrollViewBody.scrollsToTop = NO;
	[self.scrollViewBody setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.scrollViewBody];
    
    self.imgViewNotify = [[UIImageView alloc]initWithFrame:CGRectMake(DRAWER_LEFT_WIDTH-17-25, 12.5, 25, 25)];
    self.imgViewNotify.image = [UIImage imageNamed:@"notify_bell"];
    [self.scrollViewBody addSubview:self.imgViewNotify];
    
    self.lblAppName = [[UILabel alloc] initWithFrame:CGRectMake(10, fHeight, DRAWER_LEFT_WIDTH-10, 25)];
    self.lblAppName.font = [UIFont fontWithName:APP_FONT_NAME size:16.0];
    self.lblAppName.backgroundColor = [UIColor clearColor];
    self.lblAppName.textAlignment = NSTextAlignmentLeft;
    self.lblAppName.textColor = THEME_COLOR;
    self.lblAppName.text = @"菱信工单系统";
    [self.scrollViewBody addSubview:self.lblAppName];
    fHeight += 25;
    
    //4.name
    self.lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(10, fHeight, DRAWER_LEFT_WIDTH-10, 25)];
    self.lblUserName.font = [UIFont fontWithName:APP_FONT_NAME size:15.0];
    self.lblUserName.backgroundColor = [UIColor clearColor];
    self.lblUserName.textAlignment = NSTextAlignmentLeft;
    self.lblUserName.textColor = COLOR(255, 255, 255, 1);
    self.lblUserName.text = [Common getCurrentUserVo].strRealName;
    [self.scrollViewBody addSubview:self.lblUserName];
    fHeight += 25;
    
    //6.table view menu
    self.tableViewMenu = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableViewMenu.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableViewMenu.backgroundView = nil;
    _tableViewMenu.dataSource = self;
    _tableViewMenu.delegate = self;
    _tableViewMenu.scrollEnabled = NO;
    _tableViewMenu.scrollsToTop = NO;
    _tableViewMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollViewBody addSubview:_tableViewMenu];
    
    //为了动态计算tableView的高度，强制进行渲染计算（Force the table view to calculate its height）
    [self.tableViewMenu layoutIfNeeded];
    self.tableViewMenu.frame = CGRectMake(0, fHeight, kScreenWidth, self.tableViewMenu.contentSize.height);
    fHeight += self.tableViewMenu.contentSize.height;
    
    if (fHeight<kScreenHeight)
    {
        fHeight = kScreenHeight+0.5;
    }
    [self.scrollViewBody setContentSize:CGSizeMake(kScreenWidth, fHeight)];
    
    self.noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectZero];
    
    //初次选中维修单
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchViewWithKey" object:@"menu_my_ticket"];
}

- (void)initData
{
    //section 数组
    self.arySection = [@[@"",@"工单分类查看",@"设置",@"其他"] mutableCopy];

    self.aryMenu = [NSMutableArray array];
    //菜单数组
    //分组1
    NSMutableArray *aryMenuTemp = [NSMutableArray array];
    LeftMenuVo *leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"14";
    leftMenuVo.strName = @"可抢工单";
    leftMenuVo.strKey = @"menu_grab_ticket";
    leftMenuVo.strImageName = @"menu_grab_ticket";
    [aryMenuTemp addObject:leftMenuVo];
    
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"15";
    leftMenuVo.strName = @"我的工单";
    leftMenuVo.strKey = @"menu_my_ticket";
    leftMenuVo.strImageName = @"menu_worksheet";
    [aryMenuTemp addObject:leftMenuVo];
    
    [self.aryMenu addObject:aryMenuTemp];
    
    //分组2（工单分类查看）
    self.arySessionTypeMenu = [NSMutableArray array];
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"21";
    leftMenuVo.strName = @"未结束";
    leftMenuVo.strKey = @"menu_processing";
    leftMenuVo.strImageName = nil;
    leftMenuVo.bNotice = YES;
    leftMenuVo.numNotice = @0;
    [self.arySessionTypeMenu addObject:leftMenuVo];
    
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"22";
    leftMenuVo.strName = @"已结束";
    leftMenuVo.strKey = @"menu_processed";
    leftMenuVo.strImageName = nil;
    leftMenuVo.bNotice = YES;
    leftMenuVo.numNotice = @0;
    [self.arySessionTypeMenu addObject:leftMenuVo];
    
    [self.aryMenu addObject:self.arySessionTypeMenu];
    
    //分组3(设置)
    aryMenuTemp = [NSMutableArray array];
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"31";
    leftMenuVo.strName = @"我的信息";
    leftMenuVo.strKey = @"menu_my_info";
    leftMenuVo.strImageName = @"menu_my_info";
    [aryMenuTemp addObject:leftMenuVo];
    
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"32";
    leftMenuVo.strName = @"修改密码";
    leftMenuVo.strKey = @"menu_modify_pwd";
    leftMenuVo.strImageName = @"menu_modify_pwd";
    [aryMenuTemp addObject:leftMenuVo];
    
    [self.aryMenu addObject:aryMenuTemp];
    
    //分组4(其他)
    aryMenuTemp = [NSMutableArray array];
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"41";
    leftMenuVo.strName = @"关于";
    leftMenuVo.strKey = @"menu_about";
    leftMenuVo.strImageName = @"menu_about";
    [aryMenuTemp addObject:leftMenuVo];
    
    leftMenuVo = [[LeftMenuVo alloc]init];
    leftMenuVo.strMenuID = @"42";
    leftMenuVo.strName = @"退出";
    leftMenuVo.strKey = @"menu_exit";
    leftMenuVo.strImageName = @"menu_exit";
    [aryMenuTemp addObject:leftMenuVo];
    
    [self.aryMenu addObject:aryMenuTemp];
    
    
    //user basic info
//    UserVo *userVo = [Common getCurrentUserVo];
//    self.lblName.text = userVo.strUserName;
//    self.lblPosition.text = userVo.strPosition;
    
    //update notice num
    //[self.noticeNumView updateNoticeNum];
    
    self.indexPathLast = nil;
}

-(void)bindNoticeNum
{
//    LeftMenuVo *leftMenuVo = [self.aryTableView objectAtIndex:1];
//    leftMenuVo.numNotice = [NSNumber numberWithInteger:[NoticeNumView getNoticeNum]];
//    [self.tableViewMenu reloadData];
//    
//    //设置选中
//    [self.tableViewMenu selectRowAtIndexPath:self.indexPathLast animated:YES scrollPosition:UITableViewScrollPositionNone];
}

//退出
- (void)doExit
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LoginOutMsg" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)buttonAction:(UIButton*)sender
{
    
}

-(BOOL)switchView:(NSString *)strKey
{
    BOOL bSuccess = NO;//是否切换成功
    UIViewController *viewControllerTemp = nil;
    if ([strKey isEqualToString:@"menu_search"])
    {
        //搜索
        if (self.mainSearchViewController == nil)
        {
            self.mainSearchViewController = [[MainSearchViewController alloc]init];
        }
        viewControllerTemp = self.mainSearchViewController;
    }
    else if ([strKey isEqualToString:@"menu_customer"])
    {
        //客户信息
        if (self.customerListViewController == nil)
        {
            self.customerListViewController = [[CustomerListViewController alloc]init];
        }
        viewControllerTemp = self.customerListViewController;
    }
    else if ([strKey isEqualToString:@"menu_grab_ticket"])
    {
        //可抢工单
        if (self.grabTicketListViewController == nil)
        {
            self.grabTicketListViewController = [[UIStoryboard storyboardWithName:@"TicketListViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"TicketListViewController"];
            self.grabTicketListViewController.ticketListType = TicketListTryType;
        }
        viewControllerTemp = self.grabTicketListViewController;
    }
    else if ([strKey isEqualToString:@"menu_my_ticket"])
    {
        //我的工单
        if (self.myTicketListViewController == nil)
        {
            self.myTicketListViewController = [[UIStoryboard storyboardWithName:@"TicketListViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"TicketListViewController"];
            self.myTicketListViewController.ticketListType = TicketListMyType;
        }
        viewControllerTemp = self.myTicketListViewController;
    }
    else if ([strKey isEqualToString:@"menu_processing"])
    {
        //未结束
        if (self.processingTicketListViewController == nil)
        {
            self.processingTicketListViewController = [[UIStoryboard storyboardWithName:@"TicketListViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"TicketListViewController"];
            self.processingTicketListViewController.ticketListType = TicketListUnresolveType;
        }
        viewControllerTemp = self.processingTicketListViewController;
    }
    else if ([strKey isEqualToString:@"menu_processed"])
    {
        //已结束
        if (self.processedTicketListViewController == nil)
        {
            self.processedTicketListViewController = [[UIStoryboard storyboardWithName:@"TicketListViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"TicketListViewController"];
            self.processedTicketListViewController.ticketListType = TicketListResolveType;
        }
        viewControllerTemp = self.processedTicketListViewController;
    }
    else if ([strKey isEqualToString:@"menu_my_info"])
    {
        //我的信息
        if (self.userDetailViewController == nil)
        {
            self.userDetailViewController = [[UIStoryboard storyboardWithName:@"UserDetailViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"UserDetailViewController"];
        }
        viewControllerTemp = self.userDetailViewController;
    }
    else if ([strKey isEqualToString:@"menu_modify_pwd"])
    {
        //修改密码
        if (self.editPasswordViewController == nil)
        {
            self.editPasswordViewController = [[EditPasswordViewController alloc]init];
        }
        viewControllerTemp = self.editPasswordViewController;
    }
    else if ([strKey isEqualToString:@"menu_about"])
    {
        //关于
        if (self.aboutViewController == nil)
        {
            //self.aboutViewController = [[AboutViewController alloc]init];
            self.aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
        }
        viewControllerTemp = self.aboutViewController;
    }
    else if ([strKey isEqualToString:@"menu_exit"])
    {
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"你确认要退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        [alertView show];
    }
    
    if (viewControllerTemp != nil)
    {
        //UINavigationController * nav = [[MMNavigationController alloc] initWithRootViewController:viewControllerTemp];
        CommonNavigationController * nav = [[CommonNavigationController alloc] initWithRootViewController:viewControllerTemp];
        nav.navigationBarHidden = YES;
        [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
        bSuccess = YES;
    }
    return bSuccess;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.scrollViewBody.scrollsToTop = YES;
    bShowLeftMenu = YES;
    [super viewWillAppear:animated];
    //left muenu first select home
    if (self.indexPathLast == nil)
    {
        //first load
        [self.tableViewMenu selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        self.indexPathLast = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    //update notice num
    [self updateSessionStatusNum];
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.scrollViewBody.scrollsToTop = NO;
    bShowLeftMenu = NO;
    [super viewWillDisappear:animated];
}

- (void)switchViewWithKey:(NSNotification*)notification
{
    NSString *strViewKey = [notification object];
    if (strViewKey != nil)
    {
        for (int i=0;i<self.aryMenu.count;i++)
        {
            NSMutableArray *arySubMenu = self.aryMenu[i];
            for (int j=0;j<arySubMenu.count;j++)
            {
                LeftMenuVo *leftMenuVo = arySubMenu[j];
                if ([leftMenuVo.strKey  isEqualToString:strViewKey])
                {
                    [self switchView:leftMenuVo.strKey];
                    self.indexPathLast = [NSIndexPath indexPathForRow:j inSection:i];
                    [self.tableViewMenu selectRowAtIndexPath:self.indexPathLast animated:YES scrollPosition:UITableViewScrollPositionNone];
                    return;
                }
            }
        }
    }
}

- (void)updateSessionStatusNum
{
    LeftMenuVo *unprocess = self.arySessionTypeMenu[0];
    unprocess.numNotice = [ChatCountDao getSessionNumByStatus:SESSION_UNPROCESS_KEY];
    
    LeftMenuVo *processing = self.arySessionTypeMenu[1];
    processing.numNotice = [ChatCountDao getSessionNumByStatus:SESSION_PROCESSING_KEY];
//    
//    LeftMenuVo *suspend = self.arySessionTypeMenu[2];
//    suspend.numNotice = [ChatCountDao getSessionNumByStatus:SESSION_SUSPEND_KEY];
    
    [self.tableViewMenu reloadData];
    [self.tableViewMenu selectRowAtIndexPath:self.indexPathLast animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [self doExit];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arySection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *arySectionMenu = self.aryMenu[section];
    return arySectionMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"LeftMenuCell";
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[LeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        //setting tableview cell bk image
        cell.backgroundView = [[UIImageView alloc] initWithImage:[Common getImageWithColor:COLOR(31, 31, 31, 1.0)]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[Common getImageWithColor:THEME_COLOR]];
    }
    
    NSMutableArray *arySectionMenu = self.aryMenu[indexPath.section];
    LeftMenuVo *leftMenuVo = arySectionMenu[indexPath.row];
    [cell initWithLeftMenuVo:leftMenuVo];
    return cell;
}

//section header view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"MenuHeader";
    UITableViewHeaderFooterView *vHeader;
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (vHeader == nil)
    {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        vHeader.backgroundView = [[UIImageView alloc] initWithImage:[Common getImageWithColor:COLOR(41, 41, 41, 1.0)]];
        vHeader.textLabel.textColor = COLOR(102, 102, 102, 1.0);
    }
    vHeader.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    vHeader.textLabel.font = [UIFont systemFontOfSize:14];
    return vHeader;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *strSection = self.arySection[section];
    return strSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    CGFloat fHeight = 30;
    if (section == 0)
    {
        fHeight = 0.000001f;
    }
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return 0.000001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *arySectionMenu = self.aryMenu[indexPath.section];
    LeftMenuVo *leftMenuVo = arySectionMenu[indexPath.row];
    if ([self switchView:leftMenuVo.strKey])
    {
        //切换成功
        self.indexPathLast = indexPath;
    }
    else
    {
        //切换失败
        [tableView selectRowAtIndexPath:self.indexPathLast animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)tapHeaderImageView
{
//    UserCenterViewController *userCenterViewController = [[UserCenterViewController alloc]init];
//    userCenterViewController.m_userVo = [Common getCurrentUserVo];
//    [self.navigationController pushViewController:userCenterViewController animated:YES];
}

+(BOOL)getLeftMenuState
{
    return bShowLeftMenu;
}

@end
