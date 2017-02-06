//
//  GroupListViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-13.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "GroupListViewController.h"
#import "Utils.h"
#import "UserVo.h"
#import "KxMenu.h"
#import "GroupListCell.h"
#import "GroupAndUserDao.h"
#import "AddAndEditGroupViewController.h"

@interface GroupListViewController ()

@end

@implementation GroupListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SyncServerDataSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshGroupList" object:nil];
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
    
    [self initView];
    [self initData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(syncServerDataSuccess) name:@"SyncServerDataSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshGroupList) name:@"RefreshGroupList" object:nil];
}

-(void)initView
{
    self.view.backgroundColor = COLOR(230, 230, 230, 1.0);
    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnBack addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnBack];
    //notice num view
    NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
    [self.view addSubview:noticeNumView];
    
    //右边按钮
    UIButton *btnCreateGroup = [Utils buttonWithTitle:[Common localStr:@"Common_Create" value:@"创建"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:nil];
    [btnCreateGroup addTarget:self action:@selector(createGroup)forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnCreateGroup andKey:@"Common_Create"];
    
    [self setTopNavBarTitleWithArrow:[Common localStr:@"UserGroup_AllGroup" value:@"全部群组"] andKey:@"UserGroup_AllGroup"];
    
    UITapGestureRecognizer *titleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    titleGesture.numberOfTouchesRequired = 1;
    [self.scrollViewTitle addGestureRecognizer:titleGesture];
    
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    [self.view addSubview:self.searchBar];
    
    self.groupSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.groupSearchDisplayController.searchResultsDataSource = self;
    self.groupSearchDisplayController.searchResultsDelegate = self;
    self.groupSearchDisplayController.delegate = self;
    self.groupSearchDisplayController.searchResultsTableView.backgroundColor = COLOR(230, 230, 230, 1.0);
    self.groupSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableViewGroupList = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44)];
    _tableViewGroupList.dataSource = self;
    _tableViewGroupList.delegate = self;
    _tableViewGroupList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewGroupList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewGroupList];
}

-(void)initData
{
    self.m_groupListType = GroupListAllType;
    self.aryDBData = [NSMutableArray array];
    self.aryObject = [NSMutableArray array];
    self.aryFilteredObject = [NSMutableArray array];
    
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //1.检查数据库是不是同时存在用户和群组数据，若至少有其中一个不存在，则更新数据
        GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
        if (![groupAndUserDao checkBufferUserAndGroup])
        {
            [BusinessCommon updateServerGroupAndUserData];
        }
        
        //2.get db data
        [self getGroupDBDataByType];
    });
}

- (void)getGroupDBDataByType
{
    //1.检查数据库是不是同时存在用户和群组数据，若至少有其中一个不存在，则更新数据
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    self.aryDBData = [groupAndUserDao getGroupListByType:self.m_groupListType];
    self.aryObject = self.aryDBData;

    //3.go to main thread work
    dispatch_async(dispatch_get_main_queue(),^{
        [self isHideActivity:YES];
        [self.tableViewGroupList reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//pop menu
- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    [self showMenu:self.scrollViewTitle];
}

- (void)showMenu:(UIView *)sender
{
    self.menuItems = [[NSArray alloc]init];
    
    NSMutableArray *aryMenuItem = [NSMutableArray array];
    
    KxMenuItem *menuItem =[KxMenuItem menuItem:[Common localStr:@"UserGroup_AllGroup" value:@"全部群组"] image:nil target:self action:@selector(pushMenuItem:)];
    menuItem.alignment = NSTextAlignmentCenter;
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:[Common localStr:@"UserGroup_CreatedGroup" value:@"我创建的群组"] image:nil target:self action:@selector(pushMenuItem:)];
    menuItem.alignment = NSTextAlignmentCenter;
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:[Common localStr:@"UserGroup_JoinedGroup" value:@"我参与的群组"] image:nil target:self action:@selector(pushMenuItem:)];
    menuItem.alignment = NSTextAlignmentCenter;
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:[Common localStr:@"UserGroup_OtherGroup" value:@"其它群组"] image:nil target:self action:@selector(pushMenuItem:)];
    menuItem.alignment = NSTextAlignmentCenter;
    [aryMenuItem addObject:menuItem];
    
    self.menuItems = [NSArray arrayWithArray:aryMenuItem];
    
    [KxMenu showMenuInView:self.view fromRect:sender.frame menuItems:self.menuItems];
}

