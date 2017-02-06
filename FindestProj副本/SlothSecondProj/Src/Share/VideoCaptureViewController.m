//
//  VideoCaptureViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/17.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "VideoCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewExt.h"
#import "CheckVideoViewController.h"
#import "CTAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define TIMER_INTERVAL 0.05             //精度为50毫秒响应一次Timer
//至少拍摄3秒
#define VIDEO_MIN_TIME  3.0
//视频总长度 默认16秒
#define VIDEO_MAX_TIME  16.0

#define VIDEO_CHOOSE_MAX 200    //只能选择200秒以内的视频


@implementation VideoProgressVo

@end

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface VideoCaptureViewController ()<AVCaptureFileOutputRecordingDelegate,UIAlertViewDelegate,CTAssetsPickerControllerDelegate>//视频文件输出代理
{
    UIScrollView *scrollViewContainer;
    
    //顶部视图
    UIView *viewTopBar;
    UIButton *btnClose;
    UIButton *btnFlashLight;        //闪光灯
    UIButton *btnOverTurn;          //切换前后摄像头
    
    //视频视图
    UIView *viewVideoPreview;
    UIImageView *imgViewFocus;//对焦icon
    
    AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
    AVCaptureDeviceInput *captureDeviceInput;//video:负责从AVCaptureDevice获得输入数据
    AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
    
    //底部视图
    UIView *viewBottom;
    UIView *viewProgress;               //进度条视图
    UIButton *btnDelete;                //删除视频片段按钮
    UIImageView *imgViewCapture;        //进行录制按钮
    UIButton *btnNext;                  //下一部操作按钮
    UIImageView *imgViewSquare;        //进度前面的小方形
    
    //3秒
    UIImageView *imgViewMinTimeTip;             //视频至少拍摄3s
    NSMutableArray* aryVideoProgress;           //保存视频片段的VideoProgressVo数组
    NSInteger nDeleteState;                     //处于删除视频片段状态,0:不删除，1:删除单个，2:删除所有
    AVCaptureTorchMode m_torchMode;               //闪光灯状态:初始为自动、接着关闭、接着打开闪光灯
    
    //选择已有视频文件
    NSMutableArray *aryAssets;//外部在系统相册里面选择的照片
    UIImage *imgPoster;
    
    //
    float preLayerWidth;//镜头宽
    float preLayerHeight;//镜头高
    float preLayerHWRate; //高，宽比
    NSTimer *countTimer; //计时器
    
    float currentTime; //当前视频总长度
    
    float progressStep; //进度条每次变长的最小单位
}

@end

@implementation VideoCaptureViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
    [self initVideoCapture];
}

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationDidEnterBackground
{
    //移除小方形动画
    [imgViewSquare.layer removeAllAnimations];
}

- (void)applicationWillEnterForeground
{
    //开启小方形动画
    imgViewSquare.alpha = 0;
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseInOut animations:^{
        imgViewSquare.alpha = 1.0;
    } completion:nil];
}

