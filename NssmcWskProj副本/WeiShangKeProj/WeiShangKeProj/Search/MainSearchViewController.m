//
//  MainSearchViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 1/27/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "MainSearchViewController.h"
#import "Utils.h"
#import "TicketVo.h"
#import "CustomerVo.h"
#import "FAQVo.h"
#import "TicketListCell.h"
#import "CustomerListCell.h"
#import "FAQListCell.h"
#import "CustomerDetailViewController.h"
#import "TicketDetailViewController.h"
#import "UIViewExt.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface MainSearchViewController ()

@end

@implementation MainSearchViewController

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
    self.view.backgroundColor = COLOR(255, 255, 255, 1.0);
//    self.fd_prefersNavigationBarHidden = YES;
//    self.fd_interactivePopDisabled = YES;
    
    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnBack addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnBack];
    
    //search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(55, kStatusBarHeight-20+20, kScreenWidth-55-8, 44)];
    self.searchBar.placeholder = @"搜索工单";
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor whiteColor];
    //self.searchBar.barTintColor = THEME_COLOR;
    //self.searchBar.backgroundColor = [UIColor redColor];
    self.searchBar.backgroundImage = [Common getImageWithColor:THEME_COLOR];
    [self.view addSubview:self.searchBar];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:COLOR(0, 122, 255, 1.0)];
    
    //segmented control
    NSArray *arySegmented = @[@"工单",@"知识库",@"客户"];
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:arySegmented];
    self.segmentedControl.frame = CGRectMake(10, NAV_BAR_HEIGHT+12, kScreenWidth-20, 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = THEME_COLOR;
    [self.segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    self.tableViewResult = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, self.segmentedControl.bottom+10, kScreenWidth, kScreenHeight-(self.segmentedControl.bottom+10)) pullingDelegate:self];
    self.tableViewResult.dataSource = self;
    self.tableViewResult.delegate = self;
    self.tableViewResult.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableViewResult];
    
    //no search view
    self.noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, self.tableViewResult.top, kScreenWidth, self.tableViewResult.height) andDes:nil];
    self.tableViewResult.headerOnly = YES;
}

- (void)initData
{
    self.mainSearListType = SearchTicketType;
    self.nCurrPage = 1;
    self.refreshing = YES;
    
    self.aryData = [NSMutableArray array];
}

- (void)loadData
{
    if (self.searchBar.text.length == 0)
    {
        [self.aryData removeAllObjects];
        [self.tableViewResult reloadData];
        [self.tableViewResult tableViewDidFinishedLoading];
        [self.noSearchView removeFromSuperview];
        self.tableViewResult.headerOnly = YES;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0,0),^{
            if (self.aryData.count > 0)
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
            
            ServerReturnInfo *retInfo;
            if (self.mainSearListType == SearchTicketType)
            {
//                retInfo = [ServerProvider getTicketList:self.searchBar.text page:self.nCurrPage pageSize:10 status:0 custId:nil];
            }
            else if (self.mainSearListType == SearchFAQType)
            {
                retInfo = [ServerProvider getFAQList:self.searchBar.text page:self.nCurrPage pageSize:10];
            }
            else
            {
                retInfo = [ServerProvider getCustomerList:self.searchBar.text page:self.nCurrPage pageSize:10];
            }
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *dataArray = retInfo.data;
                    if (dataArray != nil && [dataArray count] > 0)
                    {
                        if (self.refreshing)
                        {
                            //下拉刷新
                            [self.aryData removeAllObjects];
                            [self.aryData addObjectsFromArray:dataArray];
                            self.nCurrPage = 2;
                        }
                        else
                        {
                            //上拖加载
                            [self.aryData addObjectsFromArray:dataArray];
                            self.nCurrPage ++;
                        }
                        [self.tableViewResult tableViewDidFinishedLoading];
                    }
                    else
                    {
                        [self.aryData removeAllObjects];
                        [self.tableViewResult tableViewDidFinishedLoading];
                    }
                    
                    NSNumber *numberTotal = retInfo.data2;
                    if (numberTotal != nil && numberTotal.integerValue<=self.aryData.count)
                    {
                        //已经加载完毕
                        self.tableViewResult.reachedTheEnd = YES;
                    }
                    else
                    {
                        //没有全部加载完毕
                        self.tableViewResult.reachedTheEnd = NO;
                    }
                    
                    [self.tableViewResult reloadData];
                    
                    if (self.aryData.count == 0)
                    {
                        [self.view addSubview:self.noSearchView];
                        self.tableViewResult.headerOnly = YES;
                    }
                    else
                    {
                        [self.noSearchView removeFromSuperview];
                        self.tableViewResult.headerOnly = NO;
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableViewResult tableViewDidFinishedLoading];
                });
            }
        });
    }
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
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

