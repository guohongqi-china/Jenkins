//
//  ProfileCollectionReusableView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/4/5.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ProfileCollectionReusableView.h"

@interface ProfileCollectionReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *lblTip;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLogo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewH;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end

@implementation ProfileCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.lblTip.textColor = [SkinManage colorNamed:@"NoSearch_Text_Color"];
    self.imgViewLogo.image = [SkinManage imageNamed:@"logo_bottom"];
}

- (void)setData:(UserVo *)userVo
{
    if([userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID] || userVo.bViewFavorite)
    {
        self.viewContainer.hidden = YES;
        self.constraintViewH.constant = 0;
    }
    else
    {
        self.viewContainer.hidden = NO;
        self.constraintViewH.constant = 342;
    }
}

@end