- (void)initData
{
    preLayerWidth = kScreenWidth;
    preLayerHeight = kScreenWidth;
    preLayerHWRate = preLayerWidth/preLayerHeight;
    
    aryVideoProgress = [NSMutableArray array];
    aryAssets = [NSMutableArray array];

    progressStep = kScreenWidth*TIMER_INTERVAL/VIDEO_MAX_TIME;
    
    currentTime = 0;
    nDeleteState = 0;
    
    imgPoster = [UIImage imageNamed:@"default_image"];
    
    m_torchMode = AVCaptureTorchModeAuto;
    
    [VideoCaptureViewController createVideoFolderIfNotExist];
    
    //获取封面图以及之前选中的URL
    [self getAlbumPosterImage];
    
    //用于恢复小方块的动画
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initView
{
    self.view.backgroundColor = COLOR(0, 0, 0, 1.0);
    self.viewTop.hidden = YES;
    //隐藏状态栏
    
    //
    scrollViewContainer = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    scrollViewContainer.autoresizingMask = NO;
    scrollViewContainer.clipsToBounds = YES;
    [self.view addSubview:scrollViewContainer];
    
    UITapGestureRecognizer *tabScrollViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScrollView)];
    [scrollViewContainer addGestureRecognizer:tabScrollViewGesture];
    
    CGFloat fHeight = kStatusBarHeight;
    //top view
    viewTopBar = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 44)];
    [scrollViewContainer addSubview:viewTopBar];
    
    btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(0, (viewTopBar.height-44)/2, 44, 44);
    [btnClose setImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"camera_close_highlighted"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(topButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewTopBar addSubview:btnClose];
    
    btnFlashLight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFlashLight.frame = CGRectMake((kScreenWidth-44)/2, (viewTopBar.height-44)/2, 44, 44);
    btnFlashLight.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight"] forState:UIControlStateNormal];
    [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight_disable"] forState:UIControlStateDisabled];
    [btnFlashLight addTarget:self action:@selector(topButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewTopBar addSubview:btnFlashLight];
    
    btnOverTurn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOverTurn.frame = CGRectMake(kScreenWidth-44, (viewTopBar.height-44)/2, 44, 44);
    btnOverTurn.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [btnOverTurn setImage:[UIImage imageNamed:@"camera_overturn"] forState:UIControlStateNormal];
    [btnOverTurn setImage:[UIImage imageNamed:@"camera_overturn_highlighted"] forState:UIControlStateHighlighted];
    [btnOverTurn addTarget:self action:@selector(topButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewTopBar addSubview:btnOverTurn];
    fHeight += viewTopBar.height;
    
    //video view
    viewVideoPreview = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, preLayerWidth, preLayerHeight)];
    [scrollViewContainer addSubview:viewVideoPreview];
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideoPreview:)];
    [viewVideoPreview addGestureRecognizer:tapGesture];
    
    imgViewFocus = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    [imgViewFocus setImage:[UIImage imageNamed:@"camera_aperture"]];
    imgViewFocus.alpha = 0;
    [viewVideoPreview addSubview:imgViewFocus];
    
    fHeight += preLayerHeight;
    
    //bottom view
    viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 184)];
    [scrollViewContainer addSubview:viewBottom];
    
    viewProgress = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
    viewProgress.backgroundColor = COLOR(119, 119, 119, 1.0);
    [viewBottom addSubview:viewProgress];
    
    //3秒的位置
    UIImageView *imgView3Second = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_min_second"]];
    CGFloat f3SecondW = (VIDEO_MIN_TIME/VIDEO_MAX_TIME)*kScreenWidth;
    imgView3Second.frame = CGRectMake(f3SecondW, 0, 3, 5);
    [viewProgress addSubview:imgView3Second];
    
    //视频至少拍摄3s
    imgViewMinTimeTip = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"helper_video_3s"]];
    imgViewMinTimeTip.frame = CGRectMake(imgView3Second.left-10, fHeight-34, 85, 31);
    imgViewMinTimeTip.alpha = 0;
    [scrollViewContainer addSubview:imgViewMinTimeTip];
    
    //灰色小方形
    imgViewSquare = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 5, 5)];
    imgViewSquare.image = [Common getImageWithColor:COLOR(68, 68, 68, 1.0)];
    [viewProgress addSubview:imgViewSquare];
    
    imgViewSquare.alpha = 0;
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseInOut animations:^{
        imgViewSquare.alpha = 1.0;
    } completion:nil];
    
    btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(((kScreenWidth-90)/2-60)/2, (184-60)/2, 60, 60);
    [btnDelete setImage:[UIImage imageNamed:@"video_delete_button"] forState:UIControlStateNormal];
    [btnDelete setImage:[UIImage imageNamed:@"video_delete_button_highlighted"] forState:UIControlStateHighlighted];
    [btnDelete addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    btnDelete.hidden = YES;
    [viewBottom addSubview:btnDelete];
    
    UILongPressGestureRecognizer *longDeleteRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDeleteVideo:)];
    [btnDelete addGestureRecognizer:longDeleteRecognizer];
    
    
    imgViewCapture = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-66)/2, (184-66)/2, 66, 66)];
    imgViewCapture.image = [UIImage imageNamed:@"camera_video_background"];
    imgViewCapture.userInteractionEnabled = YES;
    [viewBottom addSubview:imgViewCapture];
    
    UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressCapture:)];
    [imgViewCapture addGestureRecognizer:longRecognizer];
    
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(kScreenWidth/2+90/2+((kScreenWidth-90)/2-60)/2, (184-60)/2, 60, 60);
    btnNext.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [btnNext.imageView.layer setBorderWidth:0];
    [btnNext.imageView.layer setCornerRadius:2];
    btnNext.imageView.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnNext.imageView.layer setMasksToBounds:YES];
    [btnNext setImage:imgPoster forState:UIControlStateNormal];
    [btnNext setImage:[UIImage imageNamed:@"video_next_button_disabled"] forState:UIControlStateDisabled];
    [btnNext addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewBottom addSubview:btnNext];
    
    fHeight += 184;
    [scrollViewContainer setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

//初始化视频捕捉
- (void)initVideoCapture
{
    //判断隐私中相机是否启用
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoStatus != AVAuthorizationStatusAuthorized && videoStatus != AVAuthorizationStatusNotDetermined)
    {
        [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",APP_NAME]];
        return;
    }
    
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus != AVAuthorizationStatusAuthorized && audioStatus != AVAuthorizationStatusNotDetermined)
    {
        [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-麦克风”选项中，允许%@访问你的手机麦克风。",APP_NAME]];
        return;
    }
    
    //初始化会话
    captureSession=[[AVCaptureSession alloc]init];
    if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        //设置分辨率
        captureSession.sessionPreset=AVCaptureSessionPreset640x480;
    }
    
    //获得后置摄像头输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    
    //初始化设备输出对象，用于获得输出数据
    captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //将设备输入添加到会话中
    if ([captureSession canAddInput:captureDeviceInput])
    {
        [captureSession addInput:captureDeviceInput];
        [captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ])
        {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    //将设备输出添加到会话中
    if ([captureSession canAddOutput:captureMovieFileOutput])
    {
        [captureSession addOutput:captureMovieFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    
    CALayer *layer= viewVideoPreview.layer;
    layer.masksToBounds=YES;
    
    captureVideoPreviewLayer.frame=  CGRectMake(0, 0, preLayerWidth, preLayerHeight);
    captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    [layer insertSublayer:captureVideoPreviewLayer below:imgViewFocus.layer];
    
    //开始
    [captureSession startRunning];
}

//获取选择视频的封面图
- (void)getAlbumPosterImage
{
    @autoreleasepool
    {
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror)
        {
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound)
            {
                [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-照片”选项中，允许%@访问你的手机相册。",APP_NAME]];
            }
            else
            {
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop)
        {
            if (group!=nil)
            {
                imgPoster = [UIImage imageWithCGImage:group.posterImage];
                [btnNext setImage:imgPoster forState:UIControlStateNormal];
                [btnNext setImage:nil forState:UIControlStateHighlighted];
            }
        };
        
        [[Common defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:libraryGroupsEnumeration failureBlock:failureblock];
        
        if (self.urlVideoChoosed)
        {
            [[Common defaultAssetsLibrary] assetForURL:self.urlVideoChoosed resultBlock:^(ALAsset *asset) {
                if (asset)
                {
                    [aryAssets addObject:asset];
                }
            } failureBlock:nil];
        }
    }
}

-(void)startTimer
{
    countTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [countTimer fire];
}

-(void)stopTimer
{
    [countTimer invalidate];
    countTimer = nil;
}

- (void)onTimer:(NSTimer *)timer
{
    currentTime += TIMER_INTERVAL;
    
    //更新progress frame
    VideoProgressVo *progressVoLast = [aryVideoProgress lastObject];
    CGRect rectProgress = progressVoLast.imgViewSegment.frame;
    rectProgress.size = CGSizeMake(rectProgress.size.width+progressStep, 5);
    [progressVoLast.imgViewSegment setFrame:rectProgress];
    progressVoLast.fDuration += TIMER_INTERVAL;
    
    imgViewSquare.frame = CGRectMake(progressVoLast.imgViewSegment.right, 0, 5, 5);
    
    //时间到了停止录制视频
    if (currentTime>=VIDEO_MAX_TIME)
    {
        [countTimer invalidate];
        countTimer = nil;
        [captureMovieFileOutput stopRecording];
    }
    
}

+ (void)createVideoFolderIfNotExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}

//合并mov片段视频
- (void)mergeAndExportVideosAtFileURLs
{
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    for (VideoProgressVo *progressVo in aryVideoProgress) {
        NSURL *fileURL = progressVo.urlVideoFile;
        
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        [assetArray addObject:asset];
        
        NSArray* tmpAry =[asset tracksWithMediaType:AVMediaTypeVideo];
        if (tmpAry.count>0) {
            AVAssetTrack *assetTrack = [tmpAry objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];
            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
        }
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSArray*dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:([dataSourceArray count]>0)?[dataSourceArray objectAtIndex:0]:nil
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0+preLayerHWRate*(preLayerHeight-preLayerWidth)/2));
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    NSString *path = [self getVideoMergeFilePathString];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:path];
    
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW*preLayerHWRate);
    
    //设置视频压缩比 AVAssetExportPresetMediumQuality
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //完成录制操作
            [self dismissViewController:mergeFileURL];
        });
    }];
}

