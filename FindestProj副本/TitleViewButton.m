//
//  TitleViewButton.m
//  FindestProj
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 visionet. All rights reserved.
//
#import "UIView+Extension.h"
#import "TitleViewButton.h"

@implementation TitleViewButton

- (instancetype)initWithTitle:(NSString *)title normalImage:(NSString *)normalImage seletedImage:(NSString *)seletedImage{
    if (self = [super init]) {
        [self setImage:[UIImage imageNamed:normalImage] forState:(UIControlStateNormal)];
        [self setImage:[UIImage imageNamed:seletedImage] forState:(UIControlStateSelected)];
        [self setTitle:title forState:(UIControlStateNormal)];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.x = 0;
    self.imageView.x = self.titleLabel.width;
}



@end
