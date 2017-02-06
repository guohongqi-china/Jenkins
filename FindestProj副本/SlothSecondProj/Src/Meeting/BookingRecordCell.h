//
//  BookingRecordCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomVo.h"
@class BookingRecordCell;


@protocol BookingRecordCellDelegate <NSObject>

@optional
- (void)deleteButtonClickWithBookingRecordCell:(BookingRecordCell *)cell;

@end

@interface BookingRecordCell : UITableViewCell
@property (weak, nonatomic) id<BookingRecordCellDelegate>delegate;
@property (strong, nonatomic) MeetingBookVo *entity;

- (void)setEntity:(MeetingBookVo *)entity lastRow:(BOOL)bLast;

@end
