//
//  VoteSettingCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoteSettingVo.h"

@class VoteOptionViewController;

@interface VoteSettingCell : UITableViewCell

@property (nonatomic,weak) VoteOptionViewController *parentController;
@property (nonatomic,strong) VoteSettingVo *entity;

@end
