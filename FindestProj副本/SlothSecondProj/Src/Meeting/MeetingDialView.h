//
//  MeetingDialView.h
//  DialViewProj
//
//  Created by 焱 孙 on 16/1/20.
//  Copyright © 2016年 焱 孙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol MeetingDialDelegate <NSObject>

- (void)dialViewStateChanged:(NSInteger)nState timeSegment:(NSMutableArray *)aryTimeSegment;

@end

@interface MeetingDialView : UIView

@property (nonatomic, weak) id<MeetingDialDelegate> delegate;
@property (nonatomic, strong) NSString *strBookDate;    //预订日期

//状态：1：未开始（可以旋转确定起始时间），2：已开始（旋转绘制时间条），3：已结束（不能旋转，点击重置后可以到未开始状态）
@property (nonatomic) NSInteger nStatus;
@property (nonatomic) NSMutableArray *arySegmentState;    //每一段位的状态，YES:可预订，NO:不可预订
@property (nonatomic) CGFloat fRotateAngle;   //开始预订时的旋转角度

- (NSString *)getStartTimeString;
- (NSString *)getEndTimeString;
- (void)refreshBookRecord:(NSDictionary *)dicBook;          //刷新已预订记录的圆环
- (void)closeTimer;
- (void)drawOutCircle;

@end
