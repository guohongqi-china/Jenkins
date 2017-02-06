//
//  VoteSettingCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "VoteSettingCell.h"
#import "VoteOptionViewController.h"

@interface VoteSettingCell ()
{
    VoteSettingVo *settingVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewArrow;
@property (weak, nonatomic) IBOutlet UIView *sepLine;

@end

@implementation VoteSettingCell

- (void)awakeFromNib {
    // Initialization code
    _sepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.imgViewArrow.image = [SkinManage imageNamed:@"table_accessory"];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.lblValue.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(VoteSettingVo *)entity
{
    settingVo = entity;
    
    _lblTitle.text = entity.strTitle;
    
    if(entity.nID == 0)
    {
        _switchControl.hidden = NO;
        _lblValue.hidden = YES;
        _imgViewArrow.hidden = YES;
        
        if([entity.strValue isEqualToString:@"0"])
        {
            _switchControl.on = NO;
        }
        else
        {
            _switchControl.on = YES;
        }
    }
    else
    {
        _switchControl.hidden = YES;
        _lblValue.hidden = NO;
        _imgViewArrow.hidden = NO;
        
        _lblValue.text = entity.strValue;
    }
}

- (IBAction)changedSwitch:(UISwitch *)sender
{
    settingVo.strValue = sender.on?@"1":@"0";
    [self.parentController swichValueChanged:sender.on];
}

@end
