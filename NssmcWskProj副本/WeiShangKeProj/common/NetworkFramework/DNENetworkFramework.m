//
//  DNENetworkFramework.m
//  DNENetworkFramework
//
//  Created by User on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DNENetworkFramework.h"
#import "ASIFormDataRequest.h"
#import "UserVo.h"
#import <CoreFoundation/CoreFoundation.h>

static NSString *g_aesKey       = @"";
static BOOL      g_bEnableAES   = FALSE;

@implementation DNENetworkFramework
@synthesize fileDownLoadProgress;
@synthesize conDictionary;
@synthesize headDictionary;
@synthesize connectURL;
@synthesize dneResponseString;
@synthesize dneError;
@synthesize responseHeadDic;
@synthesize responseDic;
@synthesize nResponseStatusCode;

//初始化
-(id)init
{
	if(self = [super init])
	{
		//
        self.nRecursiveNum = 0;
	}
	return self;
}

//发起HTTP的同步请求
//strRequestMethod:POST/GET
//1.1 POST为:JSON格式，GET为查寻参数(Restful风格):url/parameter1/parameter2/...
- (void)startRequestToServer:(NSString*)strRequestMethod andParameter:(id)objParameter
{
    self.nRecursiveNum ++;//控制递归次数(每次请求会初始化为0，当遇到302，最多三次请求机会)
    [self sendPostToServerCommonMethod:strRequestMethod andParameter:objParameter andSessionID:nil];
    
    if (self.nResponseStatusCode == 302 && self.nRecursiveNum<=3)
    {
        ServerReturnInfo *retInfo = [ServerProvider loginToRestServer:[Common getCurrentUserVo].strLoginAccount andPwd:[Common getUserPwd]];
        if (retInfo.bSuccess)
        {
            [self startRequestToServer:strRequestMethod andParameter:objParameter];
        }
    }
}

//1.2 请求聊天服务器数据
- (void)startRequestToChatServer:(NSString*)strRequestMethod andParameter:(id)objParameter
{
    self.nRecursiveNum ++;//控制递归次数
    [self sendPostToServerCommonMethod:strRequestMethod andParameter:objParameter andSessionID:[ServerURL getFormatChatSessionID]];
    
    if (self.nResponseStatusCode == 302 && self.nRecursiveNum<=3)
    {
        ServerReturnInfo *retInfo = [ServerProvider loginToRestServer:[Common getCurrentUserVo].strLoginAccount andPwd:[Common getUserPwd]];
        if (retInfo.bSuccess)
        {
            [self startRequestToChatServer:strRequestMethod andParameter:objParameter];
        }
    }
}

//1.3 请求服务器，不含SessionID
- (void)startRequestToServerAndNoSesssion:(NSString*)strRequestMethod andParameter:(id)objParameter
{
    [self sendPostToServerCommonMethod:strRequestMethod andParameter:objParameter andSessionID:nil];
}

