/*
 Copyright (C) <2012> <Wojciech Czelalski/CzekalskiDev>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#define kRotationDegrees 90                         //CDCircleThumb 分段视图，初始旋转90°【】
#define kInitRotationDegrees (-105)                 //初始逆时针旋转105° 【让8点钟在最上方】

#import "AppDelegate.h"
#import "CDCircle.h"
#import <QuartzCore/QuartzCore.h>
#import "CDCircleGestureRecognizer.h"
#import "CDCircleThumb.h"
#import "CDCircleOverlayView.h"
#import "MeetingSegmentVo.h"
#import "MeetingDialView.h"

@interface CDCircle ()
{
    UIImageView *imgViewMeetingScale;
    CGPoint ptCenter;
    
    NSMutableArray *aryReserveLayer;        //已预订圆环的层
    
    //不可预订状态//////////////////////////////////////////////////
    CAShapeLayer *invalidLayer;
}

@end

@implementation CDCircle
@synthesize circle, recognizer, path, numberOfSegments, separatorStyle, separatorColor, ringWidth, circleColor, thumbs, overlay;
@synthesize inertiaeffect;

//Need to add property "NSInteger numberOfThumbs" and add this property to initializer definition, and property "CGFloat ringWidth equal to circle radius - path radius.
//Circle radius is equal to rect / 2 , path radius is equal to rect1/2.

- (id)initWithFrame:(CGRect)frame numberOfSegments:(NSInteger)nSegments ringWidth:(CGFloat)width
{
    self = [super initWithFrame:frame];
    if (self)
    {
        aryReserveLayer = [NSMutableArray array];
        
        imgViewMeetingScale = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        imgViewMeetingScale.image = [SkinManage imageNamed:@"meeting_scale_img"];
        [self addSubview:imgViewMeetingScale];
        
        ptCenter = CGPointMake(imgViewMeetingScale.frame.size.width/2, imgViewMeetingScale.frame.size.height/2);
        
        //惯性属性
        self.inertiaeffect = YES;
        
        //圆盘转动手势
        self.recognizer = [[CDCircleGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:self.recognizer];
        
        self.opaque = NO;
        
        //分段的数量
        self.numberOfSegments = nSegments;
        
        self.separatorStyle = CDCircleThumbsSeparatorBasic;
        
        //环的宽带
        self.ringWidth = width;
        
        self.circleColor = [UIColor clearColor];
        
        //添加每一段的视图
        CGRect rect1 = CGRectMake(0, 0, CGRectGetHeight(frame) - (2*ringWidth), CGRectGetWidth(frame) - (2*ringWidth));
        self.thumbs = [NSMutableArray array];
        
        NSInteger nFirstTime = 800; //初始从8点开始
        for (int i = 0; i < self.numberOfSegments; i++)
        {
            CDCircleThumb * thumb = [[CDCircleThumb alloc] initWithShortCircleRadius:rect1.size.height/2 longRadius:frame.size.height/2 numberOfSegments:self.numberOfSegments];
            if(i % 2 == 0)
            {
                thumb.numTime = [NSNumber numberWithInteger:nFirstTime + (i/2) * 100];
            }
            else
            {
                thumb.numTime = [NSNumber numberWithInteger:nFirstTime + (i/2) * 100 + 30];
            }
            
            [self.thumbs addObject:thumb];
        }
        
        //设置初始化transform
        self.transformInitValue = self.transform;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState (ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    
    [self.circleColor setFill];
    circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    [circle closePath];
    [circle fill];
    
    CGRect rect1 = CGRectMake(0, 0, CGRectGetHeight(rect) - (2*ringWidth), CGRectGetWidth(rect) - (2*ringWidth));
    rect1.origin.x = rect.size.width / 2  - rect1.size.width / 2;
    rect1.origin.y = rect.size.height / 2  - rect1.size.height / 2;
    
    path = [UIBezierPath bezierPathWithOvalInRect:rect1];
    [self.circleColor setFill];
    [path fill];
    CGContextRestoreGState(ctx);
    
    //Drawing Thumbs
    CGFloat fNumberOfSegments = self.numberOfSegments;
    CGFloat perSectionDegrees = 360.f / fNumberOfSegments + kInitRotationDegrees;  //初始角度设置
    CGFloat totalRotation = 360.f / fNumberOfSegments;      //每旋转一次的角度15(每一个分段的角度 = 15度)
    CGPoint centerPoint = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    //添加分段视图到圆盘上面(初始第0个segment为8点)
    for (int i = 0; i < self.numberOfSegments; i++)
    {
        CDCircleThumb * thumb = [self.thumbs objectAtIndex:i];
        thumb.tag = i;
        
        //degreesToRadians:角度转弧度
        CGFloat radius = rect1.size.height/2 + ((rect.size.height/2 - rect1.size.height/2)/2) - thumb.yydifference;
        CGFloat x = centerPoint.x + (radius * cos(degreesToRadians(perSectionDegrees)));
        CGFloat yi = centerPoint.y + (radius * sin(degreesToRadians(perSectionDegrees)));
        [thumb setTransform:CGAffineTransformMakeRotation(degreesToRadians((perSectionDegrees + kRotationDegrees)))];
        
        //set position of the thumb
        thumb.layer.position = CGPointMake(x, yi);
        perSectionDegrees += totalRotation;
        [self addSubview:thumb];
    }
    
    //滚动到当前档位
    [self setSegmentIndex:[self getCurrentTimeIndex]];
}

//获取当前时间挡位(如果是今天则滚动到有效位置，其他日期滚动到8点)
- (NSInteger)getCurrentTimeIndex
{
    NSInteger nCurrIndex = 0;
    
    NSDate *dateCurrent = [NSDate date];
    NSString *strDate = [Common getDateTimeStrFromDate:dateCurrent format:@"yyyy-MM-dd"];
    if ([self.strBookDate isEqualToString:strDate]) //如果为今天则跳转到有效时间
    {
        //计算当前时间挡位,8点钟为数组第0为，依次递推
        NSDate *dateStart = [Common getDateFromString:strDate format:@"yyyy-MM-dd"];
        NSTimeInterval timeInterval = [dateCurrent timeIntervalSinceDate:dateStart];
        CGFloat fDelta = (timeInterval-8*3600)/1800;//减去8个小时，然后除以半个小时
        if (fDelta < 0)
        {
            //未到8点
            nCurrIndex = 0;
        }
        else if (fDelta > 20)
        {
            //超过18点
            nCurrIndex = 20;
        }
        else
        {
            nCurrIndex = ceil(fDelta);
        }
    }
    
    return nCurrIndex;
}

//获取指定档位的角度（0~2PI）
- (double)getCircleCurrentAngle:(CGAffineTransform)transformStart
{
    //注：当前Segment的frame以及transform都不变，因为变得是整个容器，Segment相对于容器不变
    //起始角度
    double fStartX = transformStart.a;
    double fStartY = transformStart.b;
    double fStartAngle = atan2(fStartY,fStartX);
    if (fStartAngle<0)
    {
        fStartAngle = fStartAngle*(-1);
    }
    else
    {
        fStartAngle = M_PI+M_PI-fStartAngle;
    }
    
    //结束角度
    CGAffineTransform transformEnd = self.transform;
    double fEndX = transformEnd.a;
    double fEndY = transformEnd.b;
    double fEndAngle = atan2(fEndY,fEndX);
    if (fEndAngle<0)
    {
        fEndAngle = fEndAngle*(-1);
    }
    else
    {
        fEndAngle = M_PI+M_PI-fEndAngle;
    }
    
    //计算角度差
    double fDeltaAngle = fEndAngle - fStartAngle;
    if (fDeltaAngle < 0)
    {
        fDeltaAngle += 2*M_PI;  //当小于0时，加上2π，转为正值
    }
    
    return fDeltaAngle;
}

//重置表盘
- (void)resetCircleView
{
    [self setSegmentIndex:[self getCurrentTimeIndex]];
}

//移动到指定段位
- (void)setSegmentIndex:(NSInteger)nIndex
{
    CDCircleThumb * thumb = [self.thumbs objectAtIndex:nIndex];
    [thumb.iconView setIsSelected:YES];
    self.recognizer.currentThumb = thumb;
    
    CGFloat totalRotation = 360.f / self.numberOfSegments;      //每旋转一次的角度15(每一个分段的角度 = 15度)
    CGFloat deltaAngle= (-1) * nIndex * degreesToRadians(totalRotation);
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setTransform:CGAffineTransformRotate(self.transformInitValue,deltaAngle)];
    }];
    
    [self.delegate circle:self didMoveToSegment:nIndex thumb:thumb];
}

//获取指定范围内的时间数组
- (NSMutableArray *)getTimeSegmentArrayByRange:(NSInteger)nStart end:(NSInteger)nEnd
{
    NSMutableArray *aryTime = [NSMutableArray array];
    for (NSInteger i = nStart; i < nEnd; i++)
    {
        CDCircleThumb * thumb = [self.thumbs objectAtIndex:i];
        [aryTime addObject:thumb.numTime];
    }
    return aryTime;
}

//触摸手势响应
-(void)tapped:(CDCircleGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.ended == NO)
    {
        CGPoint point = [gestureRecognizer locationInView:self];
        //超过环形刻度则不处理
        if ([path containsPoint:point] == NO)
        {
            //调用代理
            [self.delegate circle:self didRotateAngle:gestureRecognizer.rotation];
        }
    }
}

//绘制已预订圆环进度
- (void)drawReservedCircle:(NSMutableArray*)arySegment
{
    //remove old ReservedCircle
    for (CAShapeLayer *layerReserved in aryReserveLayer)
    {
        [layerReserved removeFromSuperlayer];
    }
    [aryReserveLayer removeAllObjects];
    
    //create new arc
    for (MeetingSegmentVo *segmentVo in arySegment)
    {
        if(segmentVo.nReserveState == 1 || segmentVo.nReserveState == 3)//被已预订才绘制或者时间段过期
        {
            CAShapeLayer *layerReserved = [[CAShapeLayer alloc]init];
            layerReserved.fillColor = nil;
            layerReserved.strokeColor = COLOR(208, 197, 193, 1.0).CGColor;
            layerReserved.lineCap = kCALineCapRound;
            layerReserved.lineWidth = 11;
            layerReserved.frame = self.bounds;
            [self.layer addSublayer:layerReserved];
            
            CGFloat fDelta = degreesToRadians(15);
            CGFloat fStartAngle = -M_PI_2 + segmentVo.nIndex*fDelta;    //初始8点是从负90°开始的
            CGFloat fEndAngle = fStartAngle+fDelta;
            
            UIBezierPath *invalidPath = [UIBezierPath bezierPathWithArcCenter:ptCenter radius:123.5 startAngle:fStartAngle endAngle:fEndAngle clockwise:YES];
            invalidPath.lineCapStyle = kCGLineCapRound;
            invalidPath.lineJoinStyle = kCGLineJoinBevel;
            
            layerReserved.path = invalidPath.CGPath;
        }
    }
}

//获得当前状态可转动的最大角度(YES:顺时针，NO:逆时针)
- (CGFloat)getCouldRotateMaxAngle:(BOOL)bClockwise
{
    CGFloat fAngle = 0;
    
    MeetingDialView *dialView = (MeetingDialView *)self.delegate;
    NSMutableArray *arySegment = dialView.arySegmentState;
    
    //获取当前的角度
    CGFloat fCurrAngle = [self getCircleCurrentAngle:self.transformInitValue];
    if (dialView.nStatus == 1)
    {
        //未开始 不能滚动到 18~8这个区间（0°~300°之间）
        if(bClockwise)
        {
            //顺时针
            NSInteger nFloorSegment = floor(fCurrAngle/degreesToRadians(15)); //上取整
            if (nFloorSegment >= 0)
            {
                fAngle = fCurrAngle;
            }
        }
        else
        {
            //逆时针
            NSInteger nCeilSegment = ceil(fCurrAngle/degreesToRadians(15)); //上取整
            if (nCeilSegment <= 20)
            {
                fAngle = -1*(degreesToRadians(300)-fCurrAngle);
            }
        }
    }
    else if (dialView.nStatus == 2)
    {
        //已开始
        if(bClockwise)
        {
            //顺时针,已经开始后，顺时针不能超过转动角度
            MeetingDialView *dialView = (MeetingDialView *)self.delegate;
            fAngle = dialView.fRotateAngle;
        }
        else
        {
            //逆时针
            NSInteger nCeilSegment = ceil(fCurrAngle/degreesToRadians(15)); //上取整
            NSInteger nIndex = nCeilSegment;
            for (NSInteger i=nCeilSegment; i<arySegment.count; i++)
            {
                MeetingSegmentVo *segmentVo = arySegment[i];
                if (segmentVo.nReserveState != 0)
                {
                    nIndex = i;
                    break;
                }
            }
            
            if(nIndex>nCeilSegment)
            {
                fAngle = -1*(nIndex*degreesToRadians(15)-fCurrAngle);
            }
        }
    }
    
    if(fabs(fAngle) > degreesToRadians(300+5))
    {
        fAngle = 0;
    }
    return fAngle;
}

@end