- (void)segmentedAction:(UISegmentedControl*)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        self.searchBar.placeholder = @"搜索工单";
        self.mainSearListType = SearchTicketType;
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        self.searchBar.placeholder = @"搜索知识库";
        self.mainSearListType = SearchFAQType;
    }
    else
    {
        self.searchBar.placeholder = @"搜索客户";
        self.mainSearListType = SearchCustomerType;
    }
    //重新搜索
    [self doSearch];
}

- (void)doSearch
{
    self.nCurrPage = 1;
    self.refreshing = YES;
    [self loadData];
}

#pragma UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.frame = CGRectMake(8, kStatusBarHeight-20+20, kScreenWidth-8-8, 44);
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.frame = CGRectMake(55, kStatusBarHeight-20+20, kScreenWidth-55-8, 44);
    [self.searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self doSearch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchBar.text.length == 0)
    {
        [self.aryData removeAllObjects];
        [self.tableViewResult reloadData];
        [self.noSearchView removeFromSuperview];
        self.tableViewResult.headerOnly = YES;
    }
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aryData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mainSearListType == SearchTicketType)
    {
        return 85;
    }
    else if (self.mainSearListType == SearchFAQType)
    {
        FAQVo *faqVo = self.aryData[indexPath.row];
        return [FAQListCell calculateCellHeight:faqVo andExpandID:self.strExpandFAQID];
    }
    else
    {
        return 60.5;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mainSearListType == SearchTicketType)
    {
        //工单
        //TicketVo *ticketVo = self.aryData[indexPath.row];
        static NSString *identifier=@"TicketListCell";
        TicketListCell *cell = (TicketListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[TicketListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        //[cell initWithData:ticketVo];
        return  cell;
    }
    else if (self.mainSearListType == SearchFAQType)
    {
        //知识库
        FAQVo *faqVo = self.aryData[indexPath.row];
        static NSString *identifier=@"FAQListCell";
        FAQListCell *cell = (FAQListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[FAQListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.parentViewController = self;
            cell.delegate = self;
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
            
        }
        //configure right buttons
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"复制" backgroundColor:THEME_COLOR]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        [cell initWithData:faqVo andExpandID:self.strExpandFAQID];
        return  cell;
    }
    else
    {
        //客户
        CustomerVo *customerVo = self.aryData[indexPath.row];
        static NSString *identifier=@"CustomerListCell";
        CustomerListCell *cell = (CustomerListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[CustomerListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
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
    
    if (self.mainSearListType == SearchTicketType)
    {
        TicketDetailViewController *ticketDetailViewController = [[TicketDetailViewController alloc]init];
        ticketDetailViewController.m_ticketVo = self.aryData[indexPath.row];
        ticketDetailViewController.ticketDetailType = TicketDetailModifyType;
        [self.navigationController pushViewController:ticketDetailViewController animated:YES];
    }
    else if (self.mainSearListType == SearchFAQType)
    {
        FAQVo *faqVo = self.aryData[indexPath.row];
        if ([self.strExpandFAQID isEqualToString:faqVo.strID])
        {
            //the same UserID,then pinch
            self.strExpandFAQID = @"";
        }
        else
        {
            self.strExpandFAQID = faqVo.strID;
        }
        [self.tableViewResult reloadData];
    }
    else
    {
        CustomerDetailViewController *customerDetailViewController = [[CustomerDetailViewController alloc]init];
        customerDetailViewController.m_customerVo = self.aryData[indexPath.row];
        [self.navigationController pushViewController:customerDetailViewController animated:YES];
    }
}

#pragma mark - MGSwipeTableCellDelegate
-(BOOL) swipeTableCell:(FAQListCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft && index == 0)
    {
        //复制到剪贴板(只复制文本)
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = [Common htmlTextToPlainText:cell.m_faqVo.strTextContent];
    }
    return YES;
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
    [self.tableViewResult tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableViewResult tableViewDidEndDragging:scrollView];
}

@end