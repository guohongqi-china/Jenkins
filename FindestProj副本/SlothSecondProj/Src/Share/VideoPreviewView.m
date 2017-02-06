//
//  VideoPreviewView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/20.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "VideoPreviewView.h"
#import "UIViewExt.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoPreviewView ()
{
    UIButton *btnVideoPreview;
    UIButton *btnDelete;
    
    UIImageView *imgViewVideoIcon;
    UILabel *lblVIdeoTime;
    
    void(^previewBlock)(void);  //定义previewBlock
    void(^deleteBlock)(void);   //定义deleteBlock
}

@end

@implementation VideoPreviewView

- (instancetype)initWithFrame:(CGRect)frame previewBlock:(void(^)(void))preview deleteBlock:(void(^)(void))delete
{
    self = [super initWithFrame:frame];
    if (self)
    {
        btnVideoPreview = [UIButton buttonWithType:UIButtonTypeCustom];
        btnVideoPreview.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        btnVideoPreview.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btnVideoPreview.imageView.clipsToBounds = YES;
        [btnVideoPreview addTarget:self action:@selector(doVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnVideoPreview];
        
        btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setImage:[UIImage imageNamed:@"video_delete"] forState:UIControlStateNormal];
        [btnDelete addTarget:self action:@selector(doVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        btnDelete.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        btnDelete.frame = CGRectMake(frame.size.width-44, 0, 44,44);
        [btnVideoPreview addSubview:btnDelete];
        
        imgViewVideoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 72, 72)];
        imgViewVideoIcon.image = [UIImage imageNamed:@"multimedia_videocard_play_big"];
        imgViewVideoIcon.center = btnVideoPreview.center;
        [btnVideoPreview addSubview:imgViewVideoIcon];
        
        lblVIdeoTime = [[UILabel alloc]initWithFrame:CGRectMake(12, frame.size.height-28, 35, 16)];
        lblVIdeoTime.layer.cornerRadius = 2;
        lblVIdeoTime.layer.masksToBounds = YES;
        lblVIdeoTime.font = [UIFont systemFontOfSize:10];
        lblVIdeoTime.textColor = [UIColor whiteColor];
        lblVIdeoTime.backgroundColor = COLOR(0, 0, 0, 0.3);
        lblVIdeoTime.textAlignment = NSTextAlignmentCenter;
        [btnVideoPreview addSubview:lblVIdeoTime];
        
        //block
        previewBlock = preview;
        deleteBlock = delete;
    }
    
    return self;
}

- (void)doVideoAction:(UIButton *)sender
{
    if (sender == btnVideoPreview)
    {
        previewBlock();
    }
    else if (sender == btnDelete)
    {
        deleteBlock();
    }
}

//设置视频信息
- (void)setVideoFileURL:(NSURL *)urlVideo
{
    //根据fileURL获取video相关信息
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:urlVideo options:@{AVURLAssetPreferPreciseDurationAndTimingKey:[NSNumber numberWithBool:NO]}];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    //获取视频第一帧图片
    if (!error) {
        [btnVideoPreview setImage:[UIImage imageWithCGImage:image] forState:UIControlStateNormal];
    }
    
    //获取视频时长
    long long nMinute,nSecond;
    long long nTotalSecond = ceil(urlAsset.duration.value*1.0/urlAsset.duration.timescale);//上取整
    nMinute = nTotalSecond/60;
    nSecond = nTotalSecond%60;
    lblVIdeoTime.text = [NSString stringWithFormat:@"%lli:%.2lli",nMinute,nSecond];
    
    //获取文件大小
    double fMSize = 0.0;
    if ([urlVideo.scheme isEqualToString:@"assets-library"])
    {
        //来自于相册,直接根据时长来大概估计
        fMSize = nTotalSecond * 0.1;
    }
    else
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error1 = nil;
        NSDictionary *dicFileInfo = [fileManager attributesOfItemAtPath:urlVideo.path error:&error1];
        unsigned long long nFileSize = [dicFileInfo[@"NSFileSize"] unsignedLongValue];
        fMSize = nFileSize*1.0/1024/1024;
    }
    
    CGImageRelease(image);
}

- (void)hideCloseButton
{
    btnDelete.hidden = YES;
}

@end
