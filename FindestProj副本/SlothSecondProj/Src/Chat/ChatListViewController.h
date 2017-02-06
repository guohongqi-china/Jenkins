//
//  ChatListViewController.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//

#import <UIKit/UIKit.h>
#import "QNavigationViewController.h"
#import "MBProgressHUD.h"

@interface ChatListViewController : QNavigationViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *chatSearchDisplayController;
@property (nonatomic, retain) NSString *strSearchText;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, retain) UITableView *tableViewChat;
@property (nonatomic, retain) NSMutableArray *aryObject;            //tableView data
@property (nonatomic, retain) NSMutableArray *aryFilteredObject;    //筛选的数据
@property (nonatomic, retain) NSMutableArray *aryOrignData;         //初始数据

@property (nonatomic, retain) NSMutableArray *m_aryChoosedUser;
@property (nonatomic, retain) NSMutableArray *m_aryChoosedGroup;

//进入类别（0:首页tab进入,1:推送进入）
@property(nonatomic,assign)int nEnterType;

@property(nonatomic)BOOL bRefreshChatList;  //是否刷新列表

-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo *)groupVo;
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated; // Implemented by the subclasses
//home's tab选中调用刷新列表
-(void)refreshChatListByFlag;

@end
