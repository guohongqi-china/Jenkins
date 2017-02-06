//
//  MeetingSegmentVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/29.
//  Copyright © 2016年 visionet. All rights reserved.
//

//8:00 - 8:30 - 9:00 - 9:30 - 10:00
//0    - 1	  - 2    - 3    - 4

#import <Foundation/Foundation.h>

@interface MeetingSegmentVo : NSObject

@property (nonatomic) NSInteger nIndex; //档位，总共24个档位，0~23,从8点钟开始（8点钟为0）
@property (nonatomic) NSInteger nReserveState;      //0:没预订，1:被已预订，2:该时间段无效(18点之后的时间无效),3:该时间段已过期(如果是今天预订)

@property (nonatomic, strong) NSString *strTitle;       //主题
@property (nonatomic, strong) NSString *strUserName;
@property (nonatomic, strong) NSString *strContact;     //电话

@end
