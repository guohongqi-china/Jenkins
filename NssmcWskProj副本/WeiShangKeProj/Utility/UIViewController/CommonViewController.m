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

@interface CommonViewController ()
{
    UIBarButtonItem *backButton;
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
        SNUIBarButtonItem *item = [SNUIBarButtonItem itemWithTitle:nil
                                                             Style:SNNavItemStyleBack
                                                            target:self
                                                            action:@selector(backForePage)];
        self.navigationItem.leftBarButtonItem = item;
        
        backButton = self.navigationItem.backBarButtonItem;
        backButton.tintColor = [UIColor whiteColor];
    }
    else
    {
        
    }
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.bFirstAppear = NO;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    //[self setTitleColor:[UIColor whiteColor]];
    
    //设置默认title属性
    lblTitle = [[UILabel alloc] init];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:17.0f];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    CGRect frame = lblTitle.frame;
    lblTitle.frame = CGRectMake(frame.origin.x, 5, frame.size.width, 34);
    self.navigationItem.titleView = lblTitle;
    lblTitle.text = title;
}

- (void)setTitleImage:(UIImage *)image
{
    [super setTitle:@""];
    
    UIImageView *imgViewIcon = [[UIImageView alloc]initWithImage:image];
    self.navigationItem.titleView = imgViewIcon;
}

- (void)setTitleColor:(UIColor *)color
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,nil]];
}

- (UIBarButtonItem *)rightBtnItemWithTitle:(NSString *)name
{
    if (!_rightBtnItem) {
        
        _rightBtnItem = [SNUIBarButtonItem itemWithTitle:name
                                                   Style:SNNavItemStyleDone
                                                  target:self
                                                  action:@selector(righBarClick)];
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
    backButton.tintColor = color;
}

@end
