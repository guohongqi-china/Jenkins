//
//  MeetingDialView.m
//  DialViewProj
//
//  Created by 焱 孙 on 16/1/20.
//  Copyright © 2016年 焱 孙. All rights reserved.
//

#import "MeetingDialView.h"
#import "CDCircle.h"
#import "CDCircleOverlayView.h"
#import <AudioToolbox/AudioServices.h>
#import "Constants+OC.h"
#import "UIViewExt.h"
#import "MeetingSegmentVo.h"
#import "MeetingRoomVo.h"

@interface MeetingDialView () <CDCircleDelegate, CDCircleDataSource>
{
    CDCircle *circleMeeting;    //表盘视图
    UIImageView *imgViewMeetingDial;
    
    
    UIButton *btnStatus;   //控制状态
    
    NSInteger nStartSegment; //起始档位
    NSInteger nEndSegment;  //结束档位
    CGAffineTransform transformStart;       //起始角度
    
    
    CGPoint ptCenter;   //圆环中心点
    CGFloat fBeforeAngle;   //预订之前的旋转角度
    
    CAShapeLayer *progressLayer;
    UIBezierPath *progressPath;
    
    ////////////////////////////////////////////////////
    UILabel *lblStatus; //预订操作的状态
    UILabel *lblTime;   //预订的时间信息
    UILabel *lblTip;    //预订的提示文字
    UILabel *lblTipMore;    //预订的提示文字
    
    //声音//////////////////////////////////////////////////
    NSTimer *_timer;
    NSInteger _nRotateDelta;//计算角度差
    SystemSoundID _soundID;
    CGFloat _fRadians;  //15°的弧度
}

@end

@implementation MeetingDialView

- (void)dealloc
{
    [self closeTimer];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initData];
        [self initView];
    }
    return self;
}

- (void)initData
{
    self.nStatus = 1;
    nStartSegment = 0;
    nEndSegment = 0;
    _fRotateAngle = 0;
    
    //中心点
    ptCenter = CGPointMake(kScreenWidth/2, 74+160);
    
    //初始化声音文件
    NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"iPod Click" ofType:@"aiff"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &_soundID);
    
    _fRadians = degreesToRadians(15);
    
    _nRotateDelta = 0;
    //初始化
    self.arySegmentState = [NSMutableArray array];
    for (int i=0; i<24; i++)
    {
        MeetingSegmentVo *segmentVo = [[MeetingSegmentVo alloc]init];
        segmentVo.nIndex = i;
        segmentVo.nReserveState = 0;
        [self.arySegmentState addObject:segmentVo];
    }
    
    [self startTimer];
}

