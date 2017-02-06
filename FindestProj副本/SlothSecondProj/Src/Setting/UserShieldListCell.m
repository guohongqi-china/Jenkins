//
//  UserShieldListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserShieldListCell.h"
#import "UIImageView+WebCache.h"
#import "UserShieldListViewController.h"

@interface UserShieldListCell ()
{
    UserVo *userVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@end

@implementation UserShieldListCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    _lblName.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    
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
    _lblInfo.text = entity.strSignature;
}

- (IBAction)restoreAction:(UIButton *)sender
{
    [self.parentController restoreUserAction:userVo];
}

@end
