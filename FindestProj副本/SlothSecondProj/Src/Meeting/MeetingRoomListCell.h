//
//  MeetingRoomListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomVo.h"

@interface MeetingRoomListCell : UITableViewCell

- (void)initWithDataVo:(MeetingRoomVo*)meetingRoomVo;
+ (CGFloat)calculateCellHeight:(MeetingRoomVo*)meetingRoomVo;

@end
