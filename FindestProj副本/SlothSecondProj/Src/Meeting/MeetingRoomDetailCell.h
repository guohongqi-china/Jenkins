//
//  MeetingRoomDetailCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomVo.h"

extern const CGFloat kMeetingBookCellH;

@interface MeetingRoomDetailCell : UITableViewCell

- (void)initWithDataVo:(MeetingBookVo*)meetingBookVo;

@end
