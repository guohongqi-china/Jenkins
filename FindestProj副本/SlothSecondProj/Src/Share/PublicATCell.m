//
//  PublicATCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PublicATCell.h"
#import "UserVo.h"
#import "UIIMageView+WebCache.h"
#import "UIViewExt.h"

@interface PublicATCell ()
{
    UIView *viewSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *table_accessoryImageView;

@end

@implementation PublicATCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.table_accessoryImageView.image = [SkinManage imageNamed:@"table_accessory"];
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.imgViewIcon.image = [SkinManage imageNamed:@"at_icon"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(NSMutableArray *)entity
{
    //clear subview
    for (UIView *viewSub in self.viewContainer.subviews)
    {
        if ([viewSub isKindOfClass:[UIImageView class]])
        {
            [viewSub removeFromSuperview];
        }
    }
    
    //add subview
    UIImageView *imgViewLast = nil;
    for (int i=0; i<entity.count && i<10; i++)
    {
        UserVo *userVo = entity[i];
        UIImageView *imgViewHead = [[UIImageView alloc]init];
        imgViewHead.layer.cornerRadius = 5;
        imgViewHead.layer.masksToBounds = YES;
        [imgViewHead sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
        [self.viewContainer addSubview:imgViewHead];
        
        if ( i == 0)
        {
            imgViewHead.frame = CGRectMake(0, 7, 30, 30);
        }
        else if ( i == 5)
        {
            imgViewHead.frame = CGRectMake(0, imgViewLast.bottom + 4, 30, 30);
        }
        else
        {
            imgViewHead.frame = CGRectMake(imgViewLast.right+6, imgViewLast.top, 30, 30);
        }
        imgViewLast = imgViewHead;
    }
    
    if (entity.count > 5)
    {
        self.constraintHeight.constant = 80;
    }
    else
    {
        self.constraintHeight.constant = 46;
    }
}


@end
