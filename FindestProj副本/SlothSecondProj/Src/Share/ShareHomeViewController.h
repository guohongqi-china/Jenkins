//
//  ShareHomeViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CommonViewController.h"

@class HomeViewController;
@interface ShareHomeViewController : UIViewController

@property (nonatomic, weak) HomeViewController *homeViewController;

- (void)hideBottomWhenPushed;
- (void)updateScrollToTopState:(NSInteger)nIndex;

@end
