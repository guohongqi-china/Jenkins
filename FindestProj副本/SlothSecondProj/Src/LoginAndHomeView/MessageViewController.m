//
//  MessageViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/30.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "MessageViewController.h"
#import "MenuMessageCell.h"
#import "HomeViewController.h"
#import "ChatListViewController.h"
#import "MainMessageListViewController.h"
#import "NotifyListViewController.h"
#import "NotifyService.h"
#import "NotifyTypeVo.h"
#import "NotificationViewController.h"
NSInteger g_nNoticeNum = 0;
NSDate *g_dateNotice = nil;

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryMenu;
    UIRefreshControl* refreshControl;
}

@end

@implementation MessageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshNotifyTypeList" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
    [self updateNoticeNum:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)initView
{
    self.title = @"消息";
    self.isNeedBackItem = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNotifyTypeList) name:@"RefreshNotifyTypeList" object:nil];
    
    self.tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewMenu.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.tableViewMenu.scrollsToTop = NO;
    
    //添加刷新
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableViewMenu addSubview:refreshControl];
    [self.tableViewMenu sendSubviewToBack:refreshControl];
}

- (void)initData
{
    aryMenu = [NSMutableArray array];
    
    NotifyTypeVo *notifyTypeVo = [[NotifyTypeVo alloc]init];
    notifyTypeVo.notifyMainType = 13;
    notifyTypeVo.strNotifyTypeName = @"通知";
    notifyTypeVo.strNoticeImage = @"menu_notify";
    [aryMenu addObject:notifyTypeVo];
    
    notifyTypeVo = [[NotifyTypeVo alloc]init];
    notifyTypeVo.notifyMainType = 12;
    notifyTypeVo.strNotifyTypeName = @"评论";
    notifyTypeVo.strNoticeImage = @"menu_comment";
    [aryMenu addObject:notifyTypeVo];
    
    notifyTypeVo = [[NotifyTypeVo alloc]init];
    notifyTypeVo.notifyMainType = 14;
    notifyTypeVo.strNotifyTypeName = @"打赏";
    notifyTypeVo.strNoticeImage = @"menu_reward";
    [aryMenu addObject:notifyTypeVo];
    
    notifyTypeVo = [[NotifyTypeVo alloc]init];
    notifyTypeVo.notifyMainType = 0;
    notifyTypeVo.strNotifyTypeName = @"聊天";
    notifyTypeVo.strNoticeImage = @"menu_chat";
    [aryMenu addObject:notifyTypeVo];
    
//    notifyTypeVo = [[NotifyTypeVo alloc]init];
//    notifyTypeVo.notifyMainType = 15;
//    notifyTypeVo.strNotifyTypeName = @"私信";
//    notifyTypeVo.strNoticeImage = @"menu_private_msg";
//    [aryMenu addObject:notifyTypeVo];
    
    notifyTypeVo = [[NotifyTypeVo alloc]init];
    notifyTypeVo.notifyMainType = 16;
    notifyTypeVo.strNotifyTypeName = @"公告";
    notifyTypeVo.strNoticeImage = @"menu_lottery@3x";
    [aryMenu addObject:notifyTypeVo];

    
    [self.tableViewMenu reloadData];
}

- (void)refreshSkin
{
    [self setTitleColor:[SkinManage colorNamed:@"Nav_Bar_Title_Color"]];
    [self.navigationController.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    
    [self.tableViewMenu reloadData];
    
    self.tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewMenu.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
}

- (void)refreshView
{
    [self updateNoticeNum:NO];
}

- (void)updateNoticeNum:(BOOL)bCheckTime
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:g_dateNotice];
    if (!bCheckTime || g_dateNotice == nil || timeInterval>15)
    {
        //do thread work
        [NotifyService getAllNotifyTypeUnreadNum:^(ServerReturnInfo *retInfo) {
            [refreshControl endRefreshing];
            if (retInfo.bSuccess)
            {
                g_dateNotice = [NSDate date];
                //我的提醒和群组总量
                NSMutableArray *aryData = retInfo.data;
                if (aryData != nil && aryData.count == 5)
                {
                    g_nNoticeNum = [[aryData objectAtIndex:0] integerValue];
                    NSLog(@"wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
                    //通知
                    NotifyTypeVo *notifyTypeVo = aryMenu[0];
                    notifyTypeVo.strNotifyNum = aryData[1];
                    
                    //评论
                    notifyTypeVo = aryMenu[1];
                    notifyTypeVo.strNotifyNum = aryData[2];
                    
                    //打赏
                    notifyTypeVo = aryMenu[2];
                    notifyTypeVo.strNotifyNum = aryData[3];
                    
                    //私信
                    notifyTypeVo = aryMenu[4];
                    notifyTypeVo.strNotifyNum = aryData[4];
                }
                [self.tableViewMenu reloadData];
            }
        }];
    }
}

- (void)refreshNotifyTypeList
{
    [self updateNoticeNum:NO];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuMessageCell" forIndexPath:indexPath];
    cell.entity = aryMenu[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotifyTypeVo *typeVo = aryMenu[indexPath.row];
    if(indexPath.row == 3)
    {
        //聊天
        ChatListViewController *chatListViewController = [[ChatListViewController alloc]init];
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:chatListViewController animated:YES];
    }
    else if(indexPath.row == 4)
    {
        //公告
        NotificationViewController *mainMessageListViewController = [[NotificationViewController alloc]init];
//        mainMessageListViewController.mainMessageType = MainMessageTypeAll;
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:mainMessageListViewController animated:YES];
    }
    else
    {
        //通知、评论、打赏
        NotifyListViewController *notifyListViewController = [[UIStoryboard storyboardWithName:@"NotifyModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NotifyListViewController"];
        notifyListViewController.nNotifyMainType = typeVo.notifyMainType;
        [self.homeViewController hideBottomTabBar:YES];
        [self.navigationController pushViewController:notifyListViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return CGFLOAT_MIN;
}

@end
