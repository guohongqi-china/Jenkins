//
//  CustomHeaderView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/15/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "CustomHeaderView.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"


@interface CustomHeaderView()

@end

@implementation CustomHeaderView

//fRate:直径与边框的比率 strSuffix:边框的后缀名
- (id)initWithRate:(CGFloat)fRate andSuffix:(NSString*)strSuffix
{
    self = [super init];
    if (self)
    {
        self.fRate = fRate;
        self.strSuffix = strSuffix;
        
        //头像（最底层，方便圆环显示）
        self.imgViewHead = [[UIImageView alloc] init];
        self.imgViewHead.userInteractionEnabled = YES;
        self.imgViewHead.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imgViewHead];
        
        //头像圆环
        self.imgViewHeadBK = [[UIImageView alloc] init];
        self.imgViewHeadBK.userInteractionEnabled = YES;
        [self addSubview:self.imgViewHeadBK];
        
        UITapGestureRecognizer *headerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderImageView)];
        [self.imgViewHeadBK addGestureRecognizer:headerViewTap];
        
        //徽章
        self.imgViewBadge = [[UIImageView alloc] init];
        [self addSubview:self.imgViewBadge];
    }
    return self;
}

- (void)refreshView:(UserVo*)userVo andFrame:(CGRect)rect
{
    self.m_userVo = userVo;
    self.frame = rect;
    
    //头像圆环
    self.imgViewHeadBK.frame = CGRectMake(0, 0, self.width, self.height);
    [self.imgViewHeadBK.layer setBorderWidth:0];
    [self.imgViewHeadBK.layer setMasksToBounds:YES];
    self.imgViewHeadBK.image = [BusinessCommon getHeaderBKImageByIntegral:userVo.fIntegrationCount andSuffix:self.strSuffix];
    
    //头像（最底层，方便圆环显示）
    self.imgViewHead.frame = CGRectMake(0, 0,self.imgViewHeadBK.width-self.imgViewHeadBK.width/(self.fRate/2), self.imgViewHeadBK.height-self.imgViewHeadBK.width/(self.fRate/2));
    self.imgViewHead.center = self.imgViewHeadBK.center;//与背景一样的center
    [self.imgViewHead.layer setBorderWidth:0];
    [self.imgViewHead.layer setMasksToBounds:YES];
    
    UIImage *phImageName = [UIImage imageNamed:@"default_m"];
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:phImageName];
    
    //徽章
    if ([self.strSuffix isEqualToString:@"_big"])
    {
        //大图徽章小一点
        self.imgViewBadge.frame = CGRectMake(self.imgViewHeadBK.width/5*3.55, self.imgViewHeadBK.height/5*3.55, self.imgViewHeadBK.width/3.5, self.imgViewHeadBK.height/3.5);
    }
    else
    {
        self.imgViewBadge.frame = CGRectMake(self.imgViewHeadBK.width/5*3.3, self.imgViewHeadBK.height/5*3.3, self.imgViewHeadBK.width/2.8, self.imgViewHeadBK.height/2.8);
    }
    
    self.imgViewBadge.image = [BusinessCommon getBadgeImage:userVo.nBadge];
    
    //圆形头像
    [self.imgViewHeadBK.layer setCornerRadius:self.imgViewHeadBK.width/2];
    [self.imgViewHead.layer setCornerRadius:self.imgViewHead.width/2];
}

- (void)tapHeaderImageView
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tapHeaderViewAction:)])
    {
        [self.delegate tapHeaderViewAction:self];
    }
}

@end
