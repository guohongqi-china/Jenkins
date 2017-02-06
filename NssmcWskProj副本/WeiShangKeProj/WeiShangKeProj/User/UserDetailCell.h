//
//  UserDetailCell.h
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/9.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserKeyValueVo.h"

@class UserDetailViewController;
@interface UserDetailCell : UITableViewCell

@property (nonatomic,strong) UserKeyValueVo *entity;
@property (nonatomic,weak) UserDetailViewController *parentController;

@end
