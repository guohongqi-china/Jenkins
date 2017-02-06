//
//  UserDetailViewCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserEditVo.h"

@interface UserDetailViewCell : UITableViewCell

//nLocation:0(第一条),1(中间数据),2(最后一条)，用来设置背景
- (void)setEntity:(UserEditVo *)entity location:(NSInteger)nLocation;

@end
