//
//  SearchContentViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SearchContentViewController.h"
#import "UserProfileViewController.h"
#import "ShareDetailViewController.h"
#import "UserVo.h"
#import "BlogVo.h"
#import "ExtScope.h"
#import "MJRefresh.h"
#import "ShareListCell.h"
#import "FollowUserCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NoSearchView.h"

@interface SearchContentViewController ()<UITableViewDataSource,UITableViewDelegate,ShareListCellDelegate>
{
    NSInteger nPage;
    NoSearchView *noSearchView;
}
@property (nonatomic, strong) NSString *strSearchText;

@end

@implementation SearchContentViewController

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
    self.tableViewData.backgroundColor = [UIColor clearColor];
    self.tableViewData.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewData.backgroundColor = COLOR(250, 246, 245, 1.0);
    
    self.tableViewData.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:@"没有搜索到数据"];
    
    [self.view addSubview:self.tableViewData];
    
    [_tableViewData registerNib:[UINib nibWithNibName:@"ShareListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ShareListCell"];
    [_tableViewData registerNib:[UINib nibWithNibName:@"FollowUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FollowUserCell"];
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //下拉刷新
    @weakify(self)
    self.tableViewData.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    self.tableViewData.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    self.aryData = [[NSMutableArray alloc]init];
}

- (void)refreshData:(NSString *)strText
{
    if (![strText isEqualToString:self.strSearchText])
    {
        self.strSearchText = strText;
        [Common showProgressView:nil view:self.view modal:NO];
        [self loadNewData:YES];
    }
}

- (void)clearData
{
    [self.aryData removeAllObjects];
    [self.tableViewData reloadData];
}

//分页数据
-(void)loadNewData:(BOOL)bRefresh
{
    //block
    void (^resultBlock)(ServerReturnInfo *retInfo) = ^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryTempData != nil && aryTempData.count>0)
                {
                    [self.aryData removeAllObjects];
                    [self.aryData addObjectsFromArray:aryTempData];
                }
            }
            else
            {
                //上拖加载
                [self.aryData addObjectsFromArray:aryTempData];
            }
            
            if (self.aryData.count == 0)
            {
                [self.view addSubview:noSearchView];
            }
            else
            {
                [noSearchView removeFromSuperview];
            }
            
            if (aryTempData != nil && aryTempData.count>0)
            {
                nPage ++;
            }
            [self.tableViewData reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.tableViewData.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.tableViewData.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.tableViewData.mj_footer endRefreshing];
        }
    };
    
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    
    if (self.nPageType == 0)
    {
        [ServerProvider getShareListByType:nil search:self.strSearchText tag:nil page:nPage modelId:nil result:resultBlock];
    }
    else
    {
        //搜索人
        [ServerProvider getAllUserListByPage:nPage andSearchText:self.strSearchText andPageSize:10 result:resultBlock];
    }
}


- (void)configureCell:(ShareListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
    
    BlogVo *blogObjectVo = [_aryData objectAtIndex:[indexPath row]];
    [cell setEntity:blogObjectVo controller:self.parentController];
}

#pragma mark - ShareListCellDelegate
- (void)shareListCellAction:(NSInteger)nType data:(BlogVo *)blogVo
{
    if (nType == 0)
    {
        //屏蔽用户成功,清除同个人的分享
        for(NSInteger i=_aryData.count-1;i>=0;i--)
        {
            BlogVo *tempBlog = _aryData[i];
            if ([blogVo.strCreateBy isEqualToString:tempBlog.strCreateBy])
            {
                [_aryData removeObject:tempBlog];
            }
        }
        
        [self.tableViewData reloadData];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.aryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.nPageType == 0)
    {
        //分享搜索页面
        static NSString *identifier = @"ShareListCell";
        ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.delegate = self;
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else
    {
        //用户搜索页面
        FollowUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowUserCell" forIndexPath:indexPath];
        cell.parentController = self;
        cell.entity = _aryData[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.nPageType == 0)
    {
        //采用自动计算高度，并且带有缓存机制
        return [tableView fd_heightForCellWithIdentifier:@"ShareListCell" cacheByIndexPath:indexPath configuration:^(ShareListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
    else
    {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nPageType == 0)
    {
        //当日热贴榜
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
        shareDetailViewController.m_originalBlogVo = self.aryData[indexPath.row];
        [self.parentController.navigationController pushViewController:shareDetailViewController animated:YES];
    }
    else
    {
        //用户排名
        UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
        userProfileViewController.strUserID = ((UserVo*)self.aryData[indexPath.row]).strUserID;
        [self.parentController.navigationController pushViewController:userProfileViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
