//
//  FollowUserCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "FollowUserCell.h"
#import "UIImageView+WebCache.h"
#import "GroupAndUserDao.h"
#import "IntegralInfoVo.h"
#import "CommentVo.h"

@interface FollowUserCell ()
{
    UserVo *userVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnAttention;

@end

@implementation FollowUserCell

- (void)awakeFromNib {
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.bounds];
    viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblInfo.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(UserVo *)entity
{
    userVo = entity;
    
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    _lblName.text = entity.strUserName;
    _imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:entity.fIntegrationCount].strLevelImage];
    _lblInfo.text = entity.strRecommendDes;
    
    if(entity.bAttentioned)
    {
        [_btnAttention setImage:[UIImage imageNamed:@"user_attentioned"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnAttention setImage:[UIImage imageNamed:@"user_not_attention"] forState:UIControlStateNormal];
    }
}

- (IBAction)attentionAction:(UIButton *)sender
{
    //关注action 取消关注用户 or 关注用户
    [Common showProgressView:nil view:self.parentController.view modal:NO];
    [ServerProvider attentionUserAction:!userVo.bAttentioned andOtherUserID:userVo.strUserID result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.parentController.view];
        if (retInfo.bSuccess)
        {
            if(userVo.bAttentioned)
            {
                userVo.bAttentioned = NO;
                [_btnAttention setImage:[UIImage imageNamed:@"user_not_attention"] forState:UIControlStateNormal];
                
                //取消关注成功，更新数据库，发送推送通知
                GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                [groupAndUserDao updateUserAfterAttentionAction:userVo andAttention:NO];
            }
            else
            {
                userVo.bAttentioned = YES;
                [_btnAttention setImage:[UIImage imageNamed:@"user_attentioned"] forState:UIControlStateNormal];
                
                //关注用户成功，更新数据库，发送推送通知
                GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                [groupAndUserDao updateUserAfterAttentionAction:userVo andAttention:YES];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//add by fjz
//关注界面,隐藏自己关注自己的按钮
- (void)layoutSubviews
{
    [super layoutSubviews];
    UserVo *currentUser = [Common getCurrentUserVo];
    self.btnAttention.hidden = [currentUser.strUserID isEqualToString:userVo.strUserID];
}

@end
