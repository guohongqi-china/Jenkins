//
//  SearchBlogTypeCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SearchBlogTypeCell.h"

@interface SearchBlogTypeCell ()
{
    UIView   *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewType;
@property (weak, nonatomic) IBOutlet UILabel *lblTypeName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAccessory;

@end

@implementation SearchBlogTypeCell

- (void)awakeFromNib {
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.bounds];
    viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    _imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblTypeName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(ContentTypeVo *)entity
{
    _imgViewType.image = [UIImage imageNamed:entity.strImageName];
    _lblTypeName.text = entity.strName;
}

@end
