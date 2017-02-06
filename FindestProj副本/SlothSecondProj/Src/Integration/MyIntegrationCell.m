//
//  MyIntegrationCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MyIntegrationCell.h"

@interface MyIntegrationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;

@end

@implementation MyIntegrationCell

- (void)awakeFromNib {
    // Initialization code
    _lblName.textColor = [SkinManage colorNamed:@"Integration_Title_Color"];
    _lblValue.textColor = [SkinManage colorNamed:@"Integration_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(MenuVo *)entity row:(NSInteger)nRow
{
    if(nRow%2 == 0)
    {
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    }
    else
    {
        self.contentView.backgroundColor = [SkinManage colorNamed:@"IntegrationCell_BK"];
    }
    
    _imgViewIcon.image = [UIImage imageNamed:entity.strImageName];
    _lblName.text = entity.strName;
    _lblValue.text = entity.strRemark;
}

@end
