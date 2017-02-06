//
//  MyReserveViewCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "MyReserveViewCell.h"
#import "UIViewExt.h"

@interface MyReserveViewCell ()
{
    UILabel *lblRoomName;
    UILabel *lblMeetingTitle;
    
    UILabel *lblDate;
    UIImageView *imgViewTimeIcon;
    UILabel *lblTime;
    
    UIView *viewLine;
}

@end

@implementation MyReserveViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        lblRoomName = [[UILabel alloc] initWithFrame:CGRectZero];
        lblRoomName.backgroundColor = [UIColor clearColor];
        lblRoomName.font = [UIFont boldSystemFontOfSize:15];
        lblRoomName.textColor =  COLOR(100, 100, 100, 1.0);
        lblRoomName.textAlignment = NSTextAlignmentLeft;
        lblRoomName.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:lblRoomName];
        
        lblMeetingTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblMeetingTitle.backgroundColor = [UIColor clearColor];
        lblMeetingTitle.font = [UIFont systemFontOfSize:14];
        lblMeetingTitle.textColor =  COLOR(150, 150, 150, 1.0);
        lblMeetingTitle.textAlignment = NSTextAlignmentLeft;
        lblMeetingTitle.lineBreakMode = NSLineBreakByWordWrapping;
        lblMeetingTitle.numberOfLines = 0;
        [self addSubview:lblMeetingTitle];
        
        lblDate = [[UILabel alloc] initWithFrame:CGRectZero];
        lblDate.backgroundColor = [UIColor clearColor];
        lblDate.font = [UIFont boldSystemFontOfSize:13];
        lblDate.textColor =  COLOR(150, 150, 150, 1.0);
        lblDate.textAlignment = NSTextAlignmentLeft;
        [self addSubview:lblDate];
        
        imgViewTimeIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meeting_time_icon"]];
        [self addSubview:imgViewTimeIcon];
        
        lblTime = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTime.backgroundColor = [UIColor clearColor];
        lblTime.font = [UIFont boldSystemFontOfSize:13];
        lblTime.textColor =  COLOR(150, 150, 150, 1.0);
        lblTime.textAlignment = NSTextAlignmentLeft;
        [self addSubview:lblTime];
        
        viewLine = [[UIView alloc]init];
        viewLine.layer.borderColor = COLOR(223, 223, 223, 1.0).CGColor;
        viewLine.layer.borderWidth = 0.5;
        viewLine.backgroundColor = COLOR(243, 243, 243, 1.0);
        [self addSubview:viewLine];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithDataVo:(MeetingBookVo*)meetingBookVo
{
    CGFloat fHeight = 7;
    lblRoomName.text = meetingBookVo.strRoomName;
    lblRoomName.frame = CGRectMake(15, fHeight, kScreenWidth-30, 20);
    fHeight += 20+5;
    
    lblMeetingTitle.text = meetingBookVo.strTitle;
    CGSize size = [Common getStringSize:lblMeetingTitle.text font:lblMeetingTitle.font bound:CGSizeMake(kScreenWidth-30, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    lblMeetingTitle.frame = CGRectMake(15, fHeight, kScreenWidth-30, size.height);
    fHeight += size.height+5;
    
    lblDate.text = meetingBookVo.strBookDate;
    lblDate.frame = CGRectMake(15, fHeight, 80, 20);
    
    imgViewTimeIcon.frame = CGRectMake(lblDate.right+10, lblDate.top+3, 13.5, 13.5);
    
    lblTime.text = [NSString stringWithFormat:@"%@ - %@",meetingBookVo.strStartTime,meetingBookVo.strEndTime];
    lblTime.frame = CGRectMake(imgViewTimeIcon.right+5, fHeight, 90, 20);
    fHeight += 20+7;
    
    viewLine.frame = CGRectMake(-0.5, fHeight, kScreenWidth+1, 7.5);
}

+ (CGFloat)calculateCellHeight:(MeetingBookVo*)meetingBookVo
{
    CGFloat fHeight = 7;
    fHeight += 20+5;
    
    CGSize size = [Common getStringSize:meetingBookVo.strTitle font:[UIFont systemFontOfSize:14] bound:CGSizeMake(kScreenWidth-30, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    fHeight += size.height+5;
    
    fHeight += 20+7;
    
    fHeight += 7.5;
    return fHeight;
}

@end
