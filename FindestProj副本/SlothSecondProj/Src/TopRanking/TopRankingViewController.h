//
//  TopRankingViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@class TopRangkingManageViewController;
@interface TopRankingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableViewData;
@property (nonatomic, retain) NSMutableArray *aryData;            //tableView data

@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property(nonatomic)NSInteger nPageType;//0:当日热贴榜,1:积分排行榜,2:风云人物榜,3:我的排名,4:公司排名
@property(weak,nonatomic)TopRangkingManageViewController *homeViewController;

@property (nonatomic, strong) UIActivityIndicatorView * activity;
@property (nonatomic, strong) UIImageView *imgViewWaiting;

- (void)refreshData;
@end
