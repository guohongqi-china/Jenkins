//
//  FootballLotteryCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "FootballLotteryCell.h"
#import "FootballLotteryViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+UIImageScale.h"

@interface FootballLotteryCell ()<UIActionSheetDelegate>
{
    LeagueVo *leagueVo;
}


@property (weak, nonatomic) IBOutlet UIView *anchorView1;
@property (weak, nonatomic) IBOutlet UIView *anchorView2;

//team1
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTeam1;
@property (weak, nonatomic) IBOutlet UILabel *lblTeam1;
@property (weak, nonatomic) IBOutlet UIView *viewCircle1;

//team2
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTeam2;
@property (weak, nonatomic) IBOutlet UILabel *lblTeam2;
@property (weak, nonatomic) IBOutlet UIView *viewCircle2;

//midle
@property (weak, nonatomic) IBOutlet UILabel *lblMatchTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSelected;

//button
@property (weak, nonatomic) IBOutlet UIButton *btnWin;
@property (weak, nonatomic) IBOutlet UIButton *btnEqual;
@property (weak, nonatomic) IBOutlet UIButton *btnFail;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSepHeight;


@property (weak, nonatomic) IBOutlet UIView *viewContainerView;
@property (weak, nonatomic) IBOutlet UILabel *vsLabel;
@property (weak, nonatomic) IBOutlet UIView *viewLine;

@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation FootballLotteryCell

- (void)awakeFromNib {
    // Initialization code
    self.anchorView1.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.anchorView2.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewContainerView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewContainerView.layer.borderColor = [UIColor clearColor].CGColor;
    [self.button setImage:[SkinManage imageNamed:@"football_share"] forState:UIControlStateNormal];
    [self.btnWin setBackgroundImage:[[SkinManage imageNamed:@"football_select"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [self.btnWin setBackgroundImage:[[UIImage imageNamed:@"football_select_h"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateSelected];
    
    [self.btnEqual setBackgroundImage:[[SkinManage imageNamed:@"football_select"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [self.btnEqual setBackgroundImage:[[UIImage imageNamed:@"football_select_h"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateSelected];
    
    [self.btnFail setBackgroundImage:[[SkinManage imageNamed:@"football_select"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [self.btnFail setBackgroundImage:[[UIImage imageNamed:@"football_select_h"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateSelected];
    
    
    self.lblTeam1.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    self.lblTeam2.textColor = [SkinManage colorNamed:@"metting_Tite_color"]
    ;
    
    self.lblMatchTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblMatchTime.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.vsLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
    [self.btnWin setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    [self.btnEqual setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    [self.btnFail setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    self.viewLine.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.viewCircle1.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    self.viewCircle2.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(LeagueVo *)entity last:(BOOL)bLastRow
{
    leagueVo = entity;
    
    if (bLastRow)
    {
        self.constraintSepHeight.constant = 0;
    }
    else
    {
        self.constraintSepHeight.constant = 9;
    }
    
    self.lblMatchTitle.text = entity.strLeagueTypeName;
    self.lblMatchTime.text = entity.strTime;
    
    [self.imgViewTeam1 sd_setImageWithURL:[NSURL URLWithString:entity.strTeam1Logo] placeholderImage:[UIImage imageNamed:@"default_image"]];
    [self.imgViewTeam2 sd_setImageWithURL:[NSURL URLWithString:entity.strTeam2Logo] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    self.lblTeam1.text = entity.strTeam1;
    self.lblTeam2.text = entity.strTeam2;
    
    [self.btnWin setTitle:[NSString stringWithFormat:@"胜 %.2f",entity.fWinOdds] forState:UIControlStateNormal];
    [self.btnEqual setTitle:[NSString stringWithFormat:@"平 %.2f",entity.fEqualOdds] forState:UIControlStateNormal];
    [self.btnFail setTitle:[NSString stringWithFormat:@"负 %.2f",entity.fLoseOdds] forState:UIControlStateNormal];
    
    self.btnWin.selected = NO;
    self.btnEqual.selected = NO;
    self.btnFail.selected = NO;
    if(entity.nCurrGuess > 0)
    {
        //已竞猜
        self.imgViewSelected.hidden = NO;
        if(entity.nCurrGuess == 1)
        {
            self.btnWin.selected = YES;
        }
        else if (entity.nCurrGuess == 2)
        {
            self.btnEqual.selected = YES;
        }
        else if (entity.nCurrGuess == 3)
        {
            self.btnFail.selected = YES;
        }
    }
    else
    {
        self.imgViewSelected.hidden = YES;
        if(entity.nCommitGuess == 1)
        {
            self.btnWin.selected = YES;
        }
        else if (entity.nCommitGuess == 2)
        {
            self.btnEqual.selected = YES;
        }
        else if (entity.nCommitGuess == 3)
        {
            self.btnFail.selected = YES;
        }
    }
}

- (IBAction)guessAction:(UIButton *)sender
{
    if(leagueVo.nCurrGuess <= 0)
    {
        if(sender.selected)
        {
            //取消选择
            sender.selected = NO;
            self.parentController.leagueSelectVo.nLeagueNum -= 1;
            leagueVo.nCommitGuess = 0;
        }
        else
        {
            if(leagueVo.nCommitGuess > 0)
            {
                //修改竞猜项
                self.btnWin.selected = NO;
                self.btnEqual.selected = NO;
                self.btnFail.selected = NO;
            }
            else
            {
                //增加竞猜项
                if(self.parentController.leagueSelectVo.nLeagueNum == 4)
                {
                    [Common bubbleTip:@"竞猜一次最多选择4场" andView:self.parentController.view];
                    return;
                }
                else
                {
                    self.parentController.leagueSelectVo.nLeagueNum += 1;
                }
            }
            sender.selected = YES;
            leagueVo.nCommitGuess = sender.tag - 1000;
        }
    }
    [self.parentController updateSelectNum];
}

//添加分享链接
- (IBAction)shareLinkAction:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"复制链接去分享"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"复制"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(footballLotteryCell:copyLinkSharingWithLeagueVo:)]) {
            [self.delegate footballLotteryCell:self copyLinkSharingWithLeagueVo:leagueVo];
        }
    }
}

@end
