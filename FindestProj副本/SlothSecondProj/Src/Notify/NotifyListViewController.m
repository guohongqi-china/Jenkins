//
//  NotifyListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "NotifyListViewController.h"
#import "NotifyVo.h"
#import "MJRefresh.h"
#import "NotifyService.h"
#import "NotifyListCell.h"
#import "ExtScope.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ShareDetailViewController.h"
#import "SuggestionDetailViewController.h"
#import "MessageDetailViewController.h"
#import "UserProfileViewController.h"
#import "IntegrationDetailManageViewController.h"
#import "MyLotteryViewController.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "NoSearchView.h"

@interface NotifyListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *aryNotify;
    NSInteger nPage;
    UIBarButtonItem *btnNavRight;
    
    BOOL bRefreshWhenBack;
    
    NoSearchView *noSearchView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotify;

@end

@implementation NotifyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (bRefreshWhenBack)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshNotifyTypeList" object:nil];
    }
}

- (void)initView
{
    if (self.nNotifyMainType == 11)
    {
        self.title = @"通知";
    }
    else if (self.nNotifyMainType == 12)
    {
        self.title = @"评论";
    }
    else if (self.nNotifyMainType == 14)
    {
        self.title = @"打赏";
    }
    
    noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:[NSString stringWithFormat:@"还没有收到%@",self.title]];
    
    btnNavRight = [self rightBtnItemWithTitle:@"编辑"];
    self.navigationItem.rightBarButtonItem = btnNavRight;
    
    UIView *tableFooterView = [UIView new];
    tableFooterView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewNotify.tableFooterView = tableFooterView;
    self.tableViewNotify.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewNotify.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //下拉刷新
    @weakify(self)
    self.tableViewNotify.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    self.tableViewNotify.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    aryNotify = [NSMutableArray array];
    bRefreshWhenBack = NO;
    nPage = 1;
    
    //初始化数据
    [self loadNewData:YES];
}

- (void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    
    [NotifyService getNotifyListByType:self.nNotifyMainType page:nPage result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryTempData != nil && aryTempData.count>0)
                {
                    [aryNotify removeAllObjects];
                    [aryNotify addObjectsFromArray:aryTempData];
                }
            }
            else
            {
                //上拖加载
                [aryNotify addObjectsFromArray:aryTempData];
            }
            
            if (aryTempData != nil && aryTempData.count>0)
            {
                nPage ++;
            }
            
            if (aryNotify.count == 0)
            {
                [self.view addSubview:noSearchView];
            }
            else
            {
                [noSearchView removeFromSuperview];
            }
            [self.tableViewNotify reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.tableViewNotify.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.tableViewNotify.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.tableViewNotify.mj_footer endRefreshing];
        }
    }];
}

- (void)righBarClick
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"全部已读",@"全部删除",nil];
    actionSheet.destructiveButtonIndex = 1;
    [actionSheet showInView:self.view];
}

