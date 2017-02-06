//
//  MenuMessageCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/31.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "MenuMessageCell.h"
#import "TipNumLabel.h"

@interface MenuMessageCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet TipNumLabel *lblTipNum;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAccessory;
@end

@implementation MenuMessageCell
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}
- (void)awakeFromNib {
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(NotifyTypeVo *)entity
{
    //BK
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
    
    //消息停用提醒功能
    if (entity.notifyMainType == 15 || entity.strNotifyNum.length == 0 || [entity.strNotifyNum isEqualToString:@"0"])
    {
        _lblTipNum.hidden = YES;
    }
    else
    {
        _lblTipNum.text = entity.strNotifyNum;
        _lblTipNum.hidden = NO;
    }
    _imgViewIcon.image = [SkinManage imageNamed:entity.strNoticeImage];
    
    _lblName.text = entity.strNotifyTypeName;
    _lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}
- (void)refreshSkin
{
    [UIView animateWithDuration:0.3 animations:^{
        viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
        self.selectedBackgroundView = viewSelected;
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        _imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
    } completion:^(BOOL finished) {
        //        [self.tableViewMenu reloadData];
    }];
}
@end
