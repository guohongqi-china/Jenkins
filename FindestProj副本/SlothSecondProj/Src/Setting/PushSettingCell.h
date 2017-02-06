//
//  PushSettingCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotifyVo.h"

@class PushSettingViewController;

@interface PushSettingCell : UITableViewCell

@property (nonatomic,weak) PushSettingViewController *parentController;
@property (nonatomic,strong) NotifyVo *entity;

@end
