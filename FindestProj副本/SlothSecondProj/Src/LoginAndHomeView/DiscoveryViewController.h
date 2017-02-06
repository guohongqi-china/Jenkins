//
//  DiscoveryViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/30.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "CommonViewController.h"

@class HomeViewController;
@interface DiscoveryViewController : CommonViewController

@property (nonatomic, weak) HomeViewController *homeViewController;

@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;

@end
