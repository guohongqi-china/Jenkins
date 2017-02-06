//
//  TopRangkingManageViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TopRangkingManageViewController.h"
#import "UIViewExt.h"
#import "Utils.h"

@interface TopRangkingManageViewController ()

@end

@implementation TopRangkingManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self setTitle:@"排行榜"];
    
    // Tying up the segmented control to a scroll view
    NSArray *aryTitles = @[@"热贴榜",@"积分榜",@"人物榜",@"我的排名"];
    self.hmSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:aryTitles];
    self.hmSegmentedControl.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.hmSegmentedControl.frame = CGRectMake(-0.5, 0, kScreenWidth+1, 45);
    self.hmSegmentedControl.selectedSegmentIndex = 0;
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        self.hmSegmentedControl.layer.borderColor = COLOR(221, 208, 204, 1.0).CGColor;
        self.hmSegmentedControl.layer.borderWidth = 0.5;
        self.hmSegmentedControl.layer.masksToBounds = YES;
    }else{
        self.hmSegmentedControl.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    [self.hmSegmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString;
        if(selected)
        {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [SkinManage colorNamed:@"Menu_Title_Color"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        }
        else
        {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [SkinManage colorNamed:@"Tab_Item_Color"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        }
        return attString;
    }];
    self.hmSegmentedControl.selectionIndicatorHeight = 2.5f;
    self.hmSegmentedControl.selectionIndicatorColor = COLOR(239, 111, 88, 1.0);
    self.hmSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.hmSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    
    [self.hmSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.hmSegmentedControl];
    
//    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.hmSegmentedControl.bottom, kScreenWidth, 0.5)];
//    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
//    [self.view addSubview:viewLine];
    
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.hmSegmentedControl.bottom+0.5, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom)];
    self.m_scrollView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    self.m_scrollView.contentSize = CGSizeMake(kScreenWidth*aryTitles.count, kScreenHeight-self.hmSegmentedControl.bottom);
    self.m_scrollView.delegate = self;
    self.m_scrollView.scrollsToTop = NO;
    [self.m_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom) animated:NO];
    [self.view addSubview:self.m_scrollView];
    
    UISwipeGestureRecognizer *swipeTap = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeEvent:)];
    swipeTap.direction = UISwipeGestureRecognizerDirectionRight;
    swipeTap.delegate = self;
    [self.m_scrollView addGestureRecognizer:swipeTap];
    
    //当日热贴榜
    self.topShareViewController = [[TopRankingViewController alloc]init];
    self.topShareViewController.nPageType = 0;
    self.topShareViewController.homeViewController = self;
    self.topShareViewController.view.frame = CGRectMake(0, 0, kScreenWidth, self.m_scrollView.height);
    self.topShareViewController.tableViewData.scrollsToTop = YES;
    [self.m_scrollView addSubview:self.topShareViewController.view];
    [self.topShareViewController refreshData];
    
    //积分排行榜
    self.allIntegralViewController = [[TopRankingViewController alloc]init];
    self.allIntegralViewController.nPageType = 1;
    self.allIntegralViewController.homeViewController = self;
    self.allIntegralViewController.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
    self.allIntegralViewController.tableViewData.scrollsToTop = NO;
    [self.m_scrollView addSubview:self.allIntegralViewController.view];
    
    //风云人物榜
    self.dailyUserViewController = [[TopRankingViewController alloc]init];
    self.dailyUserViewController.nPageType = 2;
    self.dailyUserViewController.homeViewController = self;
    self.dailyUserViewController.view.frame = CGRectMake(2*kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
    self.dailyUserViewController.tableViewData.scrollsToTop = NO;
    [self.m_scrollView addSubview:self.dailyUserViewController.view];
    
    //我的排名
    self.myRankingViewController = [[TopRankingViewController alloc]init];
    self.myRankingViewController.nPageType = 3;
    self.myRankingViewController.homeViewController = self;
    self.myRankingViewController.view.frame = CGRectMake(3*kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
    self.myRankingViewController.tableViewData.scrollsToTop = NO;
    [self.m_scrollView addSubview:self.myRankingViewController.view];
    
//    //公司排名
//    self.companyRankingViewController = [[TopRankingViewController alloc]init];
//    self.companyRankingViewController.nPageType = 4;
//    self.companyRankingViewController.homeViewController = self;
//    self.companyRankingViewController.view.frame = CGRectMake(4*kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
//    self.companyRankingViewController.tableViewData.scrollsToTop = NO;
//    [self.m_scrollView addSubview:self.companyRankingViewController.view];
    
}

- (void)initData
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [AppDelegate getSlothAppDelegate].currentPageName = TopRankingPage;
    
    [MobAnalytics beginLogPageView:@"rankingPage"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
    
    [MobAnalytics endLogPageView:@"rankingPage"];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    //使得 UIScrollView 滚动到置顶区域
    CGRect rect = CGRectMake(kScreenWidth * segmentedControl.selectedSegmentIndex, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom);
    [self.m_scrollView scrollRectToVisible:rect animated:YES];
    
    self.topShareViewController.tableViewData.scrollsToTop = NO;
    self.allIntegralViewController.tableViewData.scrollsToTop = NO;
    self.dailyUserViewController.tableViewData.scrollsToTop = NO;
    self.myRankingViewController.tableViewData.scrollsToTop = NO;
    self.companyRankingViewController.tableViewData.scrollsToTop = NO;
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        self.topShareViewController.tableViewData.scrollsToTop = YES;
        [self.topShareViewController refreshData];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        self.allIntegralViewController.tableViewData.scrollsToTop = YES;
        [self.allIntegralViewController refreshData];
    }
    else if (segmentedControl.selectedSegmentIndex == 2)
    {
        self.dailyUserViewController.tableViewData.scrollsToTop = YES;
        [self.dailyUserViewController refreshData];
    }
    else if (segmentedControl.selectedSegmentIndex == 3)
    {
        self.myRankingViewController.tableViewData.scrollsToTop = YES;
        [self.myRankingViewController refreshData];
    }
    else if (segmentedControl.selectedSegmentIndex == 4)
    {
        self.companyRankingViewController.tableViewData.scrollsToTop = YES;
        [self.companyRankingViewController refreshData];
    }
    
}

- (void)receiveWebSocketPush:(NSNotification*)notifaction
{
    //...
}

- (void)swipeEvent:(UISwipeGestureRecognizer *)gesture
{
    if (self.hmSegmentedControl.selectedSegmentIndex == 0)
    {
        
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
    [self segmentedControlChangedValue:self.hmSegmentedControl];
}

@end