- (void)pushMenuItem:(id)sender
{
    if(sender == [self.menuItems objectAtIndex:0])
    {
        //全部群组
        [self setTopNavBarTitleWithArrow:[Common localStr:@"UserGroup_AllGroup" value:@"全部群组"] andKey:@"UserGroup_AllGroup"];
        [self getDataByMenuClick:(id)sender];
    }
    else if(sender == [self.menuItems objectAtIndex:1])
    {
        //我创建的群组
        [self setTopNavBarTitleWithArrow:[Common localStr:@"UserGroup_CreatedGroup" value:@"我创建的群组"] andKey:@"UserGroup_CreatedGroup"];
        [self getDataByMenuClick:(id)sender];
    }
    else if(sender == [self.menuItems objectAtIndex:2])
    {
        //我参与的群组
        [self setTopNavBarTitleWithArrow:[Common localStr:@"UserGroup_JoinedGroup" value:@"我参与的群组"] andKey:@"UserGroup_JoinedGroup"];
        [self getDataByMenuClick:(id)sender];
    }
    else if(sender == [self.menuItems objectAtIndex:3])
    {
        //其它群组
        [self setTopNavBarTitleWithArrow:[Common localStr:@"UserGroup_OtherGroup" value:@"其它群组"] andKey:@"UserGroup_OtherGroup"];
        [self getDataByMenuClick:(id)sender];
    }
}

-(void)getDataByMenuClick:(id)sender
{
    if (sender == [self.menuItems objectAtIndex:0])
    {
        //全部群组
        self.m_groupListType = GroupListAllType;
    }
    else if (sender == [self.menuItems objectAtIndex:1])
    {
        //我创建的群组
        self.m_groupListType = GroupListCreatedType;
    }
    else if (sender == [self.menuItems objectAtIndex:2])
    {
        //我参与的群组
        self.m_groupListType = GroupListJoinedType;
    }
    else if (sender == [self.menuItems objectAtIndex:3])
    {
        //其它群组
        self.m_groupListType = GroupListOtherType;
    }
    
    //get data
    [self getGroupDBDataByType];
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

-(void)createGroup
{
    AddAndEditGroupViewController *addAndEditGroupViewController = [[AddAndEditGroupViewController alloc]init];
    addAndEditGroupViewController.groupPageName = GroupAddPage;
    [self.navigationController pushViewController:addAndEditGroupViewController animated:YES];
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(self.aryDBData == nil || self.aryDBData.count <= 0)
    {
        return;
    }
    
    [self.aryFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<self.aryDBData.count; i++)
    {
        GroupVo *groupVo = (GroupVo*)[self.aryDBData objectAtIndex:i];
        
        if ([groupVo.strGroupName rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a.match name
            [aryFilteredName addObject:groupVo];
        }
        else if ([groupVo.strJP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //b.match JP
            [aryFilteredJP addObject:groupVo];
        }
        else if ([groupVo.strQP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //c.match QP
            [aryFilteredQP addObject:groupVo];
        }
    }
    
    [self.aryFilteredObject addObjectsFromArray:aryFilteredName];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredJP];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredQP];
}

//重新更新群组数据
-(void)refreshGroupList
{
    //重新更新数据
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
        [BusinessCommon updateServerGroupAndUserData];
        self.aryDBData = [groupAndUserDao getGroupListByType:self.m_groupListType];
        self.aryObject = self.aryDBData;
        
        //go to main thread work
        dispatch_async(dispatch_get_main_queue(),^{
            [self isHideActivity:YES];
            [self.tableViewGroupList reloadData];
        });
    });
}

//同步数据成功，重新加载数据库数据
- (void)syncServerDataSuccess
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        [self getGroupDBDataByType];
    });
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewGroupList)
    {
        return [self.aryObject count];
    }
    else
    {
        return [self.aryFilteredObject count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    GroupVo *groupVo = nil;
    if (tableView == self.tableViewGroupList)
    {
        groupVo = [self.aryObject objectAtIndex:[indexPath row]];
    }
    else
    {
        groupVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    fHeight = [GroupListCell calculateCellHeight:groupVo];
    return fHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupVo *groupVo = nil;
    if (tableView == self.tableViewGroupList)
    {
        groupVo = [self.aryObject objectAtIndex:[indexPath row]];
    }
    else
    {
        groupVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    
    static NSString *identifier=@"GroupListCell";
    GroupListCell *cell = (GroupListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[GroupListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        cell.selectedBackgroundView = viewSelected;
        
        //parent view
        cell.parentView = self;
    }
    
    [cell initWithGroupVo:groupVo];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupVo *groupVo = nil;
    if (tableView == self.tableViewGroupList)
    {
        groupVo = [self.aryObject objectAtIndex:[indexPath row]];
        groupVo.bIsExpanded = !groupVo.bIsExpanded;
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        groupVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
        groupVo.bIsExpanded = !groupVo.bIsExpanded;
    }
    
    //当成员数大于8时进行刷新数据
    if (groupVo.aryMemberVo.count>8)
    {
        [tableView reloadData];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewGroupList scrollRectToVisible:self.searchBar.frame animated:animated];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    self.strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doSearch];
    //auto reload data
    return YES;
}

@end
