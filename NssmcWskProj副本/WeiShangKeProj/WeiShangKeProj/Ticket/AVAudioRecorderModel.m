//
//  AVAudioRecorderModel.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AVAudioRecorderModel.h"
#import "MBProgressHUD+GHQ.h"
@implementation AVAudioRecorderModel


static AVAudioRecorderModel* _instance = nil;


+(instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}


- (instancetype)init{
    if (self = [super init]) {
        [self setAudioSession];
    }
    return self;
}
#pragma mark - 私有方法
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    
    
   
 
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    
    //默认情况下扬声器播放
    
//    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}
/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    
    if (!_audioRecorder) {
        //创建录音文件保存路径

        NSURL *url=[self getSavePath:nil];
        NSLog(@"录影路径=========%@",url);

        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        _audioRecorder.meteringEnabled = YES;
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}
- (NSString *)getSoundPath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     urlStr=[urlStr stringByAppendingPathComponent: _tagString];
    NSLog(@"%@",urlStr);
    
    return urlStr;
}
/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath:(NSString *)pathString{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *dateString1 = [formatter stringFromDate:date];
    NSString *dateString = [dateString1 stringByAppendingString:@".wav"];
    _tagString = dateString;
    NSLog(@"录影路径=========%@",dateString);
    if (pathString.length == 0) {
        urlStr=[urlStr stringByAppendingPathComponent:dateString];

    }else{
        urlStr=[urlStr stringByAppendingPathComponent:pathString];

    }
       NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    //线性采样位数
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
//    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    [dicM setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [dicM setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    //....其他设置等
    return dicM;
}
/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
//    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
//    CGFloat progress=(1.0/160.0)*(power+160.0);
//    [self.audioPower setProgress:progress];
}
//- (AVPlayer *)player{
//    NSURL *url=[NSURL fileURLWithPath:_pathWAV];
//    _player = [[AVPlayer alloc]initWithURL:url];
//    
//}
/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (_isPlaying) {
        return _audioPlayer;
    }
        NSURL *url=[NSURL fileURLWithPath:_pathWAV];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
    _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    return _audioPlayer;
}
- (void)palyRecordSound{
    if (![self.audioPlayer isPlaying]) {
//        [self.audioPlayer stop];
        NSURL *url=[NSURL fileURLWithPath:_pathWAV];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return ;
        }

        [_audioRecorder updateMeters];//刷新音量
        [self.audioRecorder peakPowerForChannel:0];//获取音量的最大值
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
        
        [self.audioPlayer play];
        //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应

    }
    
}
#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else//没黑屏幕
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
    }
}
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
//-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    if (![self.audioPlayer isPlaying]) {
//        [self.audioPlayer play];
//    }
//    NSLog(@"录音完成!");
//}
//播放结束时执行的动作
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudioPlaying];
    //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"Sound" object:nil];
}

//解码错误执行的动作
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
{
    NSLog(@"%@",error);
    [self stopAudioPlaying];
}

//处理中断的代码
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
{
    [self stopAudioPlaying];
}
//结束播放音频
-(void)stopAudioPlaying
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
 
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    if (self.delegate &&[self.delegate respondsToSelector:@selector(stopToPlaySound)]) {
        [self.delegate stopToPlaySound];
    }
    
}


@end
