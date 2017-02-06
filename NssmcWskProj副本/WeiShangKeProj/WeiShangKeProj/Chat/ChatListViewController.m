////
////  ChatListViewController.m
////  Sloth
////
////  Created by 焱 孙 on 13-6-18.
////
////
//
//#import "ChatListViewController.h"
//#import "ChatContentViewController.h"
//#import "ChatListCell.h"
//#import "UserVo.h"
//#import "ChatObjectVo.h"
//#import "GroupAndUserDao.h"
//#import "VersionControlVo.h"
//#import "ServerProvider.h"
//#import "Utils.h"
//#import "HomeViewController.h"
//#import "KxMenu.h"
//#import "Common.h"
//#import "BusinessCommon.h"
//#import "ChatInfoViewController.h"
//#import "LeftMenuViewController.h"
//#import "ChatCountDao.h"
//
//@interface ChatListViewController ()
//
//@end
//
//@implementation ChatListViewController
//@synthesize searchBar;
//@synthesize strSearchText;
//@synthesize tableViewChatObject;
//@synthesize aryObject;
//@synthesize aryFilteredObject;
//@synthesize chatSearchDisplayController;
//@synthesize aryOrignData;
//
//- (void)dealloc
//{
//    //用于防止返回后bottom tab 的显示
//    if (self.nEnterType == 1)
//    {
//        [AppDelegate getSlothAppDelegate].bRespondsToViewWillAppear = YES;
//    }
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:JPUSH_REFRESH_CHATLIST object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoRefreshChatList" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteChooseAndStartChat" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteCreateDiscussionChat" object:nil];
//}
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    [self setTopNavBarTitle:[Common localStr:@"Chat_Session_Title" value:@"聊天"] andKey:@"Chat_Session_Title"];
//    self.view.backgroundColor = [UIColor whiteColor];
//    
//    UISwipeGestureRecognizer *swipeTap = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeView:)];
//    swipeTap.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:swipeTap];
//    
//    //左边按钮
//    if (self.nEnterType == 0)
//    {
//        //tab setting(tab 进入)
//        UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
//        [btnBack addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
//        [self setLeftBarButton:btnBack andKey:nil];
//        //notice num view
//        NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
//        [self.view addSubview:noticeNumView];
//    }
//    else
//    {
//        //推送进入
//        UIButton *btnBack = [Utils leftButtonWithTitle:[Common localStr:@"Common_Return" value:@" 返回"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doBack)];
//        [self setLeftBarButton:btnBack andKey:@"Common_Return"];
//        //用于防止返回后bottom tab 的显示
//        [AppDelegate getSlothAppDelegate].bRespondsToViewWillAppear = NO;
//    }
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doJPushRefreshChatlist) name:JPUSH_REFRESH_CHATLIST object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefreshChatList:) name:@"DoRefreshChatList" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeChooseAndStartChat) name:@"CompleteChooseAndStartChat" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeChooseAndStartChat) name:@"CompleteCreateDiscussionChat" object:nil];
//    
//    [self initLayout];
//    [self initData];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    if (animated) 
//    {
//        [self.tableViewChatObject flashScrollIndicators];
//    }
//}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    //set appdelegate name
//    [super viewWillAppear:animated];
//    if(self.nEnterType == 0 && [AppDelegate getSlothAppDelegate].bRespondsToViewWillAppear)
//    {
//        [self showBottomTab];
//    }
//    
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
//    
//    if(self.homeViewController.mainTabType == ChatTabType)
//    {
//        [AppDelegate getSlothAppDelegate].currentPageName = ChatListPage;
//    }
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    //set appdelegate name
//    [super viewWillDisappear:animated];
//    if(self.nEnterType == 0 && [AppDelegate getSlothAppDelegate].bRespondsToViewWillAppear)
//    {
//        [self hideBottomWhenPushed];
//    }
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
//    
//    if(self.homeViewController.mainTabType == ChatTabType)
//    {
//        [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
//    }
//}
//
//- (void)initLayout
//{
//    //创建搜索栏
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
//    self.searchBar.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
//    self.searchBar.delegate = self;
//    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
//    [self.view addSubview:searchBar];
//    
//    self.chatSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
//    self.chatSearchDisplayController.searchResultsDataSource = self;
//    self.chatSearchDisplayController.searchResultsDelegate = self;
//    self.chatSearchDisplayController.delegate = self;
//    
//    CGRect rectTableView = CGRectZero;
//    if(self.nEnterType == 0)
//    {
//        //tab setting(tab 进入)
//        rectTableView = CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44);
//    }
//    else
//    {
//        //推送进入
//        rectTableView = CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44);
//    }
//        
//    self.tableViewChatObject = [[UITableView alloc]initWithFrame:rectTableView];
//    self.tableViewChatObject.dataSource = self;
//    self.tableViewChatObject.delegate = self;
//    self.tableViewChatObject.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    self.tableViewChatObject.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.tableViewChatObject];
//    self.tableViewChatObject.contentOffset = CGPointMake(0,0);
//    
//    //添加刷新
//    _refreshControl = [[UIRefreshControl alloc] init];
//    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
//    [self.tableViewChatObject addSubview:_refreshControl];
//    [self.tableViewChatObject sendSubviewToBack:_refreshControl];
//}
//
//- (void)initData
//{
//    self.aryObject = [[NSMutableArray alloc]init];
//    self.aryFilteredObject = [[NSMutableArray alloc]init];
//    self.aryOrignData = [[NSMutableArray alloc]init];
//    
//    self.m_aryChoosedUser = [[NSMutableArray alloc]init];
//    self.m_aryChoosedGroup = [[NSMutableArray alloc]init];
//    
//    if(self.nSessionStatus == 1)
//    {
//        [self setTopNavBarTitle:@"未处理会话"];
//    }
//    else if(self.nSessionStatus == 2)
//    {
//        [self setTopNavBarTitle:@"处理中会话"];
//    }
//    else if(self.nSessionStatus == 3)
//    {
//        [self setTopNavBarTitle:@"已暂停会话"];
//    }
//    else if(self.nSessionStatus == 4)
//    {
//        [self setTopNavBarTitle:@"已处理会话"];
//    }
//    
//    [self isHideActivity:NO];
//    dispatch_async(dispatch_get_global_queue(0,0),^{
//        //do thread work
//        [self updateServerDataAndGetDBData];
//    });
//}
//
//- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
//{
//    [self.tableViewChatObject scrollRectToVisible:self.searchBar.frame animated:animated];
//}
//
//- (BOOL) scrollViewShouldScrollToTop:(UIScrollView*) scrollView
//{
//    return YES;
//}
//
//#pragma mark - UISearchBarDelegate
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    //文字改变
//    self.strSearchText = searchText;
//}
//
//- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
//{
//    //恢复初始状态 （恢复原来数据）
//    self.aryObject = self.aryOrignData;
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    //要进行实时搜索
//    [self doSearch];
//    self.aryObject = self.aryFilteredObject;
//    return YES;
//}
//
//-(void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    
//    // Force your tableview margins (this may be a bad idea)
//    if ([self.tableViewChatObject respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableViewChatObject setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    
//    if ([self.tableViewChatObject respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.tableViewChatObject setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//}
//
//#pragma mark - UITableViewDelegate
//-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [aryObject count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *identifier = @"ChatListCell";
//    ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) 
//    {
//        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
//        //改变选中背景色
//        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
//        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
//        cell.selectedBackgroundView = viewSelected;
//    }
//    
//    ChatObjectVo *chatObjectVo = [aryObject objectAtIndex:[indexPath row]];
//    cell.parentView = self;
//    [cell initWithChatObjectVo:chatObjectVo];
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [ChatListCell calculateCellHeight];
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    //hide key board
//    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//    
//    ChatContentViewController *chatContentViewController = [[ChatContentViewController alloc] init];    
//    chatContentViewController.m_chatObjectVo = [aryObject objectAtIndex:[indexPath row]];
//    [self hideBottomWhenPushed];
//    [self.navigationController pushViewController:chatContentViewController animated:YES];
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}
//
////滑动删除
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        ChatObjectVo *chatObjectVo = [self.aryObject objectAtIndex:indexPath.row];
//        
//        ChatObjectVo *chatObjectVoTemp = [[ChatObjectVo alloc]init];
//        chatObjectVoTemp.nType = chatObjectVo.nType;
//        chatObjectVoTemp.strVestNodeID = chatObjectVo.strVestNodeID;
//        chatObjectVoTemp.strGroupNodeID = chatObjectVo.strGroupNodeID;
//        dispatch_async(dispatch_get_global_queue(0,0),^{
//            //删除会话
//            ServerReturnInfo *serverReturnInfo = [ServerProvider deleteChatSingleSession:chatObjectVoTemp];
//            if (serverReturnInfo.bSuccess)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    //清除 聊天数量为查看数目
//                    if(chatObjectVo.nType == 1)
//                    {
//                        //私聊
//                        NSString *strKey = [NSString stringWithFormat:@"vest_%@",chatObjectVo.strVestID];
//                        [ChatCountDao removeObjectByKey:strKey];
//                    }
//                    else
//                    {
//                        //群聊
//                        NSString *strKey = [NSString stringWithFormat:@"group_%@",chatObjectVo.strGroupNodeID];
//                        [ChatCountDao removeObjectByKey:strKey];
//                        
//                        //清除@标志
//                        NSString *strReplyKey = [NSString stringWithFormat:@"group_reply_%@",chatObjectVo.strGroupNodeID];
//                        [ChatCountDao removeObjectByKey:strReplyKey];
//                    }
//                    //更新主tab下面的聊天数量
//                    [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
//                });
//            }
//        });
//        
//        [self.aryObject removeObject:chatObjectVo];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (void)doSearch
//{
//    //1.Condition Check
//    if (self.strSearchText == nil || self.strSearchText.length<=0)
//    {
//        return;
//    }
//    
//    if(aryOrignData == nil || aryOrignData.count <= 0)
//    {
//        return;
//    }
//        
//    [aryFilteredObject removeAllObjects];
//    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
//    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
//    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
//    
//    for (int i=0; i<aryOrignData.count; i++)
//    {
//        ChatObjectVo *chatObjectVo = (ChatObjectVo *)[aryOrignData objectAtIndex:i];
//         
//        if (chatObjectVo.nType == 1 && [chatObjectVo.strNAME rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
//        {
//            //a1.match user name
//            [aryFilteredName addObject:chatObjectVo];
//        }
//        else if (chatObjectVo.nType == 2 && [chatObjectVo.strGroupName rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
//        {
//            //a1.match group name
//            [aryFilteredName addObject:chatObjectVo];
//        }
//        else if ([chatObjectVo.strJP rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
//        {
//            //b.match JP
//            [aryFilteredJP addObject:chatObjectVo];
//        }
//        else if ([chatObjectVo.strQP rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
//        {
//            //c.match QP
//            [aryFilteredQP addObject:chatObjectVo];
//        }
//    }
//    
//    [aryFilteredObject addObjectsFromArray:aryFilteredName];
//    [aryFilteredObject addObjectsFromArray:aryFilteredJP];
//    [aryFilteredObject addObjectsFromArray:aryFilteredQP];
//}
//
////update server data and get DB data
//- (void)updateServerDataAndGetDBData
//{
//    //历史聊天数据
//    [self getHistoryChatUserAndGroupListTask];
//        
//    //go to main thread work
//    dispatch_async(dispatch_get_main_queue(),^{
//        [self isHideActivity:YES];
//    });
//}
//
//- (void)doJPushRefreshChatlist
//{
//    [AppDelegate getSlothAppDelegate].bChatJPUSH = NO;
//    
//    //refresh
//    dispatch_async(dispatch_get_global_queue(0,0),^{
//        //do thread work
//        [self getHistoryChatUserAndGroupListTask];
//    });
//}
//
////获取会话列表
//-(void)getHistoryChatUserAndGroupListTask
//{
//    //1.get group chat data
//    NSMutableArray *aryChatSessionTemp = [NSMutableArray array];
//    NSMutableArray *aryChatKeys = nil;
//    ServerReturnInfo *retInfoSession = [ServerProvider getHistoryChatSessionList:self.nSessionStatus page:1];
//    if (retInfoSession.bSuccess)
//    {
//        aryChatSessionTemp = (NSMutableArray *)retInfoSession.data;
//        aryChatKeys = (NSMutableArray *)retInfoSession.data2;
//    }
//    
//    //2.show data
//    dispatch_async(dispatch_get_main_queue(),^{
//        if (aryChatSessionTemp != nil && [aryChatSessionTemp count] > 0)
//        {
//            self.aryOrignData = aryChatSessionTemp;
//            self.aryObject = self.aryOrignData;
//            [self.tableViewChatObject reloadData];
//        }
//    });
//    
//    //6.清理无用的缓存推送数量
//    if (aryChatKeys != nil)
//    {
//        [ChatCountDao clearUselessChatNum:aryChatKeys];//clear dictionary
//        //发送推送更新
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
//    }
//}
//
//-(void)doRefreshChatList:(NSNotification*)notification
//{
//    NSMutableDictionary* dicNotify = [notification object];  
//    NSString *strValue = [dicNotify objectForKey:@"RefreshPara"];
//    if ([strValue isEqualToString:@"fromServer"])
//    {
//        //server
//        dispatch_async(dispatch_get_global_queue(0,0),^{
//            //do thread work
//            [self getHistoryChatUserAndGroupListTask];
//        });
//    }
//    else
//    {
//        //local
//        [self.tableViewChatObject reloadData];
//    }
//}
//
//#pragma mark - ChooseUserAndGroupDelegate(完成群组和成员选择)
//-(void)completeChooseUserAndGroupAction:(ChooseUserAndGroupViewController*)chooseController andGroupList:(NSMutableArray*)aryChoosedGroup andUserList:(NSMutableArray*)aryChoosedUser andAllPeople:(BOOL)bChooseAll
//{
//    [self.m_aryChoosedUser removeAllObjects];
//    [self.m_aryChoosedGroup removeAllObjects];
//    
//    [self.m_aryChoosedUser addObjectsFromArray:aryChoosedUser];
//    [self.m_aryChoosedGroup addObjectsFromArray:aryChoosedGroup];
//}
//
////完成选择用户，开始进入聊天
//-(void)completeChooseAndStartChat
//{
//    NSMutableArray *aryChatMember = [NSMutableArray array];
//    if(self.m_aryChoosedUser != nil && self.m_aryChoosedUser.count>0)
//    {
//        //私聊
//        UserVo *userVo = [self.m_aryChoosedUser objectAtIndex:0];
//        
//        ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
//        chatObjectVo.nType = 1;
//        chatObjectVo.strVestID = userVo.strUserID;
//        chatObjectVo.strVestNodeID = userVo.strUserNodeID;
//        chatObjectVo.strNAME = userVo.strUserName;
//        chatObjectVo.strIMGURL = userVo.strHeadImageURL;
//        [aryChatMember addObject:chatObjectVo];
//    }
//    else if (self.m_aryChoosedGroup != nil && self.m_aryChoosedGroup.count>0)
//    {
//        //群聊或者讨论组
//        GroupVo *groupVo = [self.m_aryChoosedGroup objectAtIndex:0];
//        
//        ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
//        chatObjectVo.nType = 2;
//        chatObjectVo.strGroupID = groupVo.strGroupID;
//        chatObjectVo.strGroupNodeID = groupVo.strGroupNodeID;
//        chatObjectVo.strGroupName = groupVo.strGroupName;
//        [aryChatMember addObject:chatObjectVo];
//    }
//    
//    if (aryChatMember.count > 0)
//    {
//        ChatContentViewController *chatContentViewController = [[ChatContentViewController alloc] init];
//        chatContentViewController.m_chatObjectVo = [aryChatMember objectAtIndex:0];
//        [self hideBottomWhenPushed];
//        [self.navigationController pushViewController:chatContentViewController animated:YES];
//       
//        [self.m_aryChoosedUser removeAllObjects];
//        [self.m_aryChoosedGroup removeAllObjects];
//    }
//}
//
//-(void)doBack
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//-(void)hideBottomWhenPushed
//{
//    if(self.homeViewController != nil)
//    {
//        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//        [self.homeViewController hideBottomTabBar:YES];
//    }
//}
//
//-(void)showBottomTab
//{
//    if(self.homeViewController != nil)
//    {
//        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-50);
//        [self.homeViewController hideBottomTabBar:NO];
//    }
//}
//
//- (void)showSideMenu
//{
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
//}
//
//- (void)swipeView:(UISwipeGestureRecognizer*)swipeGesture
//{
//    if (![LeftMenuViewController getLeftMenuState])
//    {
//        [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
//    }
//}
//
//-(void) refreshView:(UIRefreshControl *)refresh
//{
//    dispatch_async(dispatch_get_global_queue(0,0),^{
//        //do thread work
//        [self getHistoryChatUserAndGroupListTask];
//        dispatch_async(dispatch_get_main_queue(),^{
//            [refresh endRefreshing];
//        });
//    });
//}
//
//@end
//