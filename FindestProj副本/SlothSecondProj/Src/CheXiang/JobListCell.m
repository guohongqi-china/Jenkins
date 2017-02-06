//
//  JobListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "JobListCell.h"

@interface JobListCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewArrow;

@end

@implementation JobListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.imgViewArrow.image = [SkinManage imageNamed:@"table_accessory"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    _lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(JobVo *)entity
{
    self.lblTitle.text =  entity.strName;
}

@end
