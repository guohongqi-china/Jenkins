//
//  MeetingRoomListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "MeetingRoomListCell.h"
#import "UIViewExt.h"

@interface MeetingRoomListCell()
{
    UIImageView *imgViewIcon;
    UILabel *lblName;
    UILabel *lblDesc;
    UIView *viewLine;
}

@end

@implementation MeetingRoomListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        imgViewIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meeting_room_icon"]];
        [self addSubview:imgViewIcon];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:14];
        lblName.textColor =  COLOR(100, 100, 100, 1.0);
        lblName.textAlignment = NSTextAlignmentLeft;
        lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:lblName];
        
        lblDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        lblDesc.backgroundColor = [UIColor clearColor];
        lblDesc.font = [UIFont boldSystemFontOfSize:13];
        lblDesc.textColor =  COLOR(140, 140, 140, 1.0);
        lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
        lblDesc.numberOfLines = 0;
        [self addSubview:lblDesc];
        
        viewLine = [[UIView alloc]init];
        viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
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

- (void)initWithDataVo:(MeetingRoomVo*)meetingRoomVo
{
    CGFloat fHeight = 10;
    imgViewIcon.frame = CGRectMake(10, fHeight+5, 27.5, 27.5);
    
    lblName.text = meetingRoomVo.strName;
    lblName.frame = CGRectMake(47.5, fHeight, kScreenWidth-47.5-10, 20);
    fHeight += 20;
    
    lblDesc.text = meetingRoomVo.strDesc;
    CGSize size = [Common getStringSize:lblDesc.text font:lblDesc.font bound:CGSizeMake(lblName.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    lblDesc.frame = CGRectMake(47.5, fHeight, lblName.width, size.height);
    fHeight += size.height+10;
    
    if (fHeight < 55)
    {
        fHeight = 55;
    }
    viewLine.frame = CGRectMake(0, fHeight-0.5, kScreenWidth, 0.5);
}

+ (CGFloat)calculateCellHeight:(MeetingRoomVo*)meetingRoomVo
{
    CGFloat fHeight = 10;
    fHeight += 20;
    
    CGSize size = [Common getStringSize:meetingRoomVo.strDesc font:[UIFont boldSystemFontOfSize:13] bound:CGSizeMake(kScreenWidth-47.5-10, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    fHeight += size.height+10;
    
    if (fHeight < 55)
    {
        fHeight = 55;
    }
    
    return fHeight;
}

@end
