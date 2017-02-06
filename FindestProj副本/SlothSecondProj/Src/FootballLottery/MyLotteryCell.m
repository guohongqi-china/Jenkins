//
//  MyLotteryCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/11.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MyLotteryCell.h"

@interface MyLotteryCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSepHeight;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopHeight;
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;
@property (weak, nonatomic) IBOutlet UILabel *lblMyGuess;
@property (weak, nonatomic) IBOutlet UILabel *lblBetting;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchTime;
@property (weak, nonatomic) IBOutlet UILabel *lblGetIntegral;

@end

@implementation MyLotteryCell

- (void)awakeFromNib {
    // Initialization code
    self.lblMatchTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
    self.lblResult.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
    self.lblGetIntegral.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
    self.viewBottom.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.viewLine.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.topView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.viewBottom.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    _lblDate.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblResult.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblMatchTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblMatchTime.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblMyGuess.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblBetting.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(LeagueVo *)entity last:(NSString *)strLastDate;
{
    if(strLastDate != nil && [entity.strDate isEqualToString:strLastDate])
    {
        _constraintTopHeight.constant = 0;
        _constraintSepHeight.constant = 9;
        _lblDate.hidden = YES;
    }
    else
    {
        _constraintTopHeight.constant = 35;
        _constraintSepHeight.constant = 0;
        _lblDate.hidden = NO;
    }
    
    _lblDate.text = entity.strDate;
    _lblMatchTitle.text = [NSString stringWithFormat:@"%@(主) vs %@(客)",entity.strTeam1,entity.strTeam2];
    
    NSString *strResult;
    self.lblGetIntegral.text = nil;
    if (entity.nStatus == 1)
    {
        strResult = @"等待开奖";
        self.lblResult.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    }
    else if (entity.nStatus == 3)
    {
        if(entity.fIntegration > 0)
        {
            strResult = @"中奖";
            self.lblResult.textColor = [SkinManage colorNamed:@"Tab_Item_Color_H"];
            self.lblGetIntegral.text = [NSString stringWithFormat:@"获得%g积分",entity.fIntegration];
        }
        else
        {
            strResult = @"未中奖";
            self.lblResult.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        }
    }
    else
    {
        strResult = nil;
    }
    _lblResult.text = strResult;
    
    //我猜
    if(entity.nCurrGuess == 1)
    {
        strResult = @"主胜";
    }
    else if (entity.nCurrGuess == 2)
    {
        strResult = @"平局";
    }
    else
    {
        strResult = @"主负";
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"我猜　%@",strResult]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(0, 2)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(2, 3)];
    _lblMyGuess.attributedText = attributedString;
    
    //投注
    attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"投注　%li 积分",(unsigned long)entity.nConsumeIntegral]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(0, 2)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(2, attributedString.length-2)];
    _lblBetting.attributedText = attributedString;
    
    //比赛时间
    attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"比赛时间　%@",entity.strTime]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(0, 4)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(4, attributedString.length-4)];
    _lblMatchTime.attributedText = attributedString;
    
    [self layoutIfNeeded];
}

@end
