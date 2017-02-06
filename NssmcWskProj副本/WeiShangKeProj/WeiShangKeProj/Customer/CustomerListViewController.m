//
//  UserListViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "CustomerListViewController.h"
#import "Utils.h"
#import "KxMenu.h"
#import "GroupAndUserDao.h"
#import "CustomerListCell.h"
#import "UIViewExt.h"

@interface CustomerListViewController ()

@end

@implementation CustomerListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UpdateCustomerList" object:nil];
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
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self showBottomTab];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
    [self.userSearchDisplayController setActive:NO animated:YES];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnBack addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnBack];
    //notice num view
    NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
    [self.view addSubview:noticeNumView];
    
    [self setTopNavBarTitle:@"客户列表"];
    
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    [self.view addSubview:self.searchBar];
    
    self.userSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.userSearchDisplayController.searchResultsDataSource = self;
    self.userSearchDisplayController.searchResultsDelegate = self;
    self.userSearchDisplayController.delegate = self;
    self.userSearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
    
    //2.全部用户
    self.tableViewUserList = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44) pullingDelegate:self];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewUserList];
    
    //no search view
    self.noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, self.tableViewUserList.top, kScreenWidth, self.tableViewUserList.height) andDes:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateList) name:@"UpdateCustomerList" object:nil];
}

-(void)initData
{
    self.aryUserList = [NSMutableArray array];
    self.aryFilteredObject = [NSMutableArray array];
    
    self.nCurrPage = 1;
    self.strSearchText = @"";
    [self loadData];
}

-(void)updateList
{
    self.nCurrPage = 1;
    self.refreshing = YES;
    [self loadData];
}

- (void)loadData
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        if (self.aryUserList.count > 0)
        {
            if (self.refreshing)
            {
                //下拉刷新
                self.nCurrPage = 1;
            }
            else
            {
                //上拖加载
            }
        }
        
        ServerReturnInfo *retInfo = [ServerProvider getCustomerList:nil page:self.nCurrPage pageSize:10];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *dataArray = retInfo.data;
                if (dataArray != nil && [dataArray count] > 0)
                {
                    if (self.refreshing)
                    {
                        //下拉刷新
                        [self.aryUserList removeAllObjects];
                        [self.aryUserList addObjectsFromArray:dataArray];
                        self.nCurrPage = 2;
                    }
                    else
                    {
                        //上拖加载
                        [self.aryUserList addObjectsFromArray:dataArray];
                        self.nCurrPage ++;
                    }
                    [self.tableViewUserList tableViewDidFinishedLoading];
                }
                else
                {
                    [self.tableViewUserList tableViewDidFinishedLoading];
                }
                
                NSNumber *numberTotal = retInfo.data2;
                if (numberTotal != nil && numberTotal.integerValue<=self.aryUserList.count)
                {
                    //已经加载完毕
                    self.tableViewUserList.reachedTheEnd = YES;
                }
                else
                {
                    //没有全部加载完毕
                    self.tableViewUserList.reachedTheEnd = NO;
                }
                
                [self.tableViewUserList reloadData];
                
                if (self.aryUserList.count == 0)
                {
                    [self.view addSubview:self.noSearchView];
                    self.tableViewUserList.headerOnly = YES;
                }
                else
                {
                    [self.noSearchView removeFromSuperview];
                    self.tableViewUserList.headerOnly = NO;
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewUserList tableViewDidFinishedLoading];
            });
        }
    });
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        [self.aryFilteredObject removeAllObjects];
        //暂时只能搜索前30条记录
        ServerReturnInfo *retInfo = [ServerProvider getCustomerList:self.strSearchText page:1 pageSize:30];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = (NSMutableArray *)retInfo.data;
            dispatch_async(dispatch_get_main_queue(),^{
                if (aryTemp != nil && [aryTemp count] > 0)
                {
                    [self.aryFilteredObject addObjectsFromArray:aryTemp];
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }
                [self isHideActivity:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self isHideActivity:YES];
            });
        }
    });
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewUserList)
    {
        //客户列表
        return  [self.aryUserList count];
    }
    else
    {
        //搜索结果
        if(self.aryFilteredObject.count > 0)
        {
            return self.aryFilteredObject.count;
        }
        else
        {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.5;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        //客户列表
        CustomerVo *customerVo = self.aryUserList[indexPath.row];
        static NSString *identifier=@"CustomerListCell";
        CustomerListCell *cell = (CustomerListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[CustomerListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        [cell initWithData:customerVo];
        return  cell;
    }
    else
    {
        //搜索结果
        CustomerVo *customerVo = nil;
        if (self.aryFilteredObject.count == 0)
        {
            
        }
        else
        {
            customerVo = self.aryFilteredObject[indexPath.row];
        }
        static NSString *identifier=@"SearchListCell";
        CustomerListCell *cell = (CustomerListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[CustomerListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        [cell initWithData:customerVo];
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CustomerVo *customerVo;
    if (tableView == self.tableViewUserList)
    {
        //客户列表
        customerVo = self.aryUserList[indexPath.row];
    }
    else
    {
        //搜索结果
        if (self.aryFilteredObject.count == 0)
        {
            return;
        }
        
        customerVo = self.aryUserList[indexPath.row];
    }
    
    CustomerDetailViewController *customerDetailViewController = [[CustomerDetailViewController alloc]init];
    customerDetailViewController.m_customerVo = customerVo;
    [self.navigationController pushViewController:customerDetailViewController animated:YES];
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
    [self.tableViewUserList tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableViewUserList tableViewDidEndDragging:scrollView];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewUserList scrollRectToVisible:self.searchBar.frame animated:animated];
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
    [self.searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

@end
