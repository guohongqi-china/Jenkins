//
//  MemberListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MemberListCell.h"
#import "UIImageView+WebCache.h"

@interface MemberListCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation MemberListCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(UserVo *)entity
{
    [self.imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    self.lblName.text = entity.strUserName;
}

@end
