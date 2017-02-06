//
//  NotificationViewController.m
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#import "NotificationViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "VNetworkFramework.h"
#import "ServerURL.h"
#import "MBProgressHUD+GHQ.h"
#import "TableList.h"
#import "NotificationTableViewCell.h"
#import "ScrollViewController.h"
@interface NotificationViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *contentLabel;
    

}

@property (nonatomic, strong) NSMutableArray *modelArr;/** <#注释#> */
@end

@implementation NotificationViewController
- (NSMutableArray *)modelArr{
    if (!_modelArr) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self loadTabData];
}
- (void)loadTabData{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL NotificationURL]];
    
    [framework startRequestToServer:@"POST" parameter:@{@"pageInfo":@{@"pageNumber":@"1",@"pageSize":@"5"}} result:^(id responseObject, NSError *error) {
        if (error) {
            
        }else{
            TableList *model = [[TableList alloc]init];
            [model setValuesForKeysWithDictionary:responseObject];
            self.modelArr = model.content;
            [contentLabel reloadData];
        }
    }];
    

    
}
/**
 *  设置UI
 */
- (void)setUpUI{
    //设置导航条基本信息
    self.title = @"公告";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction) image:@"3 (6)" highImage:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;

    //表视图
    contentLabel = [[UITableView alloc]initWithFrame:self.view.frame];
    contentLabel.contentInset = UIEdgeInsetsMake(64, 0, 64, 0);
    contentLabel.showsVerticalScrollIndicator = NO;
    contentLabel.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentLabel.backgroundColor = RGBACOLOR(249, 246, 245, 1);
    contentLabel.delegate = self;
    contentLabel.dataSource = self;
    [contentLabel registerClass:[NotificationTableViewCell class] forCellReuseIdentifier:@"NotificationTableViewCell"];
    [self.view addSubview:contentLabel];

    
}
/**
 * 表视图代理方法
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell" forIndexPath:indexPath];
    ManListModel *model = [[ManListModel alloc]init];
    model = self.modelArr[indexPath.row];
    cell.dataModel = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ManListModel *model = [[ManListModel alloc]init];
    model = self.modelArr[indexPath.row];

    return [model getHeight];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ManListModel *model = self.modelArr[indexPath.row];
    ScrollViewController *controller = [[ScrollViewController alloc]init];
    controller.dataModel = model;
    [self.navigationController pushViewController:controller animated:YES];
    
}



- (void)buttonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
