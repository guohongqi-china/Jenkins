//
//  MainDetailViewController.m
//  FindestProj
//
//  Created by MacBook on 16/7/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MainDetailViewController.h"
#import "VNetworkFramework.h"
#import "ManListModel.h"
#import "HeaderView.h"
#import "UIView+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "ManTitleView.h"
#import "MJRefresh.h"
#import "TableList.h"
#import "ServerURL.h"
#import "DetailTableViewCell.h"
#import "MBProgressHUD+GHQ.h"
#import "alertView.h"
@interface MainDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    ManListModel *model;
    HeaderView *HDView;
    UITableView *contentLabel;
    ManTitleView *cellView;
    UIView *baseView;
    NSInteger currentPage;
}

@property (nonatomic, strong)     UIWindow *wind;/** <#注释#> */
@property (nonatomic, strong) alertView *grayView;
/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *modelArr;/** <#注释#> */
@end

@implementation MainDetailViewController
- (alertView *)grayView{
    if (!_grayView) {
        _grayView = [[NSBundle mainBundle]loadNibNamed:@"alertView" owner:nil options:nil].lastObject;
        _grayView.x = 0;
        _grayView.y = KscreenHeight;
        _grayView.width = KscreenWidth;
        _grayView.height = KscreenHeight ;
        
    }
    return _grayView;
}
- (NSMutableArray *)modelArr{
    if (!_modelArr) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
}
- (void)dealloc{
    
    [self.wind removeFromSuperview];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self LoadHeaderData];
    [self loadTableData:1];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldRemoveView) name:@"remove" object:nil];
//    _wind = [UIApplication sharedApplication].windows.lastObject;
//    _wind.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
//    [_wind addSubview:self.grayView];
//
//    _wind.hidden = YES;


    
}
- (void)shouldRemoveView{

    [self.grayView hidden];

}
/**
 * 布局UI
 */
- (void)setUpUI{
    //隐藏tabbar
//    self.hidesBottomBarWhenPushed = YES;
//    self.tabBarController.tabBar.hidden = YES;
    currentPage = 0 ;
    self.title = @"详情";
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    HDView = [[HeaderView alloc]init];
    //表视图
    contentLabel = [[UITableView alloc]initWithFrame:self.view.frame];
    contentLabel.contentInset = UIEdgeInsetsMake(64, 0, 64, 0);
    contentLabel.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentLabel.delegate = self;
    contentLabel.dataSource = self;
    [contentLabel registerNib:[UINib nibWithNibName:@"DetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"DetailTableViewCell"];
    //下拉刷新
    @weakify(self)
    //上拉加载更多
    contentLabel.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        currentPage += 1;
        [ self loadTableData:currentPage];
    }];

    [self.view addSubview:contentLabel];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction) image:@"3 (6)" highImage:nil];
    
    cellView = [[NSBundle mainBundle]loadNibNamed:@"ManTitleView" owner:nil options:nil].lastObject;
    
    baseView = [[UIView alloc]init];
    baseView.x = 0;
    baseView.y = 0;
    baseView.width = KscreenWidth;
    
    
    if (_isHe) {
        UIBarButtonItem *item1 = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction:) withTitle:@"通过"];
        UIBarButtonItem *item2 = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction:) withTitle:@"退回"];
        self.navigationItem.rightBarButtonItems = @[item2,item1];

    }

}
- (void)buttonAction:(UIButton *)sender{
    NSLog(@"%@",sender.titleLabel.text);
    if ([sender.titleLabel.text isEqualToString:@"通过"]) {
        VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[NSString stringWithFormat:@"%@%@",[ServerURL Judgeshenhe],_dataModel.ID]];
        [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
            if (error) {
                [MBProgressHUD showSuccess:@"审核失败" toView:nil];

            }else{
                [MBProgressHUD showSuccess:@"审核通过" toView:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"mainTable" object:nil];
            }
            
        }];

    }else{
        
        self.grayView.strId = _dataModel.ID;
        [self.grayView show];

    }
}

- (void)buttonAction{
    [self.navigationController popViewControllerAnimated:YES];
    [self.grayView sdddd];
}
/**
 * 加载列表数据
 */
- (void)loadTableData:(NSInteger )pageNumber{
   
      VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:@"http://vn-functional.chinacloudapp.cn/vx/mobile/blogComment/commentList"];
    NSDictionary *bodyDic = @{@"blogId":_dataModel.ID,@"pageInfo":@{@"pageNumber":@(pageNumber),@"pageSize":@"20"}};
    [framework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            [contentLabel.mj_footer endRefreshing];

        }else{
            NSLog(@"%@",responseObject);
            TableList *model1 = [[TableList alloc]init];
            [model1 setValuesForKeysWithDictionary:responseObject];
            [self.modelArr addObjectsFromArray:[model1.content copy]];
            [contentLabel reloadData];
            [model1.totalPages integerValue] == currentPage ? [contentLabel.mj_footer endRefreshingWithNoMoreData] : [contentLabel.mj_footer endRefreshing];
        }
        
    }];
}
/**
 * 加载表头数据
 */
- (void)LoadHeaderData{

    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[NSString stringWithFormat:@"http://vn-functional.chinacloudapp.cn/vx/mobile/blog/%@",_dataModel.ID]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            NSLog(@"%@",responseObject);
             model = [[ManListModel alloc]init];
            [model setValuesForKeysWithDictionary:responseObject];
            HDView.model = model;
            [self setUpTableViewHeadeView:model];
        }
    }];
}
/**
 * 布局表头视图
 */
- (void)setUpTableViewHeadeView:(ManListModel *)dataModel{
    HDView.x = 0;
    HDView.y = 0;
    HDView.width = KscreenWidth;
    
    
    cellView.x = 0;
    cellView.y = CGRectGetMaxY(HDView.frame);
    cellView.width = KscreenWidth;
    cellView.height = 80;
    cellView.dataModel = dataModel;
    
    baseView.height = CGRectGetMaxY(cellView.frame);
    [baseView addSubview:HDView];
    [baseView addSubview:cellView];
    contentLabel.tableHeaderView = baseView;
}
/**
 * 表视图代理方法
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell" forIndexPath:indexPath];
    ManListModel  *dataModel = [[ManListModel alloc]init];
    dataModel = _modelArr[indexPath.row];
    cell.dataModel = dataModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}



@end
