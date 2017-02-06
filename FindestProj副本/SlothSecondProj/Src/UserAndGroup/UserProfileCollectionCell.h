//
//  UserProfileCollectionCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/12.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserProfileViewController;
@interface UserProfileCollectionCell : UITableViewCell

@property (nonatomic,weak) UserProfileViewController *parentController;

- (void)setData:(NSMutableArray *)aryData userVo:(UserVo*)userInfo;

@end
