//
//  CommonHeaderView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CommonHeaderView.h"
#import "UserProfileViewController.h"
#import "UIImageView+WebCache.h"

@interface CommonHeaderView ()
{
    __weak UIViewController *viewController;
    BOOL bCanTap;
    
    NSString *_strUserID;
    NSString *_strUserImageURL;
    
    UIImageView *imgViewHead;
}

@end

@implementation CommonHeaderView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero canTap:NO parent:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame canTap:NO parent:nil];
}

- (instancetype)initWithFrame:(CGRect)frame canTap:(BOOL)bTap parent:(UIViewController *)parentController
{
    self = [super initWithFrame:frame];
    if (self)
    {
        bCanTap = bTap;
        viewController = parentController;
        
        //头像（最底层，方便圆环显示）
        imgViewHead = [[UIImageView alloc] initWithFrame:frame];
        imgViewHead.userInteractionEnabled = YES;
        imgViewHead.contentMode = UIViewContentModeScaleAspectFill;
        imgViewHead.clipsToBounds = YES;
        imgViewHead.layer.masksToBounds = YES;
        imgViewHead.layer.cornerRadius = 5;
        [self addSubview:imgViewHead];
        
        UITapGestureRecognizer *headerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderImageView)];
        [imgViewHead addGestureRecognizer:headerViewTap];
    }
    return self;
}

- (void)refreshViewWithImage:(NSString*)strImageURL userID:(NSString *)strUserID
{
    _strUserID = strUserID;
    _strUserImageURL = strImageURL;
    
    [imgViewHead sd_setImageWithURL:[NSURL URLWithString:_strUserImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    imgViewHead.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    imgViewHead.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)tapHeaderImageView
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tapHeaderViewAction:)])
    {
        [self.delegate tapHeaderViewAction:self];
    }
    
    //change by fjz 5.11
//    if (bCanTap)
//    {
//        UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
//        userProfileViewController.strUserID = _strUserID;
//        [viewController.parentViewController.navigationController pushViewController:userProfileViewController animated:YES];
//    }
}



@end
