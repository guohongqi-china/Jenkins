//
//  RecordModel.h
//  NssmcWskProj
//
//  Created by MacBook on 16/8/3.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class RecordView;
@protocol RecordModelDelegate <NSObject>

- (void)RecordModelRecordURLPath:(NSString *)path;

@end
@interface RecordModel : NSObject
@property (nonatomic, assign) id<RecordModelDelegate> delegate;/** <#注释#> */
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) RecordView *soundView;/** <#注释#> */

@property (nonatomic, copy) NSString *recordPathStr;/** 语音文件路径 */
@property (nonatomic, strong) NSTimer *timerAudio;//检测音量
- (instancetype)initWith:(id)target voiceView:(UIView *)VView;
//**开始录音*/
- (void)recordStart;
//**停止录音*/
- (void)recordStop;


@end
