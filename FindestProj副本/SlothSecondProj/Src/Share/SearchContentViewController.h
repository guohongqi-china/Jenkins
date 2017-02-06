//
//  SearchContentViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchContentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableViewData;
@property (nonatomic, retain) NSMutableArray *aryData;            //tableView data

@property(nonatomic)NSInteger nPageType;//0:分享搜索页面,1:用户搜索页面
@property(weak,nonatomic)UIViewController *parentController;

- (void)refreshData:(NSString *)strText;
- (void)clearData;

@end
