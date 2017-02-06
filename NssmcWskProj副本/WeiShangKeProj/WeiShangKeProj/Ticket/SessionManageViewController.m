//
//  SessionManageViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 4/30/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SessionManageViewController.h"
#import "UIViewExt.h"
#import "Utils.h"

@interface SessionManageViewController ()

@end

@implementation SessionManageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WS_RECEIVE_MSG object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JPUSH_REFRESH_CHATLIST object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveWebSocketPush:) name:WS_RECEIVE_MSG object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doJPushRefreshChatlist:) name:JPUSH_REFRESH_CHATLIST object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnBack addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnBack];
    
    //notice num view
    NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
    [self.view addSubview:noticeNumView];
    
    if (self.sessionState == SessionUnprocess)
    {
        [self setTopNavBarTitle:@"未处理"];
    }
    else if (self.sessionState == SessionProcessing)
    {
        [self setTopNavBarTitle:@"处理中"];
    }
    else if (self.sessionState == SessionSuspended)
    {
        [self setTopNavBarTitle:@"已暂停"];
    }
    else if (self.sessionState == SessionProcessed)
    {
        [self setTopNavBarTitle:@"已处理"];
    }
    
    // Tying up the segmented control to a scroll view
    NSArray *aryImages = @[[UIImage imageNamed:@"tab_icon_all"], [UIImage imageNamed:@"tab_icon_sina"], [UIImage imageNamed:@"tab_icon_browser"],[UIImage imageNamed:@"tab_icon_weixin"]];
    NSArray *arySelectedImages =@[[UIImage imageNamed:@"tab_icon_all_h"], [UIImage imageNamed:@"tab_icon_sina_h"], [UIImage imageNamed:@"tab_icon_browser_h"],[UIImage imageNamed:@"tab_icon_weixin_h"]];
    self.hmSegmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:aryImages sectionSelectedImages:arySelectedImages];
    self.hmSegmentedControl.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 42);
    self.hmSegmentedControl.selectedSegmentIndex = 0;
    self.hmSegmentedControl.backgroundColor = COLOR(196, 227, 221, 1.0);
    self.hmSegmentedControl.selectionIndicatorHeight = 2.0f;
    self.hmSegmentedControl.selectionIndicatorColor = COLOR(62, 171, 150, 1.0);
    self.hmSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.hmSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    
    [self.hmSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.hmSegmentedControl];
    
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.hmSegmentedControl.bottom, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom)];
    self.m_scrollView.backgroundColor = [UIColor whiteColor];
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    self.m_scrollView.contentSize = CGSizeMake(kScreenWidth*4, kScreenHeight-self.hmSegmentedControl.bottom);
    self.m_scrollView.delegate = self;
    [self.m_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom) animated:NO];
    [self.view addSubview:self.m_scrollView];
    
    UISwipeGestureRecognizer *swipeTap = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeEvent:)];
    swipeTap.direction = UISwipeGestureRecognizerDirectionRight;
    swipeTap.delegate = self;
    [self.m_scrollView addGestureRecognizer:swipeTap];
    
    //所有
    self.sessionListAll = [[SessionListViewController alloc]init];
    self.sessionListAll.sessionState = self.sessionState;
    self.sessionListAll.nSessionFrom = 0;
    self.sessionListAll.homeViewController = self;
    self.sessionListAll.view.frame = CGRectMake(0, 0, kScreenWidth, self.m_scrollView.height);
    [self.m_scrollView addSubview:self.sessionListAll.view];
    
    //新浪
    self.sessionListSina = [[SessionListViewController alloc]init];
    self.sessionListSina.sessionState = self.sessionState;
    self.sessionListSina.nSessionFrom = 2;
    self.sessionListSina.homeViewController = self;
    self.sessionListSina.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
    [self.m_scrollView addSubview:self.sessionListSina.view];
    
    //浏览器(web chat)
    self.sessionListBrowser = [[SessionListViewController alloc]init];
    self.sessionListBrowser.sessionState = self.sessionState;
    self.sessionListBrowser.nSessionFrom = 9;
    self.sessionListBrowser.homeViewController = self;
    self.sessionListBrowser.view.frame = CGRectMake(kScreenWidth*2, 0, kScreenWidth, self.m_scrollView.height);
    [self.m_scrollView addSubview:self.sessionListBrowser.view];
    
    //微信
    self.sessionListWeixin = [[SessionListViewController alloc]init];
    self.sessionListWeixin.sessionState = self.sessionState;
    self.sessionListWeixin.nSessionFrom = 1;
    self.sessionListWeixin.homeViewController = self;
    self.sessionListWeixin.view.frame = CGRectMake(kScreenWidth*3, 0, kScreenWidth, self.m_scrollView.height);
    [self.m_scrollView addSubview:self.sessionListWeixin.view];
    
}

- (void)initData
{
    
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
    [AppDelegate getSlothAppDelegate].currentPageName = SessionListPage;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    //使得 UIScrollView 滚动到置顶区域
    CGRect rect = CGRectMake(kScreenWidth * segmentedControl.selectedSegmentIndex, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom);
    [self.m_scrollView scrollRectToVisible:rect animated:YES];
}

- (void)receiveWebSocketPush:(NSNotification*)notifaction
{
    //...
}

- (void)doJPushRefreshChatlist:(NSNotification*)notifaction
{
    //重新刷新列表数据
    NSDictionary *userInfo = (NSDictionary*)[notifaction object];
    if(userInfo)
    {
        //获取推送类型
        NSInteger nNotifyType = -1;
        id objType = [userInfo valueForKey:@"type"];
        if (objType != nil && objType != [NSNull null])
        {
            nNotifyType = [objType intValue];
        }
        
        if (nNotifyType == 1)
        {
            NSInteger nOrign = 0;
            id orign = [userInfo valueForKey:@"orign"];
            if(orign != nil && orign != [NSNull null])
            {
                nOrign = [orign integerValue];
            }
            
            id talkStatus = [userInfo valueForKey:@"status"];
            if(talkStatus != nil && talkStatus != [NSNull null])
            {
                NSInteger nStatus = [talkStatus integerValue];
                if(self.sessionState == nStatus)
                {
                    //刷新相应的会话列表
                    [self.sessionListAll refreshView];
                    
                    if (nOrign == 2 || nOrign == 7 || nOrign == 8)
                    {
                        [self.sessionListSina refreshView];
                    }
                    else if (nOrign == 9 || nOrign == 11)
                    {
                        [self.sessionListBrowser refreshView];
                    }
                    else if (nOrign == 1)
                    {
                        [self.sessionListWeixin refreshView];
                    }
                }
            }
        }
    }
}

- (void)swipeEvent:(UISwipeGestureRecognizer *)gesture
{
    if (self.hmSegmentedControl.selectedSegmentIndex == 0)
    {
        [self showSideMenu];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //设置tab index
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    [self.hmSegmentedControl setSelectedSegmentIndex:page animated:YES];
    
}

@end
