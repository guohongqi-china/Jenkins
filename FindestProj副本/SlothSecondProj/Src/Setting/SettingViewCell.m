//
//  SettingViewCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SettingViewCell.h"

@interface SettingViewCell ()
{
    MenuVo *menuVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewArrow;
@property (weak, nonatomic) IBOutlet UILabel *lblTip;

@end

@implementation SettingViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.imgViewArrow.image = [SkinManage imageNamed:@"table_accessory"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    _lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _lblTip.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MenuVo *)entity
{
    menuVo = entity;
    _lblTitle.text = entity.strName;
    
    if ([entity.strID isEqualToString:@"audio"] || [entity.strID isEqualToString:@"viewPhone"] || [entity.strID isEqualToString:@"viewStore"])
    {
        _switchControl.hidden = NO;
        _imgViewArrow.hidden = YES;
        
        _switchControl.on = entity.bBoolValue;
    }
    else
    {
        _switchControl.hidden = YES;
        _imgViewArrow.hidden = NO;
    }
    
    if(entity.strRemark.length > 0)
    {
        _lblTip.text = entity.strRemark;
    }
    else
    {
        _lblTip.text = nil;
    }
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(switchControlChanged: state:)])
    {
        [self.delegate switchControlChanged:menuVo state:sender.on];
    }
}

@end
