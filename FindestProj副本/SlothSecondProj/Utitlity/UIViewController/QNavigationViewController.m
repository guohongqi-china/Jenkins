//
//  QuickNavBarViewController.m
//  Sloth
//
//  Created by Ann Yao on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QNavigationViewController.h"
#import "Common.h"
#import "Utils.h"
#import "UIViewExt.h"

@interface QNavigationViewController ()

@end

@implementation QNavigationViewController
@synthesize imgViewTopBar;
@synthesize rootViewController;
@synthesize lblTitle;
@synthesize btnBack;
@synthesize viewTop;
@synthesize scrollViewTitle;
@synthesize arrowImageView;

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    viewTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, NAV_BAR_HEIGHT)];
    viewTop.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewTop];
    
    //create top nav imageview
    imgViewTopBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, NAV_BAR_HEIGHT)];
    imgViewTopBar.image = [Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]];
    [self.viewTop addSubview:imgViewTopBar];
    
    self.scrollViewTitle = [[UIScrollView alloc]initWithFrame:CGRectMake(60, kStatusBarHeight, kScreenWidth-120, NAV_BAR_HEIGHT-kStatusBarHeight)];
    self.scrollViewTitle.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollViewTitle.scrollEnabled = YES;
    self.scrollViewTitle.pagingEnabled = NO;
    self.scrollViewTitle.scrollsToTop = NO;
    self.scrollViewTitle.showsHorizontalScrollIndicator = NO;
    [self.scrollViewTitle setBackgroundColor:[UIColor clearColor]];
    [self.scrollViewTitle setContentSize:CGSizeMake(200, NAV_BAR_HEIGHT-kStatusBarHeight)];
    [self.viewTop addSubview:scrollViewTitle];
    
    //top nav title
    lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,kStatusBarHeight, kScreenWidth-120, NAV_BAR_HEIGHT-kStatusBarHeight)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont boldSystemFontOfSize:17];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [self.scrollViewTitle addSubview:lblTitle];
    
    //创建箭头图标
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_white_down"]];
    self.arrowImageView.hidden = YES;
    [self.scrollViewTitle addSubview:arrowImageView];
    
    //旋转等待
    self.imgViewWaiting = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"waiting_bk.png"]];
    self.imgViewWaiting.frame = CGRectMake((kScreenWidth-77)/2,(kScreenHeight-77)/2-100, 77, 77);
    [self.view addSubview:self.imgViewWaiting];
    self.imgViewWaiting.hidden = YES;
    
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activity setCenter:CGPointMake(kScreenWidth/2,(kScreenHeight/2-100))];
    [self.view addSubview:self.activity];
    self.activity.hidden = YES;
    
    //set left nav button
    [self setBackBarButton];
    
    if (rootViewController != nil) 
    {
        rootViewController.view.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
        [self.view addSubview:rootViewController.view];
    }

    //        UIScreenEdgePanGestureRecognizer *left2rightSwipe = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    //        [left2rightSwipe setDelegate:self];
    //        [left2rightSwipe setEdges:UIRectEdgeLeft];
    //        [self.view addGestureRecognizer:left2rightSwipe];
}

#pragma mark - ButtonListener
//设置NavBar左侧按钮
- (void)setLeftBarButton:(UIButton*)btnLeftNav
{
    [btnBack removeFromSuperview];
    self.btnBack = btnLeftNav;
    [self.viewTop addSubview:btnBack];
}

//设置NavBar右侧按钮
- (void)setRightBarButton:(UIButton*)btnRightNav
{
    [self.btnRightNav removeFromSuperview];
    self.btnRightNav = btnRightNav;
    [self.viewTop addSubview:self.btnRightNav];
}

//默认NavBar左侧为返回上一级
- (void)setBackBarButton
{
    self.btnBack = [Utils leftButtonWithTitle:nil frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(backButtonClicked)];
    [self.viewTop addSubview:btnBack];
}

//返回上一层
- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

//设置NavBar的标题
- (void)setTopNavBarTitle:(NSString *)title
{
    NSString *strTitle = title;
    CGSize sizeLabel = [Common getStringSize:strTitle font:lblTitle.font bound:CGSizeMake(CGFLOAT_MAX, NAV_BAR_HEIGHT-kStatusBarHeight) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeLabel.width<self.scrollViewTitle.width)
    {
        lblTitle.frame = CGRectMake((self.scrollViewTitle.width-sizeLabel.width)/2,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
    }
    else
    {
        lblTitle.frame = CGRectMake(0,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
    }
    lblTitle.textColor = [SkinManage colorNamed:@"Nav_Bar_Title_Color"];
    scrollViewTitle.contentSize = sizeLabel;
    self.lblTitle.text = title;
    
    self.arrowImageView.hidden = YES;
    
    //自动滚动标题
    if(scrollViewTitle.frame.size.width<scrollViewTitle.contentSize.width)
    {
        CGPoint newOffset = self.scrollViewTitle.contentOffset;
        newOffset.x = (scrollViewTitle.contentSize.width-scrollViewTitle.frame.size.width);
        NSTimeInterval time = newOffset.x/35;
        
        [UIView animateWithDuration:time delay:0.3 options: UIViewAnimationOptionCurveEaseOut  
                         animations:^{   
                             [self.scrollViewTitle setContentOffset:newOffset animated:NO];
                         } completion:^(BOOL finished){}];  
    }
}

- (void)setTopNavBarTitleWithArrow:(NSString *)title
{
    NSString *strTitle = title;
    CGSize sizeLabel = [Common getStringSize:strTitle font:lblTitle.font bound:CGSizeMake(CGFLOAT_MAX, NAV_BAR_HEIGHT-kStatusBarHeight) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeLabel.width<self.scrollViewTitle.width)
    {
        lblTitle.frame = CGRectMake((self.scrollViewTitle.width-sizeLabel.width)/2,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
    }
    else
    {
        lblTitle.frame = CGRectMake(0,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
    }
    scrollViewTitle.contentSize = sizeLabel;
    self.lblTitle.text = title;
    arrowImageView.hidden = NO;
    arrowImageView.frame = CGRectMake(lblTitle.frame.origin.x + lblTitle.frame.size.width + 4, 18, 15, 8.5);
    
    //自动滚动标题
    if(scrollViewTitle.frame.size.width<scrollViewTitle.contentSize.width)
    {
        CGPoint newOffset = self.scrollViewTitle.contentOffset;
        newOffset.x = (scrollViewTitle.contentSize.width-scrollViewTitle.frame.size.width);
        NSTimeInterval time = newOffset.x/35;
        
        [UIView animateWithDuration:time delay:0.3 options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.scrollViewTitle setContentOffset:newOffset animated:NO];
                         } completion:^(BOOL finished){}];
    }
}

-(void)changeTitleFrameByBackBtn
{
    float fLeft = self.btnBack.frame.origin.x+self.btnBack.frame.size.width+5;
    self.scrollViewTitle.frame = CGRectMake(fLeft, kStatusBarHeight, kScreenWidth-2*fLeft, NAV_BAR_HEIGHT-kStatusBarHeight);
    [self setTopNavBarTitle:self.lblTitle.text];
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

//- (void)handleSwipeGesture:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
////- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
////{
////        if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
////        {
////            return YES;
////        }
////}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    BOOL result = NO;
//    
////    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
////    {
////        result = NO;
////    }
////    else
//    if (self.navigationController.) {
//        statements
//    }
//        if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
//    {
//        result = YES;
//    }
//    return result;
//}

@end
