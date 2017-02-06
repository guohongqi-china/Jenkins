//
//  VNetworkFramework.m
//  AFNetworkingProj
//
//  Created by 焱 孙 on 15/7/22.
//  Copyright (c) 2015年 焱 孙. All rights reserved.
//

#import "VNetworkFramework.h"
#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "Common.h"
#import "ServerURL.h"
#import "ServerReturnInfo.h"
#import "UserVo.h"

@interface VNetworkFramework ()
{
    NSString *strConnectionURL;         //服务器地址
    NSInteger nRecursiveNum;            //控制递归次数，不超过3次
    NSInteger nResponseStatusCode;      //响应状态
}

@end

@implementation VNetworkFramework

- (instancetype)initWithURLString:(NSString*)strURL
{
    self = [super init];
    if (self != nil)
    {
        nRecursiveNum = 0;
        strConnectionURL = strURL;
    }
    
    return self;
}

//发起HTTP的异步请求
//strRequestMethod:POST/GET
//1.1 POST为:JSON格式，GET为查寻参数(Restful风格):url/parameter1/parameter2/...
- (void)startRequestToServer:(NSString*)strRequestMethod parameter:(id)objParameter result:(NetworkResult)networkResult
{
    nRecursiveNum ++;//控制递归次数(每次请求会初始化为0，当遇到302【Session 超时】，最多三次请求机会)
    [self sendPostToServerCommonMethod:strRequestMethod parameter:objParameter sessionId:nil result:^(id responseObject,NSError *error){
        if (nResponseStatusCode == 302 && nRecursiveNum<=3)
        {
            //遇到302，重新请求
//            [ServerProvider loginToRestServer:[Common getCurrentUserVo].strLoginAccount andPwd:[Common getUserPwd] result:^(ServerReturnInfo *retInfo) {
//                if (retInfo.bSuccess)
//                {
//                    [self startRequestToServer:strRequestMethod parameter:objParameter result:networkResult];
//                }
//            }];
            
            //为了兼容ASIHttp
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ServerReturnInfo *retInfo = [ServerProvider loginToRestServer:[Common getCurrentUserVo].strLoginAccount andPwd:[Common getUserPwd]];
                if (retInfo.bSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startRequestToServer:strRequestMethod parameter:objParameter result:networkResult];
                    });
                }
            });
            
        }
        else
        {
            if(networkResult != nil)
            {
                networkResult(responseObject,error);
            }
        }
    }];
}

//1.2 请求聊天服务器数据
- (void)startRequestToChatServer:(NSString*)strRequestMethod parameter:(id)objParameter result:(NetworkResult)networkResult
{
    nRecursiveNum ++;//控制递归次数
    [self sendPostToServerCommonMethod:strRequestMethod parameter:objParameter sessionId:[ServerURL getFormatChatSessionID] result:^(id responseObject,NSError *error){
        if (nResponseStatusCode == 302 && nRecursiveNum<=3)
        {
            //遇到302，重新请求
//            [ServerProvider loginToRestServer:[Common getCurrentUserVo].strLoginAccount andPwd:[Common getUserPwd] result:^(ServerReturnInfo *retInfo) {
//                if (retInfo.bSuccess)
//                {
//                    [self startRequestToChatServer:strRequestMethod andParameter:objParameter result:networkResult];
//                }
//            }];
            
            //为了兼容ASIHttp
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ServerReturnInfo *retInfo = [ServerProvider loginToRestServer:[Common getCurrentUserVo].strLoginAccount andPwd:[Common getUserPwd]];
                if (retInfo.bSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startRequestToServer:strRequestMethod parameter:objParameter result:networkResult];
                    });
                }
            });
        }
        else
        {
            if(networkResult != nil)
            {
                networkResult(responseObject,error);
            }
        }
    }];
}

-(void)sendPostToServerCommonMethod:(NSString*)strRequestMethod parameter:(id)objParameter sessionId:(NSString*)strSessionID result:(NetworkResult)networkResult
{
    //1.init server url
    NSString *serverURL = [strConnectionURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (strSessionID != nil)
    {
        //追加SessionID,不对SessionID进行URL编码
        serverURL = [NSString stringWithFormat:@"%@%@",strConnectionURL,strSessionID];
    }
    DLog(@"Request URL = %@",serverURL);
    
    //2.define block
    void (^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
        //2.1 success request
        nResponseStatusCode = operation.response.statusCode;
        id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
#ifdef DEBUG
        //打印响应日志（含中文）
        NSString *strResponse = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"Response Value = %@",strResponse);
#endif
        
        if(responseData == nil)
        {
            NSError *errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkResponseNilError userInfo:@{NSLocalizedDescriptionKey:ERROR_TO_SERVER_AF}];
            networkResult(nil,errorNetwork);
        }
        else
        {
            if (operation.response.statusCode != HTTP_STATUS_OK)
            {
                NSString *strErrorMsg = ERROR_TO_SERVER_AF;
                if ([responseData isKindOfClass:[NSDictionary class]])
                {
                    strErrorMsg = [responseData objectForKey:@"msg"];
                    if (strErrorMsg == nil)
                    {
                        strErrorMsg = ERROR_TO_SERVER_AF;
                    }
                }
                
                NSError *errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkHttpStatusError userInfo:@{NSLocalizedDescriptionKey:strErrorMsg}];
                networkResult(responseData,errorNetwork);
            }
            else
            {
                networkResult(responseData,nil); //success request
            }
        }
    };
    
    void (^failureBlock)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error){
        //2.2 failure request
        DLog(@"Request ERROR = %@",error);
        nResponseStatusCode = operation.response.statusCode;
        NSError *errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkRequestError userInfo:@{NSLocalizedDescriptionKey:ERROR_TO_NETWORK_AF}];
        networkResult(nil,errorNetwork);
    };
    
    //3.start request
