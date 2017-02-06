//
//  CustomLabel.m
//  TestOpenFlowView
//
//  Created by Sunyan on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StrokeLabel.h"

@implementation StrokeLabel
@synthesize fStrokeLineWidth;
@synthesize colorStroke;
@synthesize rectStroke;

- (void)drawTextInRect:(CGRect)rect 
{
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, fStrokeLineWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    //draw stroke
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = colorStroke;
    [super drawTextInRect:rectStroke];
    
    //draw UILabel Text
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeZero;
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;    
}

@end
