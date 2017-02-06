//
//  IntegrationDetailCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "IntegrationDetailCell.h"

@interface IntegrationDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblIntegral;
@property(nonatomic , strong)UIView *viewSelected;


@end

@implementation IntegrationDetailCell

- (void)awakeFromNib {
    // Initialization code
    //    self.viewSelected = [[UIView alloc] initWithFrame:self.frame];
    //    self.viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    //    self.selectedBackgroundView = self.viewSelected;
    
    self.lblIntegral.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblType.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblDateTime.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(IntegrationDetailVo*)entity row:(NSInteger)nRow
{
    if(nRow%2 == 0)
    {
        //        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    }
    else
    {
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    }
    
    self.lblTitle.text = entity.strTitle;
    self.lblDateTime.text = [Common getDateTimeStrStyle2:entity.strDateTime andFormatStr:@"yyyy-MM-dd HH:mm:ss"];
    self.lblType.text = entity.strIntegralTypeName;
    
    if (entity.fNum > 0)
    {
        self.lblIntegral.textColor = COLOR(239, 111, 88, 1.0);
        self.lblIntegral.text = [NSString stringWithFormat:@"+ %g",entity.fNum];
    }
    else
    {
        self.lblIntegral.textColor = COLOR(121, 207, 25, 1.0);
        self.lblIntegral.text = [NSString stringWithFormat:@"- %g",fabs(entity.fNum)];
    }
}

@end
