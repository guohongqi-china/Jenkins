//
//  CommonViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/26.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "CommonViewController.h"
#import "SNUIBarButtonItem.h"
#import "UIColor+SNFoundation.h"
#import "UIView+Extension.h"

@interface CommonViewController ()
{
    UIButton *backButton;
    UILabel *lblTitle;
}

@end

@implementation CommonViewController

- (id)init{
    
    self = [super init];
    
    if (self) {
        self.isNeedBackItem = YES;
        self.hasNav = YES;
        self.bSupportPanUI = YES;
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.isNeedBackItem = YES;
        self.hasNav = YES;
        self.bSupportPanUI = YES;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
        self.isNeedBackItem = YES;
        self.hasNav = YES;
        self.bSupportPanUI = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bFirstAppear = YES;
    self.tabBarController.tabBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem hidesBackButton];
    
    if (self.isNeedBackItem)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self getLeftButtonWithColor]];
    }
    else
    {
        
    }
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.bFirstAppear = NO;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    [self setTitleColor:[SkinManage colorNamed:@"Nav_Bar_Title_Color"]];
    
    //    //设置默认title属性
    //    lblTitle = [[UILabel alloc] init];
    //    lblTitle.textColor = [UIColor whiteColor];
    //    lblTitle.backgroundColor = [UIColor clearColor];
    //    lblTitle.font = [UIFont systemFontOfSize:19.0f];
    //    lblTitle.textAlignment = NSTextAlignmentCenter;
    //    CGRect frame = lblTitle.frame;
    //    lblTitle.frame = CGRectMake(frame.origin.x, 5, frame.size.width, 34);
    //    self.navigationItem.titleView = lblTitle;
    //    lblTitle.text = title;
}

- (void)setTitleImage:(UIImage *)image
{
    [super setTitle:@""];
    UIImageView *imgViewIcon = [[UIImageView alloc]initWithImage:image];
    imgViewIcon.height = 25;
    imgViewIcon.width = 40;
    imgViewIcon.centerX = self.view.centerX;
    imgViewIcon.centerY = 32;
    self.navigationItem.titleView = imgViewIcon;
}

- (void)setTitleColor:(UIColor *)color
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,nil]];
}

- (UIBarButtonItem *)leftBtnItemWithTitle:(NSString *)name
{
    if (!_leftBtnItem)
    {
        _leftBtnItem = [SNUIBarButtonItem itemWithTitle:name Style:SNNavItemStyleDone target:self action:@selector(backForePage)];
    }
    return _leftBtnItem;
}

- (UIBarButtonItem *)leftBtnItemWithImage:(NSString *)strImageName
{
    if (!_leftBtnItem)
    {
        _leftBtnItem = [SNUIBarButtonItem itemWithImage:strImageName style:SNNavItemStyleDone target:self action:@selector(backForePage)];
    }
    return _leftBtnItem;
}

- (UIBarButtonItem *)rightBtnItemWithTitle:(NSString *)name
{
    if (!_rightBtnItem)
    {
        _rightBtnItem = [SNUIBarButtonItem itemWithTitle:name Style:SNNavItemStyleDone target:self action:@selector(righBarClick)];
        _rightBtnItem.tintColor = [SkinManage colorNamed:@"Nav_Bar_Title_Color"];
    }
    return _rightBtnItem;
}

- (UIBarButtonItem *)rightBtnItemWithImage:(NSString *)strImageName
{
    if (!_rightBtnItem)
    {
        _rightBtnItem = [SNUIBarButtonItem itemWithImage:strImageName style:SNNavItemStyleDone target:self action:@selector(righBarClick)];
    }
    return _rightBtnItem;
}

//返回按钮响应
- (void)backForePage
{
    //    DLog(@"sourcePageTitle:%@",sourcePageTitle);
    //    DLog(@"sourcePageTitle_backForePage");
    //    sourcePageTitle = nil;
    //    daoPageTitle = nil;
    //erWeiMaPageTitle = nil;
    //remotePageTitle = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

//右边按钮响应
- (void)righBarClick
{
    
}

- (void)setBackButtonColor:(UIColor *)color
{
    self.colorBack = color;
}

- (UIButton *)getLeftButtonWithColor
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor clearColor];
    [btn setImage:[SkinManage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 44, 44);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    [btn addTarget:self action:@selector(backForePage) forControlEvents:UIControlEventTouchUpInside];
    btn.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
    return btn;
}

@end
