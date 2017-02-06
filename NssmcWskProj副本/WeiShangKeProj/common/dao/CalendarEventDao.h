//
//  CalendarEventDao.h
//  Sloth
//
//  Created by 焱 孙 on 12-12-25.
//
//

#import <Foundation/Foundation.h>
#import "SQLiteDBOperator.h"
#import "CalendarEventVo.h"

@interface CalendarEventDao : NSObject
{
    SQLiteDBOperator *dbOperator;
}

- (BOOL)insertEvent:(CalendarEventVo*)calendarEventVo;
- (BOOL)updateEventId:(NSString*)strOldEventId andNewEventId:(NSString*)strNewEventId;
- (CalendarEventVo*)getCalendarEventByBlogId:(NSString*)strScheduleId;

@end
