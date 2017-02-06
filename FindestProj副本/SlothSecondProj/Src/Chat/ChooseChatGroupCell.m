//
//  ChooseChatGroupCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ChooseChatGroupCell.h"
#import "UIImageView+WebCache.h"

@interface ChooseChatGroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblGroupName;

@end

@implementation ChooseChatGroupCell

- (void)awakeFromNib {
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblGroupName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(GroupVo *)entity
{
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strGroupImage] placeholderImage:[UIImage imageNamed:@"default_m"]];
    _lblGroupName.text = entity.strGroupName;
}

@end
