//
//  CalendarEventVo.h
//  Sloth
//
//  Created by 焱 孙 on 12-12-24.
//
//

#import <Foundation/Foundation.h>

@interface CalendarEventVo : NSObject

@property(nonatomic,retain)NSString *strEVENT_ID;       //事件ID
@property(nonatomic,retain)NSString *strSCHEDULE_ID;    //日程ID
@property(nonatomic,retain)NSString *strDESCRIPTION;    //描述
@property(nonatomic,retain)NSString *strMEMO1;          //备注1
@property(nonatomic,retain)NSString *strMEMO2;          //备注2

@property(nonatomic,retain)NSString *strTopic;          
@property(nonatomic,retain)NSString *strStreamContent;
@property(nonatomic,retain)NSString *strStartTime;

@end
