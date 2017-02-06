//
//  MainEmailListViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-12.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "MainMessageListViewController.h"
#import "HomeViewController.h"
#import "KxMenu.h"
#import "Utils.h"
#import "MessageListCell.h"
#import "UIViewController+MMDrawerController.h"
#import "MessageDetailViewController.h"
#import "PublishMessageViewController.h"

@interface MainMessageListViewController ()

@end

@implementation MainMessageListViewController

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
    [self initData];
}

- (void)initView
{
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44)];
    self.searchBar.placeholder = @"搜索作者";
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.searchBar.frame.size.height)];
        view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.searchBar insertSubview:view atIndex:1];
    }
    //右边按钮
    self.btnNavRight = [Utils buttonWithTitle:@"新建" frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:nil];
    [self.btnNavRight addTarget:self action:@selector(addMessage)forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:self.btnNavRight];
    
    if (self.mainMessageType == MainMessageTypeWorkOrder)
    {
        //工单消息
        [self setTopNavBarTitle:@"工单评价"];
        self.m_messageListType = MessageListWorkOrderType;
        self.searchBar.placeholder = @"搜索标题和内容";
    }
    else
    {
        self.m_messageListType = MessageListAllType;
        //标题以及下拉菜单
        [self setTopNavBarTitleWithArrow:@"我的所有消息"];
        UITapGestureRecognizer *titleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        titleGesture.numberOfTouchesRequired = 1;
        [self.scrollViewTitle addGestureRecognizer:titleGesture];
    }
    
    self.userSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.userSearchDisplayController.searchResultsDataSource = self;
    self.userSearchDisplayController.searchResultsDelegate = self;
    self.userSearchDisplayController.delegate = self;
    
    
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.searchBar.frame.size.height)];
        view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.searchBar insertSubview:view atIndex:1];
    }
    self.userSearchDisplayController.searchResultsTableView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];;
    
    //邮件列表
    self.tableViewMsgList = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44) pullingDelegate:self];
    _tableViewMsgList.dataSource = self;
    _tableViewMsgList.delegate = self;
    _tableViewMsgList.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableViewMsgList.backgroundColor = [UIColor whiteColor];
    
    _tableViewMsgList.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];;
    self.tableViewMsgList.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //_tableViewMsgList.tableHeaderView = self.searchBar;
    [self.view addSubview:_tableViewMsgList];
}

- (void)addMessage
{
    PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc]init];
    publishMessageViewController.publishMessageFromType = PublishMessageDirectlyType;
    
    CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishMessageViewController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)initData
{
    self.aryMessageList = [NSMutableArray array];
    self.m_curPageNum = 1;
    //所有消息
    [self isHideActivity:NO];
    [self loadData];
}

-(void)loadData
{
    if (self.aryMessageList != nil && [self.aryMessageList count] > 0)
    {
        if (self.refreshing)
        {
            //下拉刷新
            self.m_curPageNum = 1;
        }
        else
        {
            //上拖加载
        }
    }
    
    if (self.m_messageListType == MessageListSearchType)
    {
        [ServerProvider searchMessageList:self.strSearchText type:self.m_messageListType andPageNum:self.m_curPageNum result:^(ServerReturnInfo *retInfo) {
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo];
            }
            else
            {
                [self.tableViewMsgList tableViewDidFinishedLoading];
            }
        }];
    }
    else
    {
        [ServerProvider getMessageListByType:self.m_messageListType andFilterType:self.m_messageFilterType andPageNum:self.m_curPageNum result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo];
            }
            else
            {
                [self.tableViewMsgList tableViewDidFinishedLoading];
            }
        }];
    }
}

