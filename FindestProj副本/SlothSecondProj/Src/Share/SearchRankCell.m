//
//  SearchRankCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/26.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SearchRankCell.h"

@interface SearchRankCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *lblNum;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimes;

@end

@implementation SearchRankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblTimes.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(TagVo *)entity index:(NSInteger)nRow
{
    self.lblNum.text = [NSString stringWithFormat:@"%li",(long)(nRow+1)];
    if ((nRow+1) <= 3)
    {
        self.lblNum.textColor = COLOR(239, 111, 88, 1.0);
    }
    else
    {
        self.lblNum.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];// COLOR(166, 143, 136, 1.0);
    }
    
    self.lblTitle.text = entity.strTagName;
    self.lblTimes.text = [NSString stringWithFormat:@"%li",(long)entity.nFrequency];
}

@end
