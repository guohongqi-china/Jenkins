//
//  GHQlineView.m
//  Quartz2D
//
//  Created by MacBook on 16/4/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//
#define RGBColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#import "GHQlineView.h"

@implementation GHQlineView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.frame = CGRectMake(0, 0, self.frame.size.width / 2, 30);
        _label.center = CGPointMake(self.frame.size.width / 2 , self.frame.size.width / 2 );
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont boldSystemFontOfSize:15];
        _label.textColor = [UIColor whiteColor];
        [self addSubview:_label];

    }
    return _label;
}
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    self.label.text = [NSString stringWithFormat:@"%.0f%%",progress * 100];
    
    [self setNeedsDisplay];

}
/**
 *  什么时候调用：当你视图第一次显示的时候就会调用
 *  作用：绘图
 *  @param rect = self.bounds
 */

- (void)drawRect:(CGRect)rect{
    //我们在故事版中设置了view的尺寸为250，250，现在打印出他的尺寸看一下

    mainW = self.height > self.width ? self.width : self.height;
    [self drawRound];
    [self xiazaijindutiao];
    
    
    
}
- (void)drawRound{
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //设置圆弧的半径
    CGFloat radius = mainW / 2 - _lineWidth;
    //设置圆弧的圆心
    CGPoint center = CGPointMake(mainW / 2 ,mainW / 2);
    //设置圆弧的开始的角度（弧度制）
    CGFloat startAngle = -M_PI_2;
    //设置圆弧的终止角度
    CGFloat endAngle = -M_PI_2 + 2 * M_PI ;
    //使用UIBezierPath类绘制圆弧
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:startAngle endAngle:endAngle clockwise:YES];
    CGContextAddPath(cef, path.CGPath);
    [RGBColor(150,150,150) setStroke];
    CGContextSetLineWidth(cef, 10);
    //设置线头部分为圆角
    CGContextSetLineCap(cef, kCGLineCapRound);
    //将绘制的圆弧渲染到图层上（即显示出来）
    CGContextStrokePath(cef);

}
- (void)xiazaijindutiao{
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //设置圆弧的半径
    CGFloat radius = mainW / 2 - _lineWidth;
    //设置圆弧的圆心
    CGPoint center = CGPointMake(mainW / 2 ,mainW / 2);
    //设置圆弧的开始的角度（弧度制）
    CGFloat startAngle = -M_PI_2;
    //设置圆弧的终止角度
    NSLog(@"%f",self.progress);
    CGFloat endAngle = -M_PI_2 + 2 * M_PI* _progress ;
    //使用UIBezierPath类绘制圆弧
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:startAngle endAngle:endAngle clockwise:YES];
    CGContextAddPath(cef, path.CGPath);
    [[UIColor whiteColor]setStroke];
    CGContextSetLineWidth(cef, 10);
    //设置线头部分为圆角
    CGContextSetLineCap(cef, kCGLineCapRound);
    //将绘制的圆弧渲染到图层上（即显示出来）
    CGContextStrokePath(cef);

}
//划一条曲线
- (void)drawline3{
    //1、获取上下文
    CGContextRef cef = UIGraphicsGetCurrentContext();
    //2、设置绘图信息（拼接路径）
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startP = CGPointMake(10, 125);
    CGPoint endP = CGPointMake(240, 125);
    CGPoint contrpP = CGPointMake(125,10);
    [path moveToPoint:startP];
    [path addQuadCurveToPoint:endP controlPoint:contrpP];
    
    // 3、把路径点击到上下文（就是把画出的线添加到view上）
    // 直接把uikit的路径装换成coreGraphics，cg开头就能转
    CGContextAddPath(cef, path.CGPath);
    [[UIColor blueColor]setStroke];
    //设置线宽
    CGContextSetLineWidth(cef, 5);
    //设置线头部分为圆角
    CGContextSetLineCap(cef, kCGLineCapRound);

    // 4、把上下文渲染到视图
    // Storke描边
    CGContextStrokePath(cef);


}
-(void)drawline2{
    //1、获取上下文
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //2、设置绘图信息（拼接路径）
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //设置起点
    [path moveToPoint:CGPointMake(10, 125)];
    
    //添加一条线到某个点
    [path addLineToPoint:CGPointMake(230, 125)];
    
    // 3、把路径点击到上下文（就是把画出的线添加到view上）
    // 直接把uikit的路径装换成coreGraphics，cg开头就能转
    CGContextAddPath(cef, path.CGPath);
    [[UIColor grayColor]setStroke];
    
    // 4、把上下文渲染到视图
    // Storke描边
    CGContextStrokePath(cef);

}
//画一条直线
- (void)drawLine{
    //1、获取上下文
    CGContextRef cef = UIGraphicsGetCurrentContext();
    
    //2、设置绘图信息（拼接路径）
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //设置起点
    [path moveToPoint:CGPointMake(10, 10)];
    
    //添加一条线到某个点
    [path addLineToPoint:CGPointMake(125, 125)];
    
    //添加两条不相连的直线
//    //设置起点
//    [path moveToPoint:CGPointMake(10, 125)];
//    
//    //添加一条线到某个点
//    [path addLineToPoint:CGPointMake(230, 125)];
    
    // 3、把路径点击到上下文（就是把画出的线添加到view上）
    // 直接把uikit的路径装换成coreGraphics，cg开头就能转
    CGContextAddPath(cef, path.CGPath);
    
    // 设置绘图状态
    // 设置线宽
    CGContextSetLineWidth(cef, 10);
    //设置线头部分为圆角
    CGContextSetLineCap(cef, kCGLineCapRound);
    [[UIColor redColor] setStroke];//设置线体的颜色
    
    // 4、把上下文渲染到视图
    // Storke描边
    CGContextStrokePath(cef);

}


@end
