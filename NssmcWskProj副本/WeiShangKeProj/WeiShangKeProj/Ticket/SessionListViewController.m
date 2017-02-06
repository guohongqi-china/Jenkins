//
//  SessionListViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/17/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SessionListViewController.h"
#import "SessionManageViewController.h"
#import "UIViewExt.h"
#import "SessionListCell.h"
#import "ChatCountDao.h"
#import "MJRefresh.h"
#import "SessionDetailViewController.h"
#import "EXTScope.h"

@interface SessionListViewController ()

@end

@implementation SessionListViewController

- (void)dealloc
{
    //用于防止返回后bottom tab 的显示
    if (self.nEnterType == 1)
    {
        [AppDelegate getSlothAppDelegate].bRespondsToViewWillAppear = YES;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoRefreshChatList" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //左边按钮
    if (self.nEnterType == 0)
    {
        //tab setting(tab 进入)
        //notice num view
        NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
        [self.view addSubview:noticeNumView];
    }
    else
    {
        //用于防止返回后bottom tab 的显示
        [AppDelegate getSlothAppDelegate].bRespondsToViewWillAppear = NO;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefreshChatList:) name:@"DoRefreshChatList" object:nil];
   
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
        [self.tableViewSession flashScrollIndicators];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //set appdelegate name
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //set appdelegate name
    [super viewWillDisappear:animated];
}

- (void)initLayout
{
    self.tableViewSession = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, kScreenHeight-NAV_BAR_HEIGHT-42)];
    self.tableViewSession.dataSource = self;
    self.tableViewSession.delegate = self;
    self.tableViewSession.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewSession.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableViewSession];
    //上拉加载更多
    @weakify(self)
    self.tableViewSession.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self footerRereshing];
    }];
    
    //no search view
    self.noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, self.tableViewSession.top, kScreenWidth, self.tableViewSession.height) andDes:nil];
    
    //添加刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableViewSession addSubview:_refreshControl];
    [self.tableViewSession sendSubviewToBack:_refreshControl];
    
    //旋转等待
    self.imgViewWaiting = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"waiting_bk.png"]];
    self.imgViewWaiting.frame = CGRectMake((kScreenWidth-77)/2,(kScreenHeight-77)/2-100, 77, 77);
    [self.view addSubview:self.imgViewWaiting];
    self.imgViewWaiting.hidden = YES;
    
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activity setCenter:CGPointMake(kScreenWidth/2,(kScreenHeight/2-100))];
    [self.view addSubview:self.activity];
    self.activity.hidden = YES;
}

- (void)initData
{
    self.arySession = [[NSMutableArray alloc]init];
    self.m_curPageNum = 1;
    self.refreshing = YES;
    [self getSessionListByPage];
}

-(void)isHideActivity:(BOOL)bHide
{
    [self.view bringSubviewToFront:self.imgViewWaiting];
    [self.view bringSubviewToFront:self.activity];
    
    self.imgViewWaiting.hidden = bHide;
    [self.activity setHidden:bHide];
    if (bHide)
    {
        [self.activity stopAnimating];
    }
    else
    {
        [self.activity startAnimating];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView*) scrollView
{
    return YES;
}

//comment tableView 上拉加载
- (void)footerRereshing
{
    self.refreshing = NO;
    [self getSessionListByPage];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arySession count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SessionListCell";
    SessionListCell *cell = (SessionListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[SessionListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        cell.selectedBackgroundView = viewSelected;
    }
    
    ChatObjectVo *chatObjectVo = [self.arySession objectAtIndex:[indexPath row]];
    [cell initWithChatObjectVo:chatObjectVo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SessionListCell calculateCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //hide key board
    //[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    SessionDetailViewController *sessionDetailViewController = [[SessionDetailViewController alloc] init];
    sessionDetailViewController.m_chatObjectVo = self.arySession[indexPath.row];
    sessionDetailViewController.refreshSessionBlock = ^(void){[self refreshView];};
    
    [self.homeViewController.navigationController pushViewController:sessionDetailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//获取会话列表
-(void)getSessionListByPage
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        int nTempPage = self.m_curPageNum;
        if (self.refreshing)
        {
            //下拉刷新
            nTempPage = 1;
        }
        else
        {
            //上拖加载
            if (self.arySession.count>0)
            {
                nTempPage ++;
            }
            else
            {
                nTempPage = 1;
            }
        }
        
        ServerReturnInfo *retInfo = [ServerProvider getSessionList:self.sessionState page:nTempPage from:self.nSessionFrom];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *dataArray = retInfo.data;
                if (dataArray != nil)
                {
                    if (self.refreshing)
                    {
                        //下拉刷新
                        [self.arySession removeAllObjects];
                        [self.arySession addObjectsFromArray:dataArray];
                        self.m_curPageNum = 2;
                        [self.refreshControl endRefreshing];
                    }
                    else
                    {
                        //上拖加载
                        [self.arySession addObjectsFromArray:dataArray];
                        self.m_curPageNum ++;
                        [self.tableViewSession.mj_footer endRefreshing];
                    }
                }
                else
                {
                    if (self.refreshing)
                    {
                        [self.refreshControl endRefreshing];
                    }
                    else
                    {
                        [self.tableViewSession.mj_footer endRefreshing];
                    }
                }
                
                [self.tableViewSession reloadData];
                
                if (self.arySession.count == 0)
                {
                    [self.view addSubview:self.noSearchView];
                    [self.view sendSubviewToBack:self.noSearchView];
                }
                else
                {
                    [self.noSearchView removeFromSuperview];
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.refreshing)
                {
                    [self.refreshControl endRefreshing];
                }
                else
                {
                    [self.tableViewSession.mj_footer endRefreshing];
                }
                //[Common tipAlert:retInfo.strErrorMsg];
            });
        }
    });
    
//    //1.get group chat data
//    NSMutableArray *aryChatSessionTemp = [NSMutableArray array];
//    NSMutableArray *aryChatKeys = nil;
//    ServerReturnInfo *retInfoSession = [ServerProvider getSessionList:self.sessionState page:1 from:self.nSessionFrom];
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
//            self.arySession = aryChatSessionTemp;
//            [self.tableViewSession reloadData];
//        }
//        
//        //6.清理无用的缓存推送数量
//        if (aryChatKeys != nil)
//        {
//            [ChatCountDao clearUselessChatNum:aryChatKeys];//clear dictionary
//            //发送推送更新
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
//        }
//    });
}

-(void)doRefreshChatList:(NSNotification*)notification
{
    NSMutableDictionary* dicNotify = [notification object];
    NSString *strValue = [dicNotify objectForKey:@"RefreshPara"];
    if ([strValue isEqualToString:@"fromServer"])
    {
        //server
        [self getSessionListByPage];
    }
    else
    {
        //local
        [self.tableViewSession reloadData];
    }
}

-(void)refreshView
{
    self.m_curPageNum = 1;
    self.refreshing = YES;
    [self getSessionListByPage];
}

@end