- (void)dataFinishedLoading:(ServerReturnInfo *)retInfo
{
    NSMutableArray *dataArray = retInfo.data;
    if (dataArray != nil)
    {
        if (self.refreshing)
        {
            //下拉刷新
            [self.aryMessageList removeAllObjects];
            [self.aryMessageList addObjectsFromArray:dataArray];
            if(dataArray.count > 0)
            {
                self.m_curPageNum = 2;
            }
        }
        else
        {
            //上拖加载
            [self.aryMessageList addObjectsFromArray:dataArray];
            if(dataArray.count > 0)
            {
                self.m_curPageNum ++;
            }
        }
        [self.tableViewMsgList tableViewDidFinishedLoading];
    }
    else
    {
        [self.tableViewMsgList tableViewDidFinishedLoading];
    }
    
    NSNumber *numberTotal = retInfo.data2;
    if (numberTotal != nil && numberTotal.integerValue<=self.aryMessageList.count)
    {
        //已经加载完毕
        self.tableViewMsgList.reachedTheEnd = YES;
    }
    else
    {
        //没有全部加载完毕
        self.tableViewMsgList.reachedTheEnd = NO;
    }
    
    [self.tableViewMsgList reloadData];
    
    if (self.m_messageListType == MessageListSearchType)
    {
        [Common tipAlert:@"没有搜索到消息"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateMsgUnreadAllNum" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterMessage:(UIButton *)sender
{
    [self showFilterMenu:sender];
}

//pop menu
- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    [self showMenu:self.scrollViewTitle];
}

- (void)showMenu:(UIView *)sender
{
    self.menuItems = [[NSArray alloc]init];
    
    NSMutableArray *aryMenuItem = [NSMutableArray array];
    
    KxMenuItem *menuItem =[KxMenuItem menuItem:@"我的所有消息" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"我的私人消息" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"我的群组消息" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"我发送的消息" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"我的星标消息" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"我的工单消息" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    self.menuItems = [NSArray arrayWithArray:aryMenuItem];
    
    [KxMenu showMenuInView:self.view fromRect:sender.frame menuItems:self.menuItems];
}

- (void)showFilterMenu:(UIView*)sender
{
    self.menuFilterItems = [[NSArray alloc]init];
    
    NSMutableArray *aryMenuItem = [NSMutableArray array];
    
    KxMenuItem *menuItem =[KxMenuItem menuItem:@"邀请" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"投票" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"奖品" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    self.menuFilterItems = [NSArray arrayWithArray:aryMenuItem];
    
    [KxMenu showMenuInView:self.view fromRect:sender.frame menuItems:self.menuFilterItems];
}

- (void)pushMenuItem:(id)sender
{
    self.btnNavRight.hidden = NO;
    [self.btnNavRight setTitle:@"新建" forState:UIControlStateNormal];
    
    if( sender == [self.menuItems objectAtIndex:0])
    {
        [self setTopNavBarTitleWithArrow:@"我的所有消息"];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuItems objectAtIndex:1])
    {
        [self setTopNavBarTitleWithArrow:@"我的私人消息"];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuItems objectAtIndex:2])
    {
        [self setTopNavBarTitleWithArrow:@"我的群组消息"];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuItems objectAtIndex:3])
    {
        [self setTopNavBarTitleWithArrow:@"我发送的消息"];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuItems objectAtIndex:4])
    {
        [self setTopNavBarTitleWithArrow:@"我的星标消息"];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuItems objectAtIndex:5])
    {
        self.btnNavRight.hidden = YES;
        [self setTopNavBarTitleWithArrow:@"我的工单消息"];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuFilterItems objectAtIndex:0])
    {
        //邀请
        [self.btnNavRight setTitle:@"邀请" forState:UIControlStateNormal];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuFilterItems objectAtIndex:1])
    {
        //投票
        [self.btnNavRight setTitle:@"投票" forState:UIControlStateNormal];
        [self getDataByMenuClick:(id)sender];
    }
    else if( sender == [self.menuFilterItems objectAtIndex:2])
    {
        //奖品
        [self.btnNavRight setTitle:@"奖品" forState:UIControlStateNormal];
        [self getDataByMenuClick:(id)sender];
    }
}

