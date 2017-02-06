//
//  ActivityHistoryCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityHistoryCell.h"
#import "UIImageView+WebCache.h"
#import "ShareDetailViewController.h"
#import "ActivityHomeViewController.h"

@interface ActivityHistoryCell ()
{
    NSMutableArray *aryActivity;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPosterFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleFirst;

@property (weak, nonatomic) IBOutlet UIView *viewSecond;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPosterSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleSecond;

@property (weak, nonatomic) IBOutlet UIView *viewThird;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPosterThird;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleThird;

@end

@implementation ActivityHistoryCell

- (void)awakeFromNib {
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    // Initialization code
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
    [_imgViewPosterFirst addGestureRecognizer:tapGesture1];
    _imgViewPosterFirst.tag = 1000;
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
    [_imgViewPosterSecond addGestureRecognizer:tapGesture2];
    _imgViewPosterSecond.tag = 1001;
    
    UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
    [_imgViewPosterThird addGestureRecognizer:tapGesture3];
    _imgViewPosterThird.tag = 1002;
    
    
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.viewFirst.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewSecond.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewThird.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.lblTitleFirst.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblTitleSecond.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblTitleThird.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(NSMutableArray *)entity
{
    aryActivity = entity;
    
    if (entity.count > 0)
    {
        BlogVo *blogVo = entity[0];
        [self.imgViewPosterFirst sd_setImageWithURL:[NSURL URLWithString:blogVo.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
        self.lblTitleFirst.text = blogVo.strTitle;
        _viewFirst.hidden = NO;
    }
    else
    {
        _viewFirst.hidden = YES;
    }
    
    
    if (entity.count > 1)
    {
        BlogVo *blogVo = entity[1];
        [self.imgViewPosterSecond sd_setImageWithURL:[NSURL URLWithString:blogVo.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
        self.lblTitleSecond.text = blogVo.strTitle;
        _viewSecond.hidden = NO;
    }
    else
    {
        _viewSecond.hidden = YES;
    }
    
    
    if (entity.count > 2)
    {
        BlogVo *blogVo = entity[2];
        [self.imgViewPosterThird sd_setImageWithURL:[NSURL URLWithString:blogVo.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
        self.lblTitleThird.text = blogVo.strTitle;
        _viewThird.hidden = NO;
    }
    else
    {
        _viewThird.hidden = YES;
    }
}

- (void)tapImageAction:(UITapGestureRecognizer *)gesture
{
    NSInteger nIndex = gesture.view.tag-1000;
    
    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    BlogVo *blog = aryActivity[nIndex];
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    [self.parentController.navigationController pushViewController:shareDetailViewController animated:YES];
}

@end
