//
//  cellView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/31.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "cellView.h"
#import "DrawRound.h"
#import "GHQTimeToCalculate.h"
#import "SDWebImageDataSource.h"
#import <UIImageView+WebCache.h>
#import "ImageViewForPickImage.h"

#import "buttonAndLabel.h"
#import "MBProgressHUD+GHQ.h"
#import "AnimationImage.h"
#import "shareModel.h"
#import "GHQlineView.h"
@interface cellView ()
@property (nonatomic, strong) buttonAndLabel *soundeButton;/** <#注释#> */

@property (nonatomic, strong) UIImageView *holderView;/** <#注释#> */
@property (nonatomic, strong) shareModel *shareM;/** <#注释#> */
@end
@implementation cellView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _shareM  = [shareModel sharedManager];
        
        _drawRound = [[DrawRound alloc]init];
        
        _updateLabel = [[UILabel alloc]init];
        _updateLabel.textColor = [UIColor grayColor];
        _updateLabel.font = [UIFont systemFontOfSize:14];
        _updateLabel.text = @"更新时间:";
        
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor grayColor];
        
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.numberOfLines = 0;
        
        _progressLabel = [[UILabel alloc]init];
        _progressLabel.font = [UIFont systemFontOfSize:14];
        _progressLabel.textColor = [UIColor grayColor];

        
        _ImageButton = [[UIImageView alloc]init];
        _ImageButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_ImageButton addGestureRecognizer:tapGesture];

        
        _senderButton = [[[NSBundle mainBundle]loadNibNamed:@"AnimationImage" owner:nil options:nil] lastObject];
        _senderButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
         NSArray *imageArray = @[[UIImage imageNamed:@"ReceiverVoiceNodePlaying001@2x"],[UIImage imageNamed:@"ReceiverVoiceNodePlaying002@2x"],[UIImage imageNamed:@"ReceiverVoiceNodePlaying003@2x"]];
            _senderButton.soundImage.animationImages = imageArray;
            _senderButton.soundImage.animationDuration = 2;
            _senderButton.soundImage.animationRepeatCount = 0;

        [_senderButton addGestureRecognizer:tap];
