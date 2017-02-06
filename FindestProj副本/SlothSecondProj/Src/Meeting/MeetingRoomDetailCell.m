//
//  MeetingRoomDetailCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "MeetingRoomDetailCell.h"
#import "UIViewExt.h"
#import "UserVo.h"

const CGFloat kMeetingBookCellH = 50;

@interface MeetingRoomDetailCell ()
{
    UIImageView *imgViewSep;
    UIImageView *imgViewCircle;
    UILabel *lblTime;
    UIView *viewLine;
}

@end

@implementation MeetingRoomDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        viewLine = [[UIView alloc]init];
        viewLine.backgroundColor = COLOR(220, 220, 220, 1.0);
        [self addSubview:viewLine];
        
        imgViewSep = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"room_circle"]];
        [self addSubview:imgViewSep];
        
        imgViewCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"disable_reserve"]];
        [self addSubview:imgViewCircle];
        
        lblTime = [[UILabel alloc] init];
        lblTime.backgroundColor = [UIColor clearColor];
        lblTime.font = [UIFont systemFontOfSize:15];
        lblTime.textColor =  COLOR(60, 60, 60, 1.0);
        [self addSubview:lblTime];
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
    CGFloat fHalfW = kScreenWidth/2;
    CGFloat fHalfH = kMeetingBookCellH/2;
    
    viewLine.frame = CGRectMake(fHalfW-0.5, 0, 1, kMeetingBookCellH);
    
    imgViewSep.frame = CGRectMake(fHalfW-4.5, fHalfH-4.5, 9, 9);
    
    if (meetingBookVo.nTimeID % 100 == 0)
    {
        //right
        imgViewCircle.frame = CGRectMake(fHalfW + 10, fHalfH-16.5, 33, 33);
        
        lblTime.frame = CGRectMake(imgViewCircle.right+7.5, fHalfH-10, 120, 20);
        lblTime.textAlignment = NSTextAlignmentLeft;
        lblTime.text = meetingBookVo.strTimeDesc;
    }
    else
    {
        //left
        imgViewCircle.frame = CGRectMake(fHalfW-10-33, fHalfH-16.5, 33, 33);
        
        lblTime.frame = CGRectMake(imgViewCircle.left-7.5-120, fHalfH-10, 120, 20);
        lblTime.textAlignment = NSTextAlignmentRight;
        lblTime.text = meetingBookVo.strTimeDesc;
    }
    
    if (meetingBookVo.nState == 0)
    {
        imgViewCircle.image = [UIImage imageNamed:@"disable_reserve"];
    }
    else if (meetingBookVo.nState == 1)
    {
        imgViewCircle.image = [UIImage imageNamed:@"disable_reserve"];
    }
    else if (meetingBookVo.nState == 2)
    {
        imgViewCircle.image = [UIImage imageNamed:@"my_reserve"];
    }
    else if (meetingBookVo.nState == 3)
    {
        imgViewCircle.image = [UIImage imageNamed:@"just_reserve"];
    }
    else if (meetingBookVo.nState == 4)
    {
        imgViewCircle.image = [UIImage imageNamed:@"able_reserve"];
    }
}



@end
