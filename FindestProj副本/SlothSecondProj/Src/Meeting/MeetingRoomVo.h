//
//  MeetingRoomVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeetingRoomVo : NSObject

@property (nonatomic, strong) NSString *strID;
@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strDesc;
@property (nonatomic, strong) NSString *strPlaceID;
@property (nonatomic, strong) NSString *strPlaceName;
@property (nonatomic) BOOL bEnable;    //是否可用

//book info
@property (nonatomic, strong) NSMutableArray *aryBookInfo;
@property (nonatomic, strong) NSString *strBookDate;

@end


////////////////////////////////////////////////////////////////////////////////////

@interface MeetingBookVo : NSObject

@property (nonatomic) NSInteger nID;
@property (nonatomic) NSInteger nTimeID;
@property (nonatomic, strong) NSString *strTimeDesc;
@property (nonatomic) BOOL bEnable;    //是否可用


@property (nonatomic, strong) NSString *strTitle;       //主题
@property (nonatomic, strong) NSString *strUserName;
@property (nonatomic, strong) NSString *strContact;     //电话
@property (nonatomic, strong) NSString *strRemark;

@property (nonatomic, strong) NSString *strUserID;

@property (nonatomic, strong) NSMutableArray *aryTimeSegment;  //预订的时间段 【必填，24小时时间，持续半小时，例如800表示8:00~8:30】

//0:不可用,1:别人已预订,2:自己已预订,3:自己刚预订,4:没预订
@property (nonatomic) NSInteger nState;

//我的预定记录////////////////////////////////////////////////////////
@property (nonatomic, strong) NSString *strRoomID;      //会议室id
@property (nonatomic, strong) NSString *strRoomName;    //会议室id
@property (nonatomic, strong) NSString *strRoomDesc;    //会议室简介
@property (nonatomic, strong) NSString *strBookDate;    //会议日期
@property (nonatomic, strong) NSDate *dateBook;         //会议日期
@property (nonatomic, strong) NSString *strStartTime;   //开始时间
@property (nonatomic, strong) NSString *strEndTime;     //结束时间
@property (nonatomic) NSInteger nMinTimeId;             //开始时间
@property (nonatomic) NSInteger nMaxTimeId;             //结束时间
@property (nonatomic, strong) NSString *strTimeRange;   //时间段
@property (copy, nonatomic) NSString *bookList;

//会议室预订查询参数/////////////////////////////////////////////////////////
@property (nonatomic, strong) NSString *strPlaceID;
@property (nonatomic, strong) NSString *strPlaceName;
@property (nonatomic, strong) NSString *strPlaceDesc;
@property (nonatomic, strong) NSString *strPersonNum;//人数
@property (nonatomic, strong) NSString *strDevice;  //设备信息

//会议室信息
@property (nonatomic, strong) MeetingRoomVo *roomVo;

@end