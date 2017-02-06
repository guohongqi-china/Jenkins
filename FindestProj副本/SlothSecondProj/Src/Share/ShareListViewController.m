//
//  ShareListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/2.
//  Copyright © 2016年 visionet. All rights reserved.
//
typedef enum {
    XMGTopicTypeAll = 1,
    XMGTopicTypePicture = 10,
    XMGTopicTypeWord = 29,
    XMGTopicTypeVoice = 31,
    XMGTopicTypeVideo = 41
} XMGTopicType;

#import "ShareListViewController.h"
#import "ShareHomeViewController.h"
#import "ShareListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "ExtScope.h"
#import "ShareDetailViewController.h"
#import "ShareCoverFlowView.h"
#import "TheTableViewForTitle.h"
#import "Model.h"
#import "AFNetworking.h"
@interface ShareListViewController ()<UITableViewDataSource,UITableViewDelegate,ShareListCellDelegate,UIActionSheetDelegate,TheTableViewForTitleDelegate>
{
    NSMutableArray *aryTop;     //置顶数据
    NSMutableArray *aryShare;
    NSInteger nPage;
    NSString *strID;
    NSString  *pushId;
  
    ShareCoverFlowView *shareCoverFlowView;
}
@property (nonatomic, assign) XMGTopicType type;


@end

@implementation ShareListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshShareList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshShareListFromDetail" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isPush = NO;
    [self initView];
    [self initData];



    
}
- (void)viewWillAppear:(BOOL)animated{
    //SMR代理方法
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(NTAction:) name:@"loadNewData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(JPSHNotification:) name:@"JPSHNotification" object:nil];
}
- (void)JPSHNotification:(NSNotification *)notifie{
    pushId = notifie.userInfo[@"ID"];
    _isPush = YES;
                ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
                BlogVo *blog = [[BlogVo alloc]init];
                blog.streamId = pushId;
                shareDetailViewController.m_originalBlogVo = blog;
                if (blog.streamId.length == 0)
                {
                    [Common tipAlert:@"数据异常，请求失败"];
                    return;
                }
                
                if(self.shareHomeViewController != nil)
                {
                    [self.shareHomeViewController hideBottomWhenPushed];
                }
                shareDetailViewController.shareType = ShareDetailViewControllerNO;
                
                [self.shareHomeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
                
  
    [self loadNewData:YES];
}
#pragma ===================标题视图代理方法=============================
- (void)NTAction:(NSNotification *)textCation{
//    _Type = LoadDataFirstType;
//    currentPage = 0;
    Model *mod = textCation.userInfo[@"key"];
    strID = mod.ID;
//    _dataTP =  [mod.tagName isEqualToString:@"全部"] ? DataTypeAll : DataTypeone;
//    [self loadNewData:YES modelId:strID];
    [self.tableViewShare.mj_header beginRefreshing];  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
     [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

- (void)initView
{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshShareList) name:@"RefreshShareList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshShareListFromDetail:) name:@"RefreshShareListFromDetail" object:nil];
    
    self.tableViewShare = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableViewShare.dataSource = self;
    self.tableViewShare.delegate = self;
    self.tableViewShare.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewShare.separatorStyle = UITableViewCellSeparatorStyleNone;
//    tableViewShare.allowsSelection = NO;
    [self.view addSubview:self.tableViewShare];
    [self.tableViewShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, NAV_BAR_HEIGHT+42, 0));//+49
    }];
    
    [self.tableViewShare registerNib:[UINib nibWithNibName:@"ShareListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ShareListCell"];
    
    //下拉刷新
    @weakify(self)
    self.tableViewShare.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    self.tableViewShare.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
    
//    if(self.shareListType == ShareListAllType)
//    {
//        [self initTableHeaderView];
//    }
}

- (void)refreshSkin
{
    if(self.shareListType == ShareListAllType)
    {
        [shareCoverFlowView refreshSkin];
    }
        
    self.tableViewShare.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self.tableViewShare reloadData];
}

