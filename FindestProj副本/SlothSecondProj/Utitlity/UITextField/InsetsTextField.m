//
//  InsetsTextField.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-3.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "InsetsTextField.h"

@implementation InsetsTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//控制 placeHolder 的位置，左右缩 20
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds , 7 , 0 );
}

// 控制文本的位置，左右缩 20
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x+7, bounds.origin.y, bounds.size.width-25, bounds.size.height);
}

@end
