//
//  TagListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TagListCell.h"

@interface TagListCell ()
{
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewSelect;
@property (weak, nonatomic) IBOutlet UILabel *lblTagName;

@end

@implementation TagListCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblTagName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
//    self.table_accessoryImageView.image = [SkinManage imageNamed:@"table_accessory"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(TagVo *)entity
{
    if (entity.bChecked)
    {
        _imgViewSelect.image = [UIImage imageNamed:@"list_selected"];
    }
    else
    {
        _imgViewSelect.image = [SkinManage imageNamed:@"list_unselected"];
    }
    
    _lblTagName.text = entity.strTagName;
}

-(void)updateCheckImage:(BOOL)bChecked
{
    if (bChecked)
    {
        _imgViewSelect.image = [UIImage imageNamed:@"list_selected"];
    }
    else
    {
        _imgViewSelect.image = [SkinManage imageNamed:@"list_unselected"];
    }
}

@end
