//
//  MainSearchViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 1/27/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "PullingRefreshTableView.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "NoSearchView.h"

typedef enum _MainSearListType
{
    SearchTicketType,
    SearchFAQType,
    SearchCustomerType
}MainSearListType;

@interface MainSearchViewController : QNavigationViewController<MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>

@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISegmentedControl *segmentedControl;
@property(nonatomic,strong)NoSearchView *noSearchView;

@property(nonatomic,strong)PullingRefreshTableView *tableViewResult;
@property(nonatomic,strong)NSMutableArray *aryData;

@property (nonatomic, strong) NSString *strExpandFAQID;

@property (nonatomic) MainSearListType mainSearListType;
@property (nonatomic) NSInteger nCurrPage;
@property (nonatomic) BOOL refreshing;

@end
