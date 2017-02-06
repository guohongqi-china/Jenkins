//
//  MainEmailListViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-12.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "PullingRefreshTableView.h"
#import "MessageVo.h"

@class HomeViewController;

typedef NS_ENUM(NSInteger, MainMessageType)
{
    MainMessageTypeWorkOrder,       //工单类型
    MainMessageTypeAll              //所有消息
};

@interface MainMessageListViewController : QNavigationViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate,UIScrollViewDelegate>

@property (nonatomic) MainMessageType mainMessageType;

@property (nonatomic,strong) UIButton *btnNavRight;

@property (nonatomic,strong) NSArray *menuItems;
@property (nonatomic,strong) NSArray *menuFilterItems;//消息过滤 筛选
@property (nonatomic,strong) NSString *strSearchText;
@property (nonatomic,strong) NSMutableArray *aryMessageList;            //tableView data
@property (nonatomic,strong) NSMutableArray *aryFilteredObject;         //筛选的数据
@property (nonatomic) BOOL refreshing;
@property (nonatomic) int m_curPageNum;
@property (nonatomic) MessageListType m_messageListType;
@property (nonatomic,strong) NSString *m_messageFilterType;

@property (nonatomic,weak) HomeViewController *homeViewController;

@property (nonatomic,strong) UISearchDisplayController *userSearchDisplayController;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) PullingRefreshTableView *tableViewMsgList;

-(void)refreshMsgListAfterDel:(MessageVo*)messageVo;

@end
