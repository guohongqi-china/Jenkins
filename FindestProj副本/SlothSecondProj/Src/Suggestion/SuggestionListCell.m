//
//  SuggestionListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "SuggestionListCell.h"
#import "UIViewExt.h"

@implementation SuggestionListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        self.viewSelected = [[UIView alloc] initWithFrame:self.frame];
        self.viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
        self.selectedBackgroundView = self.viewSelected;
        
        
        self.viewBK = [[UIView alloc] initWithFrame:CGRectZero];
        self.viewBK.backgroundColor =  [UIColor whiteColor];
        [self.viewBK.layer setBorderWidth:0.5];
        [self.viewBK.layer setCornerRadius:5];
        self.viewBK.layer.borderColor = [[SkinManage colorNamed:@"Wire_Frame_Color"] CGColor];
        [self.viewBK.layer setMasksToBounds:YES];
        [self.contentView addSubview:self.viewBK];
        self.viewBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:14];
        self.lblName.textAlignment = NSTextAlignmentLeft;
        self.lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        //        self.lblName.textColor = COLOR(166, 143, 136, 1.0);
        [self.contentView addSubview:self.lblName];
        self.lblName.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont systemFontOfSize:14];
        //        self.lblTitle.textColor =  COLOR(51, 43, 41, 1.0);
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.lblTitle];
        self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        //        self.lblDepartment = [[UILabel alloc] initWithFrame:CGRectZero];
        //        self.lblDepartment.backgroundColor = [UIColor clearColor];
        //        self.lblDepartment.font = [UIFont systemFontOfSize:14];
        //        self.lblDepartment.textAlignment = NSTextAlignmentLeft;
        //        self.lblDepartment.lineBreakMode = NSLineBreakByTruncatingTail;
        //        self.lblDepartment.textColor = COLOR(102, 102, 102, 1.0);
        //        [self addSubview:self.lblDepartment];
        
        self.lblContent = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblContent.backgroundColor = [UIColor clearColor];
        self.lblContent.font = [Common fontWithName:@"PingFangSC-Light" size:14];
        self.lblContent.textAlignment = NSTextAlignmentLeft;
        self.lblContent.lineBreakMode = NSLineBreakByTruncatingTail;
        //        self.lblContent.textColor = COLOR(85, 85, 85, 1.0);
        self.lblContent.textColor = [SkinManage colorNamed:@"meeting_place_color"];
        [self.contentView addSubview:self.lblContent];
        
        self.viewLine = [[UIView alloc] initWithFrame:CGRectZero];
        self.viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        [self.contentView addSubview:self.viewLine];
        
        self.lblStatus = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblStatus.backgroundColor = [UIColor clearColor];
        self.lblStatus.font = [Common fontWithName:@"PingFangSC-Light" size:14];
        self.lblStatus.textAlignment = NSTextAlignmentLeft;
        self.lblStatus.textColor = COLOR(239, 111, 88, 1.0);
        [self.contentView addSubview:self.lblStatus];
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDate.backgroundColor = [UIColor clearColor];
        self.lblDate.font = [UIFont systemFontOfSize:12];
        self.lblDate.textColor = COLOR(191, 180, 177, 1.0);
        self.lblDate.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.lblDate];
        
        self.lblDate.textColor = [SkinManage colorNamed:@"Share_Time"];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initWithDataVo:(SuggestionVo*)suggestionVo
{
    //name
    self.lblName.text = [NSString stringWithFormat:@"%@ • %@",suggestionVo.strName,suggestionVo.strDepartmentName];
    self.lblName.frame = CGRectMake(22, 20, kScreenWidth-140, 20.5);
    
    //title
    self.lblTitle.text = suggestionVo.strSuggestionName;
    self.lblTitle.frame = CGRectMake(22, self.lblName.bottom+10, kScreenWidth-44, 16);
    
    //内容
    self.lblContent.text = suggestionVo.strProblemDes;
    self.lblContent.frame = CGRectMake(22, self.lblTitle.bottom+5, kScreenWidth-44, 16);
    
    //line
    self.viewLine.frame = CGRectMake(12.5, self.lblContent.bottom+10, kScreenWidth-25, 0.5);
    
    //建议状态+评奖结果
    self.lblStatus.frame = CGRectMake(22, self.viewLine.bottom+5, kScreenWidth-100, 16);
    
    //    UIColor *colorStatus;
    //    if (suggestionVo.nStatus == 1 || suggestionVo.nStatus == 2)
    //    {
    //        //审核中状态
    //        self.viewLine.backgroundColor = COLOR(255,0,0, 1.0);
    //        colorStatus = COLOR(255,0,0, 1.0);
    //    }
    //    else if (suggestionVo.nStatus == 4 || suggestionVo.nStatus == 5 ||
    //             suggestionVo.nStatus == 8 || suggestionVo.nStatus == 9 ||
    //             suggestionVo.nStatus == 10 )
    //    {
    //        //实施中状态
    //        self.viewLine.backgroundColor = COLOR(0, 102, 0, 1.0);
    //        colorStatus = COLOR(0, 102, 0, 1.0);
    //    }
    //    else if (suggestionVo.nStatus == 3 || suggestionVo.nStatus == 6 ||
    //             suggestionVo.nStatus == 7 || suggestionVo.nStatus == 11 ||
    //             suggestionVo.nStatus == 12 || suggestionVo.nStatus == 13)
    //    {
    //        //已结束状态
    //        self.viewLine.backgroundColor = COLOR(0,51,255, 1.0);
    //        colorStatus = COLOR(0,51,255,1.0);
    //    }
    
    NSString *strReward;
    if(suggestionVo.nStatus == 7)
    {
        //子公司评奖结果
        strReward = suggestionVo.strSubRewardValue;
    }
    else if (suggestionVo.nStatus == 11)
    {
        //总公司评奖结果
        strReward = suggestionVo.strHeadRewardValue;
    }
    else
    {
        strReward = @"";
    }
    
    NSString *strStatus = [self getStatusNameByID:suggestionVo.nStatus];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@　%@",strStatus,strReward]];
    //    [attriString addAttribute:NSForegroundColorAttributeName value:colorStatus range:NSMakeRange(0, strStatus.length)];
    //    [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(255, 103, 0, 1.0) range:NSMakeRange(strStatus.length, attriString.length-strStatus.length)];
    //    self.lblStatus.attributedText = attriString;
    self.lblStatus.text = attriString.string;
    
    //date
    self.lblDate.text = [Common getDateTimeStrStyle2:suggestionVo.strDate andFormatStr:@"yyyy-MM-dd"];
    self.lblDate.frame = CGRectMake(kScreenWidth/2, self.viewLine.bottom+5, kScreenWidth/2-22, 15);
    
    self.viewBK.frame = CGRectMake(12, 10, kScreenWidth-24, 117);
}

+ (CGFloat)calculateCellHeight:(SuggestionVo*)suggestionVo
{
    return 127;
}

- (NSString*)getStatusNameByID:(NSInteger)nStatus
{
    NSString *strName;
    switch (nStatus) {
        case 1:
            strName = @"初评";
            break;
        case 2:
            strName = @"审核";
            break;
        case 3:
            strName = @"初评退回";
            break;
        case 4:
            strName = @"实施";
            break;
        case 5:
            strName = @"暂不实施";
            break;
        case 6:
            strName = @"不实施";
            break;
        case 7:
            strName = @"子公司评奖结果";
            break;
        case 8:
            strName = @"评审";
            break;
        case 9:
            strName = @"子公司评奖";
            break;
        case 10:
            strName = @"总公司评奖";
            break;
        case 11:
            strName = @"总公司评奖结果";
            break;
        case 12:
            strName = @"子公司不评奖";
            break;
        case 13:
            strName = @"非合理化建议";
            break;
        default:
            strName = @"";
            break;
    }
    return strName;
}

@end
