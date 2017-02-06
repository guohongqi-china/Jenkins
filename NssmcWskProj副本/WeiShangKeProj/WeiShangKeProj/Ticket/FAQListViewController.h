//
//  FAQListViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/20/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "FAQVo.h"
#import "PullingRefreshTableView.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "NoSearchView.h"

@class SessionDetailViewController;
//定义发送数据后的block
typedef void(^SendMessageResultBlock)(BOOL bRes);

@interface FAQListViewController : QNavigationViewController<MGSwipeTableCellDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,PullingRefreshTableViewDelegate>

@property (nonatomic, strong) NSString *strSearchText;

@property(nonatomic,strong)NoSearchView *noSearchView;
@property (nonatomic, strong) PullingRefreshTableView *tableViewFAQList;
@property (nonatomic, strong) NSMutableArray *aryFAQList;          //全部FAQ
@property (nonatomic, strong) NSString *strExpandFAQID;             //全部展开的FAQID
@property (nonatomic, strong) NSMutableArray *aryFilteredObject;    //筛选的数据
@property (nonatomic, strong) NSString *strSearchExpandFAQID;       //当前搜索展开的FAQID

@property (nonatomic, strong) UISearchDisplayController *faqSearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, weak) SessionDetailViewController *sessionDetailViewController;

@property (nonatomic) NSInteger nCurrPage;
@property (nonatomic) BOOL refreshing;

@end