- (void)initView
{
    self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //表盘底部
    imgViewMeetingDial = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 333, 333)];
    imgViewMeetingDial.image = [SkinManage imageNamed:@"meeting_dial_img"];//[UIImage imageNamed:@"meeting_dial_img"];
    imgViewMeetingDial.center = ptCenter;
    [self addSubview:imgViewMeetingDial];
    
    //刻度视图
    circleMeeting = [[CDCircle alloc] initWithFrame:CGRectMake(0, 0, 320, 320) numberOfSegments:24 ringWidth:60.f];
    circleMeeting.dataSource = self;
    circleMeeting.delegate = self;
    circleMeeting.center = ptCenter;
    [self addSubview:circleMeeting];
    
    //该视图确保滚动表盘时，结束后处于分段的中点(该View是放在MeetingDialView，始终不动,不能放在CDCircle，否则会随它一起滚动)
    CDCircleOverlayView *overlay = [[CDCircleOverlayView alloc] initWithCircle:circleMeeting];
    [self addSubview:overlay];
    
    //状态控制按钮
    btnStatus = [UIButton buttonWithType:UIButtonTypeSystem];
    btnStatus.tintColor = COLOR(239, 111, 88, 1.0);
    btnStatus.layer.cornerRadius = 5;
    btnStatus.layer.masksToBounds = YES;
    btnStatus.layer.borderColor = COLOR(239, 111, 88, 1.0).CGColor;
    btnStatus.layer.borderWidth = 1.0;
    [btnStatus setTitle:@"开始" forState:UIControlStateNormal];
    [btnStatus addTarget:self action:@selector(changeStatus) forControlEvents:UIControlEventTouchUpInside];
    btnStatus.frame = CGRectMake(0, 0, 97, 38);
    btnStatus.center = CGPointMake(ptCenter.x, ptCenter.y+60);
    [self addSubview:btnStatus];
    
    lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    lblStatus.text = @"可预订";
    lblStatus.textColor = COLOR(51, 43, 41, 1.0);
    lblStatus.font = [UIFont systemFontOfSize:18];
    lblStatus.textAlignment = NSTextAlignmentCenter;
    lblStatus.center = CGPointMake(ptCenter.x, ptCenter.y-65);
    [self addSubview:lblStatus];
    
    lblTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    lblTime.text = @"上午 8:00";
    lblTime.textColor = COLOR(166, 143, 136, 1.0);
    lblTime.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    lblTime.textAlignment = NSTextAlignmentCenter;
    lblTime.center = CGPointMake(ptCenter.x, ptCenter.y-30);
    [self addSubview:lblTime];
    
    lblTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    lblTip.text = @"旋转时间表选择会议开始时间";
    lblTip.textColor = COLOR(166, 143, 136, 1.0);
    lblTip.font = [UIFont systemFontOfSize:12];
    lblTip.textAlignment = NSTextAlignmentCenter;
    lblTip.center = CGPointMake(ptCenter.x, ptCenter.y);
    [self addSubview:lblTip];
    
    lblTipMore = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    lblTipMore.textColor = COLOR(166, 143, 136, 1.0);
    lblTipMore.textAlignment = NSTextAlignmentCenter;
    lblTipMore.center = CGPointMake(ptCenter.x, ptCenter.y+17);
    [self addSubview:lblTipMore];
    
    //绘制环形进度
    progressLayer = [[CAShapeLayer alloc]init];
    progressLayer.fillColor = nil;
    progressLayer.strokeColor = COLOR(245, 181, 169, 1.0).CGColor;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.lineWidth = 11;
    progressLayer.frame = self.bounds;
    [self.layer addSublayer:progressLayer];
    
    [self refreshView];
}

- (void)setStrBookDate:(NSString *)strBookDate
{
    _strBookDate = strBookDate;
    circleMeeting.strBookDate = self.strBookDate;
}

