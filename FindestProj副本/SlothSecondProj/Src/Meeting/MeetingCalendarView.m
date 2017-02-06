//
//  MeetingCalendarView.m
//  TestCalendarProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 焱 孙. All rights reserved.
//

#import "MeetingCalendarView.h"
#import "PDTSimpleCalendarViewController.h"
#import "Common.h"
#import "PDTSimpleCalendarViewCell.h"
#import "PDTSimpleCalendarViewHeader.h"
#import "UIViewExt.h"

@interface MeetingCalendarView ()<PDTSimpleCalendarViewDelegate>
{
    PDTSimpleCalendarViewController *dateRangeCalendarViewController;
    CGFloat fContentH;
    
    NSDate *dateChoosed;
}

@property (strong, nonatomic) UIView *viewContainer;
@property (strong, nonatomic) UIView *viewCalendar;
@property (strong, nonatomic) UIView *viewBottom;

@property (strong, nonatomic) UIButton *btnCancel;
@property (strong, nonatomic) UIButton *btnDone;

@end

@implementation MeetingCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView];
    }
    return self;
}

- (void)initView
{
    //
    self.backgroundColor = COLOR(0, 0, 0, 0.5);
    
    //333*kScreenWidth/320 + 76
    fContentH = 333*kScreenWidth/320 + 76;
    _viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, fContentH)];
    _viewContainer.backgroundColor = [UIColor whiteColor];
    [self addSubview:_viewContainer];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCancel.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-fContentH);
    [_btnCancel addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnCancel];
    
    //calendar
    self.viewCalendar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, fContentH - 76)];
    self.viewCalendar.backgroundColor = [UIColor redColor];
    [_viewContainer addSubview:_viewCalendar];
    
    //bottom
    self.viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, _viewCalendar.bottom, kScreenWidth, 76)];
    //    self.viewBottom.backgroundColor = [UIColor greenColor];
    [_viewContainer addSubview:_viewBottom];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"meetingview_sep_color"];
    [_viewBottom addSubview:viewLine];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(12, 13, kScreenWidth-24, 50);
    [_btnDone setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    [_btnDone setBackgroundImage:[Common getImageWithColor:COLOR(221, 208, 204, 1.0)] forState:UIControlStateDisabled];
    [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setTitleColor:COLOR(236, 236, 236, 1.0) forState:UIControlStateHighlighted];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:17];
    [_btnDone addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _btnDone.layer.cornerRadius = 5;
    _btnDone.layer.masksToBounds = YES;
    [_viewBottom addSubview:_btnDone];
    
    
    _viewContainer.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    _viewCalendar.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    _viewBottom.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    
    [self initCalendarView];
}

- (void)initCalendarView
{
    dateChoosed = [NSDate date];
    
    [self appearancePDTSimpleCalendar];
    
    dateRangeCalendarViewController = [[PDTSimpleCalendarViewController alloc] init];
    dateRangeCalendarViewController.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    dateRangeCalendarViewController.weekdayHeaderEnabled = YES;
    dateRangeCalendarViewController.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeShort;
    dateRangeCalendarViewController.delegate = self;
    dateRangeCalendarViewController.firstDate = [NSDate date];
    dateRangeCalendarViewController.selectedDate = [NSDate date];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    NSDate *lastDate =[dateRangeCalendarViewController.calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    dateRangeCalendarViewController.lastDate = lastDate;
    
    dateRangeCalendarViewController.view.frame = CGRectMake(0, 0, kScreenWidth, 333*kScreenWidth/320);//
    [self.viewCalendar addSubview:dateRangeCalendarViewController.view];
}

- (void)appearancePDTSimpleCalendar
{
    //Example of how you can now customize the calendar colors
    [[PDTSimpleCalendarViewCell appearance] setCircleDefaultColor:[UIColor whiteColor]];
    SkinType skinType = [SkinManage getCurrentSkin];
    if (skinType == SkinNightType) {
        [[PDTSimpleCalendarViewCell appearance] setCircleDefaultColor:[UIColor clearColor]];
    }
    
    [[PDTSimpleCalendarViewCell appearance] setCircleSelectedColor:COLOR(239, 111, 88, 1.0)];
    [[PDTSimpleCalendarViewCell appearance] setCircleTodayColor:[UIColor whiteColor]];
    if (skinType == SkinNightType) {
        [[PDTSimpleCalendarViewCell appearance] setCircleTodayColor:[UIColor clearColor]];
    }
    
    [[PDTSimpleCalendarViewCell appearance] setTextDefaultColor:[SkinManage colorNamed:@"date_text"]];
    [[PDTSimpleCalendarViewCell appearance] setTextSelectedColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewCell appearance] setTextTodayColor:COLOR(239, 111, 88, 1.0)];
    [[PDTSimpleCalendarViewCell appearance] setTextDisabledColor:[SkinManage colorNamed:@"date_title"]];
    [[PDTSimpleCalendarViewCell appearance] setTextDefaultFont:[UIFont fontWithName:@"HelveticaNeue" size:19.0]];
    
    [[PDTSimpleCalendarViewHeader appearance] setTextColor:COLOR(239, 111, 88, 1.0)];
    [[PDTSimpleCalendarViewHeader appearance] setSeparatorColor:[SkinManage colorNamed:@"meetingview_sep_color"]];
    [[PDTSimpleCalendarViewHeader appearance] setTextFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21.0]];
    
    [[PDTSimpleCalendarViewWeekdayHeader appearance] setHeaderBackgroundColor:[SkinManage colorNamed:@"other_other_color"]];
    [[PDTSimpleCalendarViewWeekdayHeader appearance] setTextColor:[SkinManage colorNamed:@"date_text"]];
    [[PDTSimpleCalendarViewWeekdayHeader appearance] setTextFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    
    
    
    
}

- (void)showWithAnimation
{
    self.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.viewContainer.frame = CGRectMake(0, kScreenHeight-fContentH, kScreenWidth, kScreenHeight);
        } completion:nil];
    }];
}

- (void)dismissWithAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        self.viewContainer.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        self.alpha = 1.0;
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if(sender == _btnDone)
    {
        [self.delegate completedChooseDate:dateChoosed];
        [self dismissWithAnimation];
    }
    else
    {
        [self dismissWithAnimation];
    }
}

#pragma mark - PDTSimpleCalendarViewDelegate
- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date
{
    dateChoosed = date;
}

- (BOOL)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller shouldUseCustomColorsForDate:(NSDate *)date
{
    //    if ([self.customDates containsObject:date]) {
    //        return YES;
    //    }
    
    return NO;
}

- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller circleColorForDate:(NSDate *)date
{
    return [UIColor whiteColor];
}

- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller textColorForDate:(NSDate *)date
{
    return [UIColor orangeColor];
}


@end
