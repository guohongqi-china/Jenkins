//
//  AnimationImage.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AnimationImage.h"

@implementation AnimationImage

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
//    [self layoutIfNeeded];
}

@end
