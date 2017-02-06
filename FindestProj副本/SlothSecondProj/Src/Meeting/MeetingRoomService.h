//
//  MeetingRoomService.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerReturnInfo.h"
#import "ServerURL.h"
#import "MeetingRoomVo.h"

@interface MeetingRoomService : NSObject

+ (void)getMeetingPlaceList:(ResultBlock)resultBlock;

+ (void)getMeetingRoomListByPlace:(NSString*)strPlaceID result:(ResultBlock)resultBlock;

+ (void)getMeetingRoomDetail:(NSString*)strPlaceID room:(NSString*)strRoomID date:(NSString *)strDate result:(ResultBlock)resultBlock;

+ (void)cancelReserveMeetingRoomParasms:(NSString *)booklistStr result:(ResultBlock)resultBlock;

+ (void)reserveMeetingRoom:(NSString *)strRoomID
                      time:(NSMutableArray *)aryTimeID
                      date:(NSString *)strBookDate
                     title:(NSString *)strTitle
                      name:(NSString *)strName
                   contact:(NSString *)strContact
                    remark:(NSString *)strRemark
                    result:(ResultBlock)resultBlock;

+ (void)reserveMeetingRoomByBookVo:(MeetingBookVo *)bookVo result:(ResultBlock)resultBlock;

+ (void)getMyReserveMeetingList:(ResultBlock)resultBlock;

+ (void)getMeetingRoomListByParameter:(MeetingBookVo*)book result:(ResultBlock)resultBlock;

@end
