//
//  TheTableViewForTitle.m
//  FindestProj
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TheTableViewForTitle.h"
#import "UIView+Extension.h"
#import <AFNetworking.h>
#import "TBModel.h"
#import "TitleTableViewCell.h"
#import "cengView.h"
#import "ServerURL.h"
@interface TheTableViewForTitle  ()
{
    cengView *baseView;
}

@property (nonatomic, strong) NSMutableArray *modelArr;/** <#注释#> */

@end
@implementation TheTableViewForTitle
/**
 * model数组懒加载
 */
- (NSMutableArray *)modelArr{
    if (_modelArr == nil) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.dataSource = self;
        [self registerNib:[UINib nibWithNibName:@"TitleTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell1"];
        //设置背景图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height )];
        imageView.image = [UIImage imageNamed:@"popover_background"];
        self.backgroundView = imageView;
        
        self.backgroundColor = [UIColor clearColor];
        //创建表头视图
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
        view.backgroundColor = [UIColor clearColor];
        self.tableHeaderView = view;
        [self loadNewData];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeCemg) name:@"cengViwe" object:nil];
        
        baseView = [[cengView alloc]initWithFrame:CGRectMake(0, 64, KscreenWidth, KscreenHeight - 64)];
        baseView.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)removeCemg{
    [self hidden];
}

- (void)loadNewData{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];

    [manager GET:[ServerURL tableURL] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        TBModel *model = [[TBModel alloc]init];
        [model setValuesForKeysWithDictionary:responseObject];
        Model *to = [[Model alloc]init];
        to.ID = @"0";
        to.tagName = @"全部";
        [model.content insertObject:to atIndex:0];
        self.modelArr = model.content;
        [self reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.height =  self.modelArr.count > 5 ?  225  : self.modelArr.count * 45;

    return self.modelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    //字典转模型
    Model *mo = [[Model alloc]init];
    mo = self.modelArr[indexPath.row];
    cell.nameLabel.text = mo.tagName;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //字典转模型
    Model *mo = [[Model alloc]init];
    mo = self.modelArr[indexPath.row];
    //当我们点击cell时我们要隐藏视图，并且改变smrbutton的状态
    [self hidden];
    if (self.BTdelagate && [self.BTdelagate respondsToSelector:@selector(changeButtonStatus:)]) {
        [self.BTdelagate changeButtonStatus:mo];
    }
    
    //创建通知并传递参数
    NSNotification *notification = [NSNotification notificationWithName:@"loadNewData" object:nil userInfo:@{@"key":mo}];
    [[NSNotificationCenter defaultCenter]postNotification:notification];

}
- (UIWindow *)keyWin{
    _keyWin.hidden = NO;
    if (_keyWin == nil) {
        //将表视图添加到最上层windows上面去
        _keyWin = [UIApplication sharedApplication].windows.lastObject;
        //在这里我们可以设置windows的背景色半透明，而不是设置windows的alpha半透明，alpha半透明会导致加在它上面的视图也半透明
        _keyWin.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];

    }
    return _keyWin;
}
/**
 *  展示viewe
 */
- (void)show{
    self.hidden = NO;
    [self.keyWin addSubview:baseView];
    [self.keyWin addSubview:self];
    self.keyWin.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];


    [UIView animateWithDuration:0.4 animations:^{

        self.height = 225;
    } completion:^(BOOL finished) {
        
    }];
    
}
/**
 *  隐藏view
 */
- (void)hidden{
    [UIView animateWithDuration:0.3 animations:^{
        self.hidden = YES;
        self.height = 0;
        self.keyWin.hidden = YES;
    } completion:^(BOOL finished) {
        [baseView removeFromSuperview];
        self.keyWin.backgroundColor = [UIColor clearColor];
    }];
}


@end
