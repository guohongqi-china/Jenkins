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
        self.imgViewBK = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewBK.image = [Common getImageWithColor:COLOR(50, 51, 51, 1.0)];
        //[self addSubview:_imgViewBK];
        
        self.imgViewIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgViewIcon];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont boldSystemFontOfSize:15];
        self.lblName.textAlignment = NSTextAlignmentLeft;
        self.lblName.textColor = COLOR(204, 204, 204, 1.0);
        [self addSubview:_lblName];
        
        self.viewSepLine = [[UIView alloc] initWithFrame:CGRectZero];
        self.viewSepLine.backgroundColor = COLOR(0, 0, 0, 1.0);
        [self addSubview:self.viewSepLine];
        
        self.imgViewNoticeNum = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewNoticeNum.image = [UIImage imageNamed:@"notice_num_bk"];
        [self addSubview:_imgViewNoticeNum];
        
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
//    if(selected)
//    {
//        //选中用户
//        self.imgViewIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_h",self.m_leftMenuVo.strImageName]];
//        self.lblName.textColor = COLOR(0, 0, 0, 1.0);
//    }
//    else
//    {
//        //不选中
//        self.imgViewIcon.image = [UIImage imageNamed:self.m_leftMenuVo.strImageName];
//        self.lblName.textColor = COLOR(80, 80, 80, 1.0);
//    }
}

-(void)initWithLeftMenuVo:(LeftMenuVo*)leftMenuVo
{
    //0.bk img
    self.imgViewBK.frame = CGRectMake(0,0,kScreenWidth,44);
    
    //icon and name
    self.lblName.text = leftMenuVo.strName;
    if (leftMenuVo.strImageName == nil)
    {
        //工单分类（没有icon）
        //icon img
        self.imgViewIcon.hidden = YES;
        
        //menu name
        self.lblName.frame = CGRectMake(15,0,125,44);
    }
    else
    {
        //其他菜单（有icon）
        //icon img
        self.imgViewIcon.hidden = NO;
        self.imgViewIcon.frame = CGRectMake(15,12,20,20);
        self.imgViewIcon.image = [UIImage imageNamed:leftMenuVo.strImageName];
        
        //menu name
        self.lblName.frame = CGRectMake(50,0,125,44);
    }
    
    //notice num
    if (leftMenuVo.bNotice)
    {
        self.imgViewNoticeNum.hidden = NO;
        self.imgViewNoticeNum.frame = CGRectMake(DRAWER_LEFT_WIDTH-12-31, 9, 31, 23);
        
        NSString *strNoticeNum = [leftMenuVo.numNotice stringValue];
        if (leftMenuVo.numNotice.integerValue>99)
        {
            strNoticeNum = @"99+";
        }
        else if (leftMenuVo.numNotice.integerValue == 0)
        {
            self.imgViewNoticeNum.hidden = YES;
        }
        self.lblNoticeNum.text = strNoticeNum;
        self.lblNoticeNum.frame =CGRectMake(0, 0, 31, 22);
    }
    else
    {
        self.imgViewNoticeNum.hidden = YES;
    }
    
    //5.seperate line img
    self.viewSepLine.frame = CGRectMake(0,0,kScreenWidth,0.5);
}


@end
