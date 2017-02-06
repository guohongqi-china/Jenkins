//
//  RotateNavigationController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/24.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RotateNavigationController.h"

@interface RotateNavigationController ()

@end

@implementation RotateNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

@end