//最后合成为 mp4
- (NSString *)getVideoMergeFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"Merge.mp4"];
    
    return fileName;
}

//完成视频选择或者录制过程
- (void)dismissViewController:(NSURL *)urlVideo
{
    [self closeViewController];
    
    //post notification
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CompletedVideoCaptureAction" object:urlVideo];
}

- (void)closeViewController
{
    if(captureSession)
    {
        [captureSession stopRunning];
    }
    
    if (captureMovieFileOutput)
    {
        [captureMovieFileOutput stopRecording];
    }
    
    [self stopTimer];
    
    viewVideoPreview.layer.transform = CATransform3DMakeRotation(0,1,0,0);
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        viewVideoPreview.layer.transform = CATransform3DMakeRotation(M_PI/2,1,0,0);
    } completion:^(BOOL finished) {
        [NSThread sleepForTimeInterval:0.3];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - button gesture action
- (void)topButtonAction:(UIButton*)sender
{
    if (sender == btnClose)
    {
        if(aryVideoProgress.count>0)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"确定放弃这段视频" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        else
        {
            [self closeViewController];
        }
    }
    else if(sender == btnOverTurn)
    {
        //切换前后置摄像头（翻转动画）
        viewVideoPreview.layer.transform = CATransform3DMakeRotation(0,0,1,0);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewVideoPreview.layer.transform = CATransform3DMakeRotation(M_PI/2,0,1,0);
        } completion:^(BOOL finished) {
            
            AVCaptureDevice *currentDevice=[captureDeviceInput device];
            AVCaptureDevicePosition currentPosition=[currentDevice position];
            AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
            if (currentPosition==AVCaptureDevicePositionUnspecified || currentPosition==AVCaptureDevicePositionFront)
            {
                toChangePosition=AVCaptureDevicePositionBack;
                
            }
            
            AVCaptureDevice *toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
            //获得要调整的设备输入对象
            AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
            
            //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
            [captureSession beginConfiguration];
            //移除原有输入对象
            [captureSession removeInput:captureDeviceInput];
            //添加新的输入对象
            if ([captureSession canAddInput:toChangeDeviceInput])
            {
                [captureSession addInput:toChangeDeviceInput];
                captureDeviceInput=toChangeDeviceInput;
            }
            //提交会话配置
            [captureSession commitConfiguration];
            
            //前置摄像头需要关闭闪光灯
            if (toChangePosition == AVCaptureDevicePositionBack)
            {
                //重置闪光灯
                btnFlashLight.enabled = YES;
                [self setTorchMode:m_torchMode];
            }
            else
            {
                btnFlashLight.enabled = NO;
                //关闭闪光灯
                [self setTorchMode:AVCaptureTorchModeOff];
            }
            
            viewVideoPreview.layer.transform = CATransform3DMakeRotation(M_PI*3/2,0,1,0);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                viewVideoPreview.layer.transform = CATransform3DMakeRotation(M_PI*2,0,1,0);
            } completion:^(BOOL finished) {
                viewVideoPreview.layer.transform = CATransform3DMakeRotation(0,0,1,0);
            }];
        }];
    }
    else if(sender == btnFlashLight)
    {
        //闪光灯设置
        if (m_torchMode == AVCaptureTorchModeAuto)
        {
            //关闭闪光灯操作
            m_torchMode = AVCaptureTorchModeOff;
            [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight_open"] forState:UIControlStateNormal];
            [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight_open_disable"] forState:UIControlStateDisabled];
        }
        else if (m_torchMode == AVCaptureTorchModeOff)
        {
            //开启闪光灯操作
            m_torchMode = AVCaptureTorchModeOn;
            [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight_auto"] forState:UIControlStateNormal];
            [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight_auto_disable"] forState:UIControlStateDisabled];
        }
        else if (m_torchMode == AVCaptureTorchModeOn)
        {
            //闪光灯自动操作
            m_torchMode = AVCaptureTorchModeAuto;
            [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight"] forState:UIControlStateNormal];
            [btnFlashLight setImage:[UIImage imageNamed:@"camera_flashlight_disable"] forState:UIControlStateDisabled];
        }
        [self setTorchMode:m_torchMode];
    }
}

- (void)bottomButtonAction:(UIButton*)sender
{
    if (sender == btnNext)
    {
        if (aryVideoProgress.count == 0)
        {
            //跳转到选择视频界面
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.assetsFilter = [ALAssetsFilter allVideos];
            picker.delegate = self;
            picker.selectedAssets = [NSMutableArray arrayWithArray:aryAssets];//共用一个数组引用，需要重新初始化一个
            [self presentViewController:picker animated:YES completion:nil];
        }
        else if (currentTime < VIDEO_MIN_TIME)
        {
            //至少拍摄3秒
            [self.view bringSubviewToFront:imgViewMinTimeTip];
            imgViewMinTimeTip.alpha = 0;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                imgViewMinTimeTip.alpha = 1.0;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.4 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    imgViewMinTimeTip.alpha = 0;
                } completion:nil];
            }];
        }
        else
        {
            [self mergeAndExportVideosAtFileURLs];
        }
    }
    else if (sender == btnDelete)
    {
        //删除视频操作
        if(nDeleteState == 0)
        {
            //准备删除单个
            [btnDelete setImage:[UIImage imageNamed:@"video_delete_dustbin"] forState:UIControlStateNormal];
            
            VideoProgressVo *progressVo = [aryVideoProgress lastObject];
            progressVo.imgViewSegment.image = [[UIImage imageNamed:@"progress_del_img"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
            
            nDeleteState = 1;
        }
        else if (nDeleteState == 1)
        {
            //直接删除最后一个视频片段
            [btnDelete setImage:[UIImage imageNamed:@"video_delete_button"] forState:UIControlStateNormal];
            VideoProgressVo *progressVo = [aryVideoProgress lastObject];
            
            //a:删除视频文件
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:progressVo.urlVideoFile error:nil];
            
            //b:移除视图
            [progressVo.imgViewSegment removeFromSuperview];
            
            //c:恢复小方块的位置
            imgViewSquare.frame = CGRectMake(progressVo.imgViewSegment.left, 0, 5, 5);
            
            //d:设置视频时间
            currentTime -= progressVo.fDuration;
            
            //e:从数组中删除progressView
            [aryVideoProgress removeLastObject];
            
            
            nDeleteState = 0;
        }
        else if (nDeleteState == 2)
        {
            //删除所有视频片段
            [btnDelete setImage:[UIImage imageNamed:@"video_delete_button"] forState:UIControlStateNormal];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (VideoProgressVo *progressVo in aryVideoProgress)
            {
                //a:删除视频文件
                [fileManager removeItemAtURL:progressVo.urlVideoFile error:nil];
                
                //b:移除视图
                [progressVo.imgViewSegment removeFromSuperview];
            }
            
            //c:从数组中删除所有progressView
            [aryVideoProgress removeAllObjects];
            
            //d:恢复小方块的位置
            imgViewSquare.frame = CGRectMake(0, 0, 5, 5);
            
            //e:设置视频时间
            currentTime = 0;
            
            nDeleteState = 0;
        }
        
        if (aryVideoProgress.count == 0)
        {
            btnDelete.hidden = YES;
            
            //更新Next button
            btnNext.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
            [btnNext setImage:imgPoster forState:UIControlStateNormal];
            [btnNext setImage:nil forState:UIControlStateHighlighted];
            
        }
    }
}

//长按录制视频
- (void)longPressCapture:(UILongPressGestureRecognizer *)longRecognizer
{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (longRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //去掉删除视频片段的状态
        [self tapScrollView];
        
        //判断隐私中相机是否启用
        AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (videoStatus != AVAuthorizationStatusAuthorized && videoStatus != AVAuthorizationStatusNotDetermined)
        {
            [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",APP_NAME]];
            return;
        }
        
        AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (audioStatus != AVAuthorizationStatusAuthorized && audioStatus != AVAuthorizationStatusNotDetermined)
        {
            [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-麦克风”选项中，允许%@访问你的手机麦克风。",APP_NAME]];
            return;
        }
        
        //开始录制
        [UIView animateWithDuration:0.2 animations:^{
            imgViewCapture.frame = CGRectMake((kScreenWidth-86)/2, (184-86)/2, 86, 86);
            imgViewCapture.image = [UIImage imageNamed:@"camera_video_background_highlighted"];
        } completion:^(BOOL finished) {
            
        }];
        
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[captureVideoPreviewLayer connection].videoOrientation;
        [captureMovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getVideoSaveFilePathString]] recordingDelegate:self];
    }
    else if (longRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //停止录制
        [UIView animateWithDuration:0.2 animations:^{
            imgViewCapture.frame = CGRectMake((kScreenWidth-66)/2, (184-66)/2, 66, 66);
            imgViewCapture.image = [UIImage imageNamed:@"camera_video_background"];
        } completion:^(BOOL finished) {
            
        }];
        
        [self stopTimer];
        [captureMovieFileOutput stopRecording];//停止录制
    }
}

//长按删除视频片段
- (void)longPressDeleteVideo:(UILongPressGestureRecognizer *)longRecognizer
{
    if (longRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [btnDelete setImage:[UIImage imageNamed:@"video_delete_dustbin"] forState:UIControlStateNormal];
        nDeleteState = 2;
        
        //更新所有视频片段背景图片为红色
        for (VideoProgressVo *progressVo in aryVideoProgress)
        {
            progressVo.imgViewSegment.image = [[UIImage imageNamed:@"progress_del_img"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
        }
    }
}

//显示对焦的icon
-(void)tapVideoPreview:(UITapGestureRecognizer *)tapGesture
{
    //去掉删除视频片段的状态
    [self tapScrollView];
    
    static BOOL bIsFocusing = NO;
    if (!bIsFocusing)
    {
        bIsFocusing = YES;
        [imgViewFocus.layer removeAllAnimations];
        
        CGPoint point= [tapGesture locationInView:viewVideoPreview];
        imgViewFocus.center=point;
        imgViewFocus.transform=CGAffineTransformMakeScale(1.3, 1.3);
        imgViewFocus.alpha=1.0;
        [UIView animateWithDuration:0.35 animations:^{
            imgViewFocus.transform=CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            imgViewFocus.alpha=0;
            
            //设置持续自动对焦
            CGPoint cameraPoint= [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];//将UI坐标转化为摄像头坐标
            [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
            
            bIsFocusing = NO;
        }];
    }
}

//去掉删除视频片段的状态
- (void)tapScrollView
{
    if (nDeleteState == 1)
    {
        VideoProgressVo *progressVo = [aryVideoProgress lastObject];
        progressVo.imgViewSegment.image = [[UIImage imageNamed:@"progress_img"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    }
    else if (nDeleteState == 2)
    {
        for (VideoProgressVo *progressVo in aryVideoProgress)
        {
            progressVo.imgViewSegment.image = [[UIImage imageNamed:@"progress_img"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
        }
    }
    
    [btnDelete setImage:[UIImage imageNamed:@"video_delete_button"] forState:UIControlStateNormal];
    nDeleteState = 0;
}

//获取前置或后置摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras)
    {
        if ([camera position]==position)
        {
            return camera;
        }
    }
    return nil;
}

//设置对焦的图片
-(void)setFocusCursorWithPoint:(CGPoint)point
{
    [imgViewFocus.layer removeAllAnimations];
    
    imgViewFocus.center=point;
    imgViewFocus.transform=CGAffineTransformMakeScale(1.25, 1.25);
    imgViewFocus.alpha=1.0;
    [UIView animateWithDuration:0.5 animations:^{
        imgViewFocus.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        imgViewFocus.alpha=0;
    }];
}

//设置手电筒模式
-(void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice){
        if ([captureDevice isTorchModeSupported:torchMode])
        {
            [captureDevice setTorchMode:torchMode];
        }
    }];
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode])
        {
            [captureDevice setFocusMode:focusMode];//AVCaptureFocusModeAutoFocus
        }
        
        if ([captureDevice isFocusPointOfInterestSupported])
        {
            [captureDevice setFocusPointOfInterest:point];
        }
        
        if ([captureDevice isExposureModeSupported:exposureMode])
        {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        if ([captureDevice isExposurePointOfInterestSupported])
        {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange
{
    AVCaptureDevice *captureDevice= [captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error])
    {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }
    else
    {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

///////////////////////////////////////////////////////////////////////////
//初始化VideoProgress
- (void)initVideoProgress
{
    //计算progress位置
    CGFloat fLeftOffset = 0;
    if (aryVideoProgress.count>0)
    {
        VideoProgressVo *progressVoLast = [aryVideoProgress lastObject];
        fLeftOffset = progressVoLast.imgViewSegment.right;
    }
    
    VideoProgressVo *progressVo = [[VideoProgressVo alloc]init];
    progressVo.imgViewSegment = [[UIImageView alloc]initWithFrame:CGRectMake(fLeftOffset, 0, 0, 5)];
    progressVo.imgViewSegment.image = [Common getImageWithColor:COLOR(239, 111, 88, 1.0)];
    [viewProgress addSubview:progressVo.imgViewSegment];
    
    progressVo.fDuration = 0;
    
    [aryVideoProgress addObject:progressVo];
    
    //初始化小方形
    [imgViewSquare.layer removeAllAnimations];
    imgViewSquare.alpha = 1.0;
    
    //显示相关按钮
    btnDelete.hidden = NO;
    btnDelete.enabled = NO;
    btnOverTurn.enabled = NO;
    btnNext.enabled = NO;
    
    //更新Next button
    btnNext.imageEdgeInsets = UIEdgeInsetsZero;
    [btnNext setImage:[UIImage imageNamed:@"video_next_button"] forState:UIControlStateNormal];
    [btnNext setImage:[UIImage imageNamed:@"video_next_button_highlighted"] forState:UIControlStateHighlighted];
}

- (void)updateVideoProgressWithFile:(NSURL*)fileURL
{
    //更新last object
    VideoProgressVo *progressVoLast = [aryVideoProgress lastObject];
    progressVoLast.urlVideoFile = fileURL;
    progressVoLast.imgViewSegment.image = [[UIImage imageNamed:@"progress_img"]stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    
    //开启小方形动画
    imgViewSquare.alpha = 0;
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseInOut animations:^{
        imgViewSquare.alpha = 1.0;
    } completion:nil];
    
    //恢复相关按钮
    btnDelete.enabled = YES;
    btnOverTurn.enabled = YES;
    btnNext.enabled = YES;
    
}

///////////////////////////////////////////////////////////////////////////

//录制保存的时候要保存为 mov
- (NSString *)getVideoSaveFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"Temp.mov"];
    
    return fileName;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
//开始录制
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    [self initVideoProgress];
    [self startTimer];
}

//录制结束
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self updateVideoProgressWithFile:outputFileURL];
    
    //时间到了
    if (currentTime>=VIDEO_MAX_TIME)
    {
        [self mergeAndExportVideosAtFileURLs];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self closeViewController];
    }
}

#pragma mark - Assets Picker Delegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^(void){
        
    }];
    
    aryAssets = [NSMutableArray arrayWithArray:assets];
    
    //生成一个Video URL
    if (aryAssets != nil && aryAssets.count>0)
    {
        ALAsset *asset = aryAssets[0];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        [self dismissViewController:representation.url];
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    NSInteger nMaxUploadNum = 1;
    if (picker.selectedAssets.count >= nMaxUploadNum)
    {
        [Common bubbleTip:[NSString stringWithFormat:@"最多选择%li个视频",(long)nMaxUploadNum] andView:picker.view];
    }
    
    //限制视频的大小
    double fDuration = 0;
    id duration = [asset valueForProperty:ALAssetPropertyDuration];
    if (duration)
    {
        fDuration = [duration doubleValue];
        if (fDuration > VIDEO_CHOOSE_MAX)
        {
            [Common bubbleTip:@"视频过大，暂不支持" andView:picker.view];
        }
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < nMaxUploadNum && fDuration <= VIDEO_CHOOSE_MAX && asset.defaultRepresentation != nil);
}

//默认进入相机胶卷相册
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

@end
