//
//  CircleProgressView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "CircleProgressView.h"
#import "UIViewExt.h"

#define KDGREED(x) ((x)  * M_PI * 2)
#define COLOR(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@interface CircleProgressView ()
{
    CGFloat fLoadPercent; //加载的百分比
}

@end

@implementation CircleProgressView

//50*50
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat fCircleD = self.width-2;
    //Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, TRUE);//抗锯齿
    
    //绘制一个圆
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context,COLOR(190,190,190,1.0).CGColor);         //轨迹颜色
    CGContextAddEllipseInRect(context, CGRectMake(1, 1, fCircleD, fCircleD));
    CGContextDrawPath(context, kCGPathStroke);
    
    //绘制一个扇形
    float startAngle = KDGREED(-0.25);//开始弧度(从12点钟开始)
    float endAngle = KDGREED(fLoadPercent-0.25);//结束弧度
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context,COLOR(207,207,207,1.0).CGColor);
    CGContextMoveToPoint(context, self.width/2, self.height/2);//圆心
    CGContextAddArc(context, self.width/2, self.height/2, (fCircleD-4)/2, startAngle, endAngle, 0);//圆弧（与圆心组成扇形）
    CGContextDrawPath(context, kCGPathFill);
}

- (void)setLoadProgress:(CGFloat)fProgress
{
    fLoadPercent = fProgress;
    [self setNeedsDisplay];
}

@end