- (void)refreshView
{
    lblTip.center = CGPointMake(ptCenter.x, ptCenter.y);
    
    if (self.nStatus == 1)
    {
        //未开始
        MeetingSegmentVo *segmentVo = self.arySegmentState[nStartSegment];
        if (segmentVo.nReserveState == 0)
        {
            //可预订
            lblStatus.text = @"可预订";
            
            lblTime.text = [self getTimeStringBySegment:nStartSegment];
            lblTime.textColor = COLOR(166, 143, 136, 1.0);
            
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"旋转时间表选择会议开始时间"];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 9)];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(9, 4)];
            lblTip.attributedText = attriString;
            
            lblTipMore.attributedText = nil;
            
            btnStatus.enabled = YES;
            btnStatus.layer.borderColor = COLOR(239, 111, 88, 1.0).CGColor;
            
            
            lblStatus.textColor =  [SkinManage colorNamed:@"date_text"];
            //
            lblTime.textColor = [SkinManage colorNamed:@"meeting_circle_text_color"];
            lblTip.textColor = [SkinManage colorNamed:@"meeting_circle_text_color"];
            lblTipMore.textColor = [SkinManage colorNamed:@"date_title"];
        }
        else if (segmentVo.nReserveState == 1)
        {
            //被预订
            lblStatus.text = @"被预订";
            
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:segmentVo.strUserName];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:14] range:NSMakeRange(0, attriString.length)];
            [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(166, 143, 136, 1.0) range:NSMakeRange(0, attriString.length)];
            lblTime.attributedText = attriString;
            
            attriString = [[NSMutableAttributedString alloc]initWithString:segmentVo.strContact];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, attriString.length)];
            [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(166, 143, 136, 1.0) range:NSMakeRange(0, attriString.length)];
            lblTip.attributedText = attriString;
            lblTip.top -= 5;
            
            attriString = [[NSMutableAttributedString alloc]initWithString:segmentVo.strTitle];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, attriString.length)];
            [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(166, 143, 136, 1.0) range:NSMakeRange(0, attriString.length)];
            lblTipMore.attributedText = attriString;
            
            btnStatus.enabled = NO;
            btnStatus.layer.borderColor = COLOR(214, 213, 213, 1.0).CGColor;
        }
        else if (segmentVo.nReserveState == 2)
        {
            //该时间段无效(18点之后的时间无效)
            lblStatus.text = @"不可预订";
            lblStatus.textColor =  [SkinManage colorNamed:@"date_text"];
            
            lblTime.text = [self getTimeStringBySegment:nStartSegment];
            lblTime.textColor = [SkinManage colorNamed:@"meeting_circle_text_color"];
            
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"请选择有效的会议开始时间"];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 8)];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(8, 4)];
            lblTip.attributedText = attriString;
            lblTip.textColor = [SkinManage colorNamed:@"meeting_circle_text_color"];
            
            lblTipMore.attributedText = nil;
            lblTipMore.textColor = [SkinManage colorNamed:@"date_title"];
            
            btnStatus.enabled = NO;
            btnStatus.layer.borderColor = COLOR(214, 213, 213, 1.0).CGColor;
        }
        else
        {
            //该时间段已过期(如果是今天预订)
            lblStatus.text = @"不可预订";
            lblStatus.textColor =  [SkinManage colorNamed:@"date_text"];
            
            lblTime.text = [self getTimeStringBySegment:nStartSegment];
            lblTime.textColor = [SkinManage colorNamed:@"meeting_circle_text_color"];
            
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"预订今日会议，开始时间已过期"];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 7)];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(7, 7)];
            lblTip.attributedText = attriString;
            lblTip.textColor = [SkinManage colorNamed:@"meeting_circle_text_color"];
            
            lblTipMore.attributedText = nil;
            lblTipMore.textColor = [SkinManage colorNamed:@"date_title"];
            
            btnStatus.enabled = NO;
            btnStatus.layer.borderColor = COLOR(214, 213, 213, 1.0).CGColor;
        }
    }
    else if (self.nStatus == 2)
    {
        //已开始
        lblStatus.text = @"正在预订";
        
        //判断该事件段是否有效
        BOOL bValid = YES;
        for (NSInteger i=nStartSegment+1; i<nEndSegment; i++)
        {
            MeetingSegmentVo *segmentVo = self.arySegmentState[i];
            if (segmentVo.nReserveState != 0)
            {
                bValid = NO;
                break;
            }
        }
        
        NSString *strStartTime = [self getTimeStringBySegment:nStartSegment];
        NSString *strEndTime = [self getTimeStringBySegment:nEndSegment];
        if([strStartTime isEqualToString:strEndTime])
        {
            lblTime.text = [NSString stringWithFormat:@"%@",strStartTime];
        }
        else
        {
            lblTime.text = [NSString stringWithFormat:@"%@-%@",strStartTime,strEndTime];
        }
        lblTime.textColor = COLOR(239, 111, 88, 1.0);
        
        if(!bValid || nStartSegment > nEndSegment)
        {
            //无效
            lblStatus.text = @"不可预订";
            
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"所选择会议时间段不可预订"];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 8)];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(8, 4)];
            lblTip.attributedText = attriString;
            
            NSMutableAttributedString *attriStringMore = [[NSMutableAttributedString alloc]initWithString:@"请选择正确时间段"];
            [attriStringMore addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 3)];
            [attriStringMore addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(3, 5)];
            lblTipMore.attributedText = attriStringMore;
            
            btnStatus.enabled = NO;
            btnStatus.layer.borderColor = COLOR(214, 213, 213, 1.0).CGColor;
        }
        else
        {
            //有效
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"旋转时间表选择会议结束时间"];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 9)];
            [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(9, 4)];
            lblTip.attributedText = attriString;
            
            NSMutableAttributedString *attriStringMore = [[NSMutableAttributedString alloc]initWithString:@"并点击完成按钮"];
            [attriStringMore addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 3)];
            [attriStringMore addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(3, 2)];
            [attriStringMore addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(5, 2)];
            lblTipMore.attributedText = attriStringMore;
            
            btnStatus.enabled = YES;
            btnStatus.layer.borderColor = COLOR(239, 111, 88, 1.0).CGColor;
            
            if(nStartSegment == nEndSegment)
            {
                btnStatus.enabled = NO;
                btnStatus.layer.borderColor = COLOR(214, 213, 213, 1.0).CGColor;
            }
        }
    }
    else if (self.nStatus == 3)
    {
        //已结束
        lblStatus.text = @"已预订";
        
        lblTime.text = [NSString stringWithFormat:@"%@-%@",[self getTimeStringBySegment:nStartSegment],[self getTimeStringBySegment:nEndSegment]];
        lblTime.textColor = COLOR(239, 111, 88, 1.0);
        
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"点击重置按钮可重新选择会议时间"];
        [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(0, 2)];
        [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Medium" size:12] range:NSMakeRange(2, 2)];
        [attriString addAttribute:NSFontAttributeName value:[Common fontWithName:@"PingFangSC-Light" size:12] range:NSMakeRange(4, 11)];
        lblTip.attributedText = attriString;
        
        lblTipMore.attributedText = nil;
    }
}

