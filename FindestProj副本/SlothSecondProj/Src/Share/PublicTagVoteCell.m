//
//  PublicTagVoteCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PublicTagVoteCell.h"

@interface PublicTagVoteCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIImageView *table_accessoryImageView;

@end

@implementation PublicTagVoteCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.table_accessoryImageView.image = [SkinManage imageNamed:@"table_accessory"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MenuVo *)entity
{
    if([entity.strName isEqualToString:@"投票选项"])
    {
        _lblDesc.text = entity.strRemark;
    }
    else
    {
        _lblDesc.text = nil;
    }
    
    _imgViewIcon.image = [SkinManage imageNamed:entity.strImageName];
    _lblTitle.text = entity.strName;
}

@end
