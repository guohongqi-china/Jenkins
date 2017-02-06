//
//  HeaderView.h
//  FindestProj
//
//  Created by MacBook on 16/7/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManListModel.h"
@interface HeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;/** 标题label */

@property (nonatomic, strong) UILabel *contentLabel;/** 主标题label */

@property (nonatomic, strong) UILabel *zanLabel;/** <#注释#> */

@property (nonatomic, strong) ManListModel *model;/** <#注释#> */
@end
