//
//  CommonViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/26.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonViewController : UIViewController

@property (nonatomic, strong) UIBarButtonItem   *rightBtnItem;

@property (nonatomic, strong) UILabel           *titleViewLabel;

@property (nonatomic, assign) BOOL              isNeedBackItem;

@property (nonatomic, assign) BOOL              hasNav; //default is YES;

@property (nonatomic, assign) BOOL bSupportPanUI;//是否支持拖动pop手势，默认yes

@property (nonatomic, assign) BOOL bFirstAppear;    //是否第一次调用viewWillAppear

- (void)backForePage;//左边item
- (void)righBarClick;//右边item

- (UIBarButtonItem *)rightBtnItemWithTitle:(NSString *)name;
- (void)setTitleImage:(UIImage *)image;
- (void)setTitleColor:(UIColor *)color;
- (void)setBackButtonColor:(UIColor *)color;

@end
