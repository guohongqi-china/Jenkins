//
//  PushSettingCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PushSettingCell.h"
#import "PushSettingViewController.h"

@interface PushSettingCell ()
{
    NotifyVo *notifyVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@end

@implementation PushSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    _lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEntity:(NotifyVo *)entity
{
    notifyVo = entity;
    
    _lblTitle.text = entity.title;
    
    if (entity.nPush == 1)
    {
        _switchControl.on = YES;
    }
    else
    {
        _switchControl.on = NO;
    }
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    notifyVo.nPush = (notifyVo.nPush) == 1?0:1;
    [self.parentController updatePushSetting:notifyVo];
}

@end
