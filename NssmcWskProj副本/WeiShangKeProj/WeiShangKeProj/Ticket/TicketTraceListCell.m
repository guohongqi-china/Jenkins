//
//  TicketTraceListCell.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/29.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TicketTraceListCell.h"
#import "UIViewExt.h"

@implementation TicketTraceListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        //icon
        self.imgViewIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewIcon.image = [[UIImage imageNamed:@"ticket_trace_icon"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
        [self.contentView addSubview:self.imgViewIcon];
        
        //date time
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:13];
        self.lblDateTime.textColor = COLOR(149, 149, 149, 1.0);
        [self.contentView addSubview:self.lblDateTime];
        
        //content
        self.lblContent = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblContent.backgroundColor = [UIColor clearColor];
        self.lblContent.textColor = COLOR(49, 49, 49, 1.0);
        self.lblContent.font = [UIFont systemFontOfSize:14];
        self.lblContent.numberOfLines = 0;
        self.lblContent.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.lblContent];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithData:(TicketTraceVo*)ticketTraceVo
{
    CGFloat fHeight = 0;
    //date time
    self.lblDateTime.text = [Common getDateTimeStrStyle2:ticketTraceVo.strDateTime andFormatStr:@"yyyy-MM-dd hh:mm"];
    self.lblDateTime.frame = CGRectMake(35, fHeight, kScreenWidth-35, 20);
    fHeight += self.lblDateTime.height+5;
    
    //content
    self.lblContent.text = ticketTraceVo.strContent;
    CGSize size = [Common getStringSize:self.lblContent.text font:self.lblContent.font bound:CGSizeMake(kScreenWidth-35-10, MAXFLOAT) lineBreakMode:self.lblContent.lineBreakMode];
    self.lblContent.frame = CGRectMake(35, fHeight, kScreenWidth-35, size.height);
    fHeight += size.height+15;
    
    //icon
    self.imgViewIcon.frame = CGRectMake(13, 0, 18, fHeight);
}

+ (CGFloat)calculateCellHeight:(TicketTraceVo*)ticketTraceVo
{
    CGFloat fHeight = 0;
    //date time
    fHeight += 20+5;
    
    //content
    CGSize size = [Common getStringSize:ticketTraceVo.strContent font:[UIFont systemFontOfSize:14] bound:CGSizeMake(kScreenWidth-35-10, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    fHeight += size.height+15;
    
    return fHeight;
}

@end
