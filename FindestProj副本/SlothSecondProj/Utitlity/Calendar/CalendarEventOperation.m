//
//  CalendarEventOperation.m
//  Sloth
//
//  Created by 焱 孙 on 13-1-6.
//
//

#import "CalendarEventOperation.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import "CalendarEventDao.h"

@implementation CalendarEventOperation

+(void)saveCalendarEvent:(CalendarEventVo*)calendarEventVo andOperation:(int)nOperation andShowAlert:(BOOL)bShow
{ 
    // Get the event store object  
    EKEventStore *eventStore = [[EKEventStore alloc] init];  
    /* iOS 6 requires the user grant your application access to the Event Stores */
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        /* iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE */
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            if (granted)
            {
                EKEvent *event;
                if (nOperation == CREATE_CALENDAR_EVENT)
                {
                    event = [EKEvent eventWithEventStore:eventStore];
                }
                else
                {
                    event = [eventStore eventWithIdentifier:calendarEventVo.strEVENT_ID];
                    if (event == nil) 
                    {
                        event = [EKEvent eventWithEventStore:eventStore];
                    }
                }
                // Set properties of the new event object  
                event.title = calendarEventVo.strTopic; 
                event.notes = calendarEventVo.strStreamContent; 
                
                //start date and end date
                NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init]; 
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; 
                dateFormatter.locale=[NSLocale currentLocale];
                NSDate *startDate = [dateFormatter dateFromString:calendarEventVo.strStartTime];
                event.startDate = startDate; 
                
                NSTimeInterval timeInterval = 24 * 60 * 60;
                NSDate *endDate = [startDate dateByAddingTimeInterval:timeInterval];
                event.endDate = endDate;
                //[dateFormatter release];
                
                EKAlarm*alarm = [EKAlarm alarmWithRelativeOffset:-5*60];//before five minute alarm
                [event addAlarm:alarm];
                
                // set event's calendar to the default calendar  
                event.calendar = [eventStore defaultCalendarForNewEvents];  
                
                // Save the event  
                NSError *err;
                [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                if (err == nil)//if (err == noErr)
                {
                    if (nOperation == CREATE_CALENDAR_EVENT)
                    {
                        //insert to db
                        CalendarEventDao *calendarEventDao = [[CalendarEventDao alloc]init];
                        calendarEventVo.strEVENT_ID = event.eventIdentifier;
                        [calendarEventDao insertEvent:calendarEventVo];
                        //[calendarEventDao release];
                    }
                    else
                    {
                        if (![event.eventIdentifier isEqualToString:calendarEventVo.strEVENT_ID]) 
                        {
                            //new one,old calendar alert is deleted
                            CalendarEventDao *calendarEventDao = [[CalendarEventDao alloc]init];
                            [calendarEventDao updateEventId:calendarEventVo.strEVENT_ID andNewEventId:event.eventIdentifier];
                            //[calendarEventDao release];
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        if (bShow)
                        {
                            //[Common tipAlert:@"保存手机提醒成功"];
                        }
                    });
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveCalendarEventSuccess" object:nil];  
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),^{
                        if (bShow)
                        {
                            [Common tipAlert:@"保存手机提醒失败"];
                        }
                    });
                }
                //[eventStore release];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    if (bShow)
                    {
                        [Common tipAlert:@"User has not granted permission!"];
                    }
                });
                DLog(@"User has not granted permission!");
            }
        }];
    }
}  

@end
