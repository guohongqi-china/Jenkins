//
//  SurveyCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 11/28/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "SurveyCell.h"

@implementation SurveyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.imgViewCheck = [[UIImageView alloc] init];
        [self addSubview:self.imgViewCheck];
        
        self.lblOptionDesc = [[UILabel alloc] init];
        self.lblOptionDesc.numberOfLines = 0;
        self.lblOptionDesc.lineBreakMode = NSLineBreakByCharWrapping;
        self.lblOptionDesc.backgroundColor = [UIColor clearColor];
        self.lblOptionDesc.font = [UIFont systemFontOfSize:16];
        self.lblOptionDesc.textColor = COLOR(91, 91, 91, 1.0);
        [self addSubview:self.lblOptionDesc];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//(NSInteger)nMultiple:0,单选；1，多选,(QuestionVo*)questionLast上一个问题，为了做关联
- (void)initWithData:(QOptionVo*)qOptionVo andLastQ:(QuestionVo*)questionLast andMultiple:(NSInteger)nMultiple
{
    self.m_nMultiple = nMultiple;
    self.m_qOptionVo = qOptionVo;
    
    //1.判断答案是否关联
    self.bAssociation = NO;
    self.lblOptionDesc.textColor = COLOR(91, 91, 91, 1.0);
    if (questionLast != nil && questionLast.nAssociation == 1)
    {
        //上一题是关联题，判断上一题选择的答案ID与本答案是否一样，
        //答案一样则将背景变灰并且用户选择该答案则吐丝提示
        for(QOptionVo *tempOption in questionLast.aryOption)
        {
            if (tempOption.bChecked && [tempOption.strID isEqualToString:qOptionVo.strID])
            {
                self.bAssociation = YES;
                self.lblOptionDesc.textColor = COLOR(180, 180, 180, 1.0);
                break;
            }
        }
    }
    
    if(nMultiple == 0)
    {
        //单选
        if(qOptionVo.bChecked)
        {
            //选中
            self.imgViewCheck.image = [UIImage imageNamed:@"single_check"];
        }
        else
        {
            self.imgViewCheck.image = [UIImage imageNamed:@"single_uncheck"];
        }
    }
    else
    {
        //多选
        if(qOptionVo.bChecked)
        {
            //选中
            self.imgViewCheck.image = [UIImage imageNamed:@"multiple_check"];
        }
        else
        {
            self.imgViewCheck.image = [UIImage imageNamed:@"multiple_uncheck"];
        }
    }
    self.imgViewCheck.frame = CGRectMake(15, 7, 25, 25);
    
    CGSize size = [Common getStringSize:qOptionVo.strName andFont:self.lblOptionDesc.font andBound:CGSizeMake(kScreenWidth-70, MAXFLOAT)];
    self.lblOptionDesc.frame = CGRectMake(55, 10, kScreenWidth-70, size.height);
    self.lblOptionDesc.text = qOptionVo.strName;
}

+ (CGFloat)calculateCellHeight:(QOptionVo*)qOptionVo
{
    CGFloat fHeight = 10;
    CGSize size = [Common getStringSize:qOptionVo.strName andFont:[UIFont systemFontOfSize:16] andBound:CGSizeMake(kScreenWidth-70, MAXFLOAT)];
    if (size.height > 31)
    {
        fHeight += size.height;
    }
    else
    {
        fHeight += 31;
    }
    fHeight += 10;
    
    return fHeight;
}

- (void)updateCheckImage
{
    if(self.m_nMultiple == 0)
    {
        //单选
        if(self.m_qOptionVo.bChecked)
        {
            //选中
            self.imgViewCheck.image = [UIImage imageNamed:@"single_check"];
        }
        else
        {
            self.imgViewCheck.image = [UIImage imageNamed:@"single_uncheck"];
        }
    }
    else
    {
        //多选
        if(self.m_qOptionVo.bChecked)
        {
            //选中
            self.imgViewCheck.image = [UIImage imageNamed:@"multiple_check"];
        }
        else
        {
            self.imgViewCheck.image = [UIImage imageNamed:@"multiple_uncheck"];
        }
    }
}

@end
