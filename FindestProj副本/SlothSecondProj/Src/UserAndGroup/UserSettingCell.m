//
//  UserSettingCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/5.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserSettingCell.h"
#import "UIImageView+WebCache.h"

@interface UserSettingCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintValueTop;

@end

@implementation UserSettingCell

- (void)awakeFromNib {
    // Initialization code
    
    _imgViewArrow.image = [SkinManage imageNamed:@"table_accessory"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    
    _lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblValue.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
}

- (void)setEntity:(UserEditVo *)entity
{
    _lblTitle.text = entity.strTitle;
    
    if ([entity.strKey isEqualToString:@"headerImage"])
    {
        _imgViewHeader.hidden = NO;
        _lblValue.hidden = YES;
        
        [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strValue] placeholderImage:[UIImage imageNamed:@"default_m"]];
        
        _lblValue.text = @" ";
        _constraintValueTop.constant = 14+(50-16);//减去_lblValue本身的高度16
    }
    else
    {
        _imgViewHeader.hidden = YES;
        _lblValue.hidden = NO;
        
        _lblValue.text = entity.strValue;
        
        _constraintValueTop.constant = 14;
    }
    
    [self layoutIfNeeded];
}

@end
