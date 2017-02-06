//
//  CommonUserListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@protocol CommonUserListCellDelegate <NSObject>
@optional
- (void)updateAttentionState:(UserVo *)userVo;

@end

@interface CommonUserListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnAttention;

@property (nonatomic, weak) id<CommonUserListCellDelegate> delegate;
@property (nonatomic, strong) UserVo *entity;

@end
