//
//  DropDownListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "DropDownListCell.h"

@interface DropDownListCell ()
{
    MenuVo *menuVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *lblMenuName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSelected;
@property (weak, nonatomic) IBOutlet UIView *viewSep;

@end

@implementation DropDownListCell

- (void)awakeFromNib {
    // Initialization code
    _viewSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.lblMenuName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    viewSelected = [[UIView alloc] initWithFrame:self.bounds];
    viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MenuVo *)entity
{
    menuVo = entity;
    
    _lblMenuName.text = entity.strName;
    
    if(entity.bSelected)
    {
        _imgViewSelected.hidden = NO;
        _lblMenuName.textColor = [SkinManage colorNamed:@"Tab_Item_Color_H"];
    }
    else
    {
        _imgViewSelected.hidden = YES;
        _lblMenuName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    }
}

@end
