//
//  MeetBookPopupInfo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/10.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomVo.h"

@class MeetBookPopupInfo;
//取消预订回调
typedef void(^CancelBookMeeting)(MeetBookPopupInfo *bookPopupInfo,MeetingBookVo *bookVo);

@interface MeetBookPopupInfo : UIView

- (instancetype)initWithFrame:(CGRect)frame bookVo:(MeetingBookVo*)bookVo block:(CancelBookMeeting)cancelBLock;

@end
