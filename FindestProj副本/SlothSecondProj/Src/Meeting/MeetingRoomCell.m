//
//  MeetingRoomCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingRoomCell.h"

@interface MeetingRoomCell ()
{
    
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAccessory;
@property (weak, nonatomic) IBOutlet UILabel *lblRoomName;
@property (weak, nonatomic) IBOutlet UILabel *lblRoomDesc;

@end

@implementation MeetingRoomCell

- (void)awakeFromNib {
    // Initialization code
    
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    self.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    
    _lblRoomName.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    _lblRoomDesc.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    
    _imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MeetingRoomVo *)entity
{
    _lblRoomName.text = entity.strName;
    _lblRoomDesc.text = entity.strDesc;
}

@end
