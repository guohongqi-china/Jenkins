//
//  FAQListViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/20/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "FAQListViewController.h"
#import "FAQListCell.h"
#import "Utils.h"
#import "SessionDetailViewController.h"
#import "UIViewExt.h"

@interface FAQListViewController ()

@end

@implementation FAQListViewController

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
    [AppDelegate getSlothAppDelegate].currentPageName = FAQPage;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
    [super viewWillDisappear:animated];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:@"知识库"];
    
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    [self.view addSubview:self.searchBar];
    
    self.faqSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.faqSearchDisplayController.searchResultsDataSource = self;
    self.faqSearchDisplayController.searchResultsDelegate = self;
    self.faqSearchDisplayController.delegate = self;
    self.faqSearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
    self.faqSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //2.全部用户
    self.tableViewFAQList = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44) pullingDelegate:self];
    self.tableViewFAQList.dataSource = self;
    self.tableViewFAQList.delegate = self;
    self.tableViewFAQList.backgroundColor = COLOR(236, 236, 236, 1.0);
    self.tableViewFAQList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewFAQList];
    
    //no search view
    self.noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, self.tableViewFAQList.top, kScreenWidth, self.tableViewFAQList.height) andDes:nil];
    
}

-(void)initData
{
    self.aryFAQList = [NSMutableArray array];
    self.aryFilteredObject = [NSMutableArray array];
    
    self.nCurrPage = 1;
    self.strSearchText = @"";
    [self loadData];
}

- (void)loadData
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        if (self.aryFAQList.count > 0)
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
        
        ServerReturnInfo *retInfo = [ServerProvider getFAQList:nil page:self.nCurrPage pageSize:10];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *dataArray = retInfo.data;
                if (dataArray != nil && [dataArray count] > 0)
                {
                    if (self.refreshing)
                    {
                        //下拉刷新
                        [self.aryFAQList removeAllObjects];
                        [self.aryFAQList addObjectsFromArray:dataArray];
                        self.nCurrPage = 2;
                    }
                    else
                    {
                        //上拖加载
                        [self.aryFAQList addObjectsFromArray:dataArray];
                        self.nCurrPage ++;
                    }
                    [self.tableViewFAQList tableViewDidFinishedLoading];
                }
                else
                {
                    [self.tableViewFAQList tableViewDidFinishedLoading];
                }
                
                NSNumber *numberTotal = retInfo.data2;
                if (numberTotal != nil && numberTotal.integerValue<=self.aryFAQList.count)
                {
                    //已经加载完毕
                    self.tableViewFAQList.reachedTheEnd = YES;
                }
                else
                {
                    //没有全部加载完毕
                    self.tableViewFAQList.reachedTheEnd = NO;
                }
                
                [self.tableViewFAQList reloadData];
                
                if (self.aryFAQList.count == 0)
                {
                    [self.view addSubview:self.noSearchView];
                    self.tableViewFAQList.headerOnly = YES;
                }
                else
                {
                    [self.noSearchView removeFromSuperview];
                    self.tableViewFAQList.headerOnly = NO;
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewFAQList tableViewDidFinishedLoading];
            });
        }
    });
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
        ServerReturnInfo *retInfo = [ServerProvider getFAQList:self.strSearchText page:1 pageSize:30];
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
    if (tableView == self.tableViewFAQList)
    {
        //faq列表
        return  [self.aryFAQList count];
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
    if (tableView == self.tableViewFAQList)
    {
        //faq列表
        FAQVo *faqVo = self.aryFAQList[indexPath.row];
        return [FAQListCell calculateCellHeight:faqVo andExpandID:self.strExpandFAQID];
    }
    else
    {
        //搜索结果
        if(self.aryFilteredObject.count > 0)
        {
            FAQVo *faqVo = self.aryFilteredObject[indexPath.row];
            return [FAQListCell calculateCellHeight:faqVo andExpandID:self.strSearchExpandFAQID];
        }
        else
        {
            return 0;
        }
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewFAQList)
    {
        //faq列表
        FAQVo *faqVo = self.aryFAQList[indexPath.row];
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
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"链接" backgroundColor:THEME_COLOR],
                              [MGSwipeButton buttonWithTitle:@"文本" backgroundColor:COLOR(103, 212, 189, 1.0)],
                              [MGSwipeButton buttonWithTitle:@"应用" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        [cell initWithData:faqVo andExpandID:self.strExpandFAQID];
        return  cell;
    }
    else
    {
        //搜索结果
        FAQVo *faqVo = nil;
        if (self.aryFilteredObject.count == 0)
        {
            
        }
        else
        {
            faqVo = self.aryFilteredObject[indexPath.row];
        }
        
        static NSString *identifier=@"SearchListCell";
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
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"链接" backgroundColor:THEME_COLOR],
                              [MGSwipeButton buttonWithTitle:@"文本" backgroundColor:COLOR(103, 212, 189, 1.0)],
                              [MGSwipeButton buttonWithTitle:@"应用" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        
        [cell initWithData:faqVo andExpandID:self.strSearchExpandFAQID];
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.tableViewFAQList)
    {
        //faq列表
        FAQVo *faqVo = self.aryFAQList[indexPath.row];
        if ([self.strExpandFAQID isEqualToString:faqVo.strID])
        {
            //the same UserID,then pinch
            self.strExpandFAQID = @"";
        }
        else
        {
            self.strExpandFAQID = faqVo.strID;
        }
        [self.tableViewFAQList reloadData];
    }
    else
    {
        //搜索结果
        
        if (self.aryFilteredObject.count == 0)
        {
            return;
        }
        
        FAQVo *faqVo = self.aryFilteredObject[indexPath.row];
        if ([self.strSearchExpandFAQID isEqualToString:faqVo.strID])
        {
            //the same UserID,then pinch
            self.strSearchExpandFAQID = @"";
        }
        else
        {
            self.strSearchExpandFAQID = faqVo.strID;
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - MGSwipeTableCellDelegate
-(BOOL) swipeTableCell:(FAQListCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft && index == 0)
    {
        //发送富文本
        [self isHideActivity:NO];
        [self.sessionDetailViewController sendFAQ:cell.m_faqVo result:^(BOOL bRes){
            [self isHideActivity:YES];
            if (bRes)
            {
                //发送成功，返回上一界面
                [self.navigationController popViewControllerAnimated:YES];
            }
        } type:3];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 1)
    {
        //发送纯文本
        [self isHideActivity:NO];
        [self.sessionDetailViewController sendFAQ:cell.m_faqVo result:^(BOOL bRes){
            [self isHideActivity:YES];
            if (bRes)
            {
                //发送成功，返回上一界面
                [self.navigationController popViewControllerAnimated:YES];
            }
        } type:2];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 2)
    {
        //编辑
        [self.sessionDetailViewController sendFAQ:cell.m_faqVo result:nil type:1];
        [self.navigationController popViewControllerAnimated:YES];
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
    [self.tableViewFAQList tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableViewFAQList tableViewDidEndDragging:scrollView];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewFAQList scrollRectToVisible:self.searchBar.frame animated:animated];
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
    return YES;
}

@end
