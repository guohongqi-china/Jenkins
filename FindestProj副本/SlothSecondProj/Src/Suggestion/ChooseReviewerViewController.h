//
//  ChooseReviewerViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/27/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@class SuggestionDetailViewController;

@interface ChooseReviewerViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchDisplayController *userSearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableViewUserList;

@property (nonatomic, strong) NSString *strSearchText;
@property (nonatomic, strong) NSMutableArray *aryUser;
@property (nonatomic, strong) NSMutableArray *aryUserFilter;    //筛选的数据

@property (nonatomic, weak) SuggestionDetailViewController *suggestionDetailViewController;

@end
 