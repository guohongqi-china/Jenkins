//
//  CommonNavigationController.h
//  TestWebView
//
//  Created by 焱 孙 on 12-12-14.
//  Copyright (c) 2012年 DNE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonNavigationController : UINavigationController

@property (nonatomic) UIStatusBarStyle statusBarStyle;

- (void)setBarBackgroundImage:(UIImage *)image;
- (void)setBarTitleIconImage:(UIImage *)image;

@end
