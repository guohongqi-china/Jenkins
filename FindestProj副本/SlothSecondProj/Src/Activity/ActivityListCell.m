//
//  ActivityListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityListCell.h"
#import "UIImageView+WebCache.h"

@interface ActivityListCell ()
{
    UIView  *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPoster;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEnrollNum;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblAdress;
@property (weak, nonatomic) IBOutlet UIView *viewSep;

@end

@implementation ActivityListCell

- (void)awakeFromNib {
    // Initialization code
    self.lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    self.lblEnrollNum.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
    self.viewSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblDateTime.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    self.lblAdress.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(BlogVo *)entity
{
    [self.imgViewPoster sd_setImageWithURL:[NSURL URLWithString:entity.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    self.lblTitle.text = entity.strTitle;
    self.lblEnrollNum.text = [NSString stringWithFormat:@"%li 人报名",(unsigned long)entity.nActivitySignupNum];
    self.lblDateTime.text = [Common getDateTimeStringFromString:entity.strActivityStartDateTime format:@"yyyy年MM月dd日 a hh:mm"];
    self.lblAdress.text = entity.strActivityAddress;
}

@end
