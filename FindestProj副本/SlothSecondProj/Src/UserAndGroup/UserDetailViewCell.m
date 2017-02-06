//
//  UserDetailViewCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserDetailViewCell.h"

@interface UserDetailViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UIView *viewSep;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBK;

@end

@implementation UserDetailViewCell

- (void)awakeFromNib {
    // Initialization code
    
    //    self
    _viewSep.backgroundColor = [UIColor colorWithPatternImage: [SkinManage imageNamed:@"user_detail_sep"]];
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    _lblTitle.textColor = [SkinManage colorNamed:@"nameLabel_Color"];
    _lblValue.textColor = [SkinManage colorNamed:@"nameLabel_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(UserEditVo *)entity location:(NSInteger)nLocation
{
    _lblTitle.text = entity.strTitle;
    _lblValue.text = entity.strValue;
    
    if(nLocation == 0)
    {
        _viewSep.hidden = YES;
        _imgViewBK.image = [SkinManage imageNamed:@"user_corner_bk_up"]; // [[UIImage imageNamed:@"user_corner_bk_up"]stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    else if(nLocation == 1)
    {
        _viewSep.hidden = NO;
        _imgViewBK.image = [Common getImageWithColor:[SkinManage colorNamed:@"UserDetailView_middle_color"]];
    }
    else
    {
        _viewSep.hidden = NO;
        _imgViewBK.image = [SkinManage imageNamed:@"user_corner_bk_down"];// [[UIImage imageNamed:@"user_corner_bk_down"]stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
}

@end
