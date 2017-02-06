//
//  FollowUserCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@interface FollowUserCell : UITableViewCell

@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, strong) UserVo *entity;

@end
