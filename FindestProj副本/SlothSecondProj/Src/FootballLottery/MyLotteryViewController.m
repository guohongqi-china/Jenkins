//
//  MyLotteryViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MyLotteryViewController.h"
#import "MJRefresh.h"
#import "FootballService.h"
#import "MyLotteryCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "LeagueVo.h"

@interface MyLotteryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger nPage;
    NSMutableArray *aryData;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewRecord;

@end

@implementation MyLotteryViewController

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
    self.title = @"竞猜记录";
    
    self.tableViewRecord.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //上拉加载更多
    @weakify(self)
    self.tableViewRecord.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    aryData = [NSMutableArray array];
    [self loadNewData:YES];
}

- (void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    
    [FootballService getMyLeagueList:-1 page:nPage result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryTempData != nil && aryTempData.count>0)
                {
                    [aryData removeAllObjects];
                    [aryData addObjectsFromArray:aryTempData];
                }
            }
            else
            {
                //上拖加载
                [aryData addObjectsFromArray:aryTempData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                nPage ++;
            }
            [self.tableViewRecord reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.tableViewRecord.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.tableViewRecord.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.tableViewRecord.mj_footer endRefreshing];
        }
    }];
}

- (void)configureCell:(MyLotteryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    LeagueVo *leagueVo = aryData[indexPath.row];
    
    NSString *strLastDate;
    if (indexPath.row == 0)
    {
        strLastDate = nil;
    }
    else
    {
        LeagueVo *leagueVoTemp = aryData[indexPath.row-1];
        strLastDate = leagueVoTemp.strDate;
    }
    
    [cell setEntity:leagueVo last:strLastDate];
}

#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyLotteryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyLotteryCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"MyLotteryCell" cacheByIndexPath:indexPath configuration:^(MyLotteryCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