//设置某一条消息为已读或未读,type:[0:设为已读，1:设为未读]
- (void)setSingleNoticeToReadOrNot:(NotifyVo*)notifyVo type:(NSInteger)nType
{
    [Common showProgressView:nil view:self.view modal:NO];
    [NotifyService setNoticeToReadOrNot:notifyVo.strID type:nType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            notifyVo.nReadState = nType;
            [self.tableViewNotify reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
    
    bRefreshWhenBack = YES;
}

//删除单个提醒
- (void)deleteSingleNotice:(NotifyVo*)notifyVo
{
    [Common showProgressView:nil view:self.view modal:NO];
    [NotifyService deleteNoticeByID:notifyVo.strID result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryNotify removeObject:notifyVo];
            [self.tableViewNotify reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
    
    bRefreshWhenBack = YES;
}

- (void)configureCell:(NotifyListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    cell.nNotifyMainType = self.nNotifyMainType;
    [cell setEntity:aryNotify[indexPath.row]];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //全部已读
        [Common showProgressView:nil view:self.view modal:NO];
        [NotifyService setNoticeToReadByType:self.nNotifyMainType result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                for (NotifyVo *notifyVo in aryNotify)
                {
                    notifyVo.nReadState = 0;
                }
                [self.tableViewNotify reloadData];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
        
        bRefreshWhenBack = YES;
    }
    else if (buttonIndex == 1)
    {
        //全部删除
        [Common showProgressView:nil view:self.view modal:NO];
        [NotifyService deleteNoticeByType:self.nNotifyMainType result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [aryNotify removeAllObjects];
                [self.tableViewNotify reloadData];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
        
        bRefreshWhenBack = YES;
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryNotify.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotifyListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyListCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    NotifyVo *notifyVo = aryNotify[indexPath.row];
    
    NSString *strRead;
    if (notifyVo.nReadState == 0)
    {
        strRead = @"标记未读";
    }
    else
    {
        strRead = @"标记已读";
    }
    
    if(iOSPlatform < 8)
    {
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:COLOR(255, 59, 48, 1.0)],
                              [MGSwipeButton buttonWithTitle:strRead backgroundColor:COLOR(199, 199, 204, 1.0)]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"NotifyListCell" cacheByIndexPath:indexPath configuration:^(NotifyListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotifyVo *notifyVo = aryNotify[indexPath.row];
    if (notifyVo.notifySubType == NOTIFY_SUB_COMMENT_SHARE || notifyVo.notifySubType == NOTIFY_SUB_COMMENT_COMMENT ||
        notifyVo.notifySubType == NOTIFY_SUB_AT_SHARE || notifyVo.notifySubType == NOTIFY_SUB_AT_COMMENT ||
        notifyVo.notifySubType == NOTIFY_SUB_PRAISE_SHARE )
    {
        //跳转到分享
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc]init];
        BlogVo *blogVo = [[BlogVo alloc]init];
        blogVo.streamId = notifyVo.strRefID;
        shareDetailViewController.m_originalBlogVo = blogVo;
        
        //评论相关操作跳转到指定评论
        if (notifyVo.notifySubType == NOTIFY_SUB_COMMENT_SHARE || notifyVo.notifySubType == NOTIFY_SUB_COMMENT_COMMENT)
        {
            shareDetailViewController.strNotifyCommentID = notifyVo.strTitleID;
        }
        
        [self.navigationController pushViewController:shareDetailViewController animated:YES];
    }
    else if (notifyVo.notifySubType == NOTIFY_SUB_ANSWER ||
             notifyVo.notifySubType == NOTIFY_SUB_FINISHED_QUESTION ||
             notifyVo.notifySubType == NOTIFY_SUB_ADD_ANSWER ||
             notifyVo.notifySubType == NOTIFY_SUB_PRAISE_QUESTION ||
             notifyVo.notifySubType == NOTIFY_SUB_PRAISE_ANSWER ||
             notifyVo.notifySubType == NOTIFY_SUB_INVITE_ANSWER_QUESTION)
    {
        //跳转到问答详情
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
        BlogVo *blogVo = [[BlogVo alloc]init];
        blogVo.streamId = notifyVo.strRefID;
        blogVo.strBlogType = @"qa";
        shareDetailViewController.m_originalBlogVo = blogVo;
        [self.navigationController pushViewController:shareDetailViewController animated:YES];
    }
    else if (notifyVo.notifySubType == NOTIFY_SUB_ACTIVITY_ATTENTION)
    {
        //跳转到合理化建议
        SuggestionVo *suggestionVo = [[SuggestionVo alloc]init];
        suggestionVo.strID = notifyVo.strRefID;
        
        SuggestionDetailViewController *suggestionDetailViewController = [[SuggestionDetailViewController alloc]init];
        suggestionDetailViewController.suggestionBaseVo = nil;
        suggestionDetailViewController.m_suggestionVo = suggestionVo;
        [self.navigationController pushViewController:suggestionDetailViewController animated:YES];
    }
    else if (notifyVo.notifySubType == NOTIFY_SUB_ATTENTION_ME)
    {
        //别人关注我
        UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
        userProfileViewController.strUserID = notifyVo.strRefID;
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
    else if (notifyVo.notifySubType == NOTIFY_SUB_MODERATOR_INTEGRAL)
    {
        //版主对用户增减积分提醒
        IntegrationDetailManageViewController *integrationDetailManageViewController = [[IntegrationDetailManageViewController alloc]init];
        [self.navigationController pushViewController:integrationDetailManageViewController animated:YES];
    }
    else if (notifyVo.notifyMainType == NOTIFY_FOOTBALL_WIN)
    {
        //足球竞猜中奖
        MyLotteryViewController *myLotteryViewController = [[UIStoryboard storyboardWithName:@"FootballModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyLotteryViewController"];
        [self.navigationController pushViewController:myLotteryViewController animated:YES];
    }
    
    //update state
    if (notifyVo.nReadState == 1)
    {
        notifyVo.nReadState = 0;
        [self.tableViewNotify reloadData];
        
        //设置某条消息为已读
        [self setSingleNoticeToReadOrNot:notifyVo type:0];
    }
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(NotifyListCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft && index == 1)
    {
        //删除
        [self deleteSingleNotice:cell.notifyVo];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 0)
    {
        //标记未读/已读
        [self setSingleNoticeToReadOrNot:cell.notifyVo type:(cell.notifyVo.nReadState==0?1:0)];
    }
    
    return YES;
}

//iOS Version >= 8.0采用系统方式
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotifyVo *notifyVo = aryNotify[indexPath.row];
    
    @weakify(notifyVo)
    UITableViewRowAction *rowAction1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        @strongify(notifyVo)
        [self deleteSingleNotice:notifyVo];
    }];
    rowAction1.backgroundColor = COLOR(255, 59, 48, 1.0);
    
    NSString *strRead;
    if (notifyVo.nReadState == 0)
    {
        strRead = @"标记未读";
    }
    else
    {
        strRead = @"标记已读";
    }
    
    UITableViewRowAction *rowAction2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:strRead handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        @strongify(notifyVo)
        [self setSingleNoticeToReadOrNot:notifyVo type:(notifyVo.nReadState==0?1:0)];
    }];
    rowAction2.backgroundColor = COLOR(199, 199, 204, 1.0);
    
    return @[rowAction1,rowAction2];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // you need to implement this method too or nothing will work:
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; //tableview must be editable or nothing will work...
}

@end
