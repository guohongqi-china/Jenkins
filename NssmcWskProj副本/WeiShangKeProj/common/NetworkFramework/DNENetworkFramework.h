//
//  DNENetworkFramework.h
//  DNENetworkFramework
//
//  Created by User on 12-5-16.
//  Copyright (c) 2012年 DNE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "MD5.h"
#import "NSData+AESEncryption.h"
#import "ServerURL.h"

#define HEAD_SUCCESS            0
#define HEAD_SUGGEST_UPDATE     1
#define HEAD_MUST_UPDATE        2
#define HEAD_SERVICE_OVER       3
#define HEAD_INVALID_APP        4
#define HEAD_BUSY               5
#define HEAD_UNKNOW_ERROR      -1


#define SERVER_CODE_SUCCESS            @"10000"

@interface DNENetworkFramework : NSObject

@property (nonatomic, retain) NSDictionary *fileDownLoadProgress;
@property (nonatomic, retain) NSMutableDictionary *conDictionary;
@property (nonatomic, retain) NSMutableDictionary *headDictionary;
@property (nonatomic, retain) NSString *connectURL;
@property (nonatomic, retain) NSString *dneResponseString;
@property (nonatomic, retain) NSError *dneError;
@property (nonatomic, retain) NSDictionary *responseHeadDic;
@property (nonatomic, retain) id responseDic;

@property (nonatomic, retain) NSString *fileName;

/////////////////////////////////////////////////////////////////
@property (nonatomic, assign) int nResponseStatusCode;
@property (nonatomic, assign) int nRecursiveNum;          //控制递归次数，不超过3次

//开启通信AES加密
+ (void) EnableAESEncryptWithKey:(NSString *)key;

//关闭通信AES加密
+ (void) DisableAESEncrypt;

//设置框架中当前的URL地址，任何接口调用前必须先设置URL地址
- (void) setURL:(NSString *)URL;

+ (id)JSONValueFromString:(NSString *)str;

/////////////////////////////////////////////////////////////////////////////
+ (NSString*)getErrorMsgBy:(id)jsonResult;
+ (NSString*)getErrorCodeBy:(id)jsonResult;

- (id)getResponseDic;
- (int)getResponseStatusCode;

- (void)loginToRestServer:(NSMutableDictionary*)dicContent;
- (void)startRequestToServer:(NSString*)strRequestMethod andParameter:(id)objParameter;
- (void)startRequestToChatServer:(NSString*)strRequestMethod andParameter:(id)objParameter;
- (void)startRequestToServerAndNoSesssion:(NSString*)strRequestMethod andParameter:(id)objParameter;
- (NSDictionary*)uploadFileToServer:(NSString *)filePath;
+ (void)uploadPicWithUrl:(NSString *)url andParams:(id)params andPicData:(NSData *)picdata result:(void (^)(id resultObj))result;
+ (void)sendRequestToServerByStyle:(NSString *)styleString urlString:(NSString *)url parmDic:(id)bodyDic result:(ResultBlock)resultBlock;

@end