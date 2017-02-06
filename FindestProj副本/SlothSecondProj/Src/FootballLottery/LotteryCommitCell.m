//
//  LotteryCommitCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "LotteryCommitCell.h"

@interface LotteryCommitCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *lblMatchTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchTime;
@property (weak, nonatomic) IBOutlet UILabel *lblHomeCourt;
@property (weak, nonatomic) IBOutlet UILabel *lblAway;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation LotteryCommitCell

- (void)awakeFromNib {
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _containerView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblMatchTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblMatchTime.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblHomeCourt.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblAway.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblResult.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(LeagueVo *)entity
{
    self.lblMatchTitle.text = entity.strLeagueTypeName;
    self.lblMatchTime.text = entity.strTime;
    
    self.lblHomeCourt.text = [NSString stringWithFormat:@"%@(主)",entity.strTeam1];
    self.lblAway.text = [NSString stringWithFormat:@"%@(客)",entity.strTeam2];
    
    NSString *strResult;
    if(entity.nCommitGuess == 1)
    {
        strResult = [NSString stringWithFormat:@"胜(%.2f)",entity.fWinOdds];
    }
    else if (entity.nCommitGuess == 2)
    {
        strResult = [NSString stringWithFormat:@"平(%.2f)",entity.fEqualOdds];
    }
    else if (entity.nCommitGuess == 3)
    {
        strResult = [NSString stringWithFormat:@"负(%.2f)",entity.fLoseOdds];
    }
    self.lblResult.text = strResult;
}

@end
