//
//  BookingRecordCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "BookingRecordCell.h"

@interface BookingRecordCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTopic;
@property (weak, nonatomic) IBOutlet UILabel *lblRoomName;
@property (weak, nonatomic) IBOutlet UILabel *lblRoomDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceName;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceDesc;

@property (weak, nonatomic) IBOutlet UIButton *deleteTrashBtn;

@property (weak, nonatomic) IBOutlet UIView *specotor;

@end

@implementation BookingRecordCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    self.specotor.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    
    self.lblTime.textColor = [SkinManage colorNamed:@"date_title"];
    self.lblTopic.textColor = [SkinManage colorNamed:@"date_text"];
    self.lblRoomName.textColor = [SkinManage colorNamed:@"date_text"];
    self.lblRoomDesc.textColor = [SkinManage colorNamed:@"date_text"];
    self.lblPlaceName.textColor = [SkinManage colorNamed:@"date_text"];
    self.lblPlaceDesc.textColor = [SkinManage colorNamed:@"date_text"];
    
    [self.deleteTrashBtn setImage:[SkinManage imageNamed:@"btn_share_delete"] forState:UIControlStateNormal];
    
    self.specotor.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MeetingBookVo *)entity lastRow:(BOOL)bLast
{
    _entity = entity;
    if (bLast)
    {
        _specotor.hidden = YES;
    }
    else
    {
        _specotor.hidden = NO;
    }
    
    NSString *strDateNow = [Common getDateTimeStrFromDate:[NSDate date] format:@"yyyy-MM-dd"];
    
    NSString *strTimeText = entity.strBookDate;
    if ([strDateNow isEqualToString:entity.strBookDate])
    {
        strTimeText = [NSString stringWithFormat:@"%@ 今天",strTimeText];
        _lblTime.textColor = COLOR(239, 111, 88, 1.0);
    }
    else
    {
        _lblTime.textColor = COLOR(166, 143, 136, 1.0);
    }
    
    if (entity.nMinTimeId < 1200)
    {
        strTimeText = [NSString stringWithFormat:@"%@　上午 %@",strTimeText,entity.strTimeRange];
    }
    else if (entity.nMinTimeId < 1300)
    {
        strTimeText = [NSString stringWithFormat:@"%@　中午 %@",strTimeText,entity.strTimeRange];
    }
    else
    {
        strTimeText = [NSString stringWithFormat:@"%@　下午 %@",strTimeText,entity.strTimeRange];
    }
    _lblTime.text = strTimeText;
    
    _lblTopic.text = entity.strTitle;
    _lblRoomName.text = entity.strRoomName;
    _lblRoomDesc.text = entity.strRoomDesc;
    _lblPlaceName.text = entity.strPlaceName;
    _lblPlaceDesc.text = entity.strPlaceDesc;
}

- (IBAction)buttonAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonClickWithBookingRecordCell:)]) {
        [self.delegate deleteButtonClickWithBookingRecordCell:self];
    }
    
}


@end
