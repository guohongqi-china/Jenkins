//
//  QuickNavBarViewController.h
//  Sloth
//
//  Created by Ann Yao on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNavigationViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *btnBack;
@property (nonatomic, strong) UIButton *btnRightNav;
@property (nonatomic, strong) UIImageView *imgViewTopBar;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIView *viewTop;
@property (nonatomic, strong) UIScrollView *scrollViewTitle;
@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UIActivityIndicatorView * activity;
@property (nonatomic, strong) UIImageView *imgViewWaiting;

//设置NavBar的标题
- (void)setTopNavBarTitle:(NSString *)title;
- (void)setTopNavBarTitleWithArrow:(NSString *)title;

//设置NavBar左侧按钮
- (void)setLeftBarButton:(UIButton*)btnLeftNav;

//设置NavBar右侧按钮
- (void)setRightBarButton:(UIButton*)btnRightNav;

//返回上一层
- (void)backButtonClicked;

-(void)changeTitleFrameByBackBtn;

-(void)isHideActivity:(BOOL)bHide;

@end
