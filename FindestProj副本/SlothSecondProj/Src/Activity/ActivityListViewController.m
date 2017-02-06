//
//  ActivityListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityListViewController.h"
#import "ActivityListCell.h"
#import "ActivityOrderCell.h"
#import "MJRefresh.h"
#import "ActivityService.h"
#import "BlogVo.h"
#import "UIViewExt.h"
#import "ShareDetailViewController.h"
#import "NoSearchView.h"

@interface ActivityListViewController ()<UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate>
{
    NSInteger nPage;
    NSMutableArray *aryActivity;
    NSMutableArray *aryFilterActivity;    //筛选的数据
    
    NSString *strSearchText;
    NSInteger nSelfFlag;        //我报名的活动
    NoSearchView *noSearchView;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarActivity;
@property (weak, nonatomic) IBOutlet UITableView *tableViewActivity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableHeight;
@property (weak, nonatomic) IBOutlet UISearchDisplayController *searchDisplayControllerActivity;

@end

@implementation ActivityListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.searchBarActivity.height)];
        view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.searchBarActivity insertSubview:view atIndex:1];
    }
    self.searchDisplayControllerActivity.searchResultsTableView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];;
    
    self.searchDisplayControllerActivity.searchResultsTableView.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.searchDisplayControllerActivity.searchResultsTableView.scrollsToTop = NO;
    if (self.activityListType == ActivityListHistoryType)
    {
        self.title = @"活动回顾";
        self.constraintTableHeight.constant = self.searchBarActivity.height;
        nSelfFlag = 0;
    }
    else
    {
        self.title = @"我的活动";
        self.constraintTableHeight.constant = 0;
        nSelfFlag = 1;
    }
    
     noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:[NSString stringWithFormat:@"还没有%@数据",self.title]];
    
    self.tableViewActivity.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self.searchDisplayControllerActivity.searchResultsTableView registerNib:[UINib nibWithNibName:@"ActivityListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ActivityListCell"];
    self.searchDisplayControllerActivity.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableViewActivity registerNib:[UINib nibWithNibName:@"ActivityListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ActivityListCell"];
    [_tableViewActivity registerNib:[UINib nibWithNibName:@"ActivityOrderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ActivityOrderCell"];
    
    //下拉刷新
    @weakify(self)
    self.tableViewActivity.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    self.tableViewActivity.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    aryActivity = [NSMutableArray array];
    aryFilterActivity = [NSMutableArray array];
    [self loadNewData:YES];
}

- (void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    
    [ActivityService getActivityList:@"" myActivity:nSelfFlag page:nPage size:10 result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryTempData != nil && aryTempData.count>0)
                {
                    [aryActivity removeAllObjects];
                    [aryActivity addObjectsFromArray:aryTempData];
                }
            }
            else
            {
                //上拖加载
                [aryActivity addObjectsFromArray:aryTempData];
            }
            
            if (aryTempData != nil && aryTempData.count>0)
            {
                nPage ++;
            }
            
            //排序处理
            [aryActivity sortUsingComparator:^NSComparisonResult(BlogVo *obj1, BlogVo *obj2) {
                return [obj2.strCreateDate compare:obj1.strCreateDate];
            }];
            
            if (aryActivity.count == 0)
            {
                [self.view addSubview:noSearchView];
            }
            else
            {
                [noSearchView removeFromSuperview];
            }
            
            [self.tableViewActivity reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.tableViewActivity.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.tableViewActivity.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.tableViewActivity.mj_footer endRefreshing];
        }
    }];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayControllerActivity.searchResultsTableView)
    {
        return aryFilterActivity.count;
    }
    else
    {
        return aryActivity.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.activityListType == ActivityListOrderType)
    {
        ActivityOrderCell *cellActivity = [tableView dequeueReusableCellWithIdentifier:@"ActivityOrderCell" forIndexPath:indexPath];
        cellActivity.entity = aryActivity[indexPath.row];
        cell = cellActivity;
    }
    else
    {
        ActivityListCell *cellActivity = [tableView dequeueReusableCellWithIdentifier:@"ActivityListCell" forIndexPath:indexPath];
        if (tableView == self.searchDisplayControllerActivity.searchResultsTableView)
        {
            cellActivity.entity = aryFilterActivity[indexPath.row];
        }
        else
        {
            cellActivity.entity = aryActivity[indexPath.row];
        }
        cell = cellActivity;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activityListType == ActivityListOrderType)
    {
        return 127;
    }
    else
    {
        return 152;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BlogVo *blog;
    if (tableView == self.searchDisplayControllerActivity.searchResultsTableView)
    {
        //search
        blog = aryFilterActivity[indexPath.row];
        self.navigationController.navigationBar.hidden = YES;
    }
    else
    {
        blog = aryActivity[indexPath.row];
    }
    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    shareDetailViewController.fd_prefersNavigationBarHidden = YES;
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    
    
    
    [self.navigationController pushViewController:shareDetailViewController animated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    strSearchText = searchBar.text;
    [self doSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [aryFilterActivity removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)doSearch
{
    //1.Condition Check
    if (strSearchText == nil || strSearchText.length<=0)
    {
        return;
    }
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ActivityService getActivityList:strSearchText myActivity:0 page:1 size:35 result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryFilterActivity removeAllObjects];
            [aryFilterActivity addObjectsFromArray:retInfo.data];
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

@end
