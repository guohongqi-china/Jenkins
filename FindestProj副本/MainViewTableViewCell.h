//
//  MainViewTableViewCell.h
//  FindestProj
//
//  Created by MacBook on 16/7/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ManListModel;
@interface MainViewTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *IconView;//头像
@property (strong, nonatomic) IBOutlet UILabel *createLabel;//创始人姓名
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *titlelabel;//副标题
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;//图片
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;//图片高度

@property (strong, nonatomic) IBOutlet UIView *FirstView;
@property (nonatomic, strong) ManListModel *dataModel;/** <#注释#> */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *FirstViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *Hhhhh;
@property (strong, nonatomic) IBOutlet UIView *thirdView;

@end
