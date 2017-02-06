//
//  MyReserveViewCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomVo.h"

@interface MyReserveViewCell : UITableViewCell

- (void)initWithDataVo:(MeetingBookVo*)meetingBookVo;
+ (CGFloat)calculateCellHeight:(MeetingBookVo*)meetingBookVo;

@end
