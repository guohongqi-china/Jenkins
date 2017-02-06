//
//  NotifyListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "NotifyListCell.h"
#import "UIImageView+WebCache.h"

@interface NotifyListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewRead;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

@property (weak, nonatomic) IBOutlet UIImageView *imgViewContent;
@property (weak, nonatomic) IBOutlet UILabel *lblBlogTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewTrailing;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property(nonatomic , strong)UIView *viewSelected;

@end

@implementation NotifyListCell

- (void)awakeFromNib {
    // Initialization code
    self.viewSelected = [[UIView alloc] initWithFrame:self.frame];
    self.viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = self.viewSelected;
    
    //    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.leftView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblDateTime.textColor = [SkinManage colorNamed:@"Notify_Date_Color"];
    self.lblContent.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
    self.lblBlogTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (void)setEntity:(NotifyVo *)entity
{
    self.notifyVo = entity;
    
    [self.imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strUserImgUrl] placeholderImage:[UIImage imageNamed:@"default_m"]];
    self.lblName.text = entity.strFromUserName;
    self.lblDateTime.text = entity.strCreateDate;
    self.lblContent.text = entity.strDescription;
    
    if (self.nNotifyMainType == 12 || self.nNotifyMainType == 14)
    {
        //显示分享标题或图片
        if (entity.strBlogPicture.length > 0)
        {
            self.imgViewContent.hidden = NO;
            self.lblBlogTitle.hidden = YES;
            [self.imgViewContent sd_setImageWithURL:[NSURL URLWithString:entity.strBlogPicture] placeholderImage:[UIImage imageNamed:@"default_image"]];
        }
        else
        {
            self.imgViewContent.hidden = YES;
            self.lblBlogTitle.hidden = NO;
            self.lblBlogTitle.text = entity.strBlogTitle;
        }
    }
    
    //是否已读
    if(entity.nReadState == 1)
    {
        _imgViewRead.hidden = NO;
    }
    else
    {
        _imgViewRead.hidden = YES;
    }
}

@end
