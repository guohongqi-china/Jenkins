//
//  MeetingCalendarView.h
//  TestCalendarProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 焱 孙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MeetingCalendarDelegate <NSObject>

- (void)completedChooseDate:(NSDate *)date;

@end

@interface MeetingCalendarView : UIView

@property (nonatomic, strong) id<MeetingCalendarDelegate> delegate;

- (void)showWithAnimation;

@end