- (void)initData
{    nPage = 1;
    aryShare = [NSMutableArray array];
    [Common showProgressView:@"加载中..." view:self.view offset:-104 modal:NO];
    [self loadNewData:YES];
}

//分页数据
-(void)loadNewData:(BOOL)bRefresh
{
    //block
    void (^resultBlock)(ServerReturnInfo *retInfo) = ^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryData != nil && aryData.count>0)
                {
                    [aryShare removeAllObjects];
                    [aryShare addObjectsFromArray:aryData];
                }
            }
            else
            {
                //上拖加载
                [aryShare addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                nPage ++;
            }
         
            [_tableViewShare reloadData];
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
                [_tableViewShare.mj_footer endRefreshingWithNoMoreData];   //最后一页
            }
            [_tableViewShare.mj_header endRefreshing];
        }
        else
        {
            if([retInfo.data2 boolValue])
            {
                [_tableViewShare.mj_footer endRefreshingWithNoMoreData];   //最后一页
            }
            else
            {
                [_tableViewShare.mj_footer endRefreshing];
            }
        }
    };
    
    //Request action
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }

    if (self.shareListType == ShareListAllType)
    {
        [ServerProvider getShareListByType:nil search:nil tag:nil page:nPage modelId:strID result:resultBlock];
    }
    else
    {
        //关注的人分享列表
        [ServerProvider getAttentionShareList:nPage result:resultBlock];
    }
}

-(void)refreshShareList
{
    if (self.shareListType == ShareListAllType)
    {
        [self loadNewData:YES];
        [self.tableViewShare reloadData];
        [self.tableViewShare setContentOffset:CGPointZero animated:YES];
    }
}

-(void)refreshShareListFromDetail:(NSNotification*)notification
{
    BlogVo *blogVo = [notification object];
    if (blogVo!= nil)
    {
        //删除分享操作
        [aryShare removeObject:blogVo];
    }
    [self.tableViewShare reloadData];
}

- (void)initTableHeaderView
{
    UIView *vHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 208)];
    
    shareCoverFlowView = [[ShareCoverFlowView alloc]initWithFrame:vHeader.frame];
    shareCoverFlowView.shareListViewController = self;
    [vHeader addSubview:shareCoverFlowView];
    
    _tableViewShare.tableHeaderView = vHeader;
}

- (void)configureCell:(ShareListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
    
    BlogVo *blogObjectVo = [aryShare objectAtIndex:[indexPath row]];
    [cell setEntity:blogObjectVo controller:self.shareHomeViewController];
}

#pragma mark - ShareListCellDelegate
- (void)shareListCellAction:(NSInteger)nType data:(BlogVo *)blogVo
{
    if (nType == 0)
    {
        //屏蔽用户成功,清除同个人的分享
        for(NSInteger i=aryShare.count-1;i>=0;i--)
        {
            BlogVo *tempBlog = aryShare[i];
            if ([blogVo.strCreateBy isEqualToString:tempBlog.strCreateBy])
            {
                [aryShare removeObject:tempBlog];
            }
        }
        
        [_tableViewShare reloadData];
    }
}

- (void)pushViewController:(UIViewController *)viewController
{
    if(self.shareHomeViewController != nil)
    {
        [self.shareHomeViewController hideBottomWhenPushed];
    }
    viewController.hidesBottomBarWhenPushed = YES;
    [self.shareHomeViewController.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryShare.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ShareListCell";
    ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"ShareListCell" cacheByIndexPath:indexPath configuration:^(ShareListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    BlogVo *blog = [aryShare objectAtIndex:[indexPath row]];
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    
    if(self.shareHomeViewController != nil)
    {
        [self.shareHomeViewController hideBottomWhenPushed];
    }
    shareDetailViewController.shareType = ShareDetailViewControllerNO;

    [self.shareHomeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
