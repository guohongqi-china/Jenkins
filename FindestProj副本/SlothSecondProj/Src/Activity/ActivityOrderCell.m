//
//  ActivityOrderCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityOrderCell.h"
#import "UIImageView+WebCache.h"

@interface ActivityOrderCell ()
{
    
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPoster;
@property (weak, nonatomic) IBOutlet UILabel *lblEnrollInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation ActivityOrderCell

- (void)awakeFromNib {
    // Initialization code
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    self.lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
    self.lblResult.font = [Common fontWithName:@"PingFangSC-Medium" size:13];
    
    self.viewContainer.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    
    
    
    self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    _lblTitle.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    _lblEnrollInfo.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(BlogVo *)entity
{
    [self.imgViewPoster sd_setImageWithURL:[NSURL URLWithString:entity.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    self.lblTitle.text = entity.strTitle;
    self.lblEnrollInfo.text = [NSString stringWithFormat:@"场次：%li场",(unsigned long)entity.nProjectJoinNum];
}

@end
