//
//  CheckVideoViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/17.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "CommonViewController.h"

@class VideoCaptureViewController;

@interface CheckVideoViewController : CommonViewController

@property(nonatomic,strong) NSURL * urlVideo;
@property(nonatomic,weak) VideoCaptureViewController *videoCaptureViewController;

@end
