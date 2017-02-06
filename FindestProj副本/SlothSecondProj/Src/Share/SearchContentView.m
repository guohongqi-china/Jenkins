//
//  SearchContentView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SearchContentView.h"
#import "HMSegmentedControl.h"
#import "SearchContentViewController.h"
#import "UIViewExt.h"
#import "Utils.h"

@interface SearchContentView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    __weak UIViewController *parentController;
    NSString *strSearchResult;
}

@property(nonatomic,strong)HMSegmentedControl *hmSegmentedControl;
@property(nonatomic,strong)UIScrollView *m_scrollView;
@property(nonatomic)NSInteger nTabIndex;    //0:分享搜索页面,1:用户搜索页面

//来源不同的SessionList
@property(nonatomic,strong)SearchContentViewController *shareSearchViewController;       //分享搜索页面
@property(nonatomic,strong)SearchContentViewController *userSearchViewController;          //用户搜索页面

@end

@implementation SearchContentView

- (instancetype)initWithFrame:(CGRect)frame parent:(UIViewController*)controller
{
    self = [super initWithFrame:frame];
    if (self)
    {
        parentController = controller;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    // Tying up the segmented control to a scroll view
    NSArray *aryTitles = @[@"内容",@"用户"];
    self.hmSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:aryTitles];
    self.hmSegmentedControl.frame = CGRectMake(0, 0, kScreenWidth, 45);
    self.hmSegmentedControl.selectedSegmentIndex = 0;
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        self.hmSegmentedControl.layer.borderColor = COLOR(221, 208, 204, 1.0).CGColor;
        self.hmSegmentedControl.layer.borderWidth = 1;
        self.hmSegmentedControl.layer.masksToBounds = YES;
    }else{
        self.hmSegmentedControl.layer.borderColor = [UIColor clearColor].CGColor;
    }
    [self.hmSegmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString;
        if(selected)
        {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [SkinManage colorNamed:@"Menu_Title_Color"],NSFontAttributeName:[Common fontWithName:@"PingFangSC-Medium" size:16]}];
        }
        else
        {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [SkinManage colorNamed:@"Tab_Item_Color"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
            
        }
        return attString;
    }];
    self.hmSegmentedControl.selectionIndicatorHeight = 2.0f;
    self.hmSegmentedControl.selectionIndicatorColor = COLOR(239, 111, 88, 1.0);
    self.hmSegmentedControl.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.hmSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.hmSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    
    [self.hmSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.hmSegmentedControl];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.hmSegmentedControl.bottom, kScreenWidth, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(221, 208, 204, 1.0);
    [self addSubview:viewLine];
    
    UIView *viewLineV = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth/2, 7, 0.5, 30)];
    viewLineV.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(221, 208, 204, 1.0);
    [self.hmSegmentedControl addSubview:viewLineV];
    
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.hmSegmentedControl.bottom+0.5, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom)];
    self.m_scrollView.backgroundColor = [UIColor whiteColor];
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    self.m_scrollView.contentSize = CGSizeMake(kScreenWidth*5, kScreenHeight-self.hmSegmentedControl.bottom);
    self.m_scrollView.delegate = self;
    self.m_scrollView.scrollsToTop = NO;
    [self.m_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom) animated:NO];
    [self addSubview:self.m_scrollView];
    self.m_scrollView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //分享搜索页面
    self.shareSearchViewController = [[SearchContentViewController alloc]init];
    self.shareSearchViewController.nPageType = 0;
    self.shareSearchViewController.parentController = parentController;
    self.shareSearchViewController.view.frame = CGRectMake(0, 0, kScreenWidth, self.m_scrollView.height);
    self.shareSearchViewController.tableViewData.scrollsToTop = YES;
    [self.m_scrollView addSubview:self.shareSearchViewController.view];
    
    //用户搜索页面
    self.userSearchViewController = [[SearchContentViewController alloc]init];
    self.userSearchViewController.nPageType = 1;
    self.userSearchViewController.parentController = parentController;
    self.userSearchViewController.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.m_scrollView.height);
    self.userSearchViewController.tableViewData.scrollsToTop = NO;
    [self.m_scrollView addSubview:self.userSearchViewController.view];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    //使得 UIScrollView 滚动到置顶区域
    CGRect rect = CGRectMake(kScreenWidth * segmentedControl.selectedSegmentIndex, 0, kScreenWidth, kScreenHeight-self.hmSegmentedControl.bottom);
    [self.m_scrollView scrollRectToVisible:rect animated:YES];
    
    self.shareSearchViewController.tableViewData.scrollsToTop = NO;
    self.userSearchViewController.tableViewData.scrollsToTop = NO;
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        self.shareSearchViewController.tableViewData.scrollsToTop = YES;
        [self.shareSearchViewController refreshData:strSearchResult];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        self.userSearchViewController.tableViewData.scrollsToTop = YES;
        [self.userSearchViewController refreshData:strSearchResult];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)refreshSearchResult:(NSString *)strResult
{
    strSearchResult = strResult;
    
    //选中第一个tab
    [self.hmSegmentedControl setSelectedSegmentIndex:0 animated:YES];
    
    //刷新分享tab
    [self.shareSearchViewController refreshData:strSearchResult];
    
    //清理User的tab
    [self.userSearchViewController clearData];
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
