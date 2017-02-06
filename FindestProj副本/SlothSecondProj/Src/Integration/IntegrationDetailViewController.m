//
//  IntegrationDetailViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "IntegrationDetailViewController.h"
#import "IntegrationDetailCell.h"
#import "IntegrationDetailVo.h"
#import "MJRefresh.h"
#import "UIViewExt.h"
#import "UserVo.h"

@interface IntegrationDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger nPage;
    
    //Header View
    UIView *viewTableHeader;
    UILabel *lblModeratorIntegral;
}

@end

@implementation IntegrationDetailViewController

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
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.tableViewData = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-32-0.5)];
    self.tableViewData.dataSource = self;
    self.tableViewData.delegate = self;
    self.tableViewData.backgroundColor = [UIColor clearColor];
    self.tableViewData.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewData];
    [self.tableViewData registerNib:[UINib nibWithNibName:@"IntegrationDetailCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"IntegrationDetailCell"];
    
    if (self.nPageType == 2)
    {
        //版主
        viewTableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 41.5)];
        viewTableHeader.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        self.tableViewData.tableHeaderView = viewTableHeader;
        
        UIView *viewSep = [[UIView alloc]initWithFrame:CGRectMake(0, viewTableHeader.height-0.5, kScreenWidth, 0.5)];
        viewSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        [viewTableHeader addSubview:viewSep];
        
        lblModeratorIntegral = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 41.5)];
        lblModeratorIntegral.textColor = COLOR(239, 111, 88, 1.0);
        lblModeratorIntegral.textAlignment = NSTextAlignmentCenter;
        [viewTableHeader addSubview:lblModeratorIntegral];
        
        [self setModeratorText:[Common getCurrentUserVo].fBadgeIntegral];
    }
    
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

-(void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    else
    {
        //上拖加载
    }
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider getIntegrationList:nPage type:self.nPageType result:^(ServerReturnInfo *retInfo) {
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
            if([retInfo.data2 boolValue])
            {
                [self.tableViewData.mj_footer endRefreshingWithNoMoreData];   //最后一页
            }
            [self.tableViewData.mj_header endRefreshing];
        }
        else
        {
            if([retInfo.data2 boolValue])
            {
                [self.tableViewData.mj_footer endRefreshingWithNoMoreData];   //最后一页
            }
            else
            {
                [self.tableViewData.mj_footer endRefreshing];
            }
        }
    }];
}

- (void)setModeratorText:(double)fModeratorIntegral
{
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"共 %g 分",fModeratorIntegral]];
    [attri addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:14] range:NSMakeRange(0, 1)];
    [attri addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:24] range:NSMakeRange(1, attri.length-2)];
    [attri addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:14] range:NSMakeRange(attri.length-1, 1)];
    
    lblModeratorIntegral.attributedText = attri;
}

//供外部调用
- (void)refreshData
{
    if (self.aryData.count == 0)
    {
        [self loadNewData:YES];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView*) scrollView
{
    return YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.aryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntegrationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IntegrationDetailCell" forIndexPath:indexPath];
    IntegrationDetailVo *integrationDetailVo = self.aryData[indexPath.row];
    [cell setEntity:integrationDetailVo row:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
