//
//  UserShieldListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserShieldListViewController.h"
#import "UserShieldListCell.h"
#import "UserVo.h"
#import "ShareService.h"
#import "MJRefresh.h"
#import "ExtScope.h"

@interface UserShieldListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryUser;
    NSInteger nPage;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewUser;

@end

@implementation UserShieldListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)initView
{
    self.title = @"已屏蔽的人";
    
    self.tableViewUser.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewUser.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.tableViewUser.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //上拉加载更多
    @weakify(self)
    self.tableViewUser.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    aryUser = [NSMutableArray array];
    
    [self loadNewData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    
    [ShareService getShieldUserList:nPage result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryData != nil && aryData.count>0)
                {
                    [aryUser removeAllObjects];
                    [aryUser addObjectsFromArray:aryData];
                }
            }
            else
            {
                //上拖加载
                [aryUser addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                nPage ++;
            }
            [self.tableViewUser reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.tableViewUser.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.tableViewUser.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.tableViewUser.mj_footer endRefreshing];
        }
    }];
}

- (void)restoreUserAction:(UserVo *)userVo
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ShareService restoreShieldUserByID:userVo.strUserID result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryUser removeObject:userVo];
            [self.tableViewUser reloadData];
            [Common bubbleTip:@"已取消" andView:self.view];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryUser.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserShieldListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserShieldListCell" forIndexPath:indexPath];
    cell.parentController = self;
    cell.entity = aryUser[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
