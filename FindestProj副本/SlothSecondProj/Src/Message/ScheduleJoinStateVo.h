//
//  ScheduleJoinStateVo.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-11-30.
//
//

#import <Foundation/Foundation.h>

//约会人员回应状态列表
@interface ScheduleJoinStateVo : NSObject

@property(nonatomic,retain)NSString *strID;         //列表项ID
@property(nonatomic,retain)NSString *strUserID;     //用户ID
@property(nonatomic,retain)NSString *strUserName;     //用户名称
@property(nonatomic,assign)int nReply;              //回应状态,1参加2不参加3不确定

@end
