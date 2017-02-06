//
//  DrawRound.m
//  画圆
//
//  Created by MacBook on 16/5/31.
//  Copyright © 2016年 MacBook. All rights reserved.
//
#define selfWith self.frame.size.width / 2
#define selfHeight self.frame.size.height / 2
#define RGBColor(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#import "DrawRound.h"

@implementation DrawRound

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //设置圆弧的半径
    CGFloat radius = selfWith - 4;
    //设置圆弧的圆心
    CGPoint center = CGPointMake(selfWith, selfWith);
    //设置圆弧的开始的角度（弧度制）
    CGFloat startAngle = -M_PI_2;
    //设置圆弧的终止角度
   
    CGFloat endAngle = -M_PI_2 + 2 * M_PI ;
    //使用UIBezierPath类绘制圆弧
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:startAngle endAngle:endAngle clockwise:YES];
    CGContextSetLineWidth(cef, 2);
    CGContextAddPath(cef, path.CGPath);
    [RGBColor(64, 161, 132, 1)setStroke];
    //将绘制的圆弧渲染到图层上（即显示出来）
    CGContextStrokePath(cef);
    
    /**绘制直线*/
    //2、设置绘图信息（拼接路径）
    UIBezierPath *pathLine = [UIBezierPath bezierPath];
    
    //设置起点
    [pathLine moveToPoint:CGPointMake(selfWith, selfWith * 2 - 4)];
    
    //添加一条线到某个点
    [pathLine addLineToPoint:CGPointMake(selfWith, selfHeight * 2 )];
    // 3、把路径点击到上下文（就是把画出的线添加到view上）
    // 直接把uikit的路径装换成coreGraphics，cg开头就能转
    CGContextAddPath(cef, pathLine.CGPath);
    
    // 设置绘图状态
    // 设置线宽
    CGContextSetLineWidth(cef, 2);
    //设置线头部分为圆角
//    CGContextSetLineCap(cef, kCGLineCapRound);
    [RGBColor(64, 161, 132, 1) setStroke];//设置线体的颜色
    
    // 4、把上下文渲染到视图
    // Storke描边
    CGContextStrokePath(cef);


}

@end