-(void)sendPostToServerCommonMethod:(NSString*)strRequestMethod andParameter:(id)objParameter andSessionID:(NSString*)strSessionID
{
    //1.init data(POST) or url(GET)
    NSData * data = nil;
    NSString *strServerURL = [NSString stringWithFormat:@"%@",self.connectURL];
    if(objParameter != nil)
    {
        if ([strRequestMethod isEqualToString:@"POST"])
        {
            NSError *error;
            data = [NSJSONSerialization dataWithJSONObject:objParameter options:NSJSONWritingPrettyPrinted error:&error];
            if (error != nil)
            {
                DLog(@"-JSONValue failed. Error trace is: %@", error);
                return;
            }
            
            DLog(@"Request Value = %@",objParameter);
            
            //Encrypt and post data
            if (g_bEnableAES)
            {
                data = [data AESEncryptWithKey:g_aesKey];
            }
        }
        else
        {
            //GET (拼接参数)
            strServerURL = [NSString stringWithFormat:@"%@%@",self.connectURL,(NSString*)objParameter];
        }
    }
    
    //2.init ASIHTTPRequest
	NSString *serverURL = [strServerURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (strSessionID != nil)
    {
        //追加SessionID,不对SessionID进行URL编码
        serverURL = [NSString stringWithFormat:@"%@%@",strServerURL,strSessionID];
    }
    DLog(@"Request URL = %@",serverURL);
    
    ASIHTTPRequest *myRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:serverURL]];
    [myRequest setRequestMethod:strRequestMethod];
    myRequest.timeOutSeconds = 60;
    myRequest.shouldRedirect = NO;
	
    //3.http post parameter
    if(objParameter != nil && [strRequestMethod isEqualToString:@"POST"])
    {
        //JSON方式
        [myRequest addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
        [myRequest appendPostData:data];
        
        //在POST情况下禁用持续连接，避免错误：ASIHTTPRequestErrorDomain Code=1  A connection failure occurred kCFErrorDomainCFNetwork  -1005
        myRequest.shouldAttemptPersistentConnection = NO;
    }
    else
    {
        //查寻字符串方式
        [myRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded;"];
    }
	[myRequest startSynchronous];
	
	//4.编码转换 gb2313 to UTF and AES解密
	NSData *responseData = [myRequest responseData];
    if (g_bEnableAES)
    {
        responseData = [responseData AESDecryptWithKey:g_aesKey];
    }
    
    //5.get http result
    if (myRequest.error != nil)
    {
        self.dneError = myRequest.error;
        NSLog(@"Request Error:%@", myRequest.error);
    }
    else
    {
        //http response status code
        self.nResponseStatusCode = [myRequest responseStatusCode];
        
        //http response data
        NSString *strResponseData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        self.dneResponseString = strResponseData;
        id jsonResult = [DNENetworkFramework JSONValueFromString:self.dneResponseString];
        if ([jsonResult isKindOfClass:[NSDictionary class]] || [jsonResult isKindOfClass:[NSArray class]])
        {
            self.responseDic = jsonResult;
        }
        else
        {
            self.responseDic = nil;
        }
        DLog(@"Response Value = %@",self.dneResponseString);
    }
}
+ (void)sendRequestToServerByStyle:(NSString *)styleString urlString:(NSString *)url parmDic:(id)bodyDic result:(ResultBlock)resultBlock{
    dispatch_async(dispatch_get_global_queue(0,0),^{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    if ([styleString isEqualToString:@"POST"]) {
        
        [manager POST:url parameters:bodyDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           
            [DNENetworkFramework setResultInfo:YES result:responseObject result:^(ServerReturnInfo *retInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{

                resultBlock(retInfo);
                });
            }];
            

        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            [DNENetworkFramework setResultInfo:YES result:error result:^(ServerReturnInfo *retInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(retInfo);

                });
            }];

        }];
        
    }else if([styleString isEqualToString:@"GET"]){
        [manager GET:url parameters:bodyDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [DNENetworkFramework setResultInfo:YES result:responseObject result:^(ServerReturnInfo *retInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",responseObject);
                    resultBlock(retInfo);
                }) ;
            }];


        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            [DNENetworkFramework setResultInfo:YES result:error result:^(ServerReturnInfo *retInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(retInfo);

                });
                
            }];



        }];
        
    }
    });
}
+ (void )setResultInfo:(BOOL)isHe result:(id)result result:(ResultBlock)resultBlock{
    ServerReturnInfo *dataInfo = [[ServerReturnInfo alloc]init];
    dataInfo.bSuccess = isHe;
    if ([result isKindOfClass:[NSError class]]) {
        dataInfo.strErrorMsg = result;
    }else{
        dataInfo.data = result;
    }
    resultBlock(dataInfo);
}
//上传图片到服务器
+ (void)uploadPicWithUrl:(NSString *)url andParams:(id)params andPicData:(NSData *)picdata result:(void (^)(id resultObj))result
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSLog(@"图片的参数：%@",params);
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:picdata name:@"imageUrl" fileName:@"123" mimeType:@"image/jpg/png/jpeg"];
        //        [formData appendPartWithFileData:imageData name:parameter fileName:fileName mimeType:@"image/jpg/png/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"%@",responseObject);
        result(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSLog(@"%@",error);
        result(error);
    }];
}
//上传文件到服务器
- (NSDictionary*)uploadFileToServer:(NSString *)filePath
{
    //0.清除过期持久连接方法为
    NSDictionary *dicResult = nil;
    [ASIHTTPRequest clearPersistentConnections];
    
    //1.配置URL
    NSString *strFileUploadURL = [ServerURL getUploadFileURL];
    strFileUploadURL = [strFileUploadURL stringByAppendingFormat:@"?fn=%@",[Common getFileNameFromPath:filePath]];
	strFileUploadURL = [strFileUploadURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	DLog(@"Request URL = %@",strFileUploadURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strFileUploadURL]];
	[request setRequestMethod:@"POST"];
	[request setPostBodyFilePath:filePath];
	[request setShouldStreamPostDataFromDisk:YES];
    request.numberOfTimesToRetryOnTimeout = 3;
    //在POST情况下禁用持续连接，避免错误：ASIHTTPRequestErrorDomain Code=1  A connection failure occurred kCFErrorDomainCFNetwork  -1005
    request.shouldAttemptPersistentConnection = NO;
	[request startSynchronous];
    
    //2.获取数据
	NSData *responseData = [request responseData];
    
    //3.get http result
    if (request.error != nil)
    {
        NSLog(@"Request Error:%@", request.error);
    }
    else
    {
        //http response data
        NSString *strResponseData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        id jsonResult = [DNENetworkFramework JSONValueFromString:strResponseData];
        if ([jsonResult isKindOfClass:[NSDictionary class]])
        {
            dicResult = jsonResult;
            NSString *strCode = [dicResult objectForKey:@"code"];
            if ([strCode isEqualToString:@"10000"])
            {
                //上传成功
            }
            else
            {
                //上传失败
                dicResult = nil;
            }
        }
        DLog(@"Response Value = %@",strResponseData);
    }
    return dicResult;
}

