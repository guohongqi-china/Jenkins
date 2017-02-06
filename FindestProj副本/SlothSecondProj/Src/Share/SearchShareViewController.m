//
//  SearchShareViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SearchShareViewController.h"
#import "ShareListCell.h"
#import "MJRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ShareDetailViewController.h"
#import "ExtScope.h"

@interface SearchShareViewController ()<UITableViewDataSource,UITableViewDelegate,ShareListCellDelegate,UIActionSheetDelegate>
{
    NSMutableArray *aryShare;
    NSInteger nPage;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewShare;

@end

@implementation SearchShareViewController

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
    self.title = _tagVo.strTagName;
    
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.tableViewShare.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    
    
    [_tableViewShare registerNib:[UINib nibWithNibName:@"ShareListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ShareListCell"];
    //下拉刷新
    @weakify(self)
    _tableViewShare.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    _tableViewShare.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    nPage = 1;
    aryShare = [NSMutableArray array];
    
    [Common showProgressView:nil view:self.view modal:NO];
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
    
    if ([self.strPageType isEqualToString:@"categoryBlog"])
    {
        NSString *type = nil;
        if ([self.title isEqualToString:@"分享"]) {
            type = @"blog";
        }else if ([self.title isEqualToString:@"投票"]){
            type = @"vote";
        }else{
            type = @"qa";
        }
        
        [ServerProvider getShareListByType:type search:@"9810" tag:nil page:nPage modelId:nil  result:resultBlock];
    }
    else if ([self.strPageType isEqualToString:@"essence"] || [self.strPageType isEqualToString:@"hotTag"])
    {
        [ServerProvider getShareListByType:nil search:nil tag:@[self.tagVo] page:nPage modelId:nil  result:resultBlock];
    }
    else if ([self.strPageType isEqualToString:@"hotSearch"])
    {
        [ServerProvider getShareListByType:nil search:self.tagVo.strTagName tag:nil page:nPage modelId:nil result:resultBlock];
    }
}

- (void)configureCell:(ShareListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
    
    BlogVo *blogObjectVo = [aryShare objectAtIndex:[indexPath row]];
    [cell setEntity:blogObjectVo controller:self];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1001)
    {
        if (buttonIndex == 0)
        {
            //屏蔽
        }
        else if (buttonIndex == 1)
        {
            //举报
        }
    }
}

#pragma mark - ShareListCellDelegate
- (void)shareListCellAction:(NSInteger)nType data:(BlogVo *)blogVo
{
    if (nType == 0)
    {
        //屏蔽 & 举报
        
    }
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
    
    [self.navigationController pushViewController:shareDetailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
