//
//  LeftMenuCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-14.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.imgViewIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgViewIcon];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:17];
        self.lblName.textAlignment = NSTextAlignmentLeft;
        self.lblName.textColor = COLOR(204, 204, 198, 1.0);
        [self addSubview:_lblName];
        
        self.imgViewArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewArrow.image = [UIImage imageNamed:@"arrow_right"];
        [self addSubview:_imgViewArrow];
        
        self.imgViewSepLine = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewSepLine.image = [UIImage imageNamed:@"menu_sep_line"];
        [self addSubview:_imgViewSepLine];
        
        self.imgViewNoticeNum = [[UIImageView alloc] initWithFrame:CGRectMake(115, 22, 32, 19)];
        [self.imgViewNoticeNum.layer setBorderWidth:1.0];
        [self.imgViewNoticeNum.layer setCornerRadius:4];
        self.imgViewNoticeNum.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewNoticeNum.layer setMasksToBounds:YES];
        self.imgViewNoticeNum.image = [Common getImageWithColor:COLOR(247, 76, 49, 1.0)];
        [self addSubview:self.imgViewNoticeNum];
        self.imgViewNoticeNum.hidden = YES;
        
        self.lblNoticeNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblNoticeNum.backgroundColor = [UIColor clearColor];
        self.lblNoticeNum.font = [UIFont systemFontOfSize:15];
        self.lblNoticeNum.textAlignment = NSTextAlignmentCenter;
        self.lblNoticeNum.textColor = COLOR(255, 255, 255, 1.0);
        self.lblNoticeNum.backgroundColor = [UIColor clearColor];
        [self.imgViewNoticeNum addSubview:_lblNoticeNum];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if(selected)
    {
        //选中用户
        self.imgViewArrow.image = [SkinManage imageNamed:@"arrow_right_h"];
        self.imgViewIcon.image = [SkinManage imageNamed:[NSString stringWithFormat:@"%@_h",self.m_leftMenuVo.strImageName]];
        self.lblName.textColor = [SkinManage colorNamed:@"Menu_Name_H"];
    }
    else
    {
        //不选中
        self.imgViewArrow.image = [SkinManage imageNamed:@"arrow_right"];
        self.imgViewIcon.image = [SkinManage imageNamed:self.m_leftMenuVo.strImageName];
        self.lblName.textColor = [SkinManage colorNamed:@"Menu_Name"];
    }
}

-(void)initWithLeftMenuVo:(LeftMenuVo*)leftMenuVo
{
    self.m_leftMenuVo = leftMenuVo;
    
    //1.icon img
    self.imgViewIcon.frame = CGRectMake(25,24,15,15);
    self.imgViewIcon.image = [SkinManage imageNamed:leftMenuVo.strImageName];
   
    //2.menu name
    self.lblName.frame = CGRectMake(55,22.5,125,18);
    self.lblName.text = leftMenuVo.strName;

    //3.arrow img
    self.imgViewArrow.frame = CGRectMake(191,23.5,15.5,15.5);
    
    //4.notice num
    if ([leftMenuVo.strMenuID isEqualToString:@"1"])
    {
        self.imgViewNoticeNum.hidden = NO;
        
        NSString *strNoticeNum = [leftMenuVo.numNotice stringValue];
        if ([leftMenuVo.numNotice integerValue]>99)
        {
            strNoticeNum = @"99+";
        }
        self.lblNoticeNum.text = strNoticeNum;
        self.lblNoticeNum.frame =CGRectMake(0, 1, 32, 16);
    }
    else
    {
        self.imgViewNoticeNum.hidden = YES;
    }
}

@end
