//
//  CommonUserListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CommonUserListCell.h"
#import "UIImageView+WebCache.h"
#import "GroupAndUserDao.h"
#import "IntegralInfoVo.h"

@interface CommonUserListCell ()
{
    UserVo *userVo;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *viewLine;

@end

@implementation CommonUserListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    _lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    
    _viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
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
    UIViewController *parentController = (UIViewController *)self.delegate;
    [Common showProgressView:nil view:parentController.view modal:NO];
    [ServerProvider attentionUserAction:!userVo.bAttentioned andOtherUserID:userVo.strUserID result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:parentController.view];
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
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateAttentionState:)]) {
                [self.delegate updateAttentionState:userVo];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

@end
