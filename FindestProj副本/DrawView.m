//
//  DrawView.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "DrawView.h"
#import "UIView+Extension.h"
@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}
/**
 *  什么时候调用：当你视图第一次显示的时候就会调用
 *  作用：绘图
 *  @param rect = self.bounds
 */

- (void)drawRect:(CGRect)rect{
    //我们在故事版中设置了view的尺寸为250，250，现在打印出他的尺寸看一下
    //    NSLog(@"%@",NSStringFromCGRect(rect));
    //
    //    [self drawLine];//画一条直线
    //    [self drawline2];
    //    [self drawline3];
    [self xiazaijindutiao];
    [self drawRoundSmall];
    
    
}
- (void)xiazaijindutiao{
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //设置圆弧的半径
    CGFloat radius = self.width / 2 - 2;
    //设置圆弧的圆心
    CGPoint center = CGPointMake(self.width / 2, self.height / 2);
    //设置圆弧的开始的角度（弧度制）
    CGFloat startAngle = 0;
    //设置圆弧的终止角度
    CGFloat endAngle = 2 * M_PI;
    //使用UIBezierPath类绘制圆弧
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:startAngle endAngle:endAngle clockwise:YES];
    CGContextAddPath(cef, path.CGPath);
    [_lineColor setStroke];//设置线体的颜色

    //将绘制的圆弧渲染到图层上（即显示出来）
    CGContextStrokePath(cef);
}
- (void)drawRoundSmall{
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //设置圆弧的半径
    CGFloat radius = 1;
    //设置圆弧的圆心
    CGPoint center = CGPointMake(self.center.x, self.center.y);
    //设置圆弧的开始的角度（弧度制）
    CGFloat startAngle = 0;
    //设置圆弧的终止角度
    CGFloat endAngle = 2 * M_PI;
    //使用UIBezierPath类绘制圆弧
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:startAngle endAngle:endAngle clockwise:YES];
    CGContextAddPath(cef, path.CGPath);
    [_lineColor setStroke];//设置线体的颜色

    //将绘制的圆弧渲染到图层上（即显示出来）
    CGContextStrokePath(cef);

}



@end
