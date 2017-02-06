//
//  PraiseListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PraiseListCell.h"
#import "UIImageView+WebCache.h"

@interface PraiseListCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UIView *viewLine;
@end

@implementation PraiseListCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(PraiseVo *)entity
{
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.imageUrl] placeholderImage:[UIImage imageNamed:@"default_m"]];
    _lblName.text = entity.strAliasName;
}


@end
