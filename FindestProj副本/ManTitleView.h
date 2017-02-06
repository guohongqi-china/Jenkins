//
//  ManTitleView.h
//  FindestProj
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManListModel.h"
@interface ManTitleView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;

@property (nonatomic, strong) ManListModel *dataModel;/** <#注释#> */
@property (strong, nonatomic) IBOutlet UIButton *collectionButton;
@end
