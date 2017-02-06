//
//  CalendarEventDao.m
//  Sloth
//
//  Created by 焱 孙 on 12-12-25.
//
//

#import "CalendarEventDao.h"

@implementation CalendarEventDao

-(id)init
{
    self = [super init];
    if(self)
    {
        dbOperator = [SQLiteDBOperator getDBInstance];
    }
    return self;
}

//insert event 
- (BOOL)insertEvent:(CalendarEventVo*)calendarEventVo
{
    NSString *strSql = [NSString stringWithFormat:@"INSERT INTO T_CALENDAR_EVENT (EVENT_ID,SCHEDULE_ID) VALUES ('%@','%@')",
                        calendarEventVo.strEVENT_ID,calendarEventVo.strSCHEDULE_ID];
    return [dbOperator executeSql:strSql];
}

//update event id
- (BOOL)updateEventId:(NSString*)strOldEventId andNewEventId:(NSString*)strNewEventId 
{
    NSString *strSql = [NSString stringWithFormat:@"UPDATE T_CALENDAR_EVENT SET EVENT_ID = '%@' WHERE EVENT_ID='%@'",strNewEventId,strOldEventId];
    return [dbOperator executeSql:strSql];
}

//select event 
- (CalendarEventVo*)getCalendarEventByBlogId:(NSString*)strScheduleId
{
    CalendarEventVo* calendarEventVo = nil;
    NSString *strSql = [NSString stringWithFormat:@"select * from T_CALENDAR_EVENT where SCHEDULE_ID = '%@'",strScheduleId];
    NSMutableArray *ary =  [dbOperator QueryInfoFromSQL:strSql];
    if (ary.count > 0)
    {
        calendarEventVo = [[CalendarEventVo alloc]init];
        NSDictionary *dic = [ary objectAtIndex:0];
        calendarEventVo.strEVENT_ID = [dic objectForKey:@"EVENT_ID"];
        calendarEventVo.strSCHEDULE_ID = [dic objectForKey:@"SCHEDULE_ID"];
    }
    return calendarEventVo;
}

@end
