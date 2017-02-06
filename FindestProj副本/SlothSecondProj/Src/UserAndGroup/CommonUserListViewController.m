//
//  CommonUserListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CommonUserListViewController.h"
#import "MJRefresh.h"
#import "CommonUserListCell.h"
#import "ExtScope.h"
#import "ActivityService.h"
#import "UserProfileViewController.h"

@interface CommonUserListViewController ()<UITableViewDataSource,UITableViewDelegate,CommonUserListCellDelegate>
{
    NSMutableArray *aryUser;
    NSInteger nPage;
    
    NSInteger nBackRefresh;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewUser;

@end

@implementation CommonUserListViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.userListType == UserListActivityType)
    {
        self.title = @"已报名的人";
    }
    else if (self.userListType == UserListAttentionType)
    {
        //关注用户
        self.title = @"正在关注";
    }
    else
    {
        //粉丝用户
        self.title = @"关注者";
    }
    
    [_tableViewUser registerNib:[UINib nibWithNibName:@"CommonUserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CommonUserListCell"];
    _tableViewUser.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewUser.tableFooterView = [UIView new];
    
    
    self.tableViewUser.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //下拉刷新
    @weakify(self)
    _tableViewUser.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    _tableViewUser.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    nPage = 1;
    nBackRefresh = 0;
    aryUser = [NSMutableArray array];
    
    [self loadNewData:YES];
}

//分页数据
-(void)loadNewData:(BOOL)bRefresh
{
   
    void (^resultBlock)(ServerReturnInfo *retInfo) = ^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryTempData != nil && aryTempData.count>0)
                {
                    [aryUser removeAllObjects];
                    [aryUser addObjectsFromArray:aryTempData];
                }
            }
            else
            {
                //上拖加载
                [aryUser addObjectsFromArray:aryTempData];
            }
            
            if (aryTempData != nil && aryTempData.count>0)
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
    };
    
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
        
    if (self.userListType == UserListActivityType)
    {
        [ActivityService getActivityUserList:self.blogVo.streamId page:nPage result:resultBlock];
    }
    else if (self.userListType == UserListAttentionType)
    {
        //关注用户
        [ServerProvider getAttentionOrFansList:self.strUserID search:nil type:0 page:nPage size:20 result:resultBlock];
    }
    else
    {
        //粉丝用户
        [ServerProvider getAttentionOrFansList:self.strUserID search:nil type:1 page:nPage size:20 result:resultBlock];
    }
}

- (void)backForePage {
    if (nBackRefresh == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUserProfilePage" object:nil];
    }
    [super backForePage];
}

#pragma mark - CommonUserListCellDelegate
- (void)updateAttentionState:(UserVo *)userVo {
    nBackRefresh = 1;
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryUser.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonUserListCell" forIndexPath:indexPath];
    if (self.userListType == UserListActivityType)
    {
        cell.btnAttention.hidden = YES;
    }
    else
    {
        cell.btnAttention.hidden = NO;
    }
    cell.delegate = self;
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
    
    UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
    userProfileViewController.strUserID = ((UserVo*)aryUser[indexPath.row]).strUserID;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
    
}

@end
