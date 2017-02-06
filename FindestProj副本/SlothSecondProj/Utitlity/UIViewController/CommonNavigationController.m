//
//  CommonNavigationController.m
//  TestWebView
//
//  Created by 焱 孙 on 12-12-14.
//  Copyright (c) 2012年 DNE. All rights reserved.
//

#import "CommonNavigationController.h"
#import "SkinManage.h"
#import "Utils.h"
#import "UIView+XMGExtension.h"
@interface CommonNavigationController ()

@end

@implementation CommonNavigationController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}

+ (void)initialize
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    //设置导航栏的颜色
    [navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    //禁用分割线
    navigationBar.shadowImage = [UIImage new];
    //设置半透明效果
    navigationBar.translucent = NO;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    [self refreshSkin];
}

- (void)refreshSkin
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//not rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setBarBackgroundImage:(UIImage *)image
{
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setBarTitleIconImage:(UIImage *)image
{
    
}
/**
 * 可以在这个方法中拦截所有push进来的控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) { // 如果push进来的不是第一个控制器
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"  " forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"navigationButtonReturnClick"] forState:UIControlStateHighlighted];
        button.size = CGSizeMake(70, 30);
        // 让按钮内部的所有内容左对齐
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        [button sizeToFit];
        // 让按钮的内容往左边偏移10
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
        // 修改导航栏左边的item
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        // 隐藏tabbar
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    // 这句super的push要放在后面, 让viewController可以覆盖上面设置的leftBarButtonItem
    [super pushViewController:viewController animated:animated];
    
}
- (void)back{
    [self popViewControllerAnimated:YES];

}
@end
