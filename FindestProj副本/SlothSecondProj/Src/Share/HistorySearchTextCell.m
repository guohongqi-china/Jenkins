//
//  HistorySearchTextCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "HistorySearchTextCell.h"
#import "MainSearchViewController.h"

@interface HistorySearchTextCell ()
{
    HistorySearchVo *searchRecordVo;
    UIView   *viewSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *lblSearchText;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end

@implementation HistorySearchTextCell

- (void)awakeFromNib {
    // Initialization code
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblSearchText.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.imgViewIcon.image = [SkinManage imageNamed:@"history_icon"];
    [self.btnDelete setImage:[SkinManage imageNamed:@"history_delete"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(HistorySearchVo *)entity
{
    searchRecordVo = entity;
    if (entity.nColType == 0)
    {
        _lblSearchText.text = entity.strText;
        _lblSearchText.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        _lblSearchText.textAlignment = NSTextAlignmentLeft;
        _imgViewIcon.hidden = NO;
        _btnDelete.hidden = NO;
    }
    else
    {
        if (entity.nColType == 2)
        {
            _lblSearchText.text = @"全部搜索记录";
        }
        else
        {
            _lblSearchText.text = @"清除搜索记录";
        }
        
        _lblSearchText.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        _lblSearchText.textAlignment = NSTextAlignmentCenter;
        _imgViewIcon.hidden = YES;
        _btnDelete.hidden = YES;
    }
}

- (IBAction)buttonAction:(id)sender
{
    [self.mainSearchViewController deleteSearchRecordByID:searchRecordVo.nID];
}

@end