//登录到 REST 服务器，获取 SessionID
- (void)loginToRestServer:(NSMutableDictionary*)dicContent
{
    //1.init http request
    [ASIHTTPRequest setSessionCookies:nil];
    NSString *strRestLoginURL = [ServerURL getLoginToRESTServerURL];
	DLog(@"Request URL = %@",strRestLoginURL);
	NSString *serverURL = [strRestLoginURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *myRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:serverURL]];
    NSMutableDictionary *dicRequestHeaders = [NSMutableDictionary dictionary];
    [dicRequestHeaders setObject:@"application/json;charset=utf-8" forKey:@"Content-Type"];
     myRequest.timeOutSeconds = 60;
    [myRequest setRequestHeaders:dicRequestHeaders];
    [myRequest setRequestMethod:@"POST"];
	
    //2.form commit data
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicContent options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil)
    {
        DLog(@"-JSONValue failed. Error trace is: %@", error);
        return;
    }
    
    DLog(@"Request Value = %@",dicContent);
	[myRequest appendPostData:data];
	[myRequest startSynchronous];
    
    //编码转换 gb2313 to UTF and AES解密
	NSData *responseData = [myRequest responseData];
    if (g_bEnableAES)
    {
        responseData = [responseData AESDecryptWithKey:g_aesKey];
    }
	
    //get response headers
    if (myRequest.error != nil)
    {
        self.dneError = myRequest.error;
        NSLog(@"request error:%@", myRequest.error);
    }
    else
    {
        //http response status code
        self.nResponseStatusCode = [myRequest responseStatusCode];
        
        //http response data
        NSString *strResponseData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        self.dneResponseString = strResponseData;
        self.responseDic= [DNENetworkFramework JSONValueFromString:self.dneResponseString];
        if (![responseDic isKindOfClass:[NSDictionary class]])
        {
            self.responseDic = nil;
        }
        DLog(@"Response Value = %@",self.dneResponseString);
        
        //save session ID(获取全局Cookie)
        NSArray *aryCookie = [ASIHTTPRequest sessionCookies];
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
}

+ (NSString*)getErrorMsgBy:(id)jsonResult
{
    NSString *strErrorMsg = ERROR_TO_SERVER;
    if ([jsonResult isKindOfClass:[NSDictionary class]]) 
    {
        strErrorMsg = [jsonResult objectForKey:@"msg"];
        if (strErrorMsg == nil)
        {
            strErrorMsg = ERROR_TO_SERVER;
        }
    }
	return strErrorMsg;
}

+ (NSString*)getErrorCodeBy:(id)jsonResult
{
    NSString *strErrorCode = @"";
    if ([jsonResult isKindOfClass:[NSDictionary class]])
    {
        strErrorCode = [jsonResult objectForKey:@"code"];
        if (strErrorCode == nil)
        {
            strErrorCode = @"";
        }
    }
    return strErrorCode;
}

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    
    return [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

////////////////////////////////////////////////////////////////////////////////

+ (id)JSONValueFromString:(NSString *)str
{
    NSData *data= [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (!jsonObject)
    {
        NSLog(@"-JSONValue failed. Error trace is: %@", error);
    }
    return jsonObject;
}

+ (void)EnableAESEncryptWithKey:(NSString *)key
{
    g_aesKey = [key copy];
    g_bEnableAES = TRUE;
}

+ (void)DisableAESEncrypt
{
    g_aesKey     = @"";
    g_bEnableAES = FALSE;
}

// download progress
- (void)setDownLoadProgress:(NSMutableDictionary *)dictionary
{
	fileDownLoadProgress = dictionary;
}

#pragma mark framework_basic
- (void)setURL:(NSString *)URL
{
	self.connectURL = URL;//[URL copy];
}

////////////////////////////////////////////////////////////////
- (id)getResponseDic
{
    return self.responseDic;
}

- (int)getResponseStatusCode
{
    return self.nResponseStatusCode;
}

@end
