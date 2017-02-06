//
//  MeetingPlaceDao.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeetingPlaceVo.h"

@interface MeetingPlaceDao : NSObject

+ (MeetingPlaceVo *)getMeetingPlaceVo;

+ (void)setMeetingPlaceVo:(MeetingPlaceVo *)placeVo;

@end
