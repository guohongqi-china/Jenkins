//
//  TopRankingViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TopRankingViewController.h"
#import "TopRangkingManageViewController.h"
#import "UIViewExt.h"
#import "UserRankingCell.h"
#import "BlogVo.h"
#import "ShareDetailViewController.h"
#import "ShareRankingCell.h"
#import "CompanyRankingVo.h"
#import "CompanyRankingCell.h"
#import "UserProfileViewController.h"

@interface TopRankingViewController ()

@end

@implementation TopRankingViewController

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
    self.tableViewData = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-32-0.5)];
    self.tableViewData.dataSource = self;
    self.tableViewData.delegate = self;
    self.tableViewData.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewData];
    
    if (self.nPageType == 0 || self.nPageType == 1 | self.nPageType == 2)
    {
        self.tableViewData.backgroundColor = COLOR(250, 246, 245, 1.0);
    }
    self.tableViewData.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //添加刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableViewData addSubview:_refreshControl];
    [self.tableViewData sendSubviewToBack:_refreshControl];
    
    //旋转等待
    self.imgViewWaiting = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"waiting_bk.png"]];
    self.imgViewWaiting.frame = CGRectMake((kScreenWidth-77)/2,(kScreenHeight-77)/2-100, 77, 77);
    [self.view addSubview:self.imgViewWaiting];
    self.imgViewWaiting.hidden = YES;
    
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activity setCenter:CGPointMake(kScreenWidth/2,(kScreenHeight/2-100))];
    [self.view addSubview:self.activity];
    self.activity.hidden = YES;
    
    if(self.nPageType == 0)
    {
        //当日热贴榜
       
    }
    else if(self.nPageType == 1)
    {
        //积分排行榜
        
    }
    else if(self.nPageType == 2)
    {
        //风云人物榜
        
    }
    else if(self.nPageType == 3)
    {
        //我的排名
        
    }
    else if(self.nPageType == 4)
    {
        //公司排名
        self.tableViewData.allowsSelection = NO;
    }
}

- (void)initData
{
    self.aryData = [[NSMutableArray alloc]init];
}

-(void)isHideActivity:(BOOL)bHide
{
    [self.view bringSubviewToFront:self.imgViewWaiting];
    [self.view bringSubviewToFront:self.activity];
    
    self.imgViewWaiting.hidden = bHide;
    [self.activity setHidden:bHide];
    if (bHide)
    {
        [self.activity stopAnimating];
    }
    else
    {
        [self.activity startAnimating];
    }
}

-(void)getDataList:(BOOL)bFirstLoad
{
    if(self.nPageType == 0)
    {
        //当日热贴榜
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getHotShareList:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo.data status:bFirstLoad];
            }
            else
            {
                [self.refreshControl endRefreshing];
            }
        }];
    }
    else if(self.nPageType == 1)
    {
        //积分排行榜
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getIntegrationSort:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo.data status:bFirstLoad];
            }
            else
            {
                [self.refreshControl endRefreshing];
            }
        }];
    }
    else if(self.nPageType == 2)
    {
        //风云人物榜
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getHotUserList:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo.data status:bFirstLoad];
            }
            else
            {
                [self.refreshControl endRefreshing];
            }
        }];
    }
    else if(self.nPageType == 3)
    {
        //我的排名
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getSelfRankUserList:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo.data status:bFirstLoad];
            }
            else
            {
                [self.refreshControl endRefreshing];
            }
        }];
    }
    else if(self.nPageType == 4)
    {
        //公司排名
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getCompanyRankingList:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo.data status:bFirstLoad];
            }
            else
            {
                [self.refreshControl endRefreshing];
            }
        }];
    }
}

- (void)dataFinishedLoading:(NSMutableArray*)dataArray status:(BOOL)bFirstLoad
{
    if (dataArray != nil)
    {
        [self.aryData removeAllObjects];
        [self.aryData addObjectsFromArray:dataArray];
        [self.refreshControl endRefreshing];
    }
    else
    {
        [self.refreshControl endRefreshing];
    }
    [self.tableViewData reloadData];
    
    if (bFirstLoad && self.nPageType == 3)
    {
        //位置滑动到本人排名的地方
        for (int i=0;i<self.aryData.count;i++)
        {
            UserVo *userVo = self.aryData[i];
            if ([userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
            {
                [self.tableViewData scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                break;
            }
        }
    }
}

-(void)refreshView
{
    [self getDataList:NO];
}

//供外部调用
- (void)refreshData
{
    if (self.aryData.count == 0)
    {
        [self getDataList:YES];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView*) scrollView
{
    return YES;
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.aryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.nPageType == 0)
    {
        //当日热贴榜
        static NSString *identifier = @"ShareRankingCell";
        ShareRankingCell *cell = (ShareRankingCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ShareRankingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
            cell.selectedBackgroundView = viewSelected;
        }
        [cell initWithData:self.aryData[indexPath.row]];
        return cell;
    }
    else if(self.nPageType == 4)
    {
        //公司排名
        static NSString *identifier = @"CompanyRankingCell";
        CompanyRankingCell *cell = (CompanyRankingCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[CompanyRankingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
            cell.selectedBackgroundView = viewSelected;
        }
        CompanyRankingVo *rankingVo = self.aryData[indexPath.row];
        rankingVo.nIndex = indexPath.row+1;
        [cell initWithData:rankingVo];
        return cell;
    }
    else
    {
        //用户排名
        static NSString *identifier = @"UserRankingCell";
        UserRankingCell *cell = (UserRankingCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UserRankingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
            cell.selectedBackgroundView = viewSelected;
        }
        
        cell.indexPath = indexPath;
        cell.nPageType = self.nPageType;
        [cell initWithData:self.aryData[indexPath.row]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.nPageType == 0)
    {
        return 90;
    }
    else if(self.nPageType == 3)
    {
        return 60;
    }
    else if(self.nPageType == 4)
    {
        return 68;
    }
    else
    {
        return 70;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nPageType == 0)
    {
        //当日热贴榜
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
        shareDetailViewController.m_originalBlogVo = self.aryData[indexPath.row];
        [self.homeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
    }
    else if (self.nPageType == 4)
    {
        //公司排名
    }
    else
    {
        //用户排名
        UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
        userProfileViewController.strUserID = ((UserVo*)self.aryData[indexPath.row]).strUserID;
        [self.homeViewController.navigationController pushViewController:userProfileViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
