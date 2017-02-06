//
//  MeetingBookDetailCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingBookDetailCell.h"

@interface MeetingBookDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (weak, nonatomic) IBOutlet UIView *containsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@end

@implementation MeetingBookDetailCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.containsView.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    _lblTitle.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    _lblContent.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    _lblDetail.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(KeyValueVo *)entity
{
    _lblTitle.text = entity.strKey;
    
    _lblContent.text = entity.strValue;
    if ([entity.strKey isEqualToString:@"会议时间"])
    {
        _lblContent.textColor = COLOR(239, 111, 88, 1.0);
    }
    else
    {
        _lblContent.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    }
    
    if (entity.strRemark.length > 0 )
    {
        _lblDetail.text = entity.strRemark;
        _lblDetail.hidden = NO;
        
        _constraintBottom.constant = 5 + [_lblDetail sizeThatFits:CGSizeMake(kScreenWidth-44, MAXFLOAT)].height + 9;
    }
    else
    {
        _lblDetail.hidden = YES;
        _constraintBottom.constant = 9;
    }
}

@end
