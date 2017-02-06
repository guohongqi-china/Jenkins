//
//  CheXiangService.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/6.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "CheXiangService.h"
#import "NSString+MD5.h"
#import "VNetworkFramework.h"
#import "UploadFileVo.h"

#define CHEXIANG_KEY @"chexiang"

@implementation CheXiangService

+ (void)uploadCertificatePhoto:(NSString *)strPath type:(NSInteger)nType result:(ResultBlock)resultBlock
{
    NSString *strServerURL;
    if(nType == 0)
    {
        strServerURL = [ServerURL getUploadVehicleLicenseURL];
    }
    else if(nType == 1)
    {
        strServerURL = [ServerURL getUploadDriveLicenseURL];
    }
    else if(nType == 2)
    {
        strServerURL = [ServerURL getUploadIDCardURL];
    }
    
    //获取从1970到现在的毫秒数
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *strTimestamp = [NSString stringWithFormat:@"%llu",(unsigned long long)interval*1000];
    NSString *strAccessToken = [[NSString md5HexDigest:[NSString stringWithFormat:@"%@%@",strTimestamp,CHEXIANG_KEY]] lowercaseString];
    
    strServerURL = [NSString stringWithFormat:@"%@?timestamp=%@&accessToken=%@",strServerURL,strTimestamp,strAccessToken];
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:strServerURL];
    [framework uploadSingleFileWithBinary:strPath result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.strErrorMsg = [Common checkStrValue:[responseObject objectForKey:@"message"]];
    
            NSString *strStatus = [Common checkStrValue:[responseObject objectForKey:@"status"]];
            if([strStatus isEqualToString:@"success"])
            {
                retInfo.bSuccess = YES;
            }
            else
            {
                retInfo.bSuccess = NO;
            }
        }
        resultBlock(retInfo);
    }];
}

//车享家登录
+ (void)loginToCheXiangServer:(NSString *)strAccount pwd:(NSString *)strPwd result:(ResultBlock)resultBlock
{
    NSDictionary *dicBody = @{@"userAccount":strAccount,@"userPsw":strPwd};
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getLoginToCheXiangServerURL]];
    [framework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSDictionary *dicResult = responseObject;
            retInfo.data = [Common checkStrValue:dicResult[@"chexiangAccount"]];
            retInfo.data2 = [Common checkStrValue:dicResult[@"repeatUserId"]];
            retInfo.data3 = [Common checkStrValue:dicResult[@"redirectUrl"]];
        }
        resultBlock(retInfo);
    }];
}

//车享家解绑
+ (void)unbindCheXiangAccount:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getUnbindCheXiangAccountURL]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

//微信名片上传头像
+ (void)uploadWeixinCardPhoto:(NSString *)strPath result:(ResultBlock)resultBlock
{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getUploadWeixinCardPhotoURL]];
    [networkFramework uploadBatchFileToServer:@[strPath] result:^(NSArray *aryResult, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            if (aryResult.count>0)
            {
                UploadFileVo *uploadFileVo = aryResult[0];
                NSRange range = [uploadFileVo.strURL rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
                if (range.length==0)
                {
                    //需要追加前缀
                    uploadFileVo.strURL = [ServerURL getWholeURL:uploadFileVo.strURL];
                }
                
                retInfo.data = uploadFileVo.strURL;
                retInfo.bSuccess = YES;
            }
            else
            {
                retInfo.bSuccess = NO;
                retInfo.strErrorMsg = @"图片上传失败，请稍后再试";
            }
        }
        resultBlock(retInfo);
    }];
}

//车享家帐号关联验证
+ (void)verifyCheXiangAccount:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getVerifyCheXiangAccountURL]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            NSDictionary *dicResult = responseObject;
            id result = dicResult[@"result"];
            if (result != [NSNull null])
            {
                retInfo.bSuccess = [result boolValue];
            }
            else
            {
                retInfo.bSuccess = NO;
            }
            
            if (retInfo.bSuccess)
            {
                retInfo.data = [Common checkStrValue:dicResult[@"chexiangAccount"]];
                retInfo.data3 = [Common checkStrValue:dicResult[@"redirectUrl"]];
            }
            else
            {
                retInfo.strErrorMsg = [Common checkStrValue:dicResult[@"msg"]];
            }
            
        }
        resultBlock(retInfo);
    }];
}

//工作模块/////////////////////////////////////////////////////////////////////////
//1.我的工作:1,待添加的工作:2
+ (void)getMyJobListByType:(NSInteger)nType result:(ResultBlock)resultBlock
{
    NSString *strURL;
    if (nType == 1)
    {
        //我的工作
        strURL = [ServerURL getMyJobListURL];
    }
    else
    {
        //待添加的工作
        strURL = [ServerURL getRemainJobListURL];
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:strURL];
    [networkFramework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryJob = [[NSMutableArray alloc]init];
            NSArray *aryJobJSON = responseObject;
            if ([aryJobJSON isKindOfClass:[NSArray class]])
            {
                for (NSDictionary *dicJob in aryJobJSON)
                {
                    JobVo *jobVo = [[JobVo alloc]init];
                    
                    id jobId = [dicJob objectForKey:@"id"];
                    if (jobId == [NSNull null]|| jobId == nil)
                    {
                        jobVo.strID = @"";
                    }
                    else
                    {
                        jobVo.strID = [jobId stringValue];
                    }
                    
                    jobVo.strSysCode = [Common checkStrValue:dicJob[@"sysCode"]];
                    jobVo.strName = [Common checkStrValue:dicJob[@"sysDesc"]];
                    jobVo.strJobURL = [Common checkStrValue:dicJob[@"htmlUrl"]];
                    
                    [aryJob addObject:jobVo];
                }
            }
            
            retInfo.data = aryJob;
        }
        resultBlock(retInfo);
    }];
}

//2.添加工作(type:1)&移除工作(type:2)
+ (void)editChexiangJob:(NSString *)strID type:(NSInteger)nType result:(ResultBlock)resultBlock
{
    NSString *strURL;
    if (nType == 1)
    {
        //添加工作
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getAddJobURL],strID];
    }
    else
    {
        //移除工作
        strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getRemoveJobURL],strID];
    }
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:strURL];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

@end
