//
//  ScheduleVo.hhttp://www.iciba.com/
//  Sloth
//
//  Created by 焱 孙 on 12-12-24.
//
//

#import <Foundation/Foundation.h>

@interface ScheduleVo : NSObject

@property(nonatomic,retain)NSString *strId;                     //约会ID
@property(nonatomic,retain)NSString *strStartTime;              //开始时间
@property(nonatomic,assign)long lDuration;                      //为期时间(以毫秒为单位)
@property(nonatomic,retain)NSString *strAddress;                //地点
@property(nonatomic,retain)NSMutableArray *aryUserJoinState;    //约会人员回应状态列表

@property(nonatomic,retain)NSString *strScheduleContent;        //约会内容

@end
