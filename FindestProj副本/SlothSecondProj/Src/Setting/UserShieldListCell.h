//
//  UserShieldListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@class UserShieldListViewController;

@interface UserShieldListCell : UITableViewCell

@property (nonatomic, strong) UserVo *entity;
@property (nonatomic, weak) UserShieldListViewController *parentController;

@end
