//
//  IntegrationViewCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "IntegrationViewCell.h"

@interface IntegrationViewCell ()
{
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAccessory;

@end

@implementation IntegrationViewCell

- (void)awakeFromNib {
    // Initialization code
    
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _imgViewAccessory.image = [SkinManage imageNamed:@"table_accessory"];
    
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    _lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MenuVo *)entity
{
    self.lblTitle.text = entity.strName;
    if ([entity.strID isEqualToString:@"currentIntegration"])
    {
        self.lblValue.text = [NSString stringWithFormat:@"%@ 积分",entity.strRemark];
        self.lblValue.hidden = NO;
    }
    else
    {
        self.lblValue.hidden = YES;
    }
}

@end
