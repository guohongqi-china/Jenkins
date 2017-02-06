//
//  CheckVideoViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/17.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "CheckVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoCaptureViewController.h"
#import "Utils.h"

@interface CheckVideoViewController ()
{
    AVPlayer *player;
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
    
    UIImageView* playImg;
    
}

@end

@implementation CheckVideoViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"预览";
    
    //从发表页面Present过来
    self.isNeedBackItem = NO;
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithTitle:@"确定"];
    
    playerItem = [AVPlayerItem playerItemWithAsset:[AVURLAsset URLAssetWithURL:self.urlVideo options:nil]];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    
    //AVPlayerLayer
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    
    UITapGestureRecognizer *playTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
    [self.view addGestureRecognizer:playTap];
    
    //play icon
    playImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    playImg.center = CGPointMake(kScreenWidth/2, (kScreenHeight-NAV_BAR_HEIGHT)/2);
    [playImg setImage:[UIImage imageNamed:@"multimedia_videocard_play_big"]];
    [playerLayer addSublayer:playImg.layer];
    playImg.hidden = YES;
    
    //开始播放
    [playerItem seekToTime:kCMTimeZero];
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
-(void)playOrPause
{
    if (playImg.isHidden)
    {
        playImg.hidden = NO;
        [player pause];
    }
    else
    {
        playImg.hidden = YES;
        [player play];
    }
}

//播放结束
- (void)moviePlayDidEnd:(NSNotification *)notification
{
    [playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        playImg.hidden = NO;
    }];
}

- (void)righBarClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
