//
//  NotificationTableViewCell.h
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManListModel.h"
@interface NotificationTableViewCell : UITableViewCell
//@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
//
//@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong)  UILabel *contentLabel;;/** <#注释#> */
@property (nonatomic, strong) UILabel *timeLabel ;/** <#注释#> */

@property (nonatomic, strong) UIView *baseView;/** <#注释#> */
@property (nonatomic, strong) ManListModel *dataModel;/** <#注释#> */
@end