#ifdef DEBUG
    //打印请求JSON日志
    NSString *strRequest = nil;
    if (objParameter != nil)
    {
        NSData *dataLogRequest = [NSJSONSerialization dataWithJSONObject:objParameter options:NSJSONWritingPrettyPrinted error:nil];
        strRequest = [[NSString alloc]initWithData:dataLogRequest encoding:NSUTF8StringEncoding];
    }
    DLog(@"Request Value = %@",strRequest);
#endif
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = nil;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置响应数据为NSData类型，自己解析为NSDictionary/NSArray
    if ([strRequestMethod isEqualToString:@"GET"])
    {
        operation = [manager GET:serverURL parameters:nil success:successBlock failure:failureBlock];
    }
    else
    {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        operation = [manager POST:serverURL parameters:objParameter success:successBlock failure:failureBlock];
    }
    
    //处理发生Session过期，重定向操作
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)redirectResponse;
        if (httpResponse.statusCode == 302)
        {
            //发生Session过期，禁用重定向操作
            return nil;
        }
        else
        {
            return request;
        }
    }];
}

//登录主业务后台服务器
- (void)loginToRestServer:(id)objParameter result:(NetworkResult)networkResult
{
    //清理Cookie，防止抽奖webView的session同步（切换服务器地址）
    [self deleteCookies];
    
    [self sendPostToServerCommonMethod:@"POST" parameter:objParameter sessionId:nil result:^(id responseObject,NSError *error){
        if (error == nil)
        {
            //save 聊天node session ID(获取全局Cookie)
            NSArray *aryCookie = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
            for (int i=0; i<aryCookie.count; i++)
            {
                NSHTTPCookie *httpCookie = [aryCookie objectAtIndex:i];
                if ([httpCookie.name isEqualToString:@"nsid"])
                {
                    //nsid 要进行URL解码(解析%前缀的字符)
                    [Common setChatSessionID:[httpCookie.value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    break;
                }
            }
        }
        
        networkResult(responseObject,error);
    }];
}

//文件批量上传(multipart/form-data方案，缺点是单线程执行完所有文件上传操作)
- (void)uploadBatchFileToServer:(NSArray*)aryFilePath parameter:(id)objParameter result:(FileUploadResult)fileUploadResult
{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *strFileUploadURL = [strConnectionURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"Upload URL = %@",strFileUploadURL);
    
    
        
    [manager POST:strFileUploadURL parameters:objParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //采用MultipartFormData表单方式，name对应form表单里面的name，可以自定义
        for (NSInteger i=0 ; i<aryFilePath.count ; i++)        
        {
            NSString *strFilePath = aryFilePath[i];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:strFilePath] name:[NSString stringWithFormat:@"file%li",(long)i] error:nil];
            DLog(@"Upload File Path%li = %@",(long)i,strFilePath);
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#ifdef DEBUG
        //打印响应日志（含中文）
        NSString *strResponse = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"Response Value = %@",strResponse);
#endif
        
        NSError *errorNetwork = nil;
        NSMutableArray *aryResult = nil;
        
        id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if(responseData == nil)
        {
            errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkResponseNilError userInfo:@{NSLocalizedDescriptionKey:ERROR_TO_SERVER_AF}];
        }
        else
        {
            if (operation.response.statusCode != HTTP_STATUS_OK)
            {
                NSString *strErrorMsg = ERROR_TO_SERVER_AF;
                if ([responseData isKindOfClass:[NSDictionary class]])
                {
                    strErrorMsg = [responseData objectForKey:@"msg"];
                    if (strErrorMsg == nil)
                    {
                        strErrorMsg = ERROR_TO_SERVER_AF;
                    }
                }
                
                errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkHttpStatusError userInfo:@{NSLocalizedDescriptionKey:strErrorMsg}];
            }
            else
            {
                if([responseData isKindOfClass:[NSArray class]])
                {
                    aryResult = [NSMutableArray array];
                    for (NSDictionary *dicData in responseData)
                    {
                        //成功返回数据
                        UploadFileVo *uplaodFileVo = [[UploadFileVo alloc]init];
                        uplaodFileVo.strID = [Common checkStrValue:[dicData objectForKey:@"msg"]];
                        uplaodFileVo.strPrefix = [Common checkStrValue:[dicData objectForKey:@"prefix"]]; //??????
                        uplaodFileVo.strFileType = [Common checkStrValue:[dicData objectForKey:@"sign"]];
                        if ([uplaodFileVo.strFileType isEqualToString:@"image"])
                        {
                            //上传图片
                            //a:原图
                            uplaodFileVo.strURL = [Common checkStrValue:[dicData objectForKey:@"img"]];//包含downloadFile，img-mid、img-min不包含
                            
                            //b:中图
                            uplaodFileVo.strMidURL = [Common checkStrValue:[dicData objectForKey:@"img-mid"]];
                            
                            //c:小图
                            uplaodFileVo.strMinURL = [Common checkStrValue:[dicData objectForKey:@"img-min"]];
                        }
                        else if ([uplaodFileVo.strFileType isEqualToString:@"document"])
                        {
                            uplaodFileVo.strURL = [Common checkStrValue:[dicData objectForKey:@"filePath"]];
                        }
                        else
                        {
                            uplaodFileVo.strURL = [Common checkStrValue:[dicData objectForKey:@"img"]];
                        }
                        [aryResult addObject:uplaodFileVo];
                    }
                }else if([responseData isKindOfClass:[NSDictionary class]]){
                    
                }
                else
                {
                    errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkHttpStatusError userInfo:@{NSLocalizedDescriptionKey:ERROR_TO_DATA}];
                }
            }
        }
        fileUploadResult(aryResult,errorNetwork);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Upload Error:%@",error);
        fileUploadResult(nil,error);
    }];
}

