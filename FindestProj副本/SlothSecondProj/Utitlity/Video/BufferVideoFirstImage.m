//
//  BufferVideoFirstImage.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/22.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "BufferVideoFirstImage.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation BufferVideoFirstImage

//根据URL获取对应MD5值，作为文件名
+ (NSString *)fileNameForURL:(NSString *)strURL
{
    const char *str = [strURL UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

//获取网络视频第一帧
+(void)getFirstFrameImageFromURL:(NSString*)strURL finished:(void(^)(UIImage *))blockFinished
{
    //判断图片是否缓存了
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *strFileDirectory = [strDocumentPath stringByAppendingPathComponent:IMAGE_BUFFER_DIRECTORY];
        NSString *strFilePath = [strFileDirectory stringByAppendingPathComponent:[BufferVideoFirstImage fileNameForURL:strURL]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:strFilePath])
        {
            //存在缓存文件
            dispatch_async(dispatch_get_main_queue(), ^{
                blockFinished([UIImage imageWithContentsOfFile:strFilePath]);
            });
        }
        else
        {
            NSURL *url = [NSURL URLWithString:strURL];
            AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generator.appliesPreferredTrackTransform=TRUE;
            CMTime thumbTime = CMTimeMakeWithSeconds(0,30);//获取具体位置的图片
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                if (result == AVAssetImageGeneratorSucceeded)
                {
                    __block UIImage *imgTemp = [UIImage imageWithCGImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blockFinished(imgTemp);
                        //保存到缓存目录
                        BOOL isDir = NO;
                        BOOL existed = [fileManager fileExistsAtPath:strFileDirectory isDirectory:&isDir];
                        if (!(isDir == YES && existed == YES))
                        {
                            [fileManager createDirectoryAtPath:strFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        NSData *data = UIImageJPEGRepresentation(imgTemp, 1.0);
                        [data writeToFile:strFilePath atomically:YES];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blockFinished(nil);
                    });
                }
            };
            
            generator.maximumSize = CGSizeMake(400,400);
            [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
        }
    });
}


@end
