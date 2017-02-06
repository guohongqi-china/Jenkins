//
//  ActivityHistoryCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityHomeViewController;

@interface ActivityHistoryCell : UITableViewCell

@property (nonatomic,strong)NSMutableArray *entity;
@property (nonatomic,weak)ActivityHomeViewController *parentController;

@end