//刷新已预订记录的圆环
- (void)refreshBookRecord:(NSDictionary *)dicBook
{
    //如果是今天预订，则已过期时间不可预订
    NSInteger nStart = [circleMeeting getCurrentTimeIndex];
    
    //生成24个片段数据
    for (int i=0; i<24; i++)
    {
        MeetingSegmentVo *segmentVo = self.arySegmentState[i];

        MeetingBookVo *bookInfo = dicBook[[MeetingDialView getTimeIdByIndex:i]];
        if(bookInfo)
        {
            //该时间段已预订
            segmentVo.nReserveState = 1;
            
            segmentVo.strTitle = bookInfo.strTitle;
            segmentVo.strUserName = bookInfo.strUserName;
            segmentVo.strContact = bookInfo.strContact;
        }
        else if(i>=20)
        {
            //该时间段无效
            segmentVo.nReserveState = 2;
        }
        else if(i<nStart)
        {
            //该时间段已过期
            segmentVo.nReserveState = 3;
        }
        else
        {
            segmentVo.nReserveState = 0;
        }
    }
    
    [circleMeeting drawReservedCircle:self.arySegmentState];
    [self refreshView];
}

//改变状态
- (void)changeStatus
{
    NSMutableArray *aryTimeSegment;
    if (self.nStatus == 1)
    {
        //从 "未开始" -> "已开始"
        self.nStatus = 2;
        _fRotateAngle = 0;
        transformStart = circleMeeting.transform;
        [btnStatus setTitle:@"完成" forState:UIControlStateNormal];
    }
    else if (self.nStatus == 2)
    {
        //从 "已开始" -> "已结束"
        self.nStatus = 3;
        [btnStatus setTitle:@"重置" forState:UIControlStateNormal];
        
        aryTimeSegment = [circleMeeting getTimeSegmentArrayByRange:nStartSegment end:nEndSegment];
        
        [self closeTimer];
    }
    else if (self.nStatus == 3)
    {
        //从 "已结束" -> "未开始"
        [circleMeeting resetCircleView];    //重置表盘
        [self changeStateToNotStart];
    }
    
    [self.delegate dialViewStateChanged:self.nStatus timeSegment:aryTimeSegment];
    [self refreshView];
}

