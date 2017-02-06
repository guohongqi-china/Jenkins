////
////  ChatListViewController.h
////  Sloth
////
////  Created by 焱 孙 on 13-6-18.
////
////
//
//#import <UIKit/UIKit.h>
//#import "QNavigationViewController.h"
//#import "MBProgressHUD.h"
//#import "ChooseUserAndGroupViewController.h"
//
//@class HomeViewController;
//
//@interface ChatListViewController : QNavigationViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,ChooseUserAndGroupDelegate>
//
//@property (nonatomic, retain) UISearchBar *searchBar;
//@property (nonatomic, retain) UISearchDisplayController *chatSearchDisplayController;
//@property (nonatomic, retain) NSString *strSearchText;
//
//@property (nonatomic, strong) UIRefreshControl* refreshControl;
//
//@property (nonatomic, retain) UITableView *tableViewChatObject;
//@property (nonatomic, retain) NSMutableArray *aryObject;            //tableView data
//@property (nonatomic, retain) NSMutableArray *aryFilteredObject;    //筛选的数据
//@property (nonatomic, retain) NSMutableArray *aryOrignData;         //初始数据
//
//@property (nonatomic, retain) NSMutableArray *m_aryChoosedUser;
//@property (nonatomic, retain) NSMutableArray *m_aryChoosedGroup;
//
////进入类别（0:首页tab进入,1:推送进入）
//@property(nonatomic,assign)int nEnterType;
//
//@property(weak,nonatomic)HomeViewController *homeViewController;
//
//@property(nonatomic)NSInteger nSessionStatus;   //会话状态 -1: 未分配 1: 未处理 2: 处理中 3: 已暂停 4: 已结束
//
//- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated; // Implemented by the subclasses
//
//@end
