//
//  AVAudioRecorderModel.h
//  NssmcWskProj
//
//  Created by MacBook on 16/6/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "AnimationImage.h"

@class AVAudioRecorderModel;

@protocol AVAudioRecorderModelDelegate <NSObject>

- (void)stopToPlaySound;

@end

@interface AVAudioRecorderModel : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
@property(nonatomic,strong) NSTimer *timerAudio;//检测音量

@property (nonatomic, strong) AnimationImage *vioceButton;/** <#注释#> */
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@property (nonatomic, assign) BOOL isPlaying;/** 判断播放时的URL是否为空 */
@property (nonatomic, strong) AVPlayer *player;/** <#注释#> */
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (nonatomic, assign) id<AVAudioRecorderModelDelegate> delegate;/** <#注释#> */

@property (nonatomic, copy) NSString *pathWAV;/** <#注释#> */

@property (nonatomic, copy) NSString *tagString;/** <#注释#> */
- (void)palyRecordSound;//播放录音
+(instancetype)shareInstance;//创建单利方法
- (NSString *)getSoundPath;//获取音频路径
-(NSURL *)getSavePath:(NSString *)pathString;//获取录音保存的路径
@end
