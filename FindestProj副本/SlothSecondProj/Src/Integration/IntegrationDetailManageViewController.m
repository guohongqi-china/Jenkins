//
//  IntegrationDetailManageViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "IntegrationDetailManageViewController.h"
#import "HMSegmentedControl.h"
#import "IntegrationDetailViewController.h"
#import "UIViewExt.h"
#import "Utils.h"
#import "UserVo.h"

@interface IntegrationDetailManageViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong)HMSegmentedControl *hmSegmentedControl;
@property(nonatomic,strong)UIScrollView *m_scrollView;
@property(nonatomic)NSInteger nTabIndex;    //0:收入积分,1:支出积分,2:版主积分

//来源不同的SessionList
@property(nonatomic,strong)IntegrationDetailViewController *inIntegralViewController;       //收入积分
@property(nonatomic,strong)IntegrationDetailViewController *outIntegralViewController;      //支出积分
@property(nonatomic,strong)IntegrationDetailViewController *moderatorViewController;        //版主积分

@end

@implementation IntegrationDetailManageViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTitle:@"积分明细"];
    
    // Tying up the segmented control to a scroll view
    NSArray *aryTitles;
    UserVo *userVo = [Common getCurrentUserVo];
    if(userVo.nBadge == 1)
    {
        //版主
        aryTitles = @[@"收入积分",@"支出积分",@"版主积分"];
    }
    else
    {
        aryTitles = @[@"收入积分",@"支出积分"];
    }
    
    self.hmSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:aryTitles];
    self.hmSegmentedControl.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        self.hmSegmentedControl.layer.borderColor = COLOR(221, 208, 204, 1.0).CGColor;
        self.hmSegmentedControl.layer.borderWidth = 1;
        self.hmSegmentedControl.layer.masksToBounds = YES;
    }else{
        self.hmSegmentedControl.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    self.hmSegmentedControl.frame = CGRectMake(-1, 0, kScreenWidth+2, 44);
    self.hmSegmentedControl.selectedSegmentIndex = 0;
    [self.hmSegmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString;
        if(selected)
        {
            //            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : COLOR(51, 43, 41, 1.0),NSFontAttributeName:[Common fontWithName:@"PingFangSC-Medium" size:16]}];
            
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [SkinManage colorNamed:@"Menu_Title_Color"],NSFontAttributeName:[Common fontWithName:@"PingFangSC-Medium" size:16]}];
        }
        else
        {
            //            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : COLOR(166, 143, 136, 1.0),NSFontAttributeName:[UIFont systemFontOfSize:16]}];
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [SkinManage colorNamed:@"Tab_Item_Color"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
            
        }
        return attString;
    }];
    self.hmSegmentedControl.selectionIndicatorHeight = 3.0f;
    self.hmSegmentedControl.selectionIndicatorColor = COLOR(239, 111, 88, 1.0);
    self.hmSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.hmSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    
    [self.hmSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.hmSegmentedControl];
    
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.hmSegmentedControl.bottom+0.5, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom)];
    self.m_scrollView.backgroundColor = [UIColor whiteColor];
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    self.m_scrollView.contentSize = CGSizeMake(kScreenWidth*aryTitles.count, kScreenHeight-self.hmSegmentedControl.bottom);
    self.m_scrollView.delegate = self;
    self.m_scrollView.scrollsToTop = NO;
    [self.m_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom) animated:NO];
    [self.view addSubview:self.m_scrollView];
    self.m_scrollView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //收入积分
    self.inIntegralViewController = [[IntegrationDetailViewController alloc]init];
    self.inIntegralViewController.nPageType = 0;
    self.inIntegralViewController.view.frame = CGRectMake(0, 0, kScreenWidth, self.m_scrollView.height);
    self.inIntegralViewController.tableViewData.scrollsToTop = YES;
    [self.m_scrollView addSubview:self.inIntegralViewController.view];
    [self.inIntegralViewController refreshData];
    
    //支出积分
    self.outIntegralViewController = [[IntegrationDetailViewController alloc]init];
    self.outIntegralViewController.nPageType = 1;
    self.outIntegralViewController.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
    self.outIntegralViewController.tableViewData.scrollsToTop = NO;
    [self.m_scrollView addSubview:self.outIntegralViewController.view];
    
    //版主积分
    if(userVo.nBadge == 1)
    {
        self.moderatorViewController = [[IntegrationDetailViewController alloc]init];
        self.moderatorViewController.nPageType = 2;
        self.moderatorViewController.view.frame = CGRectMake(2*kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
        self.moderatorViewController.tableViewData.scrollsToTop = NO;
        [self.m_scrollView addSubview:self.moderatorViewController.view];
    }
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    //使得 UIScrollView 滚动到置顶区域
    CGRect rect = CGRectMake(kScreenWidth * segmentedControl.selectedSegmentIndex, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom);
    [self.m_scrollView scrollRectToVisible:rect animated:YES];
    
    self.inIntegralViewController.tableViewData.scrollsToTop = NO;
    self.outIntegralViewController.tableViewData.scrollsToTop = NO;
    self.moderatorViewController.tableViewData.scrollsToTop = NO;
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        self.inIntegralViewController.tableViewData.scrollsToTop = YES;
        [self.inIntegralViewController refreshData];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        self.outIntegralViewController.tableViewData.scrollsToTop = YES;
        [self.outIntegralViewController refreshData];
    }
    else if (segmentedControl.selectedSegmentIndex == 2)
    {
        self.moderatorViewController.tableViewData.scrollsToTop = YES;
        [self.moderatorViewController refreshData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //设置tab index
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    [self.hmSegmentedControl setSelectedSegmentIndex:page animated:YES];
    [self segmentedControlChangedValue:self.hmSegmentedControl];
}

@end
