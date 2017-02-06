//
//  CommonTipNumView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-4.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "CommonTipNumView.h"

@implementation CommonTipNumView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = NO;
        
        self.imgViewNotice = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"tabbar_badge"] stretchableImageWithLeftCapWidth:9 topCapHeight:0]];
        self.imgViewNotice.frame = CGRectZero;
        [self addSubview:self.imgViewNotice];
        
        self.lblNoticeNum = [[UILabel alloc]initWithFrame:CGRectZero];
        self.lblNoticeNum.font = [UIFont fontWithName:APP_FONT_NAME size:15];
        self.lblNoticeNum.textColor = [UIColor whiteColor];
        self.lblNoticeNum.textAlignment = NSTextAlignmentCenter;
        self.lblNoticeNum.backgroundColor = [UIColor clearColor];
        [self addSubview:self.lblNoticeNum];
    }
    return self;
}

- (void)updateTipNum:(NSInteger)nTipNum
{
    NSString *strCount = @"";
    if (nTipNum>99)
    {
        strCount = @"99+";
    }
    else
    {
        strCount = [NSString stringWithFormat:@"%li",(long)nTipNum];
    }
    
    CGSize sizeLbl = [Common getStringSize:strCount font:[UIFont fontWithName:APP_FONT_NAME size:15] bound:CGSizeMake(CGFLOAT_MAX, 18) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat fWidth = 18;
    if (sizeLbl.width > fWidth || nTipNum >= 10)
    {
        fWidth = sizeLbl.width + 10;
    }
    
    if (nTipNum == 0)
    {
        self.imgViewNotice.frame = CGRectZero;
    }
    else
    {
        self.imgViewNotice.frame = CGRectMake(0, 0, fWidth, 18);
    }
    
    self.lblNoticeNum.text = strCount;
    self.lblNoticeNum.frame = CGRectMake(0, 0, self.imgViewNotice.frame.size.width, self.imgViewNotice.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.imgViewNotice.frame.size.width, self.imgViewNotice.frame.size.height);
}

@end
