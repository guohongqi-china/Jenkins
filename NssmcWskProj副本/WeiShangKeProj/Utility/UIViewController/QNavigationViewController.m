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
    imgViewTopBar.image = [Common getImageWithColor:THEME_COLOR];
    [self.viewTop addSubview:imgViewTopBar];
    
    self.scrollViewTitle = [[UIScrollView alloc]initWithFrame:CGRectMake(60, kStatusBarHeight, kScreenWidth-120, NAV_BAR_HEIGHT-kStatusBarHeight)];
    self.scrollViewTitle.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollViewTitle.clipsToBounds = YES;
	self.scrollViewTitle.scrollEnabled = YES;
	self.scrollViewTitle.pagingEnabled = NO;
    self.scrollViewTitle.scrollsToTop = NO;
    self.scrollViewTitle.showsHorizontalScrollIndicator = NO;
    
	[self.scrollViewTitle setBackgroundColor:[UIColor clearColor]];
    [self.scrollViewTitle setContentSize:CGSizeMake(kScreenWidth-120, NAV_BAR_HEIGHT-kStatusBarHeight)];
    [self.viewTop addSubview:scrollViewTitle];
    
    //top nav title
    lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,kStatusBarHeight, kScreenWidth-120, NAV_BAR_HEIGHT-kStatusBarHeight)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [self.scrollViewTitle addSubview:lblTitle];
    self.bWithAllow = NO;
    
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
    self.btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_back"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(backButtonClicked)];
    //[Utils leftButtonWithTitle:[Common localStr:@"Common_Return" value:@" 返回"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(backButtonClicked)];
    [self setLeftBarButton:self.btnBack andKey:@"Common_Return"];
    
    if (rootViewController != nil) 
    {
        rootViewController.view.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
        [self.view addSubview:rootViewController.view];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - ButtonListener
//设置NavBar左侧按钮
- (void)setLeftBarButton:(UIButton*)btnLeftNav
{
    [btnBack removeFromSuperview];
    self.btnBack = btnLeftNav;
	[self.viewTop addSubview:btnBack];
}

//国际化保存key
- (void)setLeftBarButton:(UIButton*)btnLeftNav andKey:(NSString*)strKey
{
    self.strLeftKey = strKey;
    [self setLeftBarButton:btnLeftNav];
}

//设置NavBar右侧按钮
- (void)setRightBarButton:(UIButton*)btnRightNav
{
    [self.btnRightNav removeFromSuperview];
    self.btnRightNav = btnRightNav;
    [self.viewTop addSubview:self.btnRightNav];
}

- (void)setRightBarButton:(UIButton*)btnRightNav andKey:(NSString*)strKey
{
    self.strRightKey = strKey;
    [self setRightBarButton:btnRightNav];
}

//设置NavBar的标题
- (void)setTopNavBarTitle:(NSString *)title
{
    self.bWithAllow = NO;
    NSString *strTitle = title;
    CGSize sizeLabel = [Common getStringSize:strTitle font:lblTitle.font bound:CGSizeMake(CGFLOAT_MAX, NAV_BAR_HEIGHT-kStatusBarHeight) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeLabel.width<kScreenWidth-120)
    {
        lblTitle.frame = CGRectMake((kScreenWidth-120-sizeLabel.width)/2,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
    }
    else
    {
        lblTitle.frame = CGRectMake(0,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
    }
    scrollViewTitle.contentSize = sizeLabel;
    self.lblTitle.text = title;
    
    self.arrowImageView.hidden = YES;
    
    //自动滚动标题
    if(scrollViewTitle.frame.size.width<scrollViewTitle.contentSize.width)
    {
        CGPoint newOffset = self.scrollViewTitle.contentOffset;
        newOffset.x = (scrollViewTitle.contentSize.width-scrollViewTitle.frame.size.width);
        NSTimeInterval time = newOffset.x/35;
        
        [UIView animateWithDuration:time delay:0.3 options: UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollViewTitle setContentOffset:newOffset animated:NO];
        } completion:^(BOOL finished){}];
    }
}

- (void)setTopNavBarTitle:(NSString *)title andKey:(NSString*)strKey
{
    self.strTitleKey = strKey;
    [self setTopNavBarTitle:title];
}

//设置NavBar的标题（带下拉箭头）
- (void)setTopNavBarTitleWithArrow:(NSString *)title
{
    self.bWithAllow = YES;
    NSString *strTitle = title;
    CGSize sizeLabel = [Common getStringSize:strTitle font:lblTitle.font bound:CGSizeMake(CGFLOAT_MAX, NAV_BAR_HEIGHT-kStatusBarHeight) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeLabel.width<kScreenWidth-120)
    {
        lblTitle.frame = CGRectMake((kScreenWidth-120-sizeLabel.width)/2,0, sizeLabel.width,NAV_BAR_HEIGHT-kStatusBarHeight);
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

- (void)setTopNavBarTitleWithArrow:(NSString *)title andKey:(NSString*)strKey
{
    self.strTitleKey = strKey;
    [self setTopNavBarTitleWithArrow:title];
}

//设置右导航按钮文字
- (void)setRightButtonTitle:(NSString*)strTitle andKey:(NSString*)strKey
{
    //right button
    self.strRightKey = strKey;
    [self.btnRightNav setTitle:strTitle forState:UIControlStateNormal];
}

//返回上一层
- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changeTitleFrameByBackBtn
{
    float fLeft = self.btnBack.frame.origin.x+self.btnBack.frame.size.width+5;
    self.scrollViewTitle.frame = CGRectMake(fLeft, kStatusBarHeight, kScreenWidth-120-(fLeft-60), NAV_BAR_HEIGHT-kStatusBarHeight);
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

- (void)refreshTitle
{
    //title
    if (self.strTitleKey != nil)
    {
        if (self.bWithAllow)
        {
            //带箭头
            [self setTopNavBarTitleWithArrow:[Common localStr:self.strTitleKey value:nil]];
        }
        else
        {
            [self setTopNavBarTitle:[Common localStr:self.strTitleKey value:nil]];
        }
    }
    
    //left button
    if (self.strLeftKey != nil)
    {
        [self.btnBack setTitle:[Common localStr:self.strLeftKey value:nil] forState:UIControlStateNormal];
    }
    
    //right button
    if (self.strRightKey != nil)
    {
        [self.btnRightNav setTitle:[Common localStr:self.strRightKey value:nil] forState:UIControlStateNormal];
    }
}

@end
