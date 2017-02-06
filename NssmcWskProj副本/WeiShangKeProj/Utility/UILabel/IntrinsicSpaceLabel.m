//
//  IntrinsicSpaceLabel.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/22.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "IntrinsicSpaceLabel.h"

@implementation IntrinsicSpaceLabel

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
    return CGSizeMake(contentSize.width+10, contentSize.height+4);
}

@end
