//
//  SYDownloadManager.h
//  AFNetworkingProj
//
//  Created by 焱 孙 on 15/8/7.
//  Copyright (c) 2015年 焱 孙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYHTTPRequestOperation.h"


@protocol DownloadManagerDelegate <NSObject>
-(void)startDownload:(SYHTTPRequestOperation *)request;
-(void)updateDownloadProgress:(SYHTTPRequestOperation *)request bytesOfRead:(unsigned long long)totalBytesRead bytesOfExpected:(unsigned long long)totalBytesExpectedToRead;
-(void)finishedDownload:(SYHTTPRequestOperation *)request error:(NSError *)error;
@end

@interface SYDownloadManager : NSObject

+ (SYDownloadManager *)sharedDownloadManager;
+ (NSString *)fileNameForURL:(NSString *)strURL;
+ (NSString *)getCacheDirectory;
+ (NSString *)getFilePathByURL:(NSString *)strURL;
+ (BOOL)checkFileExist:(NSString *)strURL;
+ (BOOL)checkTempFileExist:(NSString *)strURL;

- (void)downloadFile:(NSString*)strURL delegate:(id<DownloadManagerDelegate>)delegate;
- (void)resumeDownload:(SYHTTPRequestOperation*)operation;
- (void)pauseDownload:(SYHTTPRequestOperation*)operation;
- (void)stopDownload:(SYHTTPRequestOperation*)operation;

@end
