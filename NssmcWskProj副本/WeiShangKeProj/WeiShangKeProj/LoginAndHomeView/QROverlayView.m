//
//  QROverlayView.h
//
//  Created by Allen on 15/12/04.
//  Copyright (c) 2015年 All rights reserved.
//

#import "QROverlayView.h"
#import "UIViewExt.h"

#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)           //计算一像素对应到程序中的Point
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)     //计算绘制奇数像素的偏移位置

@implementation QROverlayView
{
    UIImageView *imgViewLine;//闪动的线
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        //注册进入后台、进入前台模式通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    //call when frame change and addSubview
    [super layoutSubviews];
    
    imgViewLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 12)];
    imgViewLine.image = [UIImage imageNamed:@"ff_QRCodeScanLine"];
    imgViewLine.center = CGPointMake(self.frame.size.width/2, self.rcScanArea.origin.y);
    [self addSubview:imgViewLine];
    
    [self startLineAnimation];
    
    //增加4个角，（由于一像素对齐问题,不方便绘制4个角）
    [self addCornerWithImageView:self.rcScanArea];
    
    UILabel *lblTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
    lblTip.center = CGPointMake(self.frame.size.width/2, self.rcScanArea.origin.y + self.rcScanArea.size.height + 35);
    lblTip.textColor = COLOR(175, 175, 175, 1.0);
    [lblTip setTextAlignment:NSTextAlignmentCenter];
    [lblTip setFont:[UIFont systemFontOfSize:13]];
    [lblTip setText:@"将二维码放入框内，即可自动扫描"];
    [lblTip setBackgroundColor:[UIColor clearColor]];
    [self addSubview:lblTip];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //绘制整个二维码扫描界面半透明背景
    CGRect rcView = CGRectMake(0, 0, self.width, self.height);
    [self addScreenFillRect:ctx rect:rcView];
    
    //清空中间扫码区域
    CGRect clearDrawRect = self.rcScanArea;
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    //绘制白色矩形框
    [self addWhiteRect:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 0,0,0,0.5);
    CGContextFillRect(ctx, rect);
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect
{
    //绘制一像素矩形框
    CGRect rectWhite = CGRectMake(rect.origin.x-SINGLE_LINE_ADJUST_OFFSET, rect.origin.y-SINGLE_LINE_ADJUST_OFFSET, rect.size.width, rect.size.height);
    
    CGContextSetLineWidth(ctx,SINGLE_LINE_WIDTH);//线条宽度
    CGContextStrokeRect(ctx, rectWhite);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);//白色
    CGContextAddRect(ctx, rectWhite);//创建一个矩形path
    CGContextStrokePath(ctx);//填充矩形条
}

- (void)addCornerWithImageView:(CGRect)rect
{
    //左上角
    UIImageView *imgViewLeftTop = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ScanQR1"]];
    imgViewLeftTop.frame = CGRectMake(rect.origin.x-0.5, rect.origin.y-0.5, 16, 16);
    [self addSubview:imgViewLeftTop];
    
    //左下角
    UIImageView *imgViewLeftBottom = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ScanQR3"]];
    imgViewLeftBottom.frame = CGRectMake(rect.origin.x-0.5, rect.origin.y+rect.size.height-16, 16, 16);
    [self addSubview:imgViewLeftBottom];
    
    //右上角
    UIImageView *imgViewRightTop = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ScanQR2"]];
    imgViewRightTop.frame = CGRectMake(rect.origin.x+rect.size.width-16, rect.origin.y-0.5, 16, 16);
    [self addSubview:imgViewRightTop];
    
    //右下角
    UIImageView *imgViewRightBottom = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ScanQR4"]];
    imgViewRightBottom.frame = CGRectMake(rect.origin.x+rect.size.width-16, rect.origin.y+rect.size.height-16, 16, 16);
    [self addSubview:imgViewRightBottom];
}

- (void)startLineAnimation
{
    imgViewLine.center = CGPointMake(self.frame.size.width/2, self.rcScanArea.origin.y);
    [UIView animateWithDuration:2.5 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionRepeat animations:^{
        CGRect rect = imgViewLine.frame;
        rect.origin.y += self.rcScanArea.size.height;
        imgViewLine.frame = rect;
    }completion:^(BOOL complite){}];
}

- (void)applicationDidEnterBackground
{
    [self.layer removeAllAnimations];
    imgViewLine.hidden = YES;
}

- (void)applicationDidBecomeActive
{
    imgViewLine.hidden = NO;
    [self startLineAnimation];
}

@end
