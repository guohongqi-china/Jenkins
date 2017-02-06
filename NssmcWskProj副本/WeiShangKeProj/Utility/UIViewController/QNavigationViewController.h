//
//  QuickNavBarViewController.h
//  Sloth
//
//  Created by Ann Yao on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNavigationViewController : UIViewController

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

//国际化Key
@property (nonatomic, strong) NSString *strLeftKey;
@property (nonatomic, strong) NSString *strRightKey;
@property (nonatomic, strong) NSString *strTitleKey;
@property (nonatomic) BOOL bWithAllow;//是否带下拉箭头

//设置NavBar的标题
- (void)setTopNavBarTitle:(NSString *)title;
- (void)setTopNavBarTitleWithArrow:(NSString *)title;

//设置NavBar左侧按钮
- (void)setLeftBarButton:(UIButton*)btnLeftNav;

//设置NavBar右侧按钮
- (void)setRightBarButton:(UIButton*)btnRightNav;

//国际化保存Key
- (void)setLeftBarButton:(UIButton*)btnLeftNav andKey:(NSString*)strKey;
- (void)setRightBarButton:(UIButton*)btnRightNav andKey:(NSString*)strKey;
- (void)setTopNavBarTitle:(NSString *)title andKey:(NSString*)strKey;
- (void)setTopNavBarTitleWithArrow:(NSString *)title andKey:(NSString*)strKey;
- (void)setRightButtonTitle:(NSString*)strTitle andKey:(NSString*)strKey;

//返回上一层
- (void)backButtonClicked;

-(void)changeTitleFrameByBackBtn;

-(void)isHideActivity:(BOOL)bHide;

- (void)refreshTitle;

@end