//从 "已结束" -> "未开始"
- (void)changeStateToNotStart
{
    self.nStatus = 1;
    _fRotateAngle = 0;
    [btnStatus setTitle:@"开始" forState:UIControlStateNormal];
    
    //重置表盘
    progressLayer.path = nil;
    
    //初始化角度,重新从8点钟开始
    transformStart = circleMeeting.transformInitValue;
    fBeforeAngle = [circleMeeting getCircleCurrentAngle:transformStart];    //获取初始角度
    
    [self startTimer];
}

//开始预订时，绘制圆环进度
- (void)drawOutCircle
{
    if(self.nStatus == 2)
    {
        //计算角度差
        double fDelta = [circleMeeting getCircleCurrentAngle:transformStart];
        double fStartAngle = -M_PI_2;
        double fEndAngle = fStartAngle+(-1*fDelta);
        
        //不绘制无效的弧线
        if((fEndAngle-fStartAngle) > 0 || fDelta > degreesToRadians(305))
        {
            fEndAngle = fStartAngle;
        }
        
        progressPath = [UIBezierPath bezierPathWithArcCenter:ptCenter radius:123.5 startAngle:fStartAngle endAngle:fEndAngle clockwise:NO];
        progressPath.lineCapStyle = kCGLineCapRound;
        progressPath.lineJoinStyle = kCGLineJoinBevel;
        
        progressLayer.path = progressPath.CGPath;
    }
}

//时间相关
- (NSString *)getTimeStringBySegment:(NSInteger)nSegment
{
    NSString *strTime;
    if (nSegment < 0)
    {
        strTime = @"";
    }
    else
    {
        CGFloat fTime = 8 + nSegment * 0.5;
        NSInteger nHour = fTime;
        NSString *strHalf = (fTime-nHour)*1.0 > 0 ? @"30":@"00";
        
        if(nHour <= 12)
        {
            //上午
            strTime = [NSString stringWithFormat:@"上午%li:%@",(unsigned long)nHour,strHalf];
        }
        else
        {
            //下午
            strTime = [NSString stringWithFormat:@"下午%li:%@",(unsigned long)(nHour-12),strHalf];
        }
    }
    
    return strTime;
}

- (NSString *)getStartTimeString
{
    return [self getTimeStringBySegment:nStartSegment];
}

- (NSString *)getEndTimeString
{
    return [self getTimeStringBySegment:nEndSegment];
}

