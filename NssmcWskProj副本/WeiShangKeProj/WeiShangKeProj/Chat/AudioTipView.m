//
//  AudioTipView.m
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/14/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "AudioTipView.h"
#import <math.h>

@implementation AudioTipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code(150,150)
        self.backgroundColor = COLOR(0, 0, 0, 0.5);
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:8];
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.layer setMasksToBounds:YES];
        
        //状态
        self.imgViewState = [[UIImageView alloc]init];
        [self addSubview:self.imgViewState];
        
        //录音的音量
        self.imgViewSignal = [[UIImageView alloc]init];
        [self addSubview:self.imgViewSignal];
        
        //倒数计时
        self.lblNumber = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 150, 76)];
        self.lblNumber.textColor = [UIColor whiteColor];
        self.lblNumber.font = [UIFont boldSystemFontOfSize:80];//59
        self.lblNumber.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lblNumber];
        
        //提示文字
        self.lblTip = [[UILabel alloc]initWithFrame:CGRectMake(7.5, 120, 135, 25)];
        self.lblTip.font = [UIFont boldSystemFontOfSize:12];
        self.lblTip.textAlignment = NSTextAlignmentCenter;
        [self.lblTip.layer setBorderWidth:1.0];
        [self.lblTip.layer setCornerRadius:6.5];
        self.lblTip.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.lblTip.layer setMasksToBounds:YES];
        [self addSubview:self.lblTip];
        
        self.m_nState = -1;
    }
    return self;
}

//1:说话时间太短，2:手指上滑，取消发送，3:松开手指，取消发送(a:取消发送，b:倒计时)
//-1:更新音量
- (void)updateView:(NSInteger)nState andValue:(float)fValue
{
    if (nState != -1)
    {
        self.m_nState = nState;
    }
    
    if (self.m_nState == 1)
    {
        //说话时间太短
        self.imgViewState.hidden = NO;
        self.imgViewState.frame = CGRectMake(0, 0, 150, 150);
        self.imgViewState.image = [UIImage imageNamed:@"MessageTooShort"];

        self.imgViewSignal.hidden = YES;
        self.lblNumber.hidden = YES;
        
        self.lblTip.textColor = [UIColor whiteColor];
        self.lblTip.text = [Common localStr:@"Chat_Time_Short" value:@"说话时间太短"];
        self.lblTip.backgroundColor = [UIColor clearColor];
        
        [self performSelector:@selector(hideView) withObject:[NSNumber numberWithBool:YES] afterDelay:0.8];
    }
    else if (self.m_nState == 2)
    {
        //手指上滑，取消发送
        self.imgViewState.hidden = NO;
        self.imgViewState.frame = CGRectMake(36, 18, 50, 99);
        self.imgViewState.image = [UIImage imageNamed:@"RecordingBkg"];
        
        if(fValue>=1)
        {
            //倒数计时
            self.lblNumber.hidden = NO;
            self.lblNumber.text = [NSString stringWithFormat:@"%li",(long)floor(fValue)];
            
            self.imgViewSignal.hidden = YES;
            self.imgViewState.hidden = YES;
        }
        else
        {
            //音量检测
            self.lblNumber.hidden = YES;
            self.imgViewSignal.hidden = NO;
            self.imgViewSignal.frame = CGRectMake(91, 44.5, 18, 61);
            self.imgViewSignal.image = [UIImage imageNamed:[self getSignalImage:fValue]];
        }
        
        self.lblTip.textColor = COLOR(228, 228, 228, 1.0);
        self.lblTip.text = [Common localStr:@"Chat_Slide_CancelSend" value:@"手指上滑，取消发送"];
        self.lblTip.backgroundColor = [UIColor clearColor];
    }
    else if (self.m_nState == 3)
    {
        //松开手指，取消发送
        self.imgViewState.hidden = NO;
        self.imgViewState.frame = CGRectMake(40, 40, 70, 70);
        self.imgViewState.image = [UIImage imageNamed:@"RecordCancel"];
        
        self.imgViewSignal.hidden = YES;
        self.lblNumber.hidden = YES;
        
        self.lblTip.textColor = [UIColor whiteColor];
        self.lblTip.text = [Common localStr:@"Chat_Release_CancelSend" value:@"松开手指，取消发送"];
        self.lblTip.backgroundColor = COLOR(158, 56, 54, 1.0);
    }
}

-(NSString*)getSignalImage:(CGFloat)fSignal
{
    //音量范围为0~1,分为八个等级,0.3为微调常数
    return [NSString stringWithFormat:@"RecordingSignal00%li",(long)(fSignal/0.125+0.3)+1];
}

//隐藏本视图
-(void)hideView
{
    self.hidden = YES;
}

@end