//        _senderButton.frame = CGRectMake(10, 10, 100, 30);
       

        _RecordModel = [AVAudioRecorderModel shareInstance];
        _RecordModel.delegate = self;
        [self addSubview:_drawRound];
        [self addSubview:_updateLabel];
        [self addSubview:_timeLabel];
        [self addSubview:_contentLabel];
        [self addSubview:_ImageButton];

        [self addSubview:_progressLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(a) name:@"Sound" object:nil];

    }
    return self;
}
-(GHQlineView *)progressView{
    if (_progressView) {
        _progressView = [[GHQlineView alloc]initWithFrame:CGRectMake(0, 0, _ImageButton.width, _ImageButton.height)];
        _progressView.backgroundColor = [UIColor grayColor];
        _progressView.lineWidth = 3;
    }
    return _progressView;
}
- (void)a{
    [_senderButton.soundImage stopAnimating];

}
- (void)tapAction:(UITapGestureRecognizer *)sender{
    UIImageView *iamgeView = (UIImageView *)sender.view;
    ImageViewForPickImage *imageView = [[ImageViewForPickImage alloc]init];
    imageView.itemsArray = @[iamgeView.image];

}
- (void)setCellModel:(topModel *)cellModel{
    _cellModel = cellModel;
    _drawRound.frame = CGRectMake(10, 0, self.width / 13, 0);
    
    _updateLabel.frame = CGRectMake(CGRectGetMaxX(_drawRound.frame), 5, 0, 20);
    
    [_updateLabel sizeToFit];
    
    _timeLabel.frame = CGRectMake(CGRectGetMaxX(_updateLabel.frame), 5, 0, 20);
    _timeLabel.text = [GHQTimeToCalculate getTimeFromNumberofmilliseconds:[GHQTimeToCalculate checkStrValue:cellModel.updateTime] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [_timeLabel sizeToFit];
    
    
    _progressLabel.frame = CGRectMake(CGRectGetMaxX(_drawRound.frame), CGRectGetMaxY(_updateLabel.frame), self.width - 10, 20);
    _progressLabel.text = [NSString stringWithFormat:@"进度:%@%%",cellModel.percentage];
    
    NSLog(@"%@",cellModel.detailContent);
    NSLog(@"%@",cellModel.path);
    NSLog(@"%@",cellModel.percentage);

        _contentLabel.text = nil;
        _contentLabel.frame = CGRectMake(CGRectGetMaxX(_drawRound.frame), CGRectGetMaxY(_progressLabel.frame), self.width - 10, self.height - CGRectGetMaxY(_drawRound.frame));
        _contentLabel.text = cellModel.detailContent;
        [_contentLabel sizeToFit];

   if (([cellModel.path hasSuffix:@".jpg"] || [cellModel.path hasSuffix:@".png"])) {
        _ImageButton.frame = CGRectMake(CGRectGetMaxX(_drawRound.frame), CGRectGetMaxY(_contentLabel.frame), self.width /3, self.height - CGRectGetMaxY(_contentLabel.frame));

        _ImageButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageAction:)];
        [_ImageButton addGestureRecognizer:tap];
        if (self.delegate && [self.delegate respondsToSelector:@selector(CellViewUrlImage:)]) {
            [self.delegate CellViewUrlImage:cellModel.path];
        }
    
        [_ImageButton  sd_setImageWithURL:[NSURL URLWithString:cellModel.path] placeholderImage:[UIImage imageNamed:@"picf"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            /** 设置图片下载的进度 */
//            CGFloat progress = receivedSize / expectedSize * 1.0;
//            self.progressView.progress = progress;
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _ImageButton.image = image;
            self.progressView.hidden = NO;
        }];

            self.height = CGRectGetMaxY(_ImageButton.frame) + 20;

   }else if ([cellModel.path hasSuffix:@".amr"]){
       
        _senderButton.frame = CGRectMake(CGRectGetMaxX(_drawRound.frame) , CGRectGetMaxY(_contentLabel.frame), 100, 30);
       
              [self addSubview:_senderButton];

                [self RecordFileInfomation];
                self.height = CGRectGetMaxY(_senderButton.frame) + 20;
   }else{
            self.height = CGRectGetMaxY(_contentLabel.frame) + 20;
   }
    
    _drawRound.height = self.height;


    
    
    


}
- (CGFloat )getHeight{
    return self.height;
}
- (void)imageAction:(UITapGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellViewiImage:)]) {
        [self.delegate cellViewiImage:_cellModel.path];
    }
    
}
//获取文件信息并保存
- (void)RecordFileInfomation{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *array = [_cellModel.path componentsSeparatedByString:@"/"]; //从字符A中分隔成2个元素的数组
        
        
        urlStr = [[urlStr stringByAppendingPathComponent:array.lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:urlStr];
        if(!fileExists)
        {
            //文件不存在，则下载
            NSData *dataAudio = [NSData dataWithContentsOfURL:[NSURL URLWithString:_cellModel.path]];
            //写入文件
            if(dataAudio != nil)
            {
                [dataAudio writeToFile:urlStr atomically:YES];
                
                
            }
            
        }
        _pathString = [VoiceConverter amrToWav:urlStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _senderButton.timerLenglabel.text = [NSString stringWithFormat:@"%@''",[self getVoiceFileInfoByPath:_pathString]];
            
        });
        
    });

}
- (void)buttonAction:(UITapGestureRecognizer *)sender{

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
    {
        [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-麦克风”选项中，允许%@访问你的手机麦克风。",@"新日铁"]];
        return;
    }

    
    if (!_pathString) {
        [MBProgressHUD showSuccess:@"amr转wav失败" toView:nil];
        return;
    }
    _RecordModel.isPlaying = NO;
    _RecordModel.pathWAV = _pathString;
    [_RecordModel palyRecordSound];

    if (_RecordModel.vioceButton.soundImage) {
        [_RecordModel.vioceButton.soundImage stopAnimating];
    }
    
    [_senderButton.soundImage startAnimating];
    _RecordModel.vioceButton = _senderButton;

}
- (void)dealloc{
    [_RecordModel.audioPlayer stop];
}

#pragma mark - 获取音频文件信息

- (NSString *)getVoiceFileInfoByPath:(NSString *)aFilePath {
    

    
    NSRange range = [aFilePath rangeOfString:@"wav"];
    if (range.length > 0) {
        AVAudioPlayer *play = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:aFilePath] error:nil];
        NSString *timer = [NSString stringWithFormat:@"%ld",(long)(play.duration + 0.5)];
       return  timer;
    }
    
    
    return @"10";
}
#pragma mark - 获取文件大小
- (NSInteger) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}

- (void)stopToPlaySound{

}
- (void)layoutSubviews{
    [super layoutSubviews];
   
}


@end
