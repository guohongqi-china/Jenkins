//
//  UserListViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "CustomerVo.h"
#import "CustomerDetailViewController.h"
#import "PullingRefreshTableView.h"
#import "NoSearchView.h"

@interface CustomerListViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,PullingRefreshTableViewDelegate>

@property (nonatomic, strong) NSString *strSearchText;

//用户
@property(nonatomic,strong)NoSearchView *noSearchView;
@property (nonatomic, strong) PullingRefreshTableView *tableViewUserList;
@property (nonatomic, strong) NSMutableArray *aryUserList;          //全部用户
@property (nonatomic, strong) NSMutableArray *aryFilteredObject;    //筛选的数据

@property (nonatomic, strong) UISearchDisplayController *userSearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic) NSInteger nCurrPage;
@property (nonatomic) BOOL refreshing;

@end
