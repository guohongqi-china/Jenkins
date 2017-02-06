//
//  ChatListViewController.m
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//

#import "ChatListViewController.h"
#import "ChatContentViewController.h"
#import "ChatListCell.h"
#import "UserVo.h"
#import "ChatObjectVo.h"
#import "GroupAndUserDao.h"
#import "ServerProvider.h"
#import "Utils.h"
#import "KxMenu.h"
#import "Common.h"
#import "BusinessCommon.h"
#import "ChatInfoViewController.h"
#import "ChatCountDao.h"
#import "UIViewExt.h"
#import "ChooseUserViewController.h"
#import "UIImage+Extras.h"

@interface ChatListViewController ()<ChooseUserViewControllerDelegate>

@end

@implementation ChatListViewController
@synthesize searchBar;
@synthesize strSearchText;
@synthesize tableViewChat;
@synthesize aryObject;
@synthesize aryFilteredObject;
@synthesize chatSearchDisplayController;
@synthesize aryOrignData;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JPUSH_REFRESH_CHATLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoRefreshChatList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteChooseAndStartChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteCreateDiscussionChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateChatUnreadAllNum" object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopNavBarTitle:@"聊天"];
    self.view.backgroundColor = [UIColor whiteColor];
    //右边按钮
    UIButton *btnRight = [Utils buttonWithImage:[SkinManage imageNamed:@"chat_start"] frame:[Utils getNavRightBtnFrame:CGSizeMake(86,66)] target:self action:@selector(righBarClick)];
    [self setRightBarButton:btnRight];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doJPushRefreshChatlist) name:JPUSH_REFRESH_CHATLIST object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefreshChatList:) name:@"DoRefreshChatList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeChooseAndStartChat) name:@"CompleteChooseAndStartChat" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeChooseAndStartChat) name:@"CompleteCreateDiscussionChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatUnreadAllNum:) name:@"UpdateChatUnreadAllNum" object:nil];
    
    [self initLayout];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (animated) 
    {
        [self.tableViewChat flashScrollIndicators];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //set appdelegate name
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
    
    [AppDelegate getSlothAppDelegate].currentPageName = ChatListPage;
    
    //判断是否有推送，则刷新列表
    [self refreshChatListByFlag];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //set appdelegate name
    [super viewWillDisappear:animated];
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
}

- (UIImage*) getImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)initLayout
{
    //创建搜索栏
    self.searchBar = [[UISearchBar alloc]init];
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
//    //设置文本框背景
//    UIImage *imgSearchField = [self getImageWithColor:[SkinManage colorNamed:@"share_search_bg"] andHeight:28];
//    [self.searchBar setSearchFieldBackgroundImage:[imgSearchField roundedWithSize:CGSizeMake(kScreenWidth-16,28)] forState:UIControlStateNormal];
    [self.view addSubview:self.searchBar];
    
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.searchBar.frame.size.height)];
        view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.searchBar insertSubview:view atIndex:1];
    }
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(0);
        make.top.equalTo(self.viewTop.mas_bottom).offset(0);
        make.height.equalTo(44);
    }];
    
    self.chatSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.chatSearchDisplayController.searchResultsDataSource = self;
    self.chatSearchDisplayController.searchResultsDelegate = self;
    self.chatSearchDisplayController.delegate = self;
    self.chatSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatSearchDisplayController.searchResultsTableView.scrollsToTop = NO;
    
    
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.searchBar.height)];
        view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.searchBar insertSubview:view atIndex:1];
    }
    self.chatSearchDisplayController.searchResultsTableView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];;
    
    
    CGRect rectTableView = CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    
    self.tableViewChat = [[UITableView alloc]initWithFrame:rectTableView];
    tableViewChat.dataSource = self;
    tableViewChat.delegate = self;
    self.tableViewChat.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewChat.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableViewChat];
    
    [self.tableViewChat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(0);
        make.top.equalTo(self.searchBar.mas_bottom).offset(0);
    }];
    
    //添加刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor clearColor];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableViewChat addSubview:_refreshControl];
}

- (void)initData
{
    self.aryObject = [[NSMutableArray alloc]init];
    self.aryFilteredObject = [[NSMutableArray alloc]init];
    self.aryOrignData = [[NSMutableArray alloc]init];
    
    self.m_aryChoosedUser = [[NSMutableArray alloc]init];
    self.m_aryChoosedGroup = [[NSMutableArray alloc]init];
    self.bRefreshChatList = NO;
    
    [Common showProgressView:nil view:self.view modal:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        [self updateServerDataAndGetDBData];
    });
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewChat scrollRectToVisible:self.searchBar.frame animated:animated];
}