//上传单个文件
- (void)uploadSingleFileToServer:(NSString*)strFilePath result:(SingleFileUploadResult)fileUploadResult
{
    //1.表单方式上传文件(Multipart/form-data)  OK
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *strFileUploadURL = [strConnectionURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"Upload URL = %@",strFileUploadURL);
    
    [manager POST:strFileUploadURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:strFilePath] name:@"HttpServletRequest" error:nil];//HttpServletRequest 可以随便其他名称
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
#ifdef DEBUG
        //打印响应日志（含中文）
        NSString *strResponseData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"Response Value = %@",strResponseData);
#endif
        
        //成功返回数据
        UploadFileVo *uplaodFileVo = nil;
        NSError *errorNetwork = nil;
        NSArray *aryResponseData = responseData;
        if ([aryResponseData isKindOfClass:[NSArray class]] && aryResponseData.count>0)
        {
            NSDictionary *dicData = aryResponseData[0];
            
            uplaodFileVo = [[UploadFileVo alloc]init];
            id msg = [dicData objectForKey:@"msg"];     //整形
            if (msg != [NSNull null] && msg != nil)
            {
                uplaodFileVo.strID = [msg stringValue];
            }
            else
            {
                uplaodFileVo.strID = @"";
            }
            
            uplaodFileVo.strPrefix = [Common checkStrValue:[dicData objectForKey:@"prefix"]]; //??????
            uplaodFileVo.strFileType = [Common checkStrValue:[dicData objectForKey:@"sign"]];
            if ([uplaodFileVo.strFileType isEqualToString:@"image"])
            {
                //上传图片
                //a:原图
                uplaodFileVo.strURL = [Common checkStrValue:[dicData objectForKey:@"img"]];//包含downloadFile，img-mid、img-min不包含
                
                //b:中图
                uplaodFileVo.strMidURL = [Common checkStrValue:[dicData objectForKey:@"img-mid"]];
                
                //c:小图
                uplaodFileVo.strMinURL = [Common checkStrValue:[dicData objectForKey:@"img-min"]];
            }
            else if ([uplaodFileVo.strFileType isEqualToString:@"document"])
            {
                uplaodFileVo.strURL = [Common checkStrValue:[dicData objectForKey:@"filePath"]];
            }
            else
            {
                uplaodFileVo.strURL = [Common checkStrValue:[dicData objectForKey:@"img"]];
            }
        }
        else
        {
           errorNetwork = [NSError errorWithDomain:VNetworkErrorDomain code:VNetworkRequestError userInfo:@{NSLocalizedDescriptionKey:ERROR_TO_UPLOAD_FILE}];
        }
        
        fileUploadResult(uplaodFileVo,errorNetwork);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        id responseData = [NSJSONSerialization JSONObjectWithData:operation.responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"Error: %@,response:%@", error,responseData);
        
        fileUploadResult(nil,error);
    }];
}

//清理Cookie
- (void)deleteCookies
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end
