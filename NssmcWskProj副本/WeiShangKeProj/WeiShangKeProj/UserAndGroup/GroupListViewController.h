//
//  GroupListViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-13.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "GroupVo.h"

@interface GroupListViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic) GroupListType m_groupListType;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSString *strSearchText;
@property (nonatomic, strong) NSMutableArray *aryDBData;
@property (nonatomic, retain) NSMutableArray *aryObject;            //tableView data
@property (nonatomic, strong) NSMutableArray *aryFilteredObject;    //筛选的数据

@property (nonatomic, strong) UISearchDisplayController *groupSearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableViewGroupList;

@end
