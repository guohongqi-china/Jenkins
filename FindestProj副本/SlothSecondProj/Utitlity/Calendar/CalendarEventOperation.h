//
//  CalendarEventOperation.h
//  Sloth
//
//  Created by 焱 孙 on 13-1-6.
//
//

#import <Foundation/Foundation.h>
#import "CalendarEventVo.h"

#define CREATE_CALENDAR_EVENT 1
#define UPDATE_CALENDAR_EVENT 2

@interface CalendarEventOperation : NSObject

+(void)saveCalendarEvent:(CalendarEventVo*)calendarEventVo andOperation:(int)nOperation andShowAlert:(BOOL)bShow;

@end
