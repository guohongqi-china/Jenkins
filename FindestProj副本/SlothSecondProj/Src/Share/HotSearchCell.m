//
//  HotSearchCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "HotSearchCell.h"
#import "MainSearchViewController.h"
#import "SearchShareViewController.h"

@interface HotSearchCell ()
{
    TagVo *tagFirst;
    TagVo *tagSecond;
}

@property (weak, nonatomic) IBOutlet UILabel *lblSearchItem1;
@property (weak, nonatomic) IBOutlet UILabel *lblSearchItem2;
@property (weak, nonatomic) IBOutlet UIButton *btnTapItem1;
@property (weak, nonatomic) IBOutlet UIButton *btnTapItem2;
@property (weak, nonatomic) IBOutlet UIView *leftView1;
@property (weak, nonatomic) IBOutlet UIView *leftView2;
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@end

@implementation HotSearchCell

- (void)awakeFromNib {
    // Initialization code
    [_btnTapItem1 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateHighlighted];
    [_btnTapItem2 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateHighlighted];
    
    self.leftView1.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.leftView2.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.sepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblSearchItem1.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblSearchItem2.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setFirstData:(TagVo *)firstData second:(TagVo *)secondData;
{
    tagFirst = firstData;
    tagSecond = secondData;
    
    if ([tagFirst.strSearchType isEqualToString:@"essence"])
    {
        _lblSearchItem1.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        _lblSearchItem2.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    }
    else
    {
        _lblSearchItem1.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        _lblSearchItem2.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    }
    
    _lblSearchItem1.text = tagFirst.strTagName;
    _lblSearchItem2.text = tagSecond.strTagName;
}

- (IBAction)buttonAction:(UIButton *)sender
{
    TagVo *tagVo;
    if (sender == _btnTapItem1)
    {
        tagVo = tagFirst;
    }
    else
    {
        tagVo = tagSecond;
    }
    
    SearchShareViewController *searchShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SearchShareViewController"];
    searchShareViewController.strPageType = tagVo.strSearchType;
    searchShareViewController.tagVo = tagVo;
    [self.parentController.navigationController pushViewController:searchShareViewController animated:YES];
}

@end
