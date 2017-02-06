//
//  RecordModel.m
//  NssmcWskProj
//
//  Created by MacBook on 16/8/3.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "RecordModel.h"
#import "RecordView.h"
#import "Common.h"
#import "Utils.h"
#import "VoiceConverter.h"
#import "MBProgressHUD+GHQ.h"
@interface RecordModel ()
{
    BOOL timeRun;
}
@property (nonatomic, strong) NSRunLoop *RLoop;/** <#注释#> */
@property (nonatomic, strong) UIView *ALView;/** <#注释#> */

@end
@implementation RecordModel

- (instancetype)initWith:(id)target voiceView:(UIView *)VView{
    if (self = [super init]) {
        _soundView = [[[NSBundle mainBundle]loadNibNamed:@"RecordView" owner:nil options:nil] lastObject];
        _soundView.width = 100;
        _soundView.height = 100;
        _soundView.x = kScreenWidth / 2 - 50;
        _soundView.y = kScreenHeight / 2 - 50;
        _soundView.hidden = YES;
        self.delegate = target;
        
//        [VView insertSubview:_soundView aboveSubview:target];
//        _ALView = (UIView *)target;
        [VView addSubview:_soundView];
        _RLoop = [NSRunLoop currentRunLoop];
        

    }
    return self;
}

- (void)setUpSoundView{
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    _soundView.hidden = YES;
    [topWindow addSubview:_soundView];
}

- (void)recordStart{
    //判断隐私中相册是否启用
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
    {
        [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-麦克风”选项中，允许%@访问你的手机麦克风。",@"新日铁"]];
        return;
    }
    
    if (self.recorder.recording)
    {
        return;
    }
    self.soundView.hidden = NO;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    self.recordPathStr = [[Utils getTempPath] stringByAppendingPathComponent:[Common createFileNameByDateTime:@"wav"]];
    
    //语音录制目标文件
    NSURL *audioRecordUrl = [[NSURL alloc] initFileURLWithPath:self.recordPathStr];
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //录音格式
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [recordSetting setValue :[NSNumber numberWithFloat:8000] forKey: AVSampleRateKey];//
    //通道数
    [recordSetting setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];//1
    //线性采样位数
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];//16
    [recordSetting setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    //实例化AVAudioRecorder
    self.recorder = nil;
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:audioRecordUrl settings:recordSetting error:&error];
    self.recorder.meteringEnabled = YES;//开启音量检测
    //创建录音文件,准备录音
    if ([self.recorder prepareToRecord])
    {
                //开始录音
        if (!self.timerAudio) {
//            self.timerAudio = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAudioSignal) userInfo:nil repeats:YES];
            self.timerAudio = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(timerAudioSignal) userInfo:nil repeats:YES];
            [_RLoop addTimer:_timerAudio forMode:NSRunLoopCommonModes];
            self.timerAudio.fireDate = [NSDate distantPast];
        }
        [self.recorder record];

    }
    else
    {
        [Common tipAlert:[NSString stringWithFormat:@"录音失败，请重新尝试.%@",error]];
    }



}

//刷新音量大小的定时函数
static CGFloat number=0;
-(void)timerAudioSignal
{
  
    number += 0.2;
    [self updateAudioSignal:number];
}

//刷新音量大小以及10秒倒计时
-(void)updateAudioSignal:(NSInteger)nType
{
    if (number>60)
    {
        //当大于60秒停止录音
        [self  recordStop];
        [Common tipAlert:[NSString stringWithFormat:@"录制时间超出60已发送"]];
        return;
    }
    
    [self.recorder updateMeters];
    //获取音量的值,然后转化到0~1的值
    float vol = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    
    if(vol>=1)
    {
        vol = 0.99999;//防止与倒计时冲突，音量值会超过1
    }
        NSLog(@"音量=============%ld",(long)(vol/0.125+0.3)+1);
        self.soundView.soundImageView.image = [UIImage imageNamed:[self getSignalImage:vol]];


    
}
-(NSString*)getSignalImage:(CGFloat)fSignal
{
    //音量范围为0~1,分为八个等级(1/8=0.125),0.3为微调常数
    return [NSString stringWithFormat:@"RecordingSignal00%li",(long)(fSignal/0.125+0.3)+1];
}
- (void)recordStop{

    //处理录音结束
    [self tackleRecordFinished];
    
    //将wav文件 转为 amr文件
    NSString *strAmrPath = [VoiceConverter wavToAmr:self.recordPathStr];
    
    //从录制开始到现在的时间，该时间一直在增加（设断点调试会导致时间不一致）

    if (number>=1)
    {
        //发送到服务器端
        if (self.delegate && [self.delegate respondsToSelector:@selector(RecordModelRecordURLPath:) ]) {
            [self.delegate RecordModelRecordURLPath:strAmrPath];
        }
        
    }
    else
    {
        //说话时间太短
        [MBProgressHUD showSuccess:@"说话时长太短" toView:nil];
       
    }
    number = 0;
    return;

}
//处理录音结束的操作
-(void)tackleRecordFinished
{

    //clear timer
    [_timerAudio setFireDate:[NSDate distantFuture]];
    [_timerAudio invalidate];
    _timerAudio = nil;
    NSLog(@"dealloc:%@",self.timerAudio);

    //语音动画视图消失
    [self.recorder stop];
     self.recorder = nil;
     self.soundView.hidden = YES;
    
   
}

- (void)dealloc{
    [_timerAudio invalidate];
    _timerAudio = nil;
    self.recorder = nil;

}



@end