//发起聊天
-(void)righBarClick
{
    if (self.m_aryChoosedUser != nil)
    {
        [self.m_aryChoosedUser removeAllObjects];
    }
    if (self.m_aryChoosedGroup != nil)
    {
        [self.m_aryChoosedGroup removeAllObjects];
    }
    
    ChooseUserViewController *chooseUserViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChooseUserViewController"];
    chooseUserViewController.delegate = self;
    chooseUserViewController.chooseUserType = ChooseUserCreateChatType;
    [self.navigationController pushViewController:chooseUserViewController animated:YES];
}

//设置刷新的标志位
-(void)updateChatUnreadAllNum:(NSNotification*)notification
{
    NSDictionary *userInfo = (NSDictionary*)[notification object];
    if(userInfo != nil)
    {
        //极光的广播通知
        self.bRefreshChatList = YES;
    }
}

//home's tab选中调用刷新列表
-(void)refreshChatListByFlag
{
    //当有推送发生并且没有刷新数据则刷新列表
    if (self.bRefreshChatList)
    {
        [self doJPushRefreshChatlist];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    self.strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
    self.aryObject = self.aryOrignData;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doSearch];
    self.aryObject = self.aryFilteredObject;
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    //    UIView *viewTemp1 = tableView.superview.superview;//UISearchDisplayControllerContainerView
    //    viewTemp1.backgroundColor = [UIColor clearColor];
    //    viewTemp1.clipsToBounds = YES;
    //    viewTemp1.autoresizesSubviews = NO;
    //    viewTemp1.autoresizingMask = UIViewAutoresizingNone;
    //    viewTemp1.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-(NAV_BAR_HEIGHT+50));
    //    
    //    for (UIView *viewSub in viewTemp1.subviews)
    //    {
    //        viewSub.frame = CGRectMake(0, 0, viewSub.frame.size.width, viewSub.frame.size.height);
    //    }
    //    
    //    UIView *viewTemp0 = tableView.superview;
    //    viewTemp0.frame = CGRectMake(0, 44, viewTemp0.frame.size.width, viewTemp0.frame.size.height);
    //    viewTemp0.clipsToBounds = YES;
    //    viewTemp0.autoresizesSubviews = NO;
    //    viewTemp0.autoresizingMask = UIViewAutoresizingNone;
    //    
    //    tableView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
    //    controller.searchResultsTableView.contentInset = UIEdgeInsetsZero;
    //    tableView.contentInset = UIEdgeInsetsZero;
    //    tableView.backgroundColor = [UIColor redColor];
    //    tableView.contentOffset = CGPointMake(0, 0);
    //    tableView.clipsToBounds = YES;
    //    tableView.autoresizesSubviews = NO;
    //    tableView.autoresizingMask = UIViewAutoresizingNone;
    //    tableView.tableHeaderView = nil;
    
    
    //UIView *viewTemp2 = tableView.superview.superview.superview;//ChatListViewController.view
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [aryObject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ChatListCell";
    ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) 
    {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
        cell.selectedBackgroundView = viewSelected;
    }
    
    ChatObjectVo *chatObjectVo = [aryObject objectAtIndex:[indexPath row]];
    cell.parentView = self;
    [cell initWithChatObjectVo:chatObjectVo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatListCell calculateCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //hide key board
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    ChatContentViewController *chatContentViewController = [[ChatContentViewController alloc] init];    
    chatContentViewController.m_chatObjectVo = [aryObject objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:chatContentViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//滑动删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ChatObjectVo *chatObjectVo = [self.aryObject objectAtIndex:indexPath.row];
        
        //1. 清除该聊天数量
        if(chatObjectVo.nType == 1)
        {
            //私聊
            NSString *strKey = [NSString stringWithFormat:@"vest_%@",chatObjectVo.strVestID];
            [ChatCountDao removeObjectByKey:strKey];
        }
        else
        {
            //群聊
            NSString *strKey = [NSString stringWithFormat:@"group_%@",chatObjectVo.strGroupNodeID];
            [ChatCountDao removeObjectByKey:strKey];
        }
        //更新主tab下面的聊天数量
        [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
        
        
        //2. 删除数据操作
        ChatObjectVo *chatObjectVoTemp = [[ChatObjectVo alloc]init];
        chatObjectVoTemp.nType = chatObjectVo.nType;
        chatObjectVoTemp.strVestNodeID = chatObjectVo.strVestNodeID;
        chatObjectVoTemp.strGroupNodeID = chatObjectVo.strGroupNodeID;
        
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider deleteChatSingleSession:chatObjectVoTemp result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
        }];
        
        [self.aryObject removeObject:chatObjectVo];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(aryOrignData == nil || aryOrignData.count <= 0)
    {
        return;
    }
    
    [aryFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<aryOrignData.count; i++)
    {
        ChatObjectVo *chatObjectVo = (ChatObjectVo *)[aryOrignData objectAtIndex:i];
        
        if (chatObjectVo.nType == 1 && [chatObjectVo.strNAME rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a1.match user name
            [aryFilteredName addObject:chatObjectVo];
        }
        else if (chatObjectVo.nType == 2 && [chatObjectVo.strGroupName rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a1.match group name
            [aryFilteredName addObject:chatObjectVo];
        }
        else if ([chatObjectVo.strJP rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //b.match JP
            [aryFilteredJP addObject:chatObjectVo];
        }
        else if ([chatObjectVo.strQP rangeOfString:strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //c.match QP
            [aryFilteredQP addObject:chatObjectVo];
        }
    }
    
    [aryFilteredObject addObjectsFromArray:aryFilteredName];
    [aryFilteredObject addObjectsFromArray:aryFilteredJP];
    [aryFilteredObject addObjectsFromArray:aryFilteredQP];
}

//update server data and get DB data
- (void)updateServerDataAndGetDBData
{
    //历史聊天数据
    [self getHistoryChatUserAndGroupListTask:nil];
    
    //go to main thread work
    dispatch_async(dispatch_get_main_queue(),^{
        [Common hideProgressView:self.view];
    });
}

- (void)doJPushRefreshChatlist
{
    //refresh
    [self getHistoryChatUserAndGroupListTask:nil];
}

//获取会话列表
-(void)getHistoryChatUserAndGroupListTask:(void(^)())finished
{
    [ServerProvider getHistoryChatSessionList:^(ServerReturnInfo *retInfo) {
        //1.get group chat data
        NSMutableArray *aryChatSessionTemp;
        NSMutableArray *aryChatKeys = nil;
        if (retInfo.bSuccess)
        {
            aryChatSessionTemp = (NSMutableArray *)retInfo.data;
            aryChatKeys = (NSMutableArray *)retInfo.data2;
            self.bRefreshChatList = NO;
        }
        
        //2.show data
        if (aryChatSessionTemp != nil && [aryChatSessionTemp count] > 0)
        {
            self.aryOrignData = aryChatSessionTemp;
            self.aryObject = self.aryOrignData;
            [self.tableViewChat reloadData];
        }
        
        //6.清理无用的缓存推送数量
        if (aryChatKeys != nil)
        {
            [ChatCountDao clearUselessChatNum:aryChatKeys];//clear dictionary
            //发送推送更新
            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
        }
        
        if (finished)
        {
            finished();
        }
    }];
}

-(void)doRefreshChatList:(NSNotification*)notification
{
    NSMutableDictionary* dicNotify = [notification object];  
    NSString *strValue = [dicNotify objectForKey:@"RefreshPara"];
    if ([strValue isEqualToString:@"fromServer"])
    {
        //server
        [self getHistoryChatUserAndGroupListTask:nil];
    }
    else
    {
        //local
        [self.tableViewChat reloadData];
    }
}

#pragma mark - ChooseUserViewControllerDelegate(讨论组和成员选择)
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo *)groupVo
{
    [self.m_aryChoosedUser removeAllObjects];
    [self.m_aryChoosedGroup removeAllObjects];
    
    if (groupVo)
    {
        [self.m_aryChoosedGroup addObject:groupVo];
    }
    else
    {
        [self.m_aryChoosedUser addObjectsFromArray:aryChoosedUser];
    }
}

//完成选择用户，开始进入聊天
-(void)completeChooseAndStartChat
{
    NSMutableArray *aryChatMember = [NSMutableArray array];
    if(self.m_aryChoosedUser != nil && self.m_aryChoosedUser.count>0)
    {
        //私聊
        UserVo *userVo = [self.m_aryChoosedUser objectAtIndex:0];
        
        ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
        chatObjectVo.nType = 1;
        chatObjectVo.strVestID = userVo.strUserID;
        chatObjectVo.strVestNodeID = userVo.strUserNodeID;
        chatObjectVo.strNAME = userVo.strUserName;
        chatObjectVo.strIMGURL = userVo.strHeadImageURL;
        [aryChatMember addObject:chatObjectVo];
    }
    else if (self.m_aryChoosedGroup != nil && self.m_aryChoosedGroup.count>0)
    {
        //群聊或者讨论组
        GroupVo *groupVo = [self.m_aryChoosedGroup objectAtIndex:0];
        
        ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
        chatObjectVo.nType = 2;
        chatObjectVo.strGroupID = groupVo.strGroupID;
        chatObjectVo.strGroupNodeID = groupVo.strGroupNodeID;
        chatObjectVo.strGroupName = groupVo.strGroupName;
        [aryChatMember addObject:chatObjectVo];
    }
    
    if (aryChatMember.count > 0)
    {
        ChatContentViewController *chatContentViewController = [[ChatContentViewController alloc] init];
        chatContentViewController.m_chatObjectVo = [aryChatMember objectAtIndex:0];
        [self.navigationController pushViewController:chatContentViewController animated:YES];
        
        [self.m_aryChoosedUser removeAllObjects];
        [self.m_aryChoosedGroup removeAllObjects];
    }
}

- (void)backForePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    [self getHistoryChatUserAndGroupListTask:^{
        [refresh endRefreshing];
    }];
}

@end
