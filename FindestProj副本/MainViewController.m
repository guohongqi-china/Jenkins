//
//  MainViewController.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MainViewController.h"
#import "MJRefresh.h"
#import <AFNetworking.h>
#import "TableList.h"
#import "VNetworkFramework.h"
#import "TheTableViewForTitle.h"
#import "Model.h"
#import "HomeTableViewCell.h"
#import "MainViewTableViewCell.h"
#import "MainDetailViewController.h"
#import "ShareHomeViewController.h"

@interface MainViewController ()<TheTableViewForTitleDelegate,HomeTableViewCellDelegate>
{
    NSString *strID;
    NSInteger currentPage;
}

@property (nonatomic, strong) NSMutableDictionary *modelArr;/** <#注释#> */

@property (nonatomic, strong) NSMutableDictionary *modeDic;/** <#注释#> */
@end

@implementation MainViewController
- (NSMutableDictionary *)modelArr{
    if (!_modelArr) {
        _modelArr = [NSMutableDictionary dictionary];
    }
    return _modelArr;
}
- (NSMutableDictionary *)modeDic{
    if (!_modeDic) {
        _modeDic = [NSMutableDictionary dictionary];
    }
    return _modeDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
       
}

- (void)viewWillAppear:(BOOL)animated{
    //SMR代理方法
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(NTAction:) name:@"loadNewData" object:nil];
    _dataTP = DataTypeAll;
}
/**
 *  初始化视图
 */
- (void)setUpUI{
    strID = @"0";
    self.tableViewShare = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableViewShare.dataSource = self;
    self.tableViewShare.delegate = self;
    self.tableViewShare.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewShare.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewShare];
    [self.view addSubview:self.tableViewShare];
    [self.tableViewShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, NAV_BAR_HEIGHT+42, 0));//+49

    }];
    [self.tableViewShare registerClass:[HomeTableViewCell class] forCellReuseIdentifier:@"HomeTableViewCell"];
//    [self.tableViewShare registerNib:[UINib nibWithNibName:@"MainViewTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MainViewTableViewCell"];
    
    //下拉刷新
    @weakify(self)
    self.tableViewShare.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES modelId:strID];
        _Type = LoadDataNoFirstType;

    }];
    [self.tableViewShare.mj_header beginRefreshing];
    
    //上拉加载更多
    self.tableViewShare.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO modelId:strID];
        _Type = LoadDataNoFirstType;

    }];

   
    
}
/**
 *  数据管理
 */

- (void)loadNewData:(BOOL)isHe modelId:(NSString *)modelId{
    
    if (_Type == LoadDataFirstType && [self.modelArr.allKeys containsObject:modelId]) {
        //如果我们的数据已经储存就不会再发送网络请求
        [self endRefreshing];
        [self.tableViewShare reloadData];
        return;
    }
    if (isHe) {
        currentPage +=1;
    }else{
        currentPage = 1;
    }
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    [bodyDic setObject:@"0" forKey:@"endBlogId"];
    [bodyDic setObject:@{@"pageNumber":@(currentPage),@"pageSize":@"10"} forKey:@"pageInfo"];
    if (_dataTP != DataTypeAll) {
        [bodyDic setObject:@[modelId] forKey:@"tagIdList"];
    }

    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //申明请求的数据格式（json格式）
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
        //申明请求的数据格式（json格式）
    //    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    [manager POST:@"http://vn-functional.chinacloudapp.cn/vx//mobile/blog/fuzzyBlogs" parameters:bodyDic progress:^(NSProgress * _Nonnull uploadProgress) {
    
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        //结束刷新
        [self endRefreshing];
        TableList *mo = [[TableList alloc]init];
        [mo setValuesForKeysWithDictionary:responseObject];
        //如果刷新没有数据直接退出方法
        if (mo.content.count == 0) {
            if (_Type == LoadDataFirstType) {
                //如果是我们点击smr按钮刷新数据时，得到的m.content为nil，此时我们就应该刷新数据
                [self.tableViewShare reloadData];
            }
            //当下拉刷新或者上拉加载刷新的数据为空时，结束执行以下方法
            return;
        }
        // 将最新的微博数据，添加到总数组的最前面
        NSRange range = NSMakeRange(0, mo.content.count);
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
        if (isHe) {
            //判断当前ID是否已经存在
            if ([self.modelArr.allKeys containsObject:modelId]) {
                NSMutableArray *arr = self.modelArr[modelId];
                [arr insertObjects:[mo.content copy ] atIndexes:set];
                [self.modelArr setObject:arr forKey:modelId];
            }else{
                NSMutableArray *arr = [NSMutableArray array];
                [arr insertObjects:[mo.content copy ] atIndexes:set];
                [self.modelArr setObject:arr forKey:modelId];
            }
    
        }else{
            if ([self.modelArr.allKeys containsObject:modelId]) {
                [self.modelArr removeObjectForKey:modelId];
                NSMutableArray *arr = [NSMutableArray array];
                [arr insertObjects:[mo.content copy ] atIndexes:set];
                [self.modelArr setObject:arr forKey:modelId];
            }else{
    
            }
        }
        [self.tableViewShare reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [self endRefreshing];
    }];

    
    
       
}
/**
 *  结束刷新
 */

- (void)endRefreshing{
    [self.tableViewShare.mj_footer endRefreshing];
    [self.tableViewShare.mj_header endRefreshing];
}

/**
 *  内存警告
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma ===================表视图代理方法=============================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *arr = self.modelArr[strID];
    return arr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ManListModel *model = [[ManListModel alloc]init];
    model = self.modelArr[strID][indexPath.row];
    CGFloat he;
    if (self.modeDic[model.ID]) {
        return [self.modeDic[model.ID] floatValue];
    }else{
         he = [model returenCellHeight];
         NSLog(@"%f",he);
        [self.modeDic setObject:@(he) forKey:model.ID];
    }
    return he;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell" forIndexPath:indexPath];
    ManListModel *model = [[ManListModel alloc]init];
    model = self.modelArr[strID][indexPath.row];
    cell.delegate = self;
    cell.dataModel = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MainDetailViewController *shareController = [[MainDetailViewController alloc]init];
    ManListModel *model = [[ManListModel alloc]init];
    model = self.modelArr[strID][indexPath.row];
    shareController.dataModel = model;
    [self.shareHomeViewController hideBottomWhenPushed];
    [self.shareHomeViewController.navigationController pushViewController:shareController animated:YES];

}
//MessageViewController
- (void)homeTableViewCellPraiseButton:(NSString *)ID{
    currentPage -= 1;
    [self loadNewData:YES modelId:strID];
    NSInteger index;
    for (ManListModel *mo in self.modeDic[strID]) {
        if ([mo.ID isEqualToString:ID]) {
          index = [self.modeDic[strID] indexOfObject:mo];

        }
    }
    [self.tableViewShare reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:(UITableViewRowAnimationMiddle)];
}
#pragma ===================标题视图代理方法=============================
- (void)NTAction:(NSNotification *)textCation{
    _Type = LoadDataFirstType;\
    currentPage = 0;
    Model *mod = textCation.userInfo[@"key"];
    strID = mod.ID;
    _dataTP =  [mod.tagName isEqualToString:@"全部"] ? DataTypeAll : DataTypeone;
    [self loadNewData:YES modelId:strID];
}

@end
