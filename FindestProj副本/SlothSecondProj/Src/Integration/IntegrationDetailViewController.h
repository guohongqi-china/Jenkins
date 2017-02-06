//
//  IntegrationDetailViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegrationDetailViewController : UIViewController

@property (nonatomic, retain) UITableView *tableViewData;
@property (nonatomic, retain) NSMutableArray *aryData;            //tableView data

@property (nonatomic) NSInteger nPageType;//0:收入积分,1:支出积分,2:版主积分


- (void)refreshData;

@end
