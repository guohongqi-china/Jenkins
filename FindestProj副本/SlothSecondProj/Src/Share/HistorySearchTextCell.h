//
//  HistorySearchTextCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistorySearchVo.h"

@class MainSearchViewController;
@interface HistorySearchTextCell : UITableViewCell

@property (nonatomic, strong) HistorySearchVo *entity;
@property (nonatomic, weak) MainSearchViewController *mainSearchViewController;

@end
