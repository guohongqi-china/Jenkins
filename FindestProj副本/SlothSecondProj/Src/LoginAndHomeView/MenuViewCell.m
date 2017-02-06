//
//  MenuViewCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/30.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "MenuViewCell.h"
#import "SkinManage.h"

@interface MenuViewCell ()
{
    UIImageView *imgViewAccessory;
    UIView *viewSelected;
    
    MenuVo *_menuVo;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UISwitch *switchNight;

@end

@implementation MenuViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}

- (void)awakeFromNib {
    // Initialization code
    imgViewAccessory = [[UIImageView alloc] initWithImage:[SkinManage imageNamed:@"table_accessory"]];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MenuVo *)menuVo
{
    _menuVo = menuVo;
    
    //BK
    imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    
    //
    if([menuVo.strID isEqualToString:@"Personal5"])
    {
        self.accessoryView = nil;
        _switchNight.hidden = NO;
        
        if ([SkinManage getCurrentSkin] == SkinDefaultType)
        {
            //默认模式
            _switchNight.on = NO;
        }
        else
        {
            //夜间模式
            _switchNight.on = YES;
        }
    }
    else
    {
        self.accessoryView = imgViewAccessory;
        _switchNight.hidden = YES;
    }
    _imgViewIcon.image = [SkinManage imageNamed:menuVo.strImageName];
    _lblName.text = menuVo.strName;
    _lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

//夜间模式切换
- (IBAction)switchValueChanged:(UISwitch *)sender
{
    SkinType skinType = [SkinManage getCurrentSkin];
    if (skinType == SkinDefaultType)
    {
        //切换为夜间模式
        [SkinManage setCurrentSkin:SkinNightType];
    }
    else
    {
        //切换为默认模式
        [SkinManage setCurrentSkin:SkinDefaultType];
    }
    
    //更新其他页面语言，发送通知或者重新进入
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_REFRESH_SKIN object:nil userInfo:nil];
}

- (void)refreshSkin
{
    _imgViewIcon.image = [SkinManage imageNamed:_menuVo.strImageName];
    [UIView animateWithDuration:0.3 animations:^{
        imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
        _lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        
    } completion:^(BOOL finished) {
        //        [self.tableViewMenu reloadData];
    }];
}

@end
