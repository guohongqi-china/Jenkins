//
//  TipNumLabel.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/31.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "TipNumLabel.h"

@implementation TipNumLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGSize)intrinsicContentSize
{
    CGSize contentSize = [super intrinsicContentSize];
    return CGSizeMake(contentSize.width+5, contentSize.height+5);
}

@end
