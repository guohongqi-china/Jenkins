//
//  CommonNavigationController.m
//  TestWebView
//
//  Created by 焱 孙 on 12-12-14.
//  Copyright (c) 2012年 DNE. All rights reserved.
//

#import "CommonNavigationController.h"
#import "Utils.h"

@interface CommonNavigationController ()

@end

@implementation CommonNavigationController

+ (void)initialize
{
    UINavigationBar *app = [UINavigationBar appearance];
    app.translucent = YES;
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
	// Do any additional setup after loading the view.
    [self.navigationBar setBackgroundImage:[Common getImageWithColor:THEME_COLOR] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
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

@end
