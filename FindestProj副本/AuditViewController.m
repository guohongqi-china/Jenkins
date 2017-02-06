//
//  AuditViewController.m
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AuditViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "VNetworkFramework.h"
#import "ServerURL.h"
#import "TableList.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HomeTableViewCell.h"
#import "ShareListCell.h"
#import "ShareListViewController.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "ExtScope.h"
#import "ServerProvider.h"
#import "ShareDetailViewController.h"
#import "ShareCoverFlowView.h"
#import "TheTableViewForTitle.h"
#import "Model.h"
#import "MainDetailViewController.h"
@interface AuditViewController ()<UITableViewDelegate,UITableViewDataSource,ShareListCellDelegate>
{
    NSInteger currentPage;
    NSInteger totalPage;
}
@property (strong, nonatomic) IBOutlet UITableView *dataTabelView;
@property (nonatomic, strong) NSMutableArray *modelArr;/** <#注释#> */

@property (nonatomic, strong) NSMutableDictionary *modelDic;/** <#注释#> */
@end

@implementation AuditViewController
- (NSMutableDictionary *)modelDic{
    if (!_modelDic) {
        _modelDic = [NSMutableDictionary dictionary];
    }
    return _modelDic;
}
- (NSMutableArray *)modelArr{
    if (!_modelArr) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    currentPage = 1;
    totalPage = 1;
    [self setUpUI];
    [self loadData];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction) name:@"mainTable" object:nil];
}
- (void)notificationAction{
    [self loadData];
}
/**
 * 基本设置
 */
- (void)setUpUI{
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction) image:@"3 (6)" highImage:nil];
    
    self.view.backgroundColor = [UIColor redColor];
    self.title = @"审核";
    
    self.dataTabelView.contentInset = UIEdgeInsetsMake(64, 0, 64, 0);
    
//    [self.dataTabelView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:@"HomeTableViewCell"];
    [self.dataTabelView registerNib:[UINib nibWithNibName:@"ShareListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ShareListCell"];
    //下拉刷新
    @weakify(self)
    self.dataTabelView.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        currentPage = 1;
        [self loadData];
        
    }];
        [self.dataTabelView.mj_header beginRefreshing];
    
    //上拉加载更多
    self.dataTabelView.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        currentPage += 1;
        [self loadData];
        
    }];


}

/**
 * 加载数据
 */
- (void)loadData{
     VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL shenhe]];
    NSLog(@"%@",[ServerURL shenhe]);
    if (currentPage > totalPage) {
 
         [self endFresh];
        [self.dataTabelView.mj_header endRefreshing];
        [self.dataTabelView.mj_footer endRefreshingWithNoMoreData];
        [self.dataTabelView reloadData];
        return;
    }
    NSDictionary *bodyDic = @{@"pageInfo":@{@"pageNumber":@(currentPage),@"pageSize":@"20",@"sortTypeStr":@"desc",@"sortColumn":@"createDate"},@"isDraft":@"2"};
    [framework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
             [self endFresh];
        }else{
            NSLog(@"%@",responseObject);
           self.modelArr =  [ServerProvider getBlogListByJSONArray:responseObject[@"content"]];
            totalPage = [responseObject[@"totalPages"] integerValue];
             [self endFresh];
             [self.dataTabelView reloadData];
           

        }
    }];
}
- (void)endFresh{
    [self.dataTabelView.mj_footer endRefreshing];
    [self.dataTabelView.mj_header endRefreshing];

}
//返回按钮点击方法
- (void)buttonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 * 表视图代理方法
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _modelArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    ManListModel *model = [[ManListModel alloc]init];
//    model = self.modelArr[indexPath.row];
//    CGFloat he;
//    if (self.modelDic[model.ID]) {
//        return [self.modelDic[model.ID] floatValue];
//    }else{
//        he = [model returenCellHeight];
//        NSLog(@"%f",he);
//        [self.modelDic setObject:@(he) forKey:model.ID];
//    }
//    return he;
    return [tableView fd_heightForCellWithIdentifier:@"ShareListCell" cacheByIndexPath:indexPath configuration:^(ShareListCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
    }];
}
- (void)configureCell:(ShareListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
    
    BlogVo *blogObjectVo = [self.modelArr objectAtIndex:[indexPath row]];
    [cell setEntity:blogObjectVo controller:_perSONcONTROLER];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell" forIndexPath:indexPath];
//    ManListModel *model = [[ManListModel alloc]init];
//    model = self.modelArr[indexPath.row];
//
//    cell.dataModel = model;
//    return cell;
    static NSString *identifier = @"ShareListCell";
    ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;


}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    BlogVo *blog = [_modelArr objectAtIndex:[indexPath row]];
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    
    if(self.perSONcONTROLER != nil)
    {
    }
    shareDetailViewController.shareType = ShareDetailViewControllerIS;
    shareDetailViewController.detailType = YES;
    [self.perSONcONTROLER.navigationController pushViewController:shareDetailViewController animated:YES];
    shareDetailViewController.isHe = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark - ShareListCellDelegate
- (void)shareListCellAction:(NSInteger)nType data:(BlogVo *)blogVo
{
    if (nType == 0)
    {
        //屏蔽用户成功,清除同个人的分享
        for(NSInteger i=_modelArr.count-1;i>=0;i--)
        {
            BlogVo *tempBlog = _modelArr[i];
            if ([blogVo.strCreateBy isEqualToString:tempBlog.strCreateBy])
            {
                [_modelArr removeObject:tempBlog];
            }
        }
        
        [_dataTabelView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
