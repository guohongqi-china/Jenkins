//
//  SYHTTPRequest.m
//  AFNetworkingProj
//
//  Created by 焱 孙 on 15/8/7.
//  Copyright (c) 2015年 焱 孙. All rights reserved.
//

#import "SYHTTPRequestOperation.h"
#import "SYDownloadManager.h"

@interface SYHTTPRequestOperation ()
{
    AFHTTPRequestOperation *requestOperation;
}


@end


@implementation SYHTTPRequestOperation

- (instancetype)initWithFileInfo:(NSString *)strFileURL delegate:(id<DownloadManagerDelegate>)delegate
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.strFileURL = strFileURL;
    self.delegate = delegate;
    
    return self;
}

/**
 *  开始下载文件
 *
 *  @param progressBlock 进度回调
 *  @param successBlock  成功回调
 *  @param failureBlock  失败回调
 *
 *  @return 下载任务
 */
- (void)downloadFileWithProgressBlock:(DownloadProgress)progressBlock
                         successBlock:(DownloadSuccess)successBlock
                         failureBlock:(DownloadFailure)failureBlock
{
    __weak typeof(self) weakSelf = self;

    //获取临时文件目录
    NSString *strFileName = [SYDownloadManager fileNameForURL:self.strFileURL];
    NSString *strFilePath = [[SYDownloadManager getCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_temp",strFileName]];
    NSString *strDestPath = [[SYDownloadManager getCacheDirectory] stringByAppendingPathComponent:strFileName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.strFileURL]];
    
    unsigned long long downloadedBytes = 0;//已经下载大小
    //判断文件是否已经下载一部分，则进行断点下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
    {
        downloadedBytes = [self fileSizeForPath:strFilePath];
        // 检查文件是否已经下载了一部分
        if (downloadedBytes > 0)
        {
            //配置断点下载HTTP Headers
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [request setValue:requestRange forHTTPHeaderField:@"Range"];
        }
    }
    
    // 不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    // 下载请求
    requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    // 下载路径
    requestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:strFilePath append:YES];
    
    // 下载进度回调
    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progressBlock(weakSelf, (totalBytesRead + downloadedBytes), (totalBytesExpectedToRead + downloadedBytes));
    }];

    // 成功和失败回调
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //完成下载，对文件重命名
        [[NSFileManager defaultManager] moveItemAtPath:strFilePath toPath:strDestPath error:nil];
        successBlock(weakSelf, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(weakSelf, error);
    }];

    //开启任务
    [requestOperation start];
}

//暂停下载文件
- (void)pauseDownloadOperation
{
    [requestOperation pause];
}

//恢复下载任务
- (void)resumeDownloadOperation
{
    [requestOperation resume];
}

//停止下载任务
- (void)stopDownloadOperation
{
    [requestOperation cancel];
}

//是否已暂停
- (BOOL)isPaused
{
    if (requestOperation)
    {
        return requestOperation.isPaused;
    }
    else
    {
        return YES;
    }
}

//获取文件大小
- (long long)fileSizeForPath:(NSString *)path
{
    long long fileSize = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path])
    {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict)
        {
            
            fileSize = [fileDict fileSize];
        }
    }
    
    return fileSize;
}

@end
