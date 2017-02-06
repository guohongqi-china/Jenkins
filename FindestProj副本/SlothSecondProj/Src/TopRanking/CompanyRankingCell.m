//
//  CompanyRankingCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/19.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "CompanyRankingCell.h"
#import "UIViewExt.h"

@implementation CompanyRankingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.lblIndex = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblIndex.backgroundColor = [UIColor clearColor];
        self.lblIndex.font = [UIFont fontWithName:@"HeitiSC-Light" size:20];
        self.lblIndex.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lblIndex];
        
        self.lblCompanyName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCompanyName.backgroundColor = [UIColor clearColor];
        self.lblCompanyName.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        self.lblCompanyName.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblCompanyName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        [self.contentView addSubview:self.lblCompanyName];
        
        //人均
        self.lblAvgIntegral = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAvgIntegral.backgroundColor = [UIColor clearColor];
        self.lblAvgIntegral.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        self.lblAvgIntegral.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.lblAvgIntegral];
        
        //总积分
        self.lblSumIntegral = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblSumIntegral.backgroundColor = [UIColor clearColor];
        self.lblSumIntegral.textColor = COLOR(239, 111, 88, 1.0);
        self.lblSumIntegral.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lblSumIntegral];
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

-(void)initWithData:(CompanyRankingVo*)dataVo
{
    //background color
    if (dataVo.nIndex%2 == 1)
    {
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    }
    else
    {
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    }
    
    //index
    self.lblIndex.text = [NSString stringWithFormat:@"%li",(long)dataVo.nIndex];
    self.lblIndex.frame = CGRectMake(0, 0, 70, 68);
    if (dataVo.nIndex <= 3)
    {
        self.lblIndex.textColor = [SkinManage colorNamed:@"Tab_Item_Color_H"];
    }
    else
    {
        self.lblIndex.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    }
    
    //company name
    self.lblCompanyName.text = dataVo.strName;
    self.lblCompanyName.frame = CGRectMake(self.lblIndex.right, 10, kScreenWidth-self.lblIndex.right-12, 21);
    
    //avg integral
    self.lblAvgIntegral.frame = CGRectMake(self.lblCompanyName.left, self.lblCompanyName.bottom+5, 180, 22);
    NSMutableAttributedString *attriAvgIntegral = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"人均积分 %g",dataVo.fAvg]];
    [attriAvgIntegral addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 4)];
    [attriAvgIntegral addAttribute:NSBaselineOffsetAttributeName value:@1 range:NSMakeRange(0, 4)];
    [attriAvgIntegral addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(4, attriAvgIntegral.length-4)];
    self.lblAvgIntegral.attributedText = attriAvgIntegral;
    
    //sum integral
    self.lblSumIntegral.frame = CGRectMake(kScreenWidth-120, self.lblAvgIntegral.top, 120, 22);
    NSMutableAttributedString *attriSumIntegral = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"总积分 %@",[self getIntegralString:dataVo.fSum]]];
    [attriSumIntegral addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 4)];
    [attriSumIntegral addAttribute:NSBaselineOffsetAttributeName value:@1 range:NSMakeRange(0, 4)];
    [attriSumIntegral addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(4, attriSumIntegral.length-4)];
    self.lblSumIntegral.attributedText = attriSumIntegral;
}

-(NSString*)getIntegralString:(double)fIntegral
{
    NSString *strIntegral = @"";
    if(fIntegral<1000)
    {
        strIntegral = [NSString stringWithFormat:@"%g",fIntegral];
    }
    else
    {
        strIntegral = [NSString stringWithFormat:@"%0.1f K",(fIntegral/1000.0)];
    }
    return strIntegral;
}

@end