- (void)getDataByMenuClick:(id)sender
{
    self.m_messageFilterType = @"";
    
    if (sender == [self.menuItems objectAtIndex:0])
    {
        //我的所有消息
        self.m_messageListType = MessageListAllType;
    }
    else if (sender == [self.menuItems objectAtIndex:1])
    {
        //我的私人消息
        self.m_messageListType = MessageListPersonalType;
    }
    else if (sender == [self.menuItems objectAtIndex:2])
    {
        //我的群组消息
        self.m_messageListType = MessageListMyGroupType;
    }
    else if (sender == [self.menuItems objectAtIndex:3])
    {
        //我发送的消息
        self.m_messageListType = MessageListFromMeType;
    }
    else if (sender == [self.menuItems objectAtIndex:4])
    {
        //我的星标消息
        self.m_messageListType = MessageListStarType;
    }
    else if (sender == [self.menuItems objectAtIndex:5])
    {
        //我的工单消息
        self.m_messageListType = MessageListWorkOrderType;
    }
    else if( sender == [self.menuFilterItems objectAtIndex:0])
    {
        //邀请
        self.m_messageFilterType = @"B";
    }
    else if( sender == [self.menuFilterItems objectAtIndex:1])
    {
        //投票
        self.m_messageFilterType = @"C";
    }
    else if( sender == [self.menuFilterItems objectAtIndex:2])
    {
        //奖品
        self.m_messageFilterType = @"E";
    }
    
    self.m_curPageNum = 1;
    self.refreshing = YES;
    [self isHideActivity:NO];
    [self loadData];
}

//在详情删除消息，刷新列表数据
- (void)refreshMsgListAfterDel:(MessageVo*)messageVo
{
    for (MessageVo *msgVoTemp in self.aryMessageList)
    {
        if ([msgVoTemp.strID isEqualToString:messageVo.strID])
        {
            [self.aryMessageList removeObject:msgVoTemp];
            break;
        }
    }
    
    [self.tableViewMsgList reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewMsgList)
    {
        return [self.aryMessageList count];
    }
    else
    {
        return [self.aryFilteredObject count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ChatListCell";
    MessageListCell *cell = (MessageListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[MessageListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
        cell.selectedBackgroundView = viewSelected;
    }
    
    MessageVo *messageVo = nil;
    if (tableView == self.tableViewMsgList)
    {
        messageVo = [self.aryMessageList objectAtIndex:[indexPath row]];
    }
    else
    {
        messageVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    [cell initWithMessageVo:messageVo];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageVo *messageVo = nil;
    if (tableView == self.tableViewMsgList)
    {
        messageVo = [self.aryMessageList objectAtIndex:[indexPath row]];
    }
    else
    {
        messageVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    return [MessageListCell calculateCellHeight:messageVo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //hide key board
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    MessageVo *messageVo = nil;
    if (tableView == self.tableViewMsgList)
    {
        messageVo = [self.aryMessageList objectAtIndex:[indexPath row]];
    }
    else
    {
        messageVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    if (messageVo.strTitleID.length == 0)
    {
        if ([messageVo.strMsgType isEqualToString:@"D"] || [messageVo.strMsgType isEqualToString:@"N"])
        {
            
        }
        else
        {
            [Common tipAlert:@"数据异常，请求失败"];
            return;
        }
    }
    
    MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] init];
    messageDetailViewController.parentView = self;
    messageDetailViewController.m_currMessageVo = messageVo;
    [self.navigationController pushViewController:messageDetailViewController animated:YES];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    self.refreshing = YES;
    [self loadData];
}
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    self.refreshing = NO;
    [self loadData];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableViewMsgList tableViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableViewMsgList tableViewDidEndDragging:scrollView];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewMsgList scrollRectToVisible:self.searchBar.frame animated:animated];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.aryFilteredObject removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.strSearchText = searchBar.text;
    [self doSearch];
}

#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchResultsTableView setDelegate:self];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    for (UIView *subview in tableView.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [(UILabel *)subview setText:@""];
        }
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    for (UIView *subview in tableView.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [(UILabel *)subview setText:@"无结果"];
        }
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    [self isHideActivity:NO];
    [self.aryFilteredObject removeAllObjects];
    [ServerProvider searchMessageList:self.strSearchText type:self.m_messageListType andPageNum:1 result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = (NSMutableArray *)retInfo.data;
            if (aryTemp != nil && [aryTemp count] > 0)
            {
                self.aryFilteredObject = [NSMutableArray arrayWithArray:aryTemp];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        }
    }];
}

@end
