//
//  TicketTraceListCell.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/29.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketTraceVo.h"

@interface TicketTraceListCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewIcon;
@property(nonatomic,strong)UILabel *lblDateTime;
@property(nonatomic,strong)UILabel *lblContent;

-(void)initWithData:(TicketTraceVo*)ticketTraceVo;
+ (CGFloat)calculateCellHeight:(TicketTraceVo*)ticketTraceVo;

@end
