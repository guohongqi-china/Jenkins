//
//  CALayer+XibConfiguration.m
//  yixia
//
//  Created by Allen.Young on 26/3/15.
//  Copyright (c) 2015 yixia. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end