//
//  DetailTableViewCell.h
//  FindestProj
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManListModel.h"
@interface DetailTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, strong)  ManListModel *dataModel;/** <#注释#> */
@property (strong, nonatomic) IBOutlet UIButton *praiseButton;




@end
