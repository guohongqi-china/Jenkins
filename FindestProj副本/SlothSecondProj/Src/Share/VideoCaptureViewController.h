//
//  VideoCaptureViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/17.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNavigationViewController.h"

#define VIDEO_FOLDER @"videoFolder"

@interface VideoCaptureViewController : QNavigationViewController//UIViewController

@property(nonatomic,strong)NSURL *urlVideoChoosed;      //已经选择的video url
- (void)dismissViewController:(NSURL *)urlVideo;

+ (void)createVideoFolderIfNotExist;

@end

@interface VideoProgressVo : NSObject

@property (nonatomic ,strong) UIImageView *imgViewSegment;      //录制的片段背景
@property (nonatomic ,strong) NSURL *urlVideoFile;              //video文件

@property (nonatomic) CGFloat fDuration;                        //视频片段时间

@end