#pragma mark - Circle delegate & data source
- (void)circle:(CDCircle *)circle didRotateAngle:(CGFloat)fAngle
{
    if (self.nStatus == 1)
    {
        //未开始
        CGFloat fCurrAngle = fBeforeAngle* (180 / M_PI)-fAngle*(180 / M_PI);
        
        //不能滚动到 18~8这个区间（0°~300°之间）
        if(fCurrAngle < 0  || fCurrAngle > 300)
        {
            return;
        }
        
        //表盘旋转指定角度
        [circle setTransform:CGAffineTransformRotate(circle.transform, fAngle)];
        fBeforeAngle = [circle getCircleCurrentAngle:transformStart];
    }
    else if(self.nStatus == 2)
    {
        //已开始
//        CGFloat fTempAngle1 = _fRotateAngle-fAngle;
//        NSLog(@"变化角度:%g,当前角度:%g,增量后的角度:%g",fAngle*(180 / M_PI),_fRotateAngle* (180 / M_PI),fTempAngle1);
        
        //变化角度单次要超过10°,视为无效转动
//        if (fabs(fAngle) > degreesToRadians(10))
//        {
//            return;
//        }
        
        //a:不可顺时针转动 （转动角度大于0）
        CGFloat fTempAngle = _fRotateAngle-fAngle;
        if (fTempAngle < 0.0)
        {
            return;
        }
        
        //b:不可转动超过1圈
        if (fTempAngle > (M_PI*2-degreesToRadians(15)*3) && fAngle<0)
        {
            return;
        }
        
        //b:不可转动到不可预订区域
        //起始segment
        NSInteger nStartIndex = nStartSegment;
        //根据 rotate angle 计算出结束segment
        NSInteger nEnd = nStartIndex + floor(fabs(fTempAngle)/degreesToRadians(15));
        
        //如果结束segment不能够预订则不转动
        if(nEnd >= self.arySegmentState.count && fAngle<0)
        {
            return;
        }
        
        if(nEnd < self.arySegmentState.count)
        {
            //由于起始点不可预订(当某个区已经预订)，所以判断使用结束点加上结束点之前的一个点都不可预订
            MeetingSegmentVo *segmentVo = self.arySegmentState[nEnd];
            if (nEnd == 0)
            {
                if (segmentVo.nReserveState != 0)
                {
                    return;
                }
            }
            else
            {
                MeetingSegmentVo *segmentVoLast = self.arySegmentState[nEnd-1];
                if (segmentVo.nReserveState != 0 && segmentVoLast != 0 && fAngle<0)
                {
                    return;
                }
            }
        }
        
        //表盘旋转指定角度
        [circle setTransform:CGAffineTransformRotate(circle.transform, fAngle)];
        _fRotateAngle = [circle getCircleCurrentAngle:transformStart];
        
        //绘制进度条
        [self drawOutCircle];
    }
    else if(self.nStatus == 3)
    {
        //已结束
    }
}

- (void)circle:(CDCircle *)circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb
{
    if (self.nStatus == 1)
    {
        //未开始,当处于可预订状态时，可以改变开始档位
        nStartSegment = segment;
        nEndSegment = nStartSegment;
        [self refreshView];
        
        //获取初始化角度
        fBeforeAngle = [circleMeeting getCircleCurrentAngle:transformStart];
    }
    else if(self.nStatus == 2)
    {
        //已开始（可产生吸附效果）
        nEndSegment = segment;
        
        //结束和开始相同则不绘制
        {
            [self drawOutCircle];
            [self refreshView];
        }
        
        //恢复到
        if (nStartSegment == nEndSegment)
        {
            //从 "已结束" -> "未开始"
            [self changeStateToNotStart];
            [self refreshView];
        }
    }
}

- (UIImage *)circle:(CDCircle *)circle iconForThumbAtRow:(NSInteger)row
{
    return [UIImage imageNamed:@"icon_arrow_up"];
}

#pragma mark - 定时器/播放声音 相关
- (void)startTimer
{
    [self closeTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimerAction) userInfo:nil repeats:YES];
}

- (void)closeTimer
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimerAction
{
    //计算角度差
    CGFloat fDelta = [circleMeeting getCircleCurrentAngle:transformStart];
    
    //如果角度差大于15°，则播放声音
    if (fabs(fDelta-_nRotateDelta*_fRadians) >= _fRadians)
    {
        _nRotateDelta = fDelta/_fRadians;
        [self playSound];
    }
}

- (void)playSound
{
    //播放刻度声音
    AudioServicesPlaySystemSound(_soundID);
}

//通用方法///////////////////////////////////////////////////////////////////////////////
//根据segment num 获取时间点字符串0-800,1-830
+ (NSString *)getTimeIdByIndex:(NSInteger)nIndex
{
    NSInteger nTimeId = 800;
    nTimeId += (nIndex/2)*100;
    if (nIndex%2 == 1)
    {
        nTimeId += 30;
    }
    
    return [NSString stringWithFormat:@"%li",(unsigned long)nTimeId];
}

@end
