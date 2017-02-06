//
//  VideoPlayView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/24.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "VideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"
#import "UIViewExt.h"
//#import "ASIHTTPRequest.h"
#import "BufferVideoFirstImage.h"
#import "CircleProgressView.h"

@interface VideoPlayView ()
{
    AVPlayer *player;
    AVPlayerLayer *playerLayer;
    
    UIImageView* imgViewFirstFrame;
    UIImageView* imgViewPlay;
    
    //进度条
    CircleProgressView *circleProgressView;
    BOOL bDownloadStatus;
    
    NSString *strVideoPath;
    NSString *strVideoTempPath;
}

@end

@implementation VideoPlayView

//定义宽高 300 * 400
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        bDownloadStatus = NO;
        
        imgViewFirstFrame  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imgViewFirstFrame.userInteractionEnabled = YES;
        imgViewFirstFrame.contentMode = UIViewContentModeScaleAspectFill;
        imgViewFirstFrame.clipsToBounds = YES;
        imgViewFirstFrame.hidden = YES;
        [self addSubview:imgViewFirstFrame];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadAction)];
        [imgViewFirstFrame addGestureRecognizer:tapGesture];
        
        //play icon
        imgViewPlay = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
        imgViewPlay.center = CGPointMake(frame.size.width/2, (frame.size.height)/2);
        [imgViewPlay setImage:[UIImage imageNamed:@"multimedia_videocard_play_big"]];
        [imgViewFirstFrame addSubview:imgViewPlay];
        
        circleProgressView = [[CircleProgressView alloc]initWithFrame:CGRectMake(self.width/2-50, self.height/2-50, 100, 100)];
        circleProgressView.hidden = YES;
        [imgViewFirstFrame addSubview:circleProgressView];
        
        
    }
    return self;
}

//设置URL
- (void)setUrlVideo:(NSURL *)urlVideo
{
    _urlVideo = urlVideo;
    
    NSString *strURL = [self.urlVideo absoluteString];
    NSString *strVideoName = [strURL lastPathComponent];
    NSString *strVideoTempName = [NSString stringWithFormat:@"%@_temp.%@",[[strURL lastPathComponent] stringByDeletingPathExtension],[strURL pathExtension]];
    
    //下载完存储目录
    strVideoPath = [[Utils getAppSmallVideoPath]stringByAppendingPathComponent:strVideoName];
    //临时存储目录
    strVideoTempPath = [[Utils getAppSmallVideoPath]stringByAppendingPathComponent:strVideoTempName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strVideoPath];
    if (fileExists)
    {
        //直接播放
        [self playVideo];
        imgViewFirstFrame.hidden = YES;
    }
    else
    {
        //不存在，加载网络第一帧图片
        imgViewFirstFrame.hidden = NO;
        [BufferVideoFirstImage getFirstFrameImageFromURL:strURL finished:^(UIImage *image) {
            imgViewFirstFrame.image = image;
        }];
    }
}

- (void)playVideo
{
    //检查Video文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strVideoPath];
    if (fileExists)
    {
        //直接播放
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
         
        if (playerLayer)
        {
            [playerLayer removeFromSuperlayer];
            playerLayer = nil;
        }
        
        if(player)
        {
            [player pause];
            player = nil;
        }
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:strVideoPath] options:nil]];
        player = [AVPlayer playerWithPlayerItem:playerItem];
        
        //AVPlayerLayer
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer addSublayer:playerLayer];
        
        //开始播放
        [playerItem seekToTime:kCMTimeZero];
        [player play];
        imgViewFirstFrame.hidden = YES;//避免出现空白
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    }
}

//下载视频操作
- (void)downloadAction
{
    [self downloadVideoFile];
}

//播放结束
- (void)moviePlayDidEnd:(NSNotification *)notification
{
    //循环播放
    AVPlayerItem *playerItem = notification.object;
    if (playerItem == player.currentItem)
    {
        [player.currentItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [player play];
        }];
    }
}

//直接缓存视频（不用断点续传，续传失败）
- (void)downloadVideoFile
{
    //如果已经处于下载状态，不能再次下载
    if (bDownloadStatus)
    {
        return;
    }
    
    bDownloadStatus = YES;
    imgViewPlay.hidden = YES;
    circleProgressView.hidden = NO;
    [circleProgressView setLoadProgress:0];
    
    //判断是否已经有下载一半的视频，有则清理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strVideoTempPath];
    if (fileExists)
    {
        [fileManager removeItemAtPath:strVideoTempPath error:nil];
    }
    
//    //初始化下载
//    __block unsigned long long ullDownloadSize = 0;
//    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:self.urlVideo];
//    [request setDownloadDestinationPath:strVideoPath];
//    [request setTemporaryFileDownloadPath:strVideoTempPath];
//    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
//        ullDownloadSize += size;
//        [circleProgressView setLoadProgress:(ullDownloadSize*1.0)/total];
//    }];
//    
//    //完成下载，开启播放操作
//    [request setCompletionBlock:^{
//        bDownloadStatus = NO;
//        [self playVideo];
//    }];
//    
//    //下载失败,恢复UI
//    [request setFailedBlock:^{
//        bDownloadStatus = NO;
//        imgViewPlay.hidden = NO;
//        circleProgressView.hidden = YES;
//    }];
//    
//    //开启异步下载
//    [request startAsynchronous];
}

//下载完存储目录
+ (NSString *)getVideoPathByURL:(NSString *)strURL
{
    NSString *strVideoName = [strURL lastPathComponent];
    return [[Utils getAppSmallVideoPath]stringByAppendingPathComponent:strVideoName];
}

@end
