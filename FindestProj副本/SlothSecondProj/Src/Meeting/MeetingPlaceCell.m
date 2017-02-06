//
//  MeetingPlaceCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingPlaceCell.h"

@interface MeetingPlaceCell ()
{
    
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceName;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceDesc;

@end

@implementation MeetingPlaceCell

- (void)awakeFromNib {
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    
    _lblPlaceName.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    _lblPlaceDesc.textColor = [SkinManage colorNamed:@"meeting_place_color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MeetingPlaceVo *)entity
{
    if(entity.bCheck)
    {
        _imgViewCheck.image = [UIImage imageNamed:@"list_selected"];
    }
    else
    {
        _imgViewCheck.image = [SkinManage imageNamed:@"list_unselected"];
    }
    
    _lblPlaceName.text = entity.strName;
    _lblPlaceDesc.text = entity.strDesc;
}

@end
